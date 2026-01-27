import os
import sys
import xml.etree.ElementTree as ET
import streamlit as st
import xmlschema

# Page configuration
st.set_page_config(page_title="EUDAMED XML Generator", layout="wide")
st.title("EUDAMED XML Generator")

@st.cache_resource
def load_schema():
    """Load and cache the XML schema."""
    base_dir = os.path.dirname(os.path.abspath(__file__))
    xsd_path = os.path.join(base_dir, 'EUDAMED downloaded', 'XSD', 'data', 'Entity', 'DI.xsd')
    
    if not os.path.exists(xsd_path):
        return None, f"Schema file not found at: {xsd_path}"

    try:
        schema = xmlschema.XMLSchema(xsd_path)
        return schema, None
    except Exception as e:
        return None, f"Failed to load schema: {e}"

def get_enums_for_type(type_obj):
    """Extract enumeration values from a type object."""
    enums = None
    if type_obj.is_simple():
        if hasattr(type_obj, 'enumeration') and type_obj.enumeration:
            enums = type_obj.enumeration
        elif hasattr(type_obj, 'base_type') and hasattr(type_obj.base_type, 'enumeration') and type_obj.base_type.enumeration:
             enums = type_obj.base_type.enumeration
    return [str(e) for e in enums] if enums else None

def render_input_fields(element, type_obj, parent_key, state_container):
    """
    Recursively renders input fields for an element.
    Returns the value entered/selected by the user.
    """
    indent_level = len(parent_key.split(".")) if parent_key else 0
    key = f"{parent_key}.{element.name}" if parent_key else element.name
    
    # Store the structure in session state to rebuild XML later
    if 'xml_structure' not in state_container:
        state_container['xml_structure'] = {}

    if type_obj.is_simple():
        enums = get_enums_for_type(type_obj)
        label = f"{element.local_name}"
        
        help_text = f"Namespace: {element.name}"
        
        if enums:
            val = st.selectbox(label, options=enums, key=key, help=help_text)
        else:
            val = st.text_input(label, key=key, help=help_text)
            
        return val

    elif type_obj.is_complex():
        st.markdown(f"**{element.local_name}**")
        
        group = type_obj.content
        if not group: 
            return None

        children_data = {}
        # Iterate over elements in the sequence/group
        for particle in group.iter_model():
            if not isinstance(particle, xmlschema.validators.XsdElement):
                continue

            if particle.min_occurs >= 1:
                with st.container():
                     # Visual indentation
                    col1, col2 = st.columns([0.5, 9.5])
                    with col2:
                        child_val = render_input_fields(particle, particle.type, key, state_container)
                        children_data[particle.name] = child_val
        
        return children_data

def build_xml_element(element_name, xsd_type, form_data):
    """Recursively builds an ElementTree element from the dictionary form data."""
    tag = element_name
    elem = ET.Element(tag)
    
    if isinstance(form_data, dict):
        # Determine the order based on schema to ensure validity? 
        # For simplicity, we iterate over the form_data keys which were created in order.
        
        # We need to map simple names back to schema particles if possible, 
        # but here our keys in form_data are the fully qualified names (from element.name) 
        # or we stored them that way.
        
        # In render_input_fields for complex types, we returned a dict:
        # { particle.name : value }
        
        for child_tag, child_val in form_data.items():
            if child_val is None: continue # Should not happen for mandatory fields if UI works
            
            # Since child_val can be a string (simple) or dict (complex)
            if isinstance(child_val, (str, dict)):
                child_elem = build_xml_element_manual_tag(child_tag, child_val)
                elem.append(child_elem)
    
    elif isinstance(form_data, str):
        elem.text = form_data
        
    return elem

def build_xml_element_manual_tag(tag, content):
    elem = ET.Element(tag)
    if isinstance(content, dict):
        for child_tag, child_val in content.items():
            child_elem = build_xml_element_manual_tag(child_tag, child_val)
            elem.append(child_elem)
    else:
        elem.text = str(content)
    return elem

# --- Main App ---

schema, error_msg = load_schema()

if not schema:
    st.error(error_msg)
    st.stop()

