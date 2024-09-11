library(Synth)
library(readxl)
library(lubridate)

df <- read_excel("/Tables/Book1.xlsx")
df <- as.data.frame(df)

df$date <- as.numeric(as.Date(df$date))

print(unique(df$date))
print(unique(df$hour))

stop <- 19802
dis <- 10

# Prepare the data for Synthetic Control
dataprep.out <- dataprep(
  foo = df,
  predictors = c("date", "day", "week"),
  predictors.op = "mean",
  dependent = "delay",
  unit.variable = "date",
  time.variable = "hour",
  treatment.identifier = stop,
  controls.identifier = unique(df$date[-which(df$date == stop)]),

  time.predictors.prior = c(0,1,5:dis),  # e.g., days 0 to 2
  time.optimize.ssr = c(0,1,5:dis),  # e.g., days 0 to 2
  time.plot = c(0,1,5:23)  # full range available
)

synth.out <- synth(dataprep.out)
synth.tables <- synth.tab(dataprep.res = dataprep.out, synth.res = synth.out)

write.csv(synth.tables$tab.w, file = "SC_weights.csv", row.names = FALSE)
write.csv(synth.tables$tab.pred, file = "SC_predictions.csv", row.names = FALSE)

path.plot(
  synth.res = synth.out,
  dataprep.res = dataprep.out,
  tr.intake = dis,
  Ylab = "Daily aggregated delay (in min)",
  Xlab = "Time",
  Legend = c("Treated", "Synthetic"),
  Legend.position = "bottomright"
)

# gaps.plot(
#   synth.res = synth.out,
#   dataprep.res = dataprep.out,
#   Ylab = "Hourly aggregated delay along the Orange line (in min)",
#   Xlab = "Hour",
#   Main = c("Gaps: Treated - Synthetic"),
#   tr.intake = NA,
#   Ylim = NA,
#   Z.plot = FALSE)
