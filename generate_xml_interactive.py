import os
import sys
import xml.etree.ElementTree as ET

try:
    import xmlschema
except ImportError:
    print("Error: The 'xmlschema' library is required for schema parsing and validation.")
    print("Please install it using: pip install xmlschema")
    sys.exit(1)

def get_input_for_element(element, type_obj, indent_level=0):
    """
    Prompts user for input for a given schema element.
    Returns: The value string or None.
    """
    indent = "  " * indent_level
    name = element.name
    
    # documentation = ""
    # if element.annotation and element.annotation.documentation:
    #     documentation = element.annotation.documentation[0].text

    print(f"\n{indent}Field: {name}")
    # if documentation:
    #     print(f"{indent}Description: {documentation}")

    # Check for enumerations
    enums = None
    if type_obj.is_simple():
        if hasattr(type_obj, 'enumeration') and type_obj.enumeration:
            enums = type_obj.enumeration
        elif hasattr(type_obj, 'base_type') and hasattr(type_obj.base_type, 'enumeration') and type_obj.base_type.enumeration:
             enums = type_obj.base_type.enumeration
    
    if enums:
        print(f"{indent}Possible values: {', '.join([str(e) for e in enums])}")

    while True:
        val = input(f"{indent}Enter value for {name}: ").strip()
        if not val and element.min_occurs > 0:
            print(f"{indent}Value is required.")
            continue
        
        if enums and val and val not in enums:
            print(f"{indent}Invalid value. Please choose from the list.")
            continue
            
        return val

def process_complex_type(xsd_type, parent_element, indent_level=0):
    """
    Recursively processes a complex type, adding children to parent_element.
    Only processes children with min_occurs >= 1.
    """
    # In xmlschema, .content holds the model group (sequence/choice/all) for complex content
    group = xsd_type.content
    if not group: 
        return

    # Iterate over elements in the sequence/group
    for particle in group.iter_model():
        # particle could be XsdElement or XsdAnyElement
        if not isinstance(particle, xmlschema.validators.XsdElement):
            continue

        if particle.min_occurs >= 1:
            # It's mandatory, let's process it
            child_name = particle.local_name
            # If explicit name is different (e.g. ref), use it. 
            # particle.name gives the qualified name usually.
            
            # Construct namespaced tag for ElementTree
            tag = particle.name # This includes the namespace if xmlschema parsed it effectively
            
            child_elem = ET.SubElement(parent_element, tag)
            
            child_type = particle.type
            
            if child_type.is_simple():
               val = get_input_for_element(particle, child_type, indent_level)
               child_elem.text = val
            elif child_type.is_complex():
                print(f"\n{'  '*indent_level}Configuring mandatory section: {particle.local_name}")
                process_complex_type(child_type, child_elem, indent_level + 1)

def main():
    base_dir = os.path.dirname(os.path.abspath(__file__))
    xsd_path = os.path.join(base_dir, 'EUDAMED downloaded', 'XSD', 'data', 'Entity', 'DI.xsd')
    
    if not os.path.exists(xsd_path):
        print(f"Schema file not found at: {xsd_path}")
        return

    print("Loading schema... this may take a moment.")
    try:
        schema = xmlschema.XMLSchema(xsd_path)
    except Exception as e:
        print(f"Failed to load schema: {e}")
        return

    # Namespace map for cleaner output (optional)
    namespaces = {
        'device': 'https://ec.europa.eu/tools/eudamed/dtx/datamodel/Entity/Device/v1',
        'basicudi': 'https://ec.europa.eu/tools/eudamed/dtx/datamodel/Entity/Device/BasicUDI/v1',
        'udidi': 'https://ec.europa.eu/tools/eudamed/dtx/datamodel/Entity/UDIDI/v1',
        'commondi': 'https://ec.europa.eu/tools/eudamed/dtx/datamodel/Entity/Device/CommonDevice/v1',
        'xsi': 'http://www.w3.org/2001/XMLSchema-instance'
    }
    
    for prefix, uri in namespaces.items():
        ET.register_namespace(prefix, uri)

    # Root element definitions - We want device:MDRDevice
    # But in xmlschema we can look up the element definition
    mdr_device_element = schema.elements.get('MDRDevice')
    if not mdr_device_element:
        # Try finding with namespace
        mdr_device_element = schema.elements.get(f"{{{namespaces['device']}}}MDRDevice")
    
    if not mdr_device_element:
        print("Could not find MDRDevice element definition in schema.")
        return

    print("\n--- Creating MDRDevice ---")
    
    root = ET.Element(mdr_device_element.name)
    # Add xsi:type if needed, or other attributes. For root element usually not needed if element name matches.
    
    mdr_device_type = mdr_device_element.type
    
    # MDRDeviceType contains MDRBasicUDI (1) and MDRUDIDIData (1..*)
    # We will manually drive this top level to satisfy specific user request:
    # "one device:MDRBasicUDI section ... We will include more device:MDRUDIDIData sections"
    
    # 1. Process MDRBasicUDI
    # Find the MDRBasicUDI element definition inside MDRDeviceType
    # We look into the content model
    
    basic_udi_def = None
    udidi_data_def = None
    
    # In xmlschema, .content holds the model group
    for particle in mdr_device_type.content.iter_model():
        if 'MDRBasicUDI' in particle.name:
            basic_udi_def = particle
        elif 'MDRUDIDIData' in particle.name:
            udidi_data_def = particle
            
    if not basic_udi_def:
        print("Structure mismatch: Could not find MDRBasicUDI definition.")
        return

    print("\n--- Configuring MDRBasicUDI ---")
    basic_udi_elem = ET.SubElement(root, basic_udi_def.name)
    process_complex_type(basic_udi_def.type, basic_udi_elem, indent_level=1)
    
    # 2. Process MDRUDIDIData (Multiple)
    if not udidi_data_def:
        print("Structure mismatch: Could not find MDRUDIDIData definition.")
    else:
        while True:
            print("\n--- Configuring MDRUDIDIData ---")
            udidi_elem = ET.SubElement(root, udidi_data_def.name)
            process_complex_type(udidi_data_def.type, udidi_elem, indent_level=1)
            
            cont = input("\nAdd another UDI-DI? (y/n): ").lower()
            if cont != 'y':
                break

    # Generate XML string
    print("\nGenerating XML...")
    tree = ET.ElementTree(root)
    output_file = "generated_eudamed_interactive.xml"
    tree.write(output_file, encoding="utf-8", xml_declaration=True)
    
    print(f"XML saved to {output_file}")
    
    # Validation
    print("Validating generated XML against schema...")
    try:
        # We need to reload the file to validate it, or convert tree to string
        schema.validate(output_file)
        print("Validation Successful! The XML is valid.")
    except xmlschema.XMLSchemaValidationError as e:
        print("Validation Failed:")
        print(e)

if __name__ == "__main__":
    main()
