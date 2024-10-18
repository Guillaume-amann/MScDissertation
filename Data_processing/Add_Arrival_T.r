library(readxl)
library(jsonlite)
library(lubridate)
library(dplyr)

# Load the DataFrame
df <- read_excel('Matrix.xlsx')

# Function to generate the new file path based on a datetime object
generate_file_path <- function(base_path, timestamp) {
  # Reformat the timestamp back to the file format YYYY_DD_MM_HH_MM_SS
  return(format(timestamp, "%Y_%d_%m_%H_%M_%S"))
}

# Function to load and check JSON data, and retry if necessary
process_json_file <- function(json_path_base, row_latitude, row_longitude, max_attempts = 15) {
  
  # Extract date and time from the file name (assumed in format 'YYYY_DD_MM_HH_MM_SS')
  timestamp <- as.POSIXct(json_path_base, format = "%Y_%d_%m_%H_%M_%S", tz = "UTC")
  
  # Try up to 'max_attempts' times, starting with the original file and then incrementing by one minute
  for (attempt in 0:(max_attempts - 1)) {
    # Generate the current file path for the current attempt
    json_file_path <- generate_file_path(json_path_base, timestamp)
    
    # Full path to the file
    full_file_path <- paste0("/Users/guillaume/Downloads/Imperial/Spring/RESEARCH/GTFS_RT/ORANGE_LINE/JSONs/Vehicle_pos/", json_file_path, ".json")
    
    # Try to load the JSON data from the file
    if (file.exists(full_file_path)) {
      data <- fromJSON(full_file_path)
      
      # Check if "entity" exists in the JSON
      if ("entity" %in% names(data)) {
        for (entity in data$entity) {
          if ("vehicle" %in% names(entity)) {
            vehicle_info <- entity$vehicle
            
            # Check if the necessary keys exist in 'trip' and 'position'
            if ("trip" %in% names(vehicle_info) && "position" %in% names(vehicle_info)) {
              trip_info <- vehicle_info$trip
              position_info <- vehicle_info$position
              
              # Check if the necessary keys exist in 'trip' and 'position'
              if (all(c("route_id", "direction_id") %in% names(trip_info)) &&
                  all(c("latitude", "longitude") %in% names(position_info))) {
                
                # Check conditions
                if (trip_info$route_id == 'ORANGE' && 
                    trip_info$direction_id == 0 &&
                    round(position_info$latitude, 3) == round(row_latitude, 3) && 
                    round(position_info$longitude, 3) == round(row_longitude, 3)) {
                  
                  if ("timestamp" %in% names(vehicle_info)) {
                    return(vehicle_info$timestamp)
                  }
                }
              }
            }
          }
        }
      }
    } else {
      message(paste("File not found:", full_file_path))
    }
    
    # If criteria were not met, try the next file by incrementing the time by one minute
    timestamp <- timestamp + lubridate::minutes(1)
  }
  
  # If no match was found after the attempts, return NULL
  return(NULL)
}

# Create a new column for actual_AT
df$actual_AT <- NA

# Iterate through the DataFrame rows
for (idx in 1:nrow(df)) {
  # Process the JSON file and get the actual_AT value
  actual_AT_value <- process_json_file(df$address[idx], df$stop_lat[idx], df$stop_lon[idx])
  
  if (!is.null(actual_AT_value)) {
    df$actual_AT[idx] <- actual_AT_value  # Update actual_AT in the DataFrame
    print("OK")
  } else {
    print("raté")
  }
}

# Convert actual_AT to POSIXct and adjust time zone
df$actual_AT <- as.POSIXct(df$actual_AT, origin = "1970-01-01", tz = "UTC") - lubridate::hours(5)
df$delay <- df$actual_AT - df$datetime_corrigee

# Display the first few rows of the updated DataFrame
print(head(df))

# Save the updated DataFrame to an Excel file
write.xlsx(df, 'Updated_Matrix.xlsx', row.names = FALSE)

print("Processing complete. Updated DataFrame saved to 'Updated_Matrix.xlsx'.")