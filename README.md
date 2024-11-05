# Evaluation of the causal effect of disruption on delay as a benchmarking tool for public transport network performance

While black-box models are becoming increasingly accurate for prediction problems, the desire to master and understand the relationships between factors and the dependent variables is driving the need for the development of Causal Inference, which is gaining momentum. Urban mass transit systems typically generate large volumes of data on various aspects of operations. Statistical analyses can be used to summarise and present such data, drawn from within and between systems, to understand the drivers of performance. This empirical analysis leverages large-scale publicly available data from the General Transit Feed Specification (GTFS) feed of the Washington DC metro network to characterise the performance of transit systems, focusing on train on-time performance and the space-time propagation of disruption causing subsequent delays.

## Project Overview

The project aims to leverage large datasets from public transport networks to assess and benchmark their resilience under disruption scenarios. The study applies the Synthetic Control method to create a synthetic benchmark day, allowing comparison of typical and disrupted service days.

## Key Concepts

* Synthetic Control Method (SC): Used to create a counterfactual scenario in the absence of disruptions, providing a robust measure for the causal effect of disruptions on delay.
* Causal Inference: Addresses the confounding factors in network disruptions to isolate and measure their impact accurately.
* Time Unit Adjustments: Uses R scripting to handle and preprocess time data for accuracy in delay and disruption analysis.

## Database architecture

<img src="https://github.com/Guillaume-amann/MScDissertation/blob/main/Tables/Schedule_Database.png"  alt="Database Architecture">

## Requirements

* Synth R package: to install this package, first ensure that devtools is installed with

```
install.packages("Synth")
```

* GTFS Data: The research uses General Transit Feed Specification (GTFS) data; access to similar data is required for replication or adaptation.
