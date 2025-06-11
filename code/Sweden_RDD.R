rm(list = ls())

# THIS FILE IS TO RUN THE MAIN RDD ANALYSIS OF SWEDEN'S AGGREGATED DAILY ENERGY PRODUCTION MEASUREMENTS 2022-2024 (JUNE 2023 POLICY) -- as well as some EDA and visualizations

#These are the used libraries in this file. Run install.packages("library_name") to install any of the libraries if needed
library(dplyr)
library(ggplot2)
library(lubridate)
library(rdrobust)
library(fixest)
library(patchwork)

#this uses the aggregated compiled dataset (Sweden_RDD.csv") that was constructed in the "Extra_Sweden_RDD.R" file. Refer to that if needed. 
# (adjust working directory and filepath as needed)
setwd("~/filepath")
sweden_rdd <- read.csv("Sweden_RDD.csv")

# Convert Date to Date object and add time variables
sweden_rdd <- sweden_rdd %>%
  dplyr::mutate(
    Date = as.Date(Date),
    Days = as.numeric(difftime(Date, as.Date("2022-01-01"), units = "days")),
    Post_Treatment = ifelse(Date >= as.Date("2023-06-01"), 1, 0)
  )

# Define cutoff for RDD
cutoff_day <- as.numeric(difftime(as.Date("2023-06-01"), as.Date("2022-01-01"), units = "days"))


#DESCRIPTIVE STATS
    # Summarize production statistics for key energy types
    summary_stats <- sweden_rdd %>%
      dplyr::summarise(across(
        c(Nuclear, Fossil, Hydro, Wind, Solar),
        list(mean = ~mean(.), sd = ~sd(.), min = ~min(.), max = ~max(.))
      )) %>%
      tidyr::pivot_longer(everything(), names_to = c("Energy", ".value"), names_sep = "_")
    
    print(summary_stats)



#MAIN RDD ANALYSIS AND ROBUSTNESS CHECKS   
    # Run main RDD estimate (Nuclear as outcome)
    rdd_nuclear <- rdrobust::rdrobust(
      y = sweden_rdd$Nuclear,
      x = sweden_rdd$Days,
      c = cutoff_day
    )
    summary(rdd_nuclear)
    
    # Bandwidth sensitivity
    rdd_nuclear_bw_30 <- rdrobust::rdrobust(sweden_rdd$Nuclear, sweden_rdd$Days, c = cutoff_day, h = 30)
    rdd_nuclear_bw_90 <- rdrobust::rdrobust(sweden_rdd$Nuclear, sweden_rdd$Days, c = cutoff_day, h = 90)
    
    summary(rdd_nuclear_bw_30)
    summary(rdd_nuclear_bw_90)
    
    # Polynomial order robustness
    rdd_nuclear_linear <- rdrobust::rdrobust(sweden_rdd$Nuclear, sweden_rdd$Days, c = cutoff_day, p = 1)
    rdd_nuclear_quadratic <- rdrobust::rdrobust(sweden_rdd$Nuclear, sweden_rdd$Days, c = cutoff_day, p = 2)
    rdd_nuclear_cubic <- rdrobust::rdrobust(sweden_rdd$Nuclear, sweden_rdd$Days, c = cutoff_day, p = 3)
    
    summary(rdd_nuclear_linear)
    summary(rdd_nuclear_quadratic)
    summary(rdd_nuclear_cubic)
    
    # Placebo outcomes for other energy types
    rdd_fossil <- rdrobust::rdrobust(sweden_rdd$Fossil, sweden_rdd$Days, c = cutoff_day)
    rdd_hydro  <- rdrobust::rdrobust(sweden_rdd$Hydro,  sweden_rdd$Days, c = cutoff_day)
    rdd_wind   <- rdrobust::rdrobust(sweden_rdd$Wind,   sweden_rdd$Days, c = cutoff_day)
    rdd_solar  <- rdrobust::rdrobust(sweden_rdd$Solar,  sweden_rdd$Days, c = cutoff_day)
    
    summary(rdd_fossil)
    summary(rdd_hydro)
    summary(rdd_wind)
    summary(rdd_solar)
    
    # Placebo cutoff tests (pre and post policy)
    pre_policy_data <- sweden_rdd %>% dplyr::filter(Date < as.Date("2023-06-01"))
    post_policy_data <- sweden_rdd %>% dplyr::filter(Date > as.Date("2023-06-01"))
    
    pre_cutoff_day <- as.numeric(difftime(as.Date("2022-06-01"), as.Date("2022-01-01"), units = "days"))
    post_cutoff_day <- as.numeric(difftime(as.Date("2024-06-01"), as.Date("2022-01-01"), units = "days"))
    
    rdd_pre <- rdrobust::rdrobust(pre_policy_data$Nuclear, pre_policy_data$Days, c = pre_cutoff_day)
    rdd_post <- rdrobust::rdrobust(post_policy_data$Nuclear, post_policy_data$Days, c = post_cutoff_day)
    
    summary(rdd_pre)
    summary(rdd_post)
    
    # Seasonality controls using month fixed effects and Fourier terms
    sweden_rdd <- sweden_rdd %>%
      dplyr::mutate(
        Month = factor(lubridate::month(Date)),
        Cos_Yearly = cos(2 * pi * Days / 365),
        Sin_Yearly = sin(2 * pi * Days / 365)
      )
    
    rdd_seasonality <- fixest::feols(
      Nuclear ~ Post_Treatment + Cos_Yearly + Sin_Yearly | Month,
      data = sweden_rdd
    )
    summary(rdd_seasonality)
    
    # Additional fixed effects model with energy controls
    fe_model <- fixest::feols(
      Nuclear ~ Post_Treatment + Fossil + Hydro + Wind + Solar | Month,
      data = sweden_rdd
    )
    summary(fe_model)


    
