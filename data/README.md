# Data Access Instructions

This project uses raw electricity generation data from the ENTSO-E Transparency Platform. Due to licensing and institutional access restrictions, the original data files are not included in this repository.

To reproduce the analysis, you must manually download the raw datasets from the ENTSO-E website using the instructions below.

## Step-by-Step Download Instructions

**Note:** You must first **register for an account** on the ENTSO-E Transparency Platform and **log in using a valid institutional or university email address** before you can download data.

1. Visit: https://transparency.entsoe.eu/dashboard/show  
2. Navigate to:  
   **Generation → All Data Views → Actual Generation per Production Type**
3. In the filter menu:
   - Select **Country: Sweden**
   - Select one **Bidding Zone** at a time (e.g., SE1, SE2, SE3, SE4)
   - Set the **date range** to start with **January 1, 2022**
4. Click **Export Data** (you will need to log in using an institutional or university email address)
5. Repeat the process for each of the following:
   - All four bidding zones: **SE1**, **SE2**, **SE3**, **SE4**
   - For each year: **2022**, **2023**, and **2024**

This should result in a total of **12 CSV files** (4 areas × 3 years), each containing hourly generation data by production type.

## Data Processing

Once all files are downloaded, run the script: code/`Extra_Sweden_RDD.R`

This script processes the raw hourly data and produces the composite daily dataset used in the main analysis. The data transformation steps are primarily located in lines 1–150 of the script. The resulting output is used by `Sweden_RDD.R` and `Sweden_RDD.Rmd` to generate all tables and figures.




