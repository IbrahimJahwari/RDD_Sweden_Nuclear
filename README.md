# RDD_Sweden_Nuclear
Background Information:
This is a Regression Discontinuity Design (RDD) study of Swedish nuclear energy production amid an energy policy change in June 2023. The implemented policy broadened the focus of energy production from 'renewable' to 'clean', thus allowing for more nuclear production. I aim to study the statistical and economic impacts of this policy change utilizing RDD.

File Directories:
- The "Sweden_RDD.pdf" file is the final report in pdf form;
- The "Sweden_RDD.rmd" file is the r markdown file that was used to generate the fina report (knitted to pdf);
- The "Sweden_RDD.R" file is an r script that runs contains the main RDD analysis conducted (as well as some data construction, EDA and visualizations);
- The "Extra_Sweden_RDD.R" file is an r sctipt that contains supplemental R code that loads, cleans, merges, and pre-processes the orignial raw datasets.

Data Sources & Reproducibility:
The data used in this study are obtained from the European Network of Transmission System Operators for Electricity (ENTSO-E) Transparency Platform, (available at https://transparency.entsoe.eu/dashboard/show) which provides publicly accessible electricity market and generation data across Europe. The data is accessible to all and downloadable to those that log-in with a valid istitutional email address. Once logged in, the "Extra_Sweden_RDD.R" file provides step by step instructions on downloading the datasets -- allowing for complete reproducibility of the analysis! The "Sweden_RDD.R" file uses the generated cleaned and merged dataset (Sweden_RDD.csv) to run the core RDD analysis. 

Acknowledgements:
This work was initially conducted as part of an undergradute course ECON32252 Econometrics and Data Science (Professor Ralf Becker) at The University of Manchester, alongside fellow students Aurick Angsana and Yousuf Rashid in March-April 2025. Since then, I have substantially expanded the work to incorporate more advanced analysis. 
