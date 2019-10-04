#install.packages("rgdal")
#install.packages("leaflet")
#install.packages("shinydashboard")
#install.packages("DT")

library(leaflet)
library(rgdal)
library(DT)


# Read in the county shape files
us.map.county <- readOGR(dsn= './cb_2018_us_county_500k', layer = "cb_2018_us_county_500k", stringsAsFactors = FALSE)

### Create color scheme
pal <- colorQuantile("Spectral", NULL, n = 10)

### Create dummy data
set.seed(111)
mydf <- data.frame(place = unique(us.map.county$GEOID),
                   value = sample.int(n = 1000000, size = length(unique(us.map.county$GEOID)), replace = TRUE))


