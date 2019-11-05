#install.packages("rgdal")
#install.packages("leaflet")
#install.packages("shinydashboard")
#install.packages("DT")
#install.packages("rgeos")
#install.packages("viridis")
#install.packages("wesanderson")

library(DT)
library(rgdal)
library(rgeos)
library(leaflet)
library(viridis)
library(stringr)
library(dplyr)
library(readxl)
library(tidyverse)
library(wesanderson)

options(scipen=999)

#County Shape files
# Read in the county shape files
us.map.county <- readOGR(dsn= './cb_2018_us_county_500k', layer = "cb_2018_us_county_500k", stringsAsFactors = FALSE)

# Remove Alaska(2), Hawaii(15), Puerto Rico (72), Guam (66), Virgin Islands (78), American Samoa (60) Mariana Islands (69), Micronesia (64), Marshall Islands (68), Palau (70), Minor Islands (74)
us.map.county <- us.map.county[!us.map.county$STATEFP %in% c("02", "15", "72", "66", "78", "60", "69","64", "68", "70", "74"),]

# Make sure other outling islands are removed.
us.map.county <- us.map.county[!us.map.county$STATEFP %in% c("81", "84", "86", "87", "89", "71", "76","95", "79"),]

simplified_shp <- gSimplify(us.map.county, tol = 0.0125, topologyPreserve = FALSE)
simplified_county <- SpatialPolygonsDataFrame(simplified_shp, data = us.map.county@data)

#format(object.size(simplified), units = "Mb")

#State shape files
us.map.state <- readOGR(dsn= './cb_2018_us_state_500k', layer = "cb_2018_us_state_500k", stringsAsFactors = FALSE)

# Remove Alaska(2), Hawaii(15), Puerto Rico (72), Guam (66), Virgin Islands (78), American Samoa (60) Mariana Islands (69), Micronesia (64), Marshall Islands (68), Palau (70), Minor Islands (74)
us.map.state <- us.map.state[!us.map.state$STATEFP %in% c("02", "15", "72", "66", "78", "60", "69","64", "68", "70", "74"),]

# Make sure other outling islands are removed.
us.map.state <- us.map.state[!us.map.state$STATEFP %in% c("81", "84", "86", "87", "89", "71", "76","95", "79"),]

simplified_shp_v1 <- gSimplify(us.map.state, tol = 0.0001, topologyPreserve = FALSE)
simplified_state <- SpatialPolygonsDataFrame(simplified_shp_v1, data = us.map.state@data)

format(object.size(us.map.state), units = "Mb")
### Create dummy data
set.seed(111)
mydf <- data.frame(place = unique(us.map.county$GEOID),
                   value_1 = sample.int(n = 1000000, size = length(unique(us.map.county$GEOID)), replace = TRUE),
                   value_2 = sample.int(n = 1000000, size = length(unique(us.map.county$GEOID)), replace = TRUE),
                   value_3 = sample.int(n = 1000000, size = length(unique(us.map.county$GEOID)), replace = TRUE),
                   value_4 = sample.int(n = 1000000, size = length(unique(us.map.county$GEOID)), replace = TRUE))

# Import the monthly enrollment data for all medicare products 
# found here https://www.cms.gov/Research-Statistics-Data-and-Systems/Statistics-Trends-and-Reports/CMSProgramStatistics/Downloads/Enrollment_Dashboard_Data_File.zip
df <- read_excel("./data/enrollment_data.xlsx", sheet = 3, skip = 5)

colnames(df) <- c("Year", "Month", "State", "County", "OriginalMedicare", "MedAdvOther", "MedicareTotal",
                  "PrescriptionDrug", "MedAdvPresDrug", "PresDrugTotal")

df <- transform(df, OrigMedicare_perc = as.integer(100*OriginalMedicare / MedicareTotal))
df <- transform(df, MedAdvOther_perc = as.integer(100*MedAdvOther / MedicareTotal))
df <- transform(df, MedicareTotal_perc = 100*MedicareTotal / MedicareTotal)


df <- as.data.frame(merge(df, us.map.state, by.x="State", by.y="NAME"))

#Import the county enrollment data
# df_county <- read_excel("./data/county_payer_statistics.xlsx")
df_county <- read_excel("./data/county_payer_stats_t12mo.xlsx")