# Namespace handling
namespaces = {
    'device': 'https://ec.europa.eu/tools/eudamed/dtx/datamodel/Entity/Device/v1',
    'basicudi': 'https://ec.europa.eu/tools/eudamed/dtx/datamodel/Entity/Device/BasicUDI/v1',
    'udidi': 'https://ec.europa.eu/tools/eudamed/dtx/datamodel/Entity/UDIDI/v1',
    'commondi': 'https://ec.europa.eu/tools/eudamed/dtx/datamodel/Entity/Device/CommonDevice/v1',
    'xsi': 'http://www.w3.org/2001/XMLSchema-instance'
}
for prefix, uri in namespaces.items():
    ET.register_namespace(prefix, uri)

# Find definitions
mdr_device_element = schema.elements.get('MDRDevice')
if not mdr_device_element:
    mdr_device_element = schema.elements.get(f"{{{namespaces['device']}}}MDRDevice")

if not mdr_device_element:
    st.error("Could not find MDRDevice element definition in schema.")
    st.stop()

mdr_device_type = mdr_device_element.type
basic_udi_def = None
udidi_data_def = None

for particle in mdr_device_type.content.iter_model():
    if 'MDRBasicUDI' in particle.name:
        basic_udi_def = particle
    elif 'MDRUDIDIData' in particle.name:
        udidi_data_def = particle

if not basic_udi_def or not udidi_data_def:
    st.error("Structure mismatch: Could not find MDRBasicUDI or MDRUDIDIData definitions.")
    st.stop()


# --- UI Layout ---

with st.form("xml_form"):
    st.header("MDR Basic UDI Configuration")
    st.info("Fill in the mandatory fields for the Basic UDI. Min Occurs >= 1 fields only.")
    
    # We use a distinct key prefix
    basic_udi_data = render_input_fields(basic_udi_def, basic_udi_def.type, "root", {})
    
    st.header("MDR UDI-DI Data Entries")
    st.info("Fill in the mandatory fields for the UDI-DI. You can add multiple entries.")
    
    # Dynamic form for multiple UDI-DIs
    # Streamlit handling for dynamic add/remove is tricky inside a big form.
    # We will prioritize a specific number selector for simplicity in this generated version, 
    # or just one for initial proof of concept, or use session state outside form to manage count.
    
    # Since 'st.form' prevents rerun on interactions, let's use a number input for count 
    # OUTSIDE the form or just put it inside.
    
    num_udis = st.number_input("Number of UDI-DI entries", min_value=1, max_value=10, value=1)
    
    udidi_data_list = []
    for i in range(num_udis):
        st.subheader(f"UDI-DI Entry #{i+1}")
        # Pass unique parent key
        udidi_data = render_input_fields(udidi_data_def, udidi_data_def.type, f"root.udidi_{i}", {})
        udidi_data_list.append(udidi_data)

    submitted = st.form_submit_button("Generate XML")

if submitted:
    st.success("Generating XML...")
    
    # Build Root
    root = ET.Element(mdr_device_element.name)
    
    # 1. Add Basic UDI
    # basic_udi_data contains the nested dict structure of values
    # We need to construct the elements. 
    # The render function returned the data relative to the CHILDREN of 'basic_udi_def'.
    # We need to wrap it in the basic_udi_def tag itself.
    
    if basic_udi_data:
        basic_udi_elem = build_xml_element_manual_tag(basic_udi_def.name, basic_udi_data)
        root.append(basic_udi_elem)
        
    # 2. Add UDI-DIs
    for udi_data in udidi_data_list:
        if udi_data:
             udidi_elem = build_xml_element_manual_tag(udidi_data_def.name, udi_data)
             root.append(udidi_elem)

    # Generate String
    # Note: ElementTree doesn't support pretty printing natively well in older versions, 
    # but valid XML is produced.
    xml_str = ET.tostring(root, encoding="utf-8", method="xml").decode("utf-8")
    
    # Add header manually as ET may omit it or make it simple
    final_xml = '<?xml version="1.0" encoding="utf-8"?>\n' + xml_str
    
    st.text_area("Generated XML", value=final_xml, height=400)
    
    # Validation
    st.subheader("Validation")
    
    # Save to temp file for validation
    temp_filename = "generated_eudamed_streamlit.xml"
    with open(temp_filename, "w", encoding="utf-8") as f:
        f.write(final_xml)
        
    try:
        schema.validate(temp_filename)
        st.success("✅ Validation Successful! The XML is valid against the schema.")
        
        with open(temp_filename, "rb") as f:
            st.download_button(
                label="Download XML",
                data=f,
                file_name="eudamed_device.xml",
                mime="application/xml"
            )
            
    except xmlschema.XMLSchemaValidationError as e:
        st.error(f"❌ Validation Failed:\n{e}")
