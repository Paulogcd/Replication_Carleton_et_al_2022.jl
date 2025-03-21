# Home

This page is the home page of the documentation of the replication package of [Carleton et al., 2022: Valuing the Global Mortality Consequences of Climate Change Accounting for Adaptation Costs and Benefits Get access  Arrow ](https://doi.org/10.1093/qje/qjac020).

This replication package was done for the Development Economics class, taught by [Clément Imbert](https://sites.google.com/site/clemimbert/) at Sciences Po in the summer 2025 semester. Our goal was to try to replicate some of the results of the authors, translating the code from STATA, R and Python to Julia.

## Introduction

How will future increases in global temperatures and the effects of climate change influence human mortality?
To answer this question, the authors use sub-national data from 40 countries to estimate age-specific mortality-temperature-relationships which they then extrapolate to the rest of the world to assess global mortality risks linked to climate change.
The authors then combine this with different climate change projections to estimate fatality rates in the upcoming decades.
Finally, based on their regional estimates of mortality rates given climate and income data, they use a revealed preferences approach to infer the costs of climate change adaptation.
They find that mortality rates will increase especially in very cold and very hot regions in the more than 64 age group, disproportionately affect poor countries, and estimate the climate-change mortality risk at 3.2% of global GDP under their projected climate change adaptation scenario.

For our replication, we wanted to reproduce figures on the temperature-mortality relationship by age group and its distribution across geographical regions. However, we encountered a number of technical and computational difficulties, which severely limited our ability to replicate the author’s findings, despite various attempts to overcome these logistical challenges.

## Overview of documentation

The documentation of our replication package is divided so: 

1. Presentation of the course of our replication attempt
2. Technical documentation
3. Tests of the package

### Presentation of the course of our replication attempt

You will find the presentation of our replication attempt at [this page](./description.md).
We mainly discuss the challenges we encountered, how we tried to tackle them, and how our expected replication results
did compare with our final replication results.

### Technical documentation

You will find the list of functions of this package in the list page, [available here](./list.md).
This section goes through the installation of the package, how to run the results, and how to delete the files.

### Tests of the package

You will find the discussion of the set of tests of this package at [this page](./tests.md).
