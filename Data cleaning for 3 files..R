library(tidyverse)


forecast_data <- main_df %>% 
  unnest(list.weather)
str(forest_data)
summary(forecast_data)

forecast_data <- forcast_data %>% 
  select(-cod, -message, -cnt, -list.dt, -id, -icon, -city.id, -city.sunrise, -city.sunset )

forecast_data <- forecast_data %>% 
  mutate(list.rain.3h = ifelse(is.na(list.rain.3h), 0, list.rain.3h))

forecast_data <- forecast_data %>% 
  rename(
    visibility = list.visibility,
    probability_of_precipitation = list.pop,
    temp = list.main.temp,
    feels_like = list.main.feels_like,
    temp_min = list.main.temp_min,
    temp_max = list.main.temp_max,
    pressure = list.main.pressure,
    grnd_level = list.main.grnd_level,
    humidity = list.main.humidity,
    temp_kf = list.main.temp_kf,
    clouds_all = list.clouds.all,
    wind_speed = list.wind.speed,
    wind_deg = list.wind.deg,
    wind_gust = list.wind.gust,
    sys_pod = list.sys.pod,
    rain_over_3h = list.rain.3h,
  )

forecast_data$city.sunrise <- as.POSIXct(forecast_data$city.sunrise, origin="1970-01-01", tz="UTC")
forecast_data$city.sunset <- as.POSIXct(forecast_data$city.sunset, origin="1970-01-01", tz="UTC")

names(forecast_data) <-toupper(names(forecast_data))


str(forecast_data)

forecast_data <- expanded_df %>% 
  separate(LIST.DT_TXT, into = c("DATE", "HOUR_INTERVAL"), sep = " ")

forecast_data <- forecast_data %>% 
  mutate(
    DATE = as.Date(DATE),
    HOUR_INTERVAL = hms::as.hms(HOUR_INTERVAL))



#clean table1(rideshare data pulled from wikipedia)
# this project was created sometime ago where the data table that I pulled from the internet has an additional column listing how many bicycles were in the network. 
#because of this I need to use a supplied csv from IBM that includes this
bike_sharingsystems <-read.csv("raw_bike_sharing_systems.csv", stringsAsFactors = FALSE)


#Rename the column headers to capital + only need the 4 columns
names(bike_sharingsystems) <-toupper(names(bike_sharingsystems))
bike_sharingsystems <- bike_sharingsystems %>% 
  select(COUNTRY, CITY, SYSTEM,BICYCLES)

#Within the column, there are alot of the [reference links].
bike_sharingsystems <- bike_sharingsystems %>% 
  mutate_all(~ gsub("\\[.*?\\]", "", .))

#Within the BICYCLES column I have some values with (content) within them. First I want to look at them then choose what I want to do with them after.
unique(bike_sharingsystems$BICYCLES)

#So some values have "32 (including 6 rollers)", "100(220)", "4650 (1000 E)" and 1 figure that is 400+.
#These values are not needed & I couldnt get any info on 100(220) meaning on google.
#When I looked at the 100(220) value on the main table it was in france from same system but a different city that had a value of 100, so I'll work off that number and forget the 220
#BUT one figure that stood out was "initially 800(later 2500)" this I'll change first to 2500 then apply a gsub filter to remove all other () values.
update_value <- function(value) {
  if (is.na(value)){
    return(NA)
  } else if (value == "initially 800 (later 2500)") {
    return("2500")
  } else if (value == "400+") {
    return("400")
  } else if (value == "") {
    return("NA")
  } else {
    return(value)
  }
}
bike_sharingsystems <- bike_sharingsystems %>% 
  mutate(BICYCLES = sapply(BICYCLES, update_value))
##alot of code for 1 change, the issue is I tried to apply this with just the if value = , return =
#But the column has NA's it, requiring that additional line prior
bike_sharingsystems <- bike_sharingsystems %>% 
  mutate(BICYCLES = gsub("\\s*\\([^\\)]+\\)", '', BICYCLES))
## I have saved that code chunk saved on my cheatsheet, one day i'll memorise it all
summary(bike_sharingsystems)


## So if you noticed before, I changed all NA values to the actual letter NA
#to make it more uniform I'll change the whole column to numeric to make the value NA like the other NA's
# there is no instruction to remove the NA values so i'll leave them inside for now.
#The other columns are characters so they are fine
bike_sharingsystems <- bike_sharingsystems %>% 
  mutate(BICYCLES = as.numeric(BICYCLES))




