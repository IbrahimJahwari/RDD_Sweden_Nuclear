rm(list = ls())

# THIS FILE IS TO DOWNLOAD, LOAD, CLEAN AND PROCESS DATA TO GET SWEDEN'S AGGREGATED DAILY ENERGY PRODUCTION MEASUREMENTS 2022-2024

#These are the used libraries in this file. Run install.packages("library_name") to install any of the libraries if needed
library(dplyr)
library(stringr)
library(lubridate)
library(tidyverse)
library(zoo)

# Load datasets
  # these datasets are gathered from the website: https://transparency.entsoe.eu/dashboard/show. To download datasets:
    # use dashboard to go to generation > all data views > actual generation per production type > select sweden (start with SE1) > select date (start with Jan1 2022 > export data. 
      # this will give you the hourly production rates for different energy types across Area SE1 of sweden for all of 2022. 
    # Repeat to get the different areas (SE2, SE3, SE4), and the different years (2023, 2024). 
    # Hence, there should be 4 datasets per year (one for each area) and so 12 in total. 

# Loading the 12 datasets (adjust to your filepath and filenames as needed)
setwd("~/Desktop/GitHub/RDD_Sweden_Nuclear/datas")
sweden_SE1_22 <- read.csv("sweden_SE1_22.csv")
sweden_SE2_22 <- read.csv("sweden_SE2_22.csv")
sweden_SE3_22 <- read.csv("sweden_SE3_22.csv")
sweden_SE4_22 <- read.csv("sweden_SE4_22.csv")

sweden_SE1_23 <- read.csv("sweden_SE1_23.csv")
sweden_SE2_23 <- read.csv("sweden_SE2_23.csv")
sweden_SE3_23 <- read.csv("sweden_SE3_23.csv")
sweden_SE4_23 <- read.csv("sweden_SE4_23.csv")

sweden_SE1_24 <- read.csv("sweden_SE1_24.csv")
sweden_SE2_24 <- read.csv("sweden_SE2_24.csv")
sweden_SE3_24 <- read.csv("sweden_SE3_24.csv")
sweden_SE4_24 <- read.csv("sweden_SE4_24.csv")


# Define function to clean and format each raw dataset
clean_data <- function(df) {
  df <- df %>%
    dplyr::mutate(
      Date = as.Date(stringr::str_sub(MTU, 1, 10), format = "%d.%m.%Y")  # extract and convert date from MTU string
    ) %>%
    dplyr::select(-MTU) %>%  # remove original MTU column
    dplyr::mutate(
      across(where(is.character), ~ ifelse(. %in% c("n/e", "N/A"), "0", .))  # replace missing entries
    ) %>%
    dplyr::mutate(
      across(-c(Area, Date), as.numeric)  # convert numeric fields
    )
  return(df)
}

# Define function to aggregate daily data into broader energy groups
aggregate_energy <- function(daily_df) {
  daily_df <- daily_df %>%
    dplyr::select(
      Date,
      Biomass = Biomass...Actual.Aggregated..MW.,
      Fossil_Brown_Coal = Fossil.Brown.coal.Lignite...Actual.Aggregated..MW.,
      Fossil_Coal_Gas = Fossil.Coal.derived.gas...Actual.Aggregated..MW.,
      Fossil_Gas = Fossil.Gas...Actual.Aggregated..MW.,
      Fossil_Hard_Coal = Fossil.Hard.coal...Actual.Aggregated..MW.,
      Fossil_Oil = Fossil.Oil...Actual.Aggregated..MW.,
      Fossil_Oil_Shale = Fossil.Oil.shale...Actual.Aggregated..MW.,
      Fossil_Peat = Fossil.Peat...Actual.Aggregated..MW.,
      Energy_Storage = Energy.storage...Actual.Aggregated..MW.,
      Geothermal = Geothermal...Actual.Aggregated..MW.,
      Hydro_Reservoir = Hydro.Water.Reservoir...Actual.Aggregated..MW.,
      Hydro_Run_River = Hydro.Run.of.river.and.poundage...Actual.Aggregated..MW.,
      Marine = Marine...Actual.Aggregated..MW.,
      Nuclear = Nuclear...Actual.Aggregated..MW.,
      Other = Other...Actual.Aggregated..MW.,
      Other_Renewable = Other.renewable...Actual.Aggregated..MW.,
      Waste = Waste...Actual.Aggregated..MW.,
      Wind_Offshore = Wind.Offshore...Actual.Aggregated..MW.,
      Wind_Onshore = Wind.Onshore...Actual.Aggregated..MW.,
      Solar = Solar...Actual.Aggregated..MW.
    ) %>%
    dplyr::mutate(
      Fossil = rowSums(dplyr::select(., dplyr::starts_with("Fossil_")), na.rm = TRUE),
      Hydro = rowSums(dplyr::select(., dplyr::starts_with("Hydro_")), na.rm = TRUE),
      Wind = Wind_Offshore + Wind_Onshore,
      Other = Other + Other_Renewable
    ) %>%
    dplyr::select(Date, Biomass, Fossil, Energy_Storage, Geothermal, Hydro, Marine, Nuclear, Other, Waste, Wind, Solar)
  return(daily_df)
}

# Clean and process each raw dataset into daily-level aggregates
dataset_names <- c(
  "sweden_SE1_22", "sweden_SE2_22", "sweden_SE3_22", "sweden_SE4_22",
  "sweden_SE1_23", "sweden_SE2_23", "sweden_SE3_23", "sweden_SE4_23",
  "sweden_SE1_24", "sweden_SE2_24", "sweden_SE3_24", "sweden_SE4_24"
)

daily_data_list <- lapply(dataset_names, function(name) {
  df <- get(name)
  df_cleaned <- clean_data(df)
  
  df_daily <- df_cleaned %>%
    dplyr::group_by(Date) %>%
    dplyr::summarise(across(where(is.numeric), sum, na.rm = TRUE))
  
  aggregate_energy(df_daily)
})

# Combine regional datasets into national daily datasets for each year
datasets_22 <- dplyr::bind_rows(daily_data_list[1:4]) %>%
  dplyr::group_by(Date) %>%
  dplyr::summarise(across(where(is.numeric), sum, na.rm = TRUE))

datasets_23 <- dplyr::bind_rows(daily_data_list[5:8]) %>%
  dplyr::group_by(Date) %>%
  dplyr::summarise(across(where(is.numeric), sum, na.rm = TRUE))

datasets_24 <- dplyr::bind_rows(daily_data_list[9:12]) %>%
  dplyr::group_by(Date) %>%
  dplyr::summarise(across(where(is.numeric), sum, na.rm = TRUE))

# Combine all years into aggregated dataset used for analysis
Sweden_RDD <- dplyr::bind_rows(datasets_22, datasets_23, datasets_24) %>%
  dplyr::group_by(Date) %>%
  dplyr::summarise(across(where(is.numeric), sum, na.rm = TRUE))

# Inspect the generated dataset
print(head(Sweden_RDD))
print(summary(Sweden_RDD))
print(colnames(Sweden_RDD))

# Export dataset
write.csv(Sweden_RDD, file = "~/Desktop/GitHub/RDD_Sweden_Nuclear/data/Sweden.RDD.csv", row.names = FALSE) #adjust the file directory as needed
  # This is the generated dataset that is all that is used in the "Sweden_RDD.R" file, which runs the main RDD analysis