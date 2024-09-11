import pandas as pd
import json
import os
from datetime import datetime, timedelta

# Load the DataFrame
df = pd.read_excel('Matrix.xlsx')

# Function to generate the new file path based on a datetime object
def generate_file_path(base_path, timestamp):
    # Reformat the timestamp back to the file format YYYY_DD_MM_HH_MM_SS
    return timestamp.strftime('%Y_%d_%m_%H_%M_%S')
        
# Function to load and check JSON data, and retry if necessary
def process_json_file(json_path_base, row_latitude, row_longitude, max_attempts=15):

    # Extract date and time from the file name (assumed in format 'YYYY_DD_MM_HH_MM_SS')
    try:
        # Parse the initial file name into a datetime object
        timestamp = datetime.strptime(json_path_base, '%Y_%d_%m_%H_%M_%S')
    except ValueError as ve:
        print(f"Error parsing file path date: {json_path_base}")
        return None

    # Try up to 'max_attempts' times, starting with the original file and then incrementing by one minute
    for attempt in range(max_attempts):
        # Generate the current file path for the current attempt
        json_file_path = generate_file_path(json_path_base, timestamp)

        try:
            # Full path to the file
            full_file_path = f"/Users/guillaume/Downloads/Imperial/Spring/RESEARCH/GTFS_RT/ORANGE_LINE/JSONs/Vehicle_pos/{json_file_path}.json"

            # Load the JSON data from the file
            with open(full_file_path, 'r') as f:
                data = json.load(f)

            # Check if "entity" exists in the JSON
            if 'entity' in data:
                for entity in data['entity']:
                    if 'vehicle' in entity:
                        vehicle_info = entity['vehicle']

                        # Check if the necessary keys exist in 'trip' and 'position'
                        if 'trip' in vehicle_info and 'position' in vehicle_info:
                            trip_info = vehicle_info['trip']
                            position_info = vehicle_info['position']

                            # Check if the necessary keys exist in 'trip' and 'position'
                            if ('route_id' in trip_info and 
                                'direction_id' in trip_info and 
                                'latitude' in position_info and 
                                'longitude' in position_info):
                                
                                # Check conditions
                                if (trip_info['route_id'] == 'ORANGE' and
                                        trip_info['direction_id'] == 0 and
                                        round(position_info['latitude'], 3) == round(row_latitude, 3) and
                                        round(position_info['longitude'], 3) == round(row_longitude, 3)):
         
                                    if 'timestamp' in vehicle_info:
                                        return vehicle_info['timestamp']

        except FileNotFoundError:
            print(f"File not found: {full_file_path}")
     
        except Exception as e:
            print(f"Error processing {full_file_path}: {e}")

        # If criteria were not met, try the next file by incrementing the time by one minute
        timestamp += timedelta(minutes=1)

    # If no match was found after the attempts, return None
    return None

# Assuming df is your DataFrame and 'address', 'latitude', and 'longitude' columns exist
df['actual_AT'] = None  # Create a new column

for idx, row in df.iterrows():

    # Process the JSON file and get the actual_AT value, trying up to 10 minutes later
    actual_AT_value = process_json_file(row['address'], row['stop_lat'], row['stop_lon'])

    if actual_AT_value:
        df.at[idx, 'actual_AT'] = actual_AT_value  # Update actual_AT in the DataFrame
        print("OK")
    else:
        print("raté")

df['actual_AT'] = pd.to_datetime(df['actual_AT'], unit='s', errors='coerce') - pd.to_timedelta(5, unit='h')
df['delay'] = df['actual_AT'] - df['datetime_corrigee']

# Display the first few rows of the updated DataFrame
print(df.head())

# Save the updated DataFrame to an Excel file
df.to_excel('Updated_Matrix.xlsx', index=False)

print("Processing complete. Updated DataFrame saved to 'Updated_Matrix.xlsx'.")