#VIZUALIZATIONS! 
  # 1-Side-by-side plots of daily and monthly energy production by energy type  
    # Plot daily electricity production over time
    plot_data <- sweden_rdd %>%
      dplyr::select(Date, Nuclear, Fossil, Hydro, Wind, Solar) %>%
      tidyr::pivot_longer(cols = -Date, names_to = "Energy", values_to = "Production")
    
    daily_plot <- ggplot2::ggplot(plot_data, ggplot2::aes(x = Date, y = Production, color = Energy)) +
      ggplot2::geom_line(alpha = 0.7) +
      ggplot2::labs(
        title = "Daily Electricity Production by Energy Type",
        x = "Date", y = "Production (MW)"
      ) +
      ggplot2::theme_minimal()
    
    # Plot monthly averages
    monthly_avg <- sweden_rdd %>%
      dplyr::mutate(Month = lubridate::floor_date(Date, "month")) %>%
      dplyr::group_by(Month) %>%
      dplyr::summarise(across(c(Nuclear, Fossil, Hydro, Wind, Solar), mean))
    
    monthly_avg_long <- monthly_avg %>%
      tidyr::pivot_longer(-Month, names_to = "Energy", values_to = "AvgProduction")
    
    monthly_plot <- ggplot2::ggplot(monthly_avg_long, ggplot2::aes(x = Month, y = AvgProduction, color = Energy)) +
      ggplot2::geom_line(size = 1) +
      ggplot2::labs(
        title = "Monthly Electricity Production by Energy Type",
        x = "Month", y = "Average Production (MW)"
      ) +
      ggplot2::theme_minimal()
    
    # Combine plots
    daily_plot + monthly_plot        
    
# 2-RDD smoothed plot
  ggplot2::ggplot(sweden_rdd, ggplot2::aes(x = Days, y = Nuclear)) +
    ggplot2::geom_point(color = "blue") +
    ggplot2::geom_smooth(method = "loess", span = 0.2, color = "red") +
    ggplot2::geom_vline(xintercept = cutoff_day, linetype = "solid", color = "black") +
    ggplot2::labs(
      title = "RDD on Nuclear Energy Production",
      x = "Days since Jan 1, 2022",
      y = "Nuclear Energy Production (MW)"
    ) +
    ggplot2::theme_minimal()

# 3-Formal RD plot
  rdrobust::rdplot(
    y = sweden_rdd$Nuclear,
    x = sweden_rdd$Days,
    c = cutoff_day,
    h = 45,
    title = "RDD on Nuclear Energy Production",
    x.label = "Days since Jan 1, 2022",
    y.label = "Nuclear Energy Production (MW)"
  )

##   
  