# Now last sheet to clean, which is a ridesharing information sheet based in Seoul
#The csv is from the website https://data.seoul.go.kr/dataList/5/literacyView.do with data from Open Weather API combined
#this data encompasses data for an entire year starting from december 2017 and ending on the last day of november 2018
bike_sharing_df <- read.csv("raw_seoul_bike_sharing.csv")
summary(bike_sharing_df)
str(bike_sharing_df)
#Date column is stored as chr, lets change that first, it was stored as day/month/year
bike_sharing_df$Date <- as.Date(bike_sharing_df$Date, format = "%d/%m/%Y")
#There is a date column that is saved as character which needs to be converted
#In the summary there is NA's in temperature(11) & rented_bike_count column(295)
NA_temp <- bike_sharing_df %>% 
  filter(is.na(TEMPERATURE))
#The table shows the 11 values being all in the summer period, so ill get the average temp in summer and apply to the NA values
summer_data <- bike_sharing_df %>% 
  filter(SEASONS == "Summer")
average_summer_temp <- mean(summer_data$TEMPERATURE, na.rm = TRUE)
#Apply the mean to main data table
bike_sharing_df <- bike_sharing_df %>% 
  mutate(TEMPERATURE = ifelse(is.na(TEMPERATURE), average_summer_temp, TEMPERATURE))

#Lets check NA's in rented bike count
NA_bike <-bike_sharing_df %>% 
  filter(is.na(RENTED_BIKE_COUNT))
#I cant believe this, some of the NA values fall in November which is now, around the dates of my OpenWeatherAPI data.
#This is a complicated I need to group by time of day to make more appropriate
november_data <- bike_sharing_df %>%
  filter(format(Date, "%Y-%m") == "2018-11")

monthly_average_counts <- November_data %>%
  group_by(Hour) %>%
  summarise(avg_rented_bike_count = round(mean(RENTED_BIKE_COUNT, na.rm = TRUE)))


november_bike_data <- november_data %>%
  left_join(monthly_average_counts, by = "Hour") %>%
  mutate(RENTED_BIKE_COUNT = ifelse(is.na(RENTED_BIKE_COUNT) & format(Date, "%Y-%m") == "2018-11", avg_rented_bike_count, RENTED_BIKE_COUNT)) %>%
  select(-avg_rented_bike_count)
#Took me 30minutes to figure out how to use this I'll need to practice this more


#Because the forecast data I have is in 3 hour blocks im going to do the same to the data in this sheet so I can do some modeling later
create_3hr_interval <- function(hour) {
  return((hour %/% 3) * 3)
}
  


november_bike_data <- november_bike_data %>% 
  mutate(HOUR_INTERVAL = create_3hr_interval(Hour)) %>% 
  group_by(Date, HOUR_INTERVAL) %>% 
  summarise(
               RENTED_BIKE_COUNT = round(sum(RENTED_BIKE_COUNT, na.rm = TRUE)),
               RAINFALL = mean(RAINFALL, na.rm = TRUE),
               TEMPERATURE = mean(HUMIDITY, na.rm = TRUE),
               WIND_SPEED = mean(WIND_SPEED, na.rm = TRUE),
               VISIBILITY = round(mean(Visibility, na.rm = TRUE)),
               DEW_POINT_TEMPERATURE = mean(DEW_POINT_TEMPERATURE, na.rm = TRUE),
               SOLAR_RADIATION = mean(SOLAR_RADIATION, na.rm = TRUE),
               SNOWFALL = mean(Snowfall, na.rm = TRUE)
             )


str(november_bike_data)           
#too many decimal places, I'll work with only 2
november_bike_data <- november_bike_data %>% 
  mutate_if(is.numeric, ~ round(., 2))


# this below function is stating, the value has to be 2 values, if it isnt it "pads" the beginning with a 0.
#then after the next line adds the minutes and seconds. Its not fully needed but because it was like that for the forecast_data table I thought it should be uniform.
november_bike_data <- november_bike_data %>% 
  mutate(HOUR_INTERVAL = str_pad(HOUR_INTERVAL, width = 2, pad = "0"),
         HOUR_INTERVAL = paste0(HOUR_INTERVAL, ":00:00"))

#Changes column to desired 
november_bike_data <- november_bike_data %>% 
  mutate(
    Date = as.Date(Date),
    HOUR_INTERVAL = hms::as.hms(HOUR_INTERVAL)
  )
  
november_bike_data <- november_bike_data %>% 
  rename(DATE = Date)

str(november_bike_data)
#I need to change my TEMPERATURE from Fahrenheit to Celsius, after a google I found 
# https://cran.r-project.org/web/packages/weathermetrics/weathermetrics.pdf pretty sure this will be helpful in the future!
install.packages("weathermetrics")
library(weathermetrics)
#
november_bike_data <- november_bike_data %>% 
  mutate(TEMPERATURE = round(fahrenheit.to.celsius(TEMPERATURE), 2))



