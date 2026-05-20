import os
import glob
import sys
import xml.etree.ElementTree as ET
import pandas as pd
from sqlalchemy import create_engine
from pathlib import Path
import math

def strip_namespace(tag):
    if '}' in tag:
        return tag.split('}', 1)[1]
    return tag

def get_xml_data(xml_path):
    tree = ET.parse(xml_path)
    root = tree.getroot()
    
    rows = []
    
    # Find both MDRUDIDIData (from DEVICE_CREATE) and UDIDIData (from UDI_DI_CREATE) elements
    for md_data in root.iter():
        if strip_namespace(md_data.tag) in ('MDRUDIDIData', 'UDIDIData'):
            gtin = None
            basic_udi = None
            dpt_eud = None
            cyl_eud = None
            
            # Search within this MDRUDIDIData block
            for elem in md_data.iter():
                tag = strip_namespace(elem.tag)
                
                if tag == 'identifier':
                    # Looking for commondi:DICode inside identifier
                    for child in elem:
                        if strip_namespace(child.tag) == 'DICode':
                            gtin = child.text
                            
                elif tag == 'basicUDIIdentifier':
                    # Looking for commondi:DICode inside basicUDIIdentifier
                    for child in elem:
                        if strip_namespace(child.tag) == 'DICode':
                            basic_udi = child.text
                            
                elif tag == 'clinicalSize':
                    cst_type = None
                    val = None
                    for child in elem:
                        ctag = strip_namespace(child.tag)
                        if ctag == 'clinicalSizeType':
                            cst_type = child.text
                        elif ctag == 'value':
                            val = child.text
                    
                    if cst_type == 'CST38' and val is not None:
                        dpt_eud = float(val) if val.replace('.','',1).replace('-','',1).isdigit() else val
                    elif cst_type == 'CST39' and val is not None:
                        cyl_eud = float(val) if val.replace('.','',1).replace('-','',1).isdigit() else val

            # Model_EUD: cut off first 6 and last 2 characters from Basic UDI
            model_eud = None
            if basic_udi and len(basic_udi) > 8:
                model_eud = basic_udi[6:-2]
                
            rows.append({
                'GTIN': gtin,
                'BasicUDICode': basic_udi,
                'Model_EUD': model_eud,
                'DPT_EUD': dpt_eud,
                'CYL_EUD': cyl_eud
            })
            
    return rows

