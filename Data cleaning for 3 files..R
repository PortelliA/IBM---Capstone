library(tidyverse)
#IBM supplied data
#The csv is a commbination of data from the website https://data.seoul.go.kr/dataList/5/literacyView.do & forecast data which I'm not sure is from
#this data encompasses data for an entire year starting from december 2017 and ending on the last day of november 2018

summary(raw_seoul_bike_sharing)
dim(raw_seoul_bike_sharing)
#Rented bike count and temperature column have NA's, course suggests because only 3% 295/8760 values are NA, to drop them.
raw_seoul_bike_sharing <- raw_seoul_bike_sharing %>% 
  drop_na(RENTED_BIKE_COUNT)
summary(raw_seoul_bike_sharing)
dim(raw_seoul_bike_sharing)
#inspect na's in TEMPERATURE column
NA_temps <- raw_seoul_bike_sharing %>%  
  filter(is.na(TEMPERATURE))
#All NA's are in Season of Summer, find the average and apply to NA's
avg_temp <-raw_seoul_bike_sharing %>% 
  filter(SEASONS == "Summer") %>% 
  summarise(avg_temperature = mean(TEMPERATURE, na.rm = TRUE))
#26.58771 is average temperature, going to apply to all NA values in column TEMPERATURE
raw_seoul_bike_sharing <- raw_seoul_bike_sharing %>% 
  mutate(TEMPERATURE = ifelse(is.na(TEMPERATURE), 26.58771, TEMPERATURE))
summary(raw_seoul_bike_sharing)
#make all column names uppercase
seoul_bike_sharing <- raw_seoul_bike_sharing %>% 
  rename_all(toupper)





#Weather API dataset
forecast_data <- main_df %>% 
  unnest(list.weather)
str(forest_data)
summary(forecast_data)

forecast_data <- forecast_data %>% 
  select(-cod, -message, -cnt, -list.dt, -id, -icon, -city.id, -city.sunrise, -city.sunset )

forecast_data <- forecast_data %>% 
  mutate(list.rain.3h = ifelse(is.na(list.rain.3h), 0, list.rain.3h))

forecast_data <- forecast_data %>% 
  rename(
    visibility = list.visibility,
    probability_of_precipitation = list.pop,
    temperature = list.main.temp,
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
    city_name = city.name,
    city_coord_lat = city.coord.lat,
    city_coord_lon = city.coord.lon,
    city_country = city.country,
    city_population = city.population,
    city_timezone = city.timezone,
  )


names(forecast_data) <-toupper(names(forecast_data))

forecast_data <- forecast_data %>% 
  separate(LIST.DT_TXT, into = c("DATE", "HOUR_INTERVAL"), sep = " ")
forecast_data <- forecast_data %>% 
  mutate(HOUR_INTERVAL = ifelse(is.na(HOUR_INTERVAL), "00:00:00", HOUR_INTERVAL)) 

forecast_data <- forecast_data %>% 
  mutate(DATE = as.Date(DATE),
         HOUR_INTERVAL = hms::as.hms(HOUR_INTERVAL))
forecast_data <- forecast_data %>%
mutate(DATE = format(DATE, "%d/%m/%Y"))

#Forecast data complete


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

#Some values have "32 (including 6 rollers)", "100(220)", "4650 (1000 E)" and 1 figure that is 400+.
#These values are not needed & I couldnt get any info on 100(220) meaning on google.
#When I looked at the 100(220) value on the main table it was in france from same system but a different city that had a value of 100, so I'll work off that number and forget the 220
#One figure that stood out was "initially 800(later 2500)" this I'll change first to 2500 then apply a gsub filter to remove all other () values.
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

bike_sharingsystems <- bike_sharingsystems %>% 
  mutate(BICYCLES = gsub("\\s*\\([^\\)]+\\)", '', BICYCLES))
summary(bike_sharingsystems)
#Previously changed all NA values to the actual letter NA as input was required
#to make it more uniform I'll change the whole column to numeric to make the value NA like the other NA's
# there is no instruction to remove the NA values so i'll leave them inside for now.
bike_sharingsystems <- bike_sharingsystems %>% 
  mutate(BICYCLES = as.numeric(BICYCLES))


write.csv(seoul_bike_sharing, "seoul_bike_sharing.csv", row.names = FALSE)
write.csv(forecast_data, "forecast_data.csv", row.names = FALSE)
write.csv(bike_sharingsystems, "bike_sharing_systems.csv", row.names = FALSE)


#SQLite load below


con <- dbConnect(RSQLite::SQLite(), dbname = "my_database.sqlite")

dbExecute(con, "CrEATE TABLE IF NOT EXISTS bike_world (
          
          COUNTRY VARCHAR(15) NOT NULL,
          CITY VARCAR(15) NOT NULL,
          SYSTEM VARCHAR(20) NOT NULL,
          BICYCLES INT
          )")

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