#install.packages("rgdal")
#install.packages("leaflet")
#install.packages("shinydashboard")
#install.packages("DT")
#install.packages("rgeos")
#install.packages("viridis")

library(leaflet)
library(rgdal)
library(DT)
library(rgeos)
library(viridis)

# Read in the county shape files
us.map.county <- readOGR(dsn= './cb_2018_us_county_500k', layer = "cb_2018_us_county_500k", stringsAsFactors = FALSE)

# Remove Alaska(2), Hawaii(15), Puerto Rico (72), Guam (66), Virgin Islands (78), American Samoa (60) Mariana Islands (69), Micronesia (64), Marshall Islands (68), Palau (70), Minor Islands (74)
us.map.county <- us.map.county[!us.map.county$STATEFP %in% c("02", "15", "72", "66", "78", "60", "69","64", "68", "70", "74"),]

# Make sure other outling islands are removed.
us.map.county <- us.map.county[!us.map.county$STATEFP %in% c("81", "84", "86", "87", "89", "71", "76","95", "79"),]

simplified_shp <- gSimplify(us.map.county, tol = 0.0125, topologyPreserve = FALSE)
simplified <- SpatialPolygonsDataFrame(simplified_shp, data = us.map.county@data)

# Figure out a way to use this CSV import to generate a list of States/FIPS codes
#statesFIPS <- read.csv(file="statesFIPS.csv", header=TRUE, sep=",")
#statesFIPS$label = paste(statesFIPS$labels, statesFIPS$values, sep=", ")

#format(object.size(simplified), units = "Mb")
### Create color scheme
#pal <- colorQuantile("Reds", NULL, n = 9)
#pal <- colorQuantile(viridis(n=10))
#pal <- colorNumeric(c("red", "green", "blue"), n=20)

### Create dummy data
set.seed(111)
mydf <- data.frame(place = unique(us.map.county$GEOID),
                   value_1 = sample.int(n = 1000000, size = length(unique(us.map.county$GEOID)), replace = TRUE),
                   value_2 = sample.int(n = 1000000, size = length(unique(us.map.county$GEOID)), replace = TRUE),
                   value_3 = sample.int(n = 1000000, size = length(unique(us.map.county$GEOID)), replace = TRUE),
                   value_4 = sample.int(n = 1000000, size = length(unique(us.map.county$GEOID)), replace = TRUE))


