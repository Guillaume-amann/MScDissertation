library(dplyr)
library(lubridate)
library(Synth)

set.seed(123)

stop_times <- read.csv("GTFS_S/stop_times.txt")
trips <- read.csv("GTFS_S/trips.txt")
stops <- read.csv("GTFS_S/stops.txt")

######################################################################################################################################### # nolint: line_length_linter.

orange_trips <- trips %>% filter(route_id == "ORANGE" & direction_id == 0)

orange_stop_times <- stop_times %>%
  filter(trip_id %in% orange_trips$trip_id) %>%
  left_join(orange_trips, by = "trip_id") %>%
  left_join(stops, by = "stop_id")

unique_stops <- unique(orange_stop_times$stop_id)
print(unique_stops)

stop_id_mapping <- setNames(seq_along(unique_stops), unique_stops)
orange_stop_times$stop_id <- as.integer(factor(orange_stop_times$stop_id,
                                                levels = unique_stops))

orange_stop_times$datetime_corrigee <- as.POSIXct("2024-01-21T00:00:00")

for (i in 1:nrow(orange_stop_times)) {
  time <- hms(orange_stop_times$arrival_time[i])
  if (!is.na(time)) {
    orange_stop_times$datetime_corrigee[i] <- update(orange_stop_times$datetime_corrigee[i], hour = hour(time), minute = minute(time), second = second(time)) # nolint: line_length_linter.
    orange_stop_times$datetime_corrigee[i] <- orange_stop_times$datetime_corrigee[i] # nolint: line_length_linter.
  }
}

######################################################################################################################################### # nolint: line_length_linter.

new_date <- as.Date("2024-01-29")
time_part <- format(orange_stop_times$datetime_corrigee, "%H:%M:%S")
new_datetime <- as.POSIXct(paste(new_date, time_part))
orange_stop_times$datetime_corrigee <- new_datetime
orange_stop_times$new_date <- as.Date("2024-01-29")

# Loop over each row to update the date
for (i in 2:nrow(orange_stop_times)) {
  current_hour <- hour(orange_stop_times$datetime_corrigee[i])
  previous_hour <- hour(orange_stop_times$datetime_corrigee[i - 1])

  if ((current_hour == 0 || current_hour == 1) && (previous_hour == 22 || previous_hour == 23)) { # nolint: line_length_linter.
    orange_stop_times$new_date[i] <- orange_stop_times$new_date[i - 1] + 1
  } else {
    orange_stop_times$new_date[i] <- orange_stop_times$new_date[i - 1]
  }
}

time_part <- format(orange_stop_times$datetime_corrigee, "%H:%M:%S")
new_datetime <- as.POSIXct(paste(orange_stop_times$new_date, time_part))
orange_stop_times$datetime_corrigee <- new_datetime

######################################################################################################################################### # nolint: line_length_linter.

orange_stop_times_doubled <- rbind(orange_stop_times, orange_stop_times)

start_date <- as.Date("2024-01-29")
time_part_doubled <- format(orange_stop_times_doubled$datetime_corrigee, "%H:%M:%S") # nolint: line_length_linter.
orange_stop_times_doubled$datetime_corrigee <- as.POSIXct(paste(start_date, time_part_doubled)) # nolint: line_length_linter.
orange_stop_times_doubled$new_date <- start_date

# Update new_date for the doubled dataframe
for (i in 2:nrow(orange_stop_times_doubled)) {
  current_hour <- hour(orange_stop_times_doubled$datetime_corrigee[i])
  previous_hour <- hour(orange_stop_times_doubled$datetime_corrigee[i - 1])

  if ((current_hour == 0 || current_hour == 1) && (previous_hour == 22 || previous_hour == 23)) { # nolint: line_length_linter.
    orange_stop_times_doubled$new_date[i] <- orange_stop_times_doubled$new_date[i - 1] + 1 # nolint: line_length_linter.
  } else {
    orange_stop_times_doubled$new_date[i] <- orange_stop_times_doubled$new_date[i - 1] # nolint: line_length_linter.
  }
}

time_part <- format(orange_stop_times_doubled$datetime_corrigee, "%H:%M:%S")
orange_stop_times_doubled$datetime_corrigee <- as.POSIXct(paste(orange_stop_times_doubled$new_date, time_part)) # nolint: line_length_linter.

######################################################################################################################################### # nolint: line_length_linter.

write.xlsx(orange_stop_times, "try.xlsx")
write.xlsx(orange_stop_times_doubled, "2Months.xlsx")

orange_stop_times_stop1 <- orange_stop_times_doubled %>%
  filter(stop_id == 1)

write.xlsx(orange_stop_times_stop1, "orange_stop_times_stop1.xlsx")