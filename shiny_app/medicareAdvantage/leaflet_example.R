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


#Import the county enrollment data
# df_county <- read_excel("./data/county_payer_statistics.xlsx")
df.payers <- read_excel("./data/county_payer_stats_t12mo.xlsx")
df.population <- read_csv("./data/PEP_2018_PEPAGESEX_with_ann.csv")
sum(us.map.county$AFFGEOID == "0500000US01001")

as.numeric(as.factor(df.population$est72018sex0_age65to69))

df.population$est72018sex0_age65to69 <- as.numeric(as.factor(df.population$est72018sex0_age65to69))

df.population$est72018sex0_age65to69

test.df <- merge(us.map.county,
      df.population[, c("GEO.id", "est72018sex0_age65to69"), drop = TRUE],
      #df.population,
      by.x = "AFFGEOID",
      by.y = "GEO.id")

pal_ <- colorQuantile(
  palette = "Oranges",
  domain = df.population$est72018sex0_age65to69)

leaflet() %>%
  addProviderTiles("Esri.WorldGrayCanvas") %>%
  addPolygons(data = test.df[which(test.df$STATEFP == "21" & test.df$COUNTYFP != "011"), ],
              fillColor = ~pal_(test.df$est72018sex0_age65to69),
              stroke = FALSE,
              smoothFactor = 0.2,
              fillOpacity = 0.3)# %>%
  #addPolygons(data = test.df[which(test.df$COUNTYFP == "011" & test.df$STATEFP == "21"), ],
  #            fillColor = "Red")
                                         
                                         