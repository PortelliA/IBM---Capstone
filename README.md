# Seoul Bike Data Analysis

## Overview
This project, a **capstone project in an IBM Data Analysis with Excel & R**, involves a comprehensive analysis using web scraping, data cleaning, rSQLite EDA, ggplot visualization, and various regression models to understand bike usage patterns in Seoul.

## Key Insights from Seoul Bike Data
- **Peak Usage**: Highest bike usage from 6pm to 9pm; lowest from 3am to 6am.
- **Morning Peak**: Significant usage between 6am and 9am, likely due to commuting.
- **Active Seasons**: Summer most active for bike sharing; Winter least.
- **Autumn Variability**: Most fluctuations in patterns, highest coefficient absolute value.
- **Temperature Impact**: Highest bike usage recorded in the temperature range of 15-30 degrees.
- **Weather Impact**:
  - Summer: Highest average temperature, humidity, and dew point.
  - Winter: Lowest temperature, highest wind speed, and lowest solar radiation.
- **Rainfall and Snowfall**:
  - No rainfall: 8,257 hours
  - Light rainfall: 457 hours
  - Moderate rainfall: 0.58 hours
  - Heavy rainfall: 13 hours
  - Snowfall: 443 hours
  - **Holidays in Seoul**: - Holidays generally lead to a decrease in bike usage, except during Autumn, when there's an increase. Seoul observes 18 holidays annually.

## Specific Dates and Events
- **Chuseok (September 23)**: Significant holiday with high bike usage.
- **Hangul Day (October 3 and 9)**: Celebrates the creation of the Korean alphabet, showing high bike usage.

## Forecast Data Insights
- **Temperature and "Feels Like"**:
  - Occurrences where average temperature exceeds "feels like" temperature due to factors like humidity and air pressure.
- **Weather Patterns**: Highest occurrence of "clear sky" during the forecast period.
- **Average Ranges**:
  - Temperature: 8.7-12.73 degrees Celsius.
  - Humidity: 24.13%-47%.
  - Wind speed: 1.24 to 3.92 m/s.

## Excel Review, Data Cleaning, Descriptive Statistics, and Regression Analysis with XLminer

### Excel Review and Data Cleaning
- **Techniques Used**:
  - Seasonal Averages: Calculated using `=AVERAGEIFS`.
  - Time Conversion: Numeric to time format using `=TEXT`.
  - Humidity Adjustment: Decimal adjustment using `=E2 / 100`.
  - Column Alignment: Corrected data types, bold headers, and cell formatting.
- **Dataset Used**: Data with filled missing values for Autumn bike counts to retain comparative size.

### Descriptive Statistics
- Measures such as mean, median, mode, variance, and standard deviation were calculated for each season and the entire year.
- Pivot tables created to show aggregations from different viewpoints.

### Regression Analysis with XLminer

#### Temperature's Relationship with Ride Count
- **rSquared**: 31.5% variability explained by temperature.
- **Coefficients**: Estimated ride count of 348 at 0 degrees, with an increase of 29.95 per degree rise.

#### Rainfall's Relationship with Ride Count
- **rSquared**: 1.6% variability explained by rainfall.
- **Impact**: For every mm increase of rain, ride count drops by roughly 72.

#### Wind Speed's Relationship with Rainfall
- **rSquared**: 0.0387% variability explained by rainfall. Not statistically significant.

#### Humidity's Relationship with Rainfall
- **rSquared**: 5.59% variability explained by rainfall.
- **Impact**: Humidity increases by 4.27% for every 1mm increase of rainfall.

## Overall Model Performance
- **rSquared Value**: 77.8% correlation between rented bike counts and weather variables.
- **RMSE**: 8.27%.
- **Key influences**: While temperature might seem like the primary factor, variations in rainfall, humidity, and dew point temperature have a more significant impact when deviating from the average or expected levels.

## Forecast data with Predicted Bike Usage

Here are the results of the bike usage range of the Predicted rented bike counts based on the previous Model, under it are normalized bike counts from Autumn that was pulled from that said Model's dataset used to get my previous results, showing relatively close results.

### Forecasted Rented Bike Counts:
- **Minimum**: 0.00000
- **1st Quartile**: 0.01029
- **Median**: 0.18627
- **Mean**: 0.26970
- **3rd Quartile**: 0.41391
- **Maximum**: 0.92155

### Normalized Rented Bike Counts (Autumn):
- **Minimum**: 0.0000
- **1st Quartile**: 0.1215
- **Median**: 0.2393
- **Mean**: 0.2589
- **3rd Quartile**: 0.3566
- **Maximum**: 0.9274

The relatively close results, particularly in the mean and median values, indicate good alignment between the predictions and the actual data. However, there is some variance due to the smaller sample size, which increases the room for residuals.
