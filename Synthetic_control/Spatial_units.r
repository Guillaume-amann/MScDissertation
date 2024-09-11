library(Synth)
library(readxl)
library(lubridate)

df <- read_excel("2W_Agg_All.xlsx")
df <- as.data.frame(df)
df$date <- as.numeric(as.Date(df$date))

print(unique(df$date))

stop <- 15
dis <- 19759

# Prepare the data for Synthetic Control
dataprep.out <- dataprep(
  foo = df,
  predictors = c("shape", "zone"),
  predictors.op = "mean",
  dependent = "delay",
  unit.variable = "stop",
  time.variable = "date",
  treatment.identifier = stop,
  controls.identifier = unique(df$stop[-which(df$stop == stop)]),
  time.predictors.prior = 19751:dis,
  time.optimize.ssr = 19751:dis,
  time.plot = 19751:19764
)

synth.out <- synth(dataprep.out)
synth.tables <- synth.tab(dataprep.res = dataprep.out, synth.res = synth.out)

# write.csv(synth.tables$tab.w, file = "SC_weights.csv", row.names = FALSE)
# write.csv(synth.tables$tab.pred, file = "SC_predictions.csv", row.names = FALSE)

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
#   Ylab = "Daily aggregated delay (in min)",
#   Xlab = "Time",
#   Main = c("Gaps: Treated - Synthetic"),
#   tr.intake = NA,
#   Ylim = NA,
#   Z.plot = FALSE)