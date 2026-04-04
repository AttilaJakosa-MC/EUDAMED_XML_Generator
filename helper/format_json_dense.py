import re
import sys
import os

def format_objects_dense(filepath):
    if not os.path.exists(filepath):
        print(f"Error: File '{filepath}' not found.")
        return

    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    def replacer(match):
        # Get the matched { ... } block
        block = match.group(0)
        # Replace all whitespace (including newlines and tabs) with a single space
        condensed = re.sub(r'\s+', ' ', block)
        # Clean up some unnecessary spaces around array brackets to make it look nicer
        condensed = condensed.replace('[ ', '[').replace(' ]', ']')
        return condensed

    # Find everything between { and } (non-greedy) and pass it to our replacer
    # re.DOTALL makes '.' match newlines as well
    new_content = re.sub(r'\{.*?\}', replacer, content, flags=re.DOTALL)

    # Save to a new file
    output_filepath = filepath + '.dense.txt'
    with open(output_filepath, 'w', encoding='utf-8') as f:
        f.write(new_content)
    
    print(f"Success! Condensed output saved to: {output_filepath}")

if __name__ == '__main__':
    if len(sys.argv) > 1:
        format_objects_dense(sys.argv[1])
    else:
        print("Usage: python format_json_dense.py <path_to_your_file>")
