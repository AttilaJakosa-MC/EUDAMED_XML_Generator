# EUDAMED XML Generator (Node.js)

This tool generates EUDAMED XML files based on YAML configuration and XSD Schema.

## Prerequisites

- Node.js (v14+)
- npm

## Usage

1. Install dependencies:
   ```bash
   npm install
   ```

2. Run the generator for the 4 supported scenarios:

   ```bash
   # Full Device Registration
   node index.js --config "./EUDAMED_data_Lens_877PAY-test.yaml" --out "output" --type "DEVICE" --mode "POST"

   # UDI-DI Registration (New)
   node index.js --config "./EUDAMED_data_Lens_877PAY-test.yaml" --out "output" --type "UDI_DI" --mode "POST"

   # UDI-DI Update (Update existing)
   node index.js --config "./EUDAMED_data_Lens_877PAY-test.yaml" --out "output" --type "UDI_DI" --mode "PATCH"

   # Basic UDI-DI Update
   node index.js --config "./EUDAMED_data_Lens_877PAY-test.yaml" --out "output" --type "BASIC_UDI" --mode "PATCH"
   ```

   Arguments:
   - `-c, --config`: Path to the YAML configuration file (default: `./EUDAMED_data_Lens_877PAY-test.yaml`).
   - `-s, --schema`: Path to `Message.xsd` (default: `../EUDAMED downloaded/XSD/service/Message.xsd`).
   - `-o, --out`: Output directory (default: `output`).
   - `--type`: Type of XML to generate: `DEVICE`, `UDI_DI`, or `BASIC_UDI`. (Mandatory)
   - `--mode`: Operation mode: `POST` or `PATCH`. (Default: `POST`)

### Supported Combinations

| Type | Mode | Description |
| :--- | :--- | :--- |
| `DEVICE` | `POST` | Full device registration (Bulk/Push). |
| `UDI_DI` | `POST`, `PATCH` | UDI-DI registration or update. |
| `BASIC_UDI` | `PATCH` | Basic UDI-DI updates. |

### Multi-Entity Distribution Logic

The tool filters and distributes data from the YAML configuration across the four primary scenarios to match the EUDAMED migration workflow:

| Scenario | Service Type | Mode | Represented YAML Entities |
| :--- | :--- | :--- | :--- |
| **Initial Registration** | `DEVICE` | `POST` | **Index `[0]` Only**. Includes the `BasicUDI` and the first primary `UDI_DI` record. |
| **Secondary Registration** | `UDI_DI` | `POST` | **Indices `[1], [2], ...`**. All secondary UDI-DI records (excluding index 0) generated as batch siblings. |
| **UDI-DI Update** | `UDI_DI` | `PATCH` | **Indices `[0], [1], [2], ...`**. All specified UDI-DI records for batch modification. |
| **Basic UDI Update** | `BASIC_UDI` | `PATCH` | The single `BasicUDI` branch (independent of UDI-DI indices). |

#### Batch Behavior
For the `UDI_DI` services (`POST` and `PATCH`), multiple entities are bundled into a single XML message. Each index in the YAML results in a sibling `<device:UDIDIData>` tag within the `<m:payload>` element.

## Logic

- **Schema Resolution**: The tool parses the XSD to understand the structure. It automatically resolves recursive imports and merges namespaces.
- **Path Mapping**: It traverses the XSD and matches elements against flat keys in the YAML `defaults` section (e.g., `Push/payload/MDRDevice/...`).
- **Optimization**: The generator skips schema branches that have no corresponding data in the configuration, significantly improving performance for large EUDAMED XSDs.
- **Structural Fixes**:
  - **Substitution**: Automatically handles abstract elements (e.g., replacing `MDRDevice` with `Device` and injecting `xsi:type`).
  - **Sequencing**: Enforces strict XSD element ordering (Base types before extension types).
  - **Header Support**: Generates fragmentary payloads (UDI_DI, BASIC_UDI) and wraps them in a compliant `m:Push` message with automated `messageID`, `correlationID`, and timestamp.
  - **Metadata Handling**: Automatically strips versioning info (`version`, `state`) for `POST` operations to ensure clean registrations.

## Output

Generated files are saved in the output directory using the naming convention:
`{TYPE}-{MODE}.xml` (e.g., `UDI_DI-POST.xml`).

## Validation

The generator uses the XSD to drive the creation. If the XSD requires structure that is missing in the Config, it might skip it (if optional) or produce a partial XML.
Strict content validation (regex patterns) is partially supported through XSD simpleType checks (future enhancement).

## Project Structure

- `index.js`: Main CLI entry point.
- `lib/schema.js`: XSD Parser and Context Loader.
- `lib/generator.js`: XML Generation Logic.
