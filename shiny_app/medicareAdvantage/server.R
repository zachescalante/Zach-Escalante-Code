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
  output$TestText <- renderText({
    input$state
  })
  
  pal <- reactive({
    colorQuantile("Reds", stateData()[, input$value, drop = TRUE], n=9)
  })
  
  stateData <- reactive({
    df %>%
      filter(County == 'TOTAL' & Year == input$year_us & Month == input$month_us)
  })
  
  output$tbl2 <- DT::renderDataTable({
    DT::datatable(as.data.frame(merge(us.map.state, stateData()[,c("State", input$value), drop = TRUE], by.x = "NAME", by.y = "State")))
  })
  
  output$myMap <- renderLeaflet({
    
    medicare_market <- merge(us.map.state, stateData()[,c("State", input$value), drop = TRUE], by.x = "NAME", by.y = "State")
    
    leaflet() %>%
      setView(mean(coordinates(us.map.state)[, 1]), mean(coordinates(us.map.state)[, 2]), 4) %>%
      # This is where we adjust the basemap graphics
      addProviderTiles("Hydda.Base") %>%
      addPolygons(
        data = medicare_market,
        # mydf$value will be the variable passed from the user dropdown menu in Shiny
        fillColor = ~ pal()(medicare_market@data[, input$value, drop = TRUE]),
        stroke = FALSE,
        smoothFactor = 0.2,
        fillOpacity = 0.3,
        popup = paste("Region: ", us.map.state$NAME, "<br>",
                      "Value: ", medicare_market@data[, input$value, drop = TRUE])
      )
  })
  
  output$stateMap <- renderLeaflet({
    req(input$state)
    leaflet() %>%
      fitBounds(
        lng1 = min(coordinates(simplified_county[which(simplified_county$STATEFP == input$state),])[, 1]),
        lat1 = min(coordinates(simplified_county[which(simplified_county$STATEFP ==
                                                  input$state),])[, 2]),
        lng2 = max(coordinates(simplified_county[which(simplified_county$STATEFP ==
                                                  input$state),])[, 1]),
        lat2 = max(coordinates(simplified_county[which(simplified_county$STATEFP ==
                                                  input$state),])[, 2])
      ) 
      addProviderTiles("Hydda.Base") %>%
      addPolygons(data = simplified_county[which(simplified_county$STATEFP == input$state),])
  })
  
  
  # Test barplot 1
  output$totalMarket <- renderPlot({
    state_total <- stateData() %>%
      arrange_at(desc(stateData()[, input$value, drop = TRUE]))
    
    top_10 <- tail(stateData()[, input$value, drop = TRUE], n = 10)
    labels <- tail(stateData()[, 1, drop = TRUE], n = 10)
    
    # Render a barplot
    par(mar=c(7,5,1,1))
    barplot(
      top_10,
      main = "Total Market",
      xlab = "",
      col = wes_palette(11),
      names.arg = labels,
      las = 2
    )
  })
  
  # Test barplot 2
  output$totalPercent <- renderPlot({
    top_10 <- tail(mydf[, input$value, drop = TRUE], n = 10)
    labels <- tail(mydf[, "place", drop = TRUE], n = 10)
    
    # Render a barplot
    barplot(
      top_10,
      main = "Total as Percent (%)",
      xlab = "",
      col = viridis(10),
      names.arg = labels,
      las = 2
    )
  })
  
})
