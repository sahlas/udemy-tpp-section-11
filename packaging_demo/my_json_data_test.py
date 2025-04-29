from pathlib import Path
import json

THIS_DIR = Path(__file__).parent
DATA_JSON_FPATH = THIS_DIR / "./my_folder/my_data.json"

def process_json_list(file_path):
    with open(file_path, 'r') as file:
        data = json.load(file)
    
    my_list = data['items'] # Assuming the list is under the key 'items'

    for item in my_list:
        # Process each item in the list
        print(item)

# Example usage
file_path = DATA_JSON_FPATH
process_json_list(file_path)