def main():
    # 1. Read XML Files
    xml_dir = r"K:\PMO Projects\24_01_E New ERP Introduction\Migration\EUDAMED\EUD Upload\BACKUP\Validation\XML"
    xml_files = glob.glob(os.path.join(xml_dir, "**", "*.xml"), recursive=True)
    
    print(f"Found {len(xml_files)} XML files.")
    
    xml_rows = []
    total_udi_dis = 0
    for idx, f in enumerate(xml_files, 1):
        data = get_xml_data(f)
        valid_data = [d for d in data if d['GTIN']]
        total_udi_dis += len(valid_data)
        xml_rows.extend(valid_data)
        if idx % 50 == 0:
            print(f"Parsed {idx}/{len(xml_files)} files... extracted {total_udi_dis} UDI-DIs so far.")
            
    df = pd.DataFrame(xml_rows)
    
    if df.empty:
        print("No valid GTINs found in XML files.")
        sys.exit(0)
    
    print(f"\nFinished parsing. Extracted a total of {len(df)} UDI-DI(s) from XML files.")
    
    # 2. Database Connection
    db_user = os.getenv("ORAUSER")
    db_password = os.getenv("ORAPW")
    db_alias = "MC9ELES"

    print(f"\nTrying to connect to Oracle database via alias '{db_alias}'.")
    try:
        engine = create_engine(f"oracle+oracledb://{db_user}:{db_password}@{db_alias}")
        with engine.connect() as conn:
            print("Database connection successful.")
    except Exception as e:
        print(f"Failed to connect to DB: {e}")
        sys.exit(1)

    # 3. Query IFS for each GTIN in bulk (Oracle constraint: 1000 items in IN clause)
    unique_gtins = df['GTIN'].dropna().unique()
    total_gtins = len(unique_gtins)
    print(f"\nStarting Oracle DB batch queries for {total_gtins} unique GTIN(s)...")

    # Cut off leading '0' for search keys, but keep a mapping back to the XML GTIN
    search_to_gtin = { (g[1:] if g.startswith('0') else g): g for g in unique_gtins }
    search_keys = list(search_to_gtin.keys())
    
    chunk_size = 999
    chunks = [search_keys[i:i + chunk_size] for i in range(0, len(search_keys), chunk_size)]
    
    ifs_data_all = []
    
    for i, chunk in enumerate(chunks, 1):
        print(f"Executing batch {i}/{len(chunks)} ({len(chunk)} search keys)...")
        in_clause = ",".join(f"'{k}'" for k in chunk)
        
        # We need the GTIN in the result to pivot correctly per technical_spec_no
        query = f"""
            SELECT
                technical_spec_no,
                attribute,
                COALESCE(TO_CHAR(info), TO_CHAR(value_no)) as val
            FROM
                technical_specification_tab
            WHERE
                attribute IN ('ET_GTIN', 'ET_DIOPTRIA', 'ET_CYLINDER', 'ET_TIPUS', 'ET_API')
                AND technical_spec_no IN (
                    SELECT technical_spec_no
                    FROM technical_specification_tab
                    WHERE attribute = 'ET_GTIN' AND info IN ({in_clause})
                )
        """
        
        try:
            res_df = pd.read_sql(query, engine)
            ifs_data_all.append(res_df)
        except Exception as e:
            print(f"Error querying batch {i}: {e}")
            
    if ifs_data_all:
        ifs_df_raw = pd.concat(ifs_data_all, ignore_index=True) if len(ifs_data_all) > 1 else ifs_data_all[0]
        
        # Pivot the data by technical_spec_no
        # Since multiple specs might match one GTIN (or duplicate GTINs), drop duplicates or aggregate
        pivot_df = ifs_df_raw.pivot_table(index='technical_spec_no', columns='attribute', values='val', aggfunc='first').reset_index()
        
        ifs_results = []
        for _, row in pivot_df.iterrows():
            if 'ET_GTIN' not in row or pd.isna(row['ET_GTIN']):
                continue
                
            search_key = str(row['ET_GTIN']).strip()
            xml_gtin = search_to_gtin.get(search_key)
            if not xml_gtin:
                continue
                
            model_ifs = str(row.get('ET_TIPUS', '')).strip() if pd.notnull(row.get('ET_TIPUS')) else None
            
            dpt_val = row.get('ET_DIOPTRIA')
            if pd.notnull(dpt_val):
                try: dpt_ifs = float(str(dpt_val).strip())
                except ValueError: dpt_ifs = str(dpt_val).strip()
            else:
                dpt_ifs = None
                
            cyl_val = row.get('ET_CYLINDER')
            if pd.notnull(cyl_val):
                try: cyl_ifs = float(str(cyl_val).strip())
                except ValueError: cyl_ifs = str(cyl_val).strip()
            else:
                cyl_ifs = 0.0
                
            api_ifs = str(row.get('ET_API', '')).strip() if pd.notnull(row.get('ET_API')) else None
                
            ifs_results.append({
                'GTIN': xml_gtin,
                'Model_IFS': model_ifs,
                'DPT_IFS': dpt_ifs,
                'CYL_IFS': cyl_ifs,
                'API_IFS': api_ifs
            })
            
        ifs_df = pd.DataFrame(ifs_results)
        # In case multiple technical specs hold the same GTIN, keep the first one
        ifs_df = ifs_df.drop_duplicates(subset=['GTIN'])
    else:
        ifs_df = pd.DataFrame()

    if not ifs_df.empty:
        merged_df = pd.merge(df, ifs_df, on='GTIN', how='left')
    else:
        merged_df = df
        merged_df['Model_IFS'] = None
        merged_df['DPT_IFS'] = None
        merged_df['CYL_IFS'] = 0.0
        merged_df['API_IFS'] = None

    # 4. Compare columns
    def compare_vals(val1, val2):
        if pd.isna(val1) and pd.isna(val2):
            return "Yes"
        if pd.isna(val1) or pd.isna(val2):
            return "No"
            
        try:
            return "Yes" if float(val1) == float(val2) else "No"
        except (ValueError, TypeError):
            return "Yes" if str(val1).strip().lower() == str(val2).strip().lower() else "No"

    merged_df['Model_OK'] = merged_df.apply(lambda row: compare_vals(row['Model_EUD'], row['Model_IFS']), axis=1)
    merged_df['DPT_OK'] = merged_df.apply(lambda row: compare_vals(row['DPT_EUD'], row['DPT_IFS']), axis=1)
    merged_df['CYL_OK'] = merged_df.apply(lambda row: compare_vals(row['CYL_EUD'], row['CYL_IFS']), axis=1)

    # Reorder columns
    cols = ['GTIN', 'BasicUDICode', 'Model_EUD', 'Model_IFS', 'Model_OK', 
            'DPT_EUD', 'DPT_IFS', 'DPT_OK', 'CYL_EUD', 'CYL_IFS', 'CYL_OK', 'API_IFS']
    merged_df = merged_df[[c for c in cols if c in merged_df.columns]]

    # 5. Save to User's customized folder
    downloads_path = r"K:\PMO Projects\24_01_E New ERP Introduction\Migration\EUDAMED\EUD Upload\BACKUP\Validation\Validation_EUD_vs_IFS.xlsx"
    
    writer = pd.ExcelWriter(downloads_path, engine='xlsxwriter')
    merged_df.to_excel(writer, sheet_name='Validation', index=False)
    
    workbook  = writer.book
    worksheet = writer.sheets['Validation']
    
    (max_row, max_col) = merged_df.shape
    if max_row > 0:
        column_settings = [{'header': column} for column in merged_df.columns]
        worksheet.add_table(0, 0, max_row, max_col - 1, {'columns': column_settings, 'style': 'Table Style Medium 9'})
    
    writer.close()
    
    print(f"\nData successfully written to: {downloads_path}")

if __name__ == '__main__':
    main()
