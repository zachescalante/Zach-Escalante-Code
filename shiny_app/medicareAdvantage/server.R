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
  
  output$TestText <- renderText({input$state})
  output$dataTable <- renderTable({
    mydf[, input$value, drop = TRUE]
  })
  
  output$myMap <- renderLeaflet({
    leaflet() %>%
      setView(mean(coordinates(simplified)[,1]), mean(coordinates(simplified)[,2]), 4) %>%
      # This is where we adjust the basemap graphics
      addProviderTiles("OpenStreetMap.Mapnik") %>%
      addPolygons(data = simplified,
                  # mydf$value will be the variable passed from the user dropdown menu in Shiny
                  fillColor = ~pal(mydf[, input$value, drop = TRUE]),
                  stroke = FALSE,
                  smoothFactor = 0.2,
                  fillOpacity = 0.3,
                  popup = paste("Region: ", us.map.county$NAME, "<br>"))#,
                                #"Value: ", input$value, "<br>"))
  })
  
  output$stateMap <- renderLeaflet({
    req(input$state)
    leaflet() %>%
      fitBounds(lng1 = min(coordinates(simplified[ which(simplified$STATEFP==input$state), ])[,1]), 
                lat1 = min(coordinates(simplified[ which(simplified$STATEFP==input$state), ])[,2]), 
                lng2 = max(coordinates(simplified[ which(simplified$STATEFP==input$state), ])[,1]), 
                lat2 = max(coordinates(simplified[ which(simplified$STATEFP==input$state), ])[,2])) %>%
      #setView(mean(coordinates(simplified[ which(simplified$STATEFP==input$state), ])[,1]), 
      #          mean(coordinates(simplified[ which(simplified$STATEFP==input$state), ])[,2]), 
      #          6) %>%
      # This is where we adjust the basemap graphics
      addProviderTiles("OpenStreetMap.Mapnik") %>%
      addPolygons(data = simplified[ which(simplified$STATEFP==input$state), ])
  })
  
})


