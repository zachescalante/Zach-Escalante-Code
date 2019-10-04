#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  output$myMap <- renderLeaflet({
    leaflet() %>%
      setView(-96, 37.8, 4) %>%
      # This is where we adjust the basemap graphics
      addProviderTiles("OpenStreetMap.Mapnik") %>%
      addPolygons(data = us.map.county,
                  # mydf$value will be the variable passed from the user dropdown menu in Shiny
                  fillColor = ~pal(mydf$value),
                  stroke = FALSE,
                  smoothFactor = 0.2,
                  fillOpacity = 0.3,
                  popup = paste("Region: ", us.map.county$NAME, "<br>",
                                "Value: ", mydf$value, "<br>"))
  })
  
})
