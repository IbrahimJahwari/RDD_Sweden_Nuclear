# Sweden's Nuclear Energy Production

This repository contains code and documentation for a research project examining the effect of Sweden’s 2023 nuclear reclassification on electricity production. The analysis uses a regression discontinuity design (RDD) to estimate the short-run impact on nuclear output.

**See the output file for the full PDF report.** 

This report is a more academic, formal, journal-style most suitable for readers with a good foundation in econometric methods. 

## Description

On June 1, 2023, Sweden formally reclassified nuclear energy as a "fossil-free" source under its climate and energy framework. This project evaluates whether that change was associated with a measurable shift in daily nuclear electricity generation. The analysis relies on high-frequency generation data and applies a sharp RDD centered on the policy date.

## Repository Structure
```
RDD_Sweden_Nuclear/
├── code/
│   ├── Sweden_RDD.Rmd         # Main report with code, results, and text (knit to PDF)
│   ├── Sweden_RDD.R           # Standalone R script version of the analysis
│   └── Extra_Sweden_RDD.R     # Script to clean and transform raw data
│
├── data/
│   └── README.md              # Instructions for downloading raw datasets from the source
│
├── output/
│   └── Sweden_RDD.pdf         # Final PDF version of the report
│
├── LICENSE                    # MIT License governing reuse and distribution
└── README.md                  # Project overview and reproduction instructions
```

## How to Reproduce

1. Refer to `data/README.md` for instructions on accessing the raw datasets from the ENTSO-E Transparency Platform.
2. Run `Extra_Sweden_RDD.R` to clean and merge the raw files.
3. Use `Sweden_RDD.R` or knit `Sweden_RDD.Rmd` to reproduce the analysis and results.

## Software Requirements

This project uses R (version 4.0 or later) and the following R packages: `rdrobust`, `rddensity`, `fixest`, `dplyr`, `ggplot2`, `lubridate`, `readr`,`tidyr`

## Potential Improvements

Looking back, a central issue was the assumption that the policy would have an immediate effect on nuclear electricity output. In reality, its impact is more plausibly felt through investment decisions, affecting capacity over the long run rather than short-run production. This weakens the case for using a regression discontinuity design, especially with time as the running variable. A difference-in-differences (DiD) approach, perhaps using a country like Finland as a control, would likely have been more appropriate. It would better match the policy’s timeline and help account for confounding seasonal and weather-related variation in electricity generation.

## License

This project is released under the MIT License. See the `LICENSE` file for details.

## Author

Ibrahim Al Jahwari

Contact: ibrahim.aljahwari23.19@takatufscholars.om

