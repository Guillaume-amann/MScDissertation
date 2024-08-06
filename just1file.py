import pandas as pd
import json
import os

# Load the DataFrame from the Excel file
df = pd.read_excel('matrix.xlsx')

# Create two new columns for arrival_time and stop_time_update
df['real_arrival_time'] = None
df['stop_time_update'] = None

# Iterate over each row in the DataFrame
for index, row in df.iterrows():
    # Construct the file path
    file_path = '/Users/guillaume/Downloads/Imperial/Spring/RESEARCH/GTFS_RT/ORANGE_LINE/JSONs/Trip_updates/' + row['address'] + '.json'

    # Check if the file exists
    if os.path.isfile(file_path):
        # Open the JSON file
        with open(file_path) as f:
            data = json.load(f)

        # Search for the entity with the same trip_id, stop_id, and route_id
        for entity in data:
            # Check if the entity has the same trip_id, stop_id, and route_id
            if 'trip_id' in entity and 'stop_id' in entity and 'route_id' in entity:
                if entity['trip_id'] == row['trip_id'] and entity['stop_id'] == row['stop_id'] and entity['route_id'] == row['route_id']:
                    # If found, retrieve the arrival_time and stop_time_update
                    arrival_time = entity.get('real_arrival_time')
                    stop_time_update = entity.get('stop_time_update')

                    df.at[index, 'real_arrival_time'] = arrival_time
                    df.at[index, 'stop_time_update'] = stop_time_update

                    break
            else:
                continue
    else:
        continue

# Save the updated DataFrame to a new Excel file
df.to_excel('updated_matrix.xlsx', index=False)