#And that concludes the data wrangliing, took abit of time but I feel like compared to a previous project this went by much quicker which is a good sign.
#I'll save the 3 files being november_bike_data, forecast_data & bike_sharingsystems

head(november_bike_data)
head(forecast_data)

november_bike_data <- november_bike_data %>% 
  mutate(
    VISIBILITY = as.integer(VISIBILITY),
    RENTED_BIKE_COUNT = as.integer(RENTED_BIKE_COUNT)
  )


#With that all the data is uniform so I can begin exploring the data and then do some linear regression!
write.csv(november_bike_data, "november_seoul_bike_data.csv", row.names = FALSE)
write.csv(forecast_data, "forecast_data.csv", row.names = FALSE)
write.csv(bike_sharingsystems, "bike_sharing_systems.csv", row.names = FALSE)


#SQLite load below


con <- dbConnect(RSQLite::SQLite(), dbname = "my_database.sqlite")

dbExecute(con, "CREATE TABLE IF NOT EXISTS nvmbr_seoul (
          ROW_ID INTEGER NOT NULL,
          DATE DATE NOT NULL,
          HOUR_INTERVAL TEXT, VALUE INTEGER NOT NULL,
          RENTED_BIKE_COUNT INT NOT NULL,
          RAINFALL NUMERIC NOT NULL,
          TEMPERATURE NUMERIC NOT NULL,
          WIND_SPEED NUMERIC NOT NULL,
          VISIBILTY INT NOT NULL,
          DEW_POINT_TEMPERATURE NUMERIC NOT NULL,
          SOLAR_RADIATION NUMERIC NOT NULL,
          SNOWFALL NUMERIC NOT NULL,
          PRIMARY KEY(ROW_ID)
)")

dbExecute(con, "CREATE TABLE IF NOT EXISTS forecast (
          ROW_ID INTEGER NOT NULL,
          MAIN VARCHAR(10) NOT NULL,
          DESCRIPTION VARCHAR(15) NOT NULL,
          VISIBILITY INTEGER NOT NULL,
          PROBABILITY_OF_PRECIPITATION NUMERIC NOT NULL,
          DATE DATE NOT NULL,
          HOUR_INTERVAL TEXT, VALUE INTEGER NOT NULL,
          TEMP NUMERIC NOT NULL,
          FEELS_LIKE NUMERIC NOT NULL,
          TEMP_MIN NUMERIC NOT NULL,
          TEMP_MAX NUMERIC NOT NULL,
          PRESSURE INTEGER NOT NULL,
          MAIN_SEA_LEVEL INTEGER NOT NULL,
          GRND_LEVEL INTEGER NOT NULL,
          HUMIDITY INTEGER NOT NULL,
          TEMP_KF NUMERIC NOT NULL,
          CLOUDS_ALL INTEGER NOT NULL,
          WIND_SPEED NUMERIC NOT NULL,
          WIND_DEG INTEGER NOT NULL,
          WIND_GUST NUMERIC NOT NULL,
          SYS_POD VARCHAR(1) NOT NULL,
          RAIN_OVER_3H NUMERIC NOT NULL,
          CITY_NAME VARCHAR(15) NOT NULL,
          CITY_COORD_LAT NUMERIC NOT NULL,
          CITY_COORD_LON NUMERIC NOT NULL,
          CITY_COUNTR VARCHAR(2) NOT NULL,
          CITY_POPULATION INTEGER NOT NULL,
          CITY_TIMEZONE INTEGER NOT NULL,
          PRIMARY KEY(ROW_ID)
          )")

dbWriteTable(con, "nvmbr_seoul", november_seoul_bike_data, overwrite = TRUE)
dbWriteTable(con, "forecast", forecast_data, overwrite = TRUE)






#creating datetime column without year variable so I can merge data for regression
seoul_data$DATE <- as.Date(seoul_data$DATE, "%d/%m/%Y")
seoul_data <- seoul_data %>% 
  mutate(datetime = as.POSIXct(as.character(paste(DATE, HOUR_INTERVAL), format= "%Y-%m-%d %h:%M:%S")))
seoul_data$datetime <- substr(seoul_data$datetime, 6, 16)

november_seoul_bike_data$DATE <- as.Date(november_seoul_bike_data$DATE, "%d/%m/%Y")

november_seoul_bike_data <- november_seoul_bike_data %>% 
  mutate(datetime = as.POSIXct(as.character(paste(DATE, HOUR_INTERVAL), format= "%Y-%m-%d %h:%M:%S")))
november_seoul_bike_data$datetime <- substr(november_seoul_bike_data$datetime, 6, 16)


#Merge
forecast_model_data <- merge(november_seoul_bike_data, seoul_data, by="datetime")
