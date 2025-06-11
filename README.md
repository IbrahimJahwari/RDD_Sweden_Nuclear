# RDD_Sweden_Nuclear

This repository contains code and documentation for a research project examining the effect of Sweden’s 2023 nuclear reclassification on electricity production. The analysis uses a regression discontinuity design (RDD) to estimate the short-run impact on nuclear output.

## Repository Structure
RDD_Sweden_Nuclear/
├── code/
│ ├── Sweden_RDD.Rmd # Main R Markdown report
│ ├── Sweden_RDD.R # Analysis script
│ └── Extra_Sweden_RDD.R # Data processing script
├── data/
│ └── README.md # Instructions for obtaining raw data
├── output/
│ ├── Sweden_RDD.pdf # Knitted PDF report
│ └── Sweden_RDD.html # Knitted HTML report
├── LICENSE # MIT license
└── README.md # Project overview and usage

## Description

On June 1, 2023, Sweden formally reclassified nuclear energy as a "fossil-free" source under its climate and energy framework. This project evaluates whether that change was associated with a measurable shift in daily nuclear electricity generation. The analysis relies on high-frequency generation data and applies a sharp RDD centered on the policy date.

## How to Reproduce

1. Refer to `data/README.md` for instructions on accessing the raw datasets from the ENTSO-E Transparency Platform.
2. Run `Extra_Sweden_RDD.R` to clean and merge the raw files.
3. Use `Sweden_RDD.R` or knit `Sweden_RDD.Rmd` to reproduce the analysis and results.
4. Outputs will be saved to the `output/` directory.

## Software Requirements

This project uses R (version 4.0 or later) and the following R packages:
- `rdrobust`
- `rddensity`
- `fixest`
- `dplyr`
- `ggplot2`
- `lubridate`
- `readr`
- `tidyr`

## License

This project is released under the MIT License. See the `LICENSE` file for details.
