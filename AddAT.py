import pandas as pd
import json
from datetime import datetime, timedelta
import os

# Initialize an empty DataFrame to store the alert information
alerts = pd.DataFrame()

# Loop through the GTFS real-time trip updates files
start_date = datetime(2024, 1, 29, 10, 5, 0)
end_date = datetime(2024, 3, 25, 1, 0, 0)
current_date = start_date

while current_date <= end_date:
    # Construct the file path
    file_path = f'/Users/guillaume/Downloads/Imperial/Spring/RESEARCH/GTFS_RT/ORANGE_LINE/JSONs/Trip_updates/{current_date.strftime("%Y_%d_%m_%H_%M_%S")}.json'
    
    if os.path.exists(file_path):
        # Load the JSON data
        with open(file_path, 'r') as f:
            data = json.load(f)
        
        # Extract alert entities and filter for route_id "orange"
        new_rows = []
        for entity in data['entity']:
            if 'alert' in entity:
                for informed_entity in entity['alert']['informed_entity']:
                    if informed_entity.get('route_id') == 'orange':
                        new_rows.append(entity)
                        break
        
        # Add new rows to the DataFrame
        if new_rows:
            alerts = pd.concat([alerts, pd.DataFrame(new_rows)], ignore_index=True)
    
    # Increment the current date by one minute
    current_date += timedelta(minutes=1)

alerts.to_csv('alerts.csv', index=False)
