import os
import json
import shutil

def filter_and_copy_alerts(src_folder, dest_folder):
    # Create the destination folder if it does not exist
    os.makedirs(dest_folder, exist_ok=True)

    # Iterate over all files in the source folder
    for filename in os.listdir(src_folder):
        if filename.endswith('.json'):
            file_path = os.path.join(src_folder, filename)
            with open(file_path, 'r') as file:
                try:
                    data = json.load(file)   
                    # Extract header information
                    header = data.get('header', {})
                    header_info = {
                        'gtfs_realtime_version': header.get('gtfs_realtime_version'),
                        'incrementality': header.get('incrementality'),
                        'timestamp': header.get('timestamp')
                    }
                    
                    # Filter entities
                    filtered_entities = []
                    for entity in data.get('entity', []):
                        if 'alert' in entity:
                            alert = entity['alert']
                            for informed_entity in alert.get('informed_entity', []):
                                if informed_entity.get('route_id') == 'ORANGE':
                                    filtered_entities.append(entity)
                                    break
                    
                    # Create a new JSON structure
                    filtered_data = {
                        'header': header_info,
                        'entity': filtered_entities
                    }
                    
                    # Write the filtered data to a new file in the destination folder
                    dest_file_path = os.path.join(dest_folder, filename)
                    with open(dest_file_path, 'w') as dest_file:
                        json.dump(filtered_data, dest_file, indent=2)
                    
                    print(f'Filtered and copied: {filename}')
                
                except json.JSONDecodeError:
                    print(f'Error reading {filename}')

def filter_and_copy_trip_up(src_folder, dest_folder):
    # Create the destination folder if it does not exist
    os.makedirs(dest_folder, exist_ok=True)

    # Iterate over all files in the source folder
    for filename in os.listdir(src_folder):
        if filename.endswith('.json'):
            file_path = os.path.join(src_folder, filename)
            with open(file_path, 'r') as file:
                try:
                    data = json.load(file)   
                    # Extract header information
                    header = data.get('header', {})
                    header_info = {
                        'gtfs_realtime_version': header.get('gtfs_realtime_version'),
                        'incrementality': header.get('incrementality'),
                        'timestamp': header.get('timestamp')
                    }
                    
                    # Filter entities
                    filtered_entities = []
                    for entity in data.get('entity', []):
                        if 'trip_update' in entity and 'trip' in entity['trip_update']:
                            trip_info = entity['trip_update']['trip']
                            if trip_info.get('route_id') == 'ORANGE':
                                filtered_entities.append(entity)
                    
                    # Create a new JSON structure
                    filtered_data = {
                        'header': header_info,
                        'entity': filtered_entities
                    }
                    
                    # Write the filtered data to a new file in the destination folder
                    dest_file_path = os.path.join(dest_folder, filename)
                    with open(dest_file_path, 'w') as dest_file:
                        json.dump(filtered_data, dest_file, indent=2)
                    
                    print(f'Filtered and copied: {filename}')
                
                except json.JSONDecodeError:
                    print(f'Error reading {filename}')

def filter_and_copy_vehicle_p(src_folder, dest_folder):
    # Create the destination folder if it does not exist
    os.makedirs(dest_folder, exist_ok=True)

    # Iterate over all files in the source folder
    for filename in os.listdir(src_folder):
        if filename.endswith('.json'):
            file_path = os.path.join(src_folder, filename)
            with open(file_path, 'r') as file:
                try:
                    data = json.load(file)
                    # Extract header information
                    header = data.get('header', {})
                    header_info = {
                        'gtfs_realtime_version': header.get('gtfs_realtime_version'),
                        'incrementality': header.get('incrementality'),
                        'timestamp': header.get('timestamp')
                    }
                    
                    # Filter entities
                    filtered_entities = []
                    for entity in data.get('entity', []):
                        if 'vehicle' in entity and 'trip' in entity['vehicle']:
                            trip_info = entity['vehicle']['trip']
                            if trip_info.get('route_id') == 'ORANGE':
                                filtered_entities.append(entity)
                    
                    # Create a new JSON structure with filtered data
                    filtered_data = {
                        'header': header_info,
                        'entity': filtered_entities
                    }
                    
                    # Write the filtered data to a new file in the destination folder
                    dest_file_path = os.path.join(dest_folder, filename)
                    with open(dest_file_path, 'w') as dest_file:
                        json.dump(filtered_data, dest_file, indent=2)
                    
                    print(f'Filtered and copied: {filename}')
                
                except json.JSONDecodeError as e:
                    print(f'Error reading {filename}: {e}')

filter_and_copy_alerts('GTFS_RT/RAIL_RT_ALERTS', 'GTFS_RT/ORANGE_LINE/JSONs/Alerts')
#filter_and_copy_trip_up('GTFS_RT/RAIL_RT_TRIP_UPDATES', 'GTFS_RT/ORANGE_LINE/JSONs/Trip_updates')
#filter_and_copy_vehicle_p('GTFS_RT/RAIL_RT_VEHICAL_POSITIONS_ENDPOINT','GTFS_RT/ORANGE_LINE/JSONs/Vehicle_pos')