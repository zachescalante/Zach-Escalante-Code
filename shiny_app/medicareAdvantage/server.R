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
shinyServer(function(input, output, session) {
  ######## REACTIVE OBJECTS ########
  
  pal <- reactive({
    colorQuantile("viridis", stateData()[, input$value, drop = TRUE], n = 9)
  })
  
  stateData <- reactive({
    df %>%
      filter(County == 'TOTAL' &
               Year == input$year_us & Month == input$month_us)
  })
  
  state_ts <- reactive({
    df %>%
      filter(County == 'TOTAL' & GEOID == input$select_state)
  })
  
  county_ts <- reactive({
    req(input$state_tab2)
    df_county %>%
      filter(State_FIPS == input$state_tab2) %>%
      group_by(Parent_Organization) %>%
      summarise_if(is.numeric, funs(sum))
      # filter(State_FIPS == input$state_tab2 & FIPS == input$county_tab2)
  })
  
  
  #### PANEL: TAB 1, RHS, INPUT: "TYPE", UPDATE: "SELECT DEMOGRAPHIC" #####
  observeEvent(input$scale, {
    if (input$scale == "Percent") {
      x <- c(
        "ORIGINAL MEDICARE" = "OrigMedicare_perc",
        "MA-C & OTHER" = "MedAdvOther_perc"
      )
    } else {
      x <- c(
        "ORIGINAL MEDICARE" = "OriginalMedicare",
        "MA-C & OTHER" = "MedAdvOther",
        "TOTAL MEDICARE" = "MedicareTotal"
      )
    }
    
    updateSelectizeInput(session, "value",
                         choices = x,
                         server = TRUE)
  })
  
  #### PANEL: TAB 1, LHS, INPUT: "TYPE", UPDATE: "SELECT DEMOGRAPHIC" #####
  observeEvent(input$scale_state, {
    if (input$scale_state == "Percent") {
      y <- c(
        "ORIGINAL MEDICARE" = "OrigMedicare_perc",
        "MA-C & OTHER" = "MedAdvOther_perc"
      )
    } else {
      y <- c(
        "ORIGINAL MEDICARE" = "OriginalMedicare",
        "MA-C & OTHER" = "MedAdvOther",
        "TOTAL MEDICARE" = "MedicareTotal"
      )
    }
    
    updateSelectizeInput(session, "market_state",
                         choices = y,
                         server = TRUE)
  })
  
  #### PANEL: TAB 2, LHS, INPUT: "state_tab2", UPDATE: "county_tab2" #####
  observeEvent(input$state_tab2, {
    df_county_update <- df_county %>%
      filter(State_FIPS == input$state_tab2)
    
    df_county_update <- unique(df_county_update$FIPS)
    
    updateSelectizeInput(session, "county_tab2",
                         choices = unique(df_county_update),
                         server = TRUE)
  })
  
  ######## DATA TABLES ########
  
  ######## PANEL 1, RHS ######
  
  output$tbl2 <- DT::renderDataTable({
    req(input$value)
    df <- stateData()[, c("State", input$value), drop = TRUE]
    
    DT::datatable(df,
                  options = list(pageLength = 8, dom = 'rtip')) %>%
      formatStyle(0,
                  target = 'row',
                  color = 'black',
                  lineHeight = '60%') %>%
      formatCurrency(
        input$value,
        currency = "",
        interval = 3,
        mark = ","
      )
  })
  
  output$state_ts_tbl <- DT::renderDataTable({
    req(input$market_state)
    
    #df_ts <- state_ts()[, c("Year", "Month", input$market_state)]
    DT::datatable(state_ts()[, c("Year", "Month", input$market_state)],
                  options = list(pageLength = 12, dom = 'rtip')) %>%
      formatStyle(0,
                  target = 'row',
                  color = 'black',
                  lineHeight = '60%') %>%
      formatCurrency(
        input$market_state,
        currency = "",
        interval = 3,
        mark = ","
      )
  })
  
  output$tbl_county <- DT::renderDataTable({
    req(input$state_tab2)
    DT::datatable(county_ts())
  })
  
  output$TestText <- renderText({
    input$state_tab2
  })
  
  ######## LEAFLET MAPS ########
  
  output$myMap <- renderLeaflet({
    req(input$value)
    medicare_market <-
      merge(us.map.state,
            stateData()[, c("State", input$value), drop = TRUE],
            by.x = "NAME",
            by.y = "State")
    
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
        popup = paste(
          "Region: ",
          us.map.state$NAME,
          "<br>",
          "Value: ",
          medicare_market@data[, input$value, drop = TRUE]
        )
      )
  })
  
  output$stateMap <- renderLeaflet({
    req(input$state_tab2)
    leaflet() %>%
      fitBounds(
        lng1 = min(coordinates(us.map.county[which(us.map.county$STATEFP == input$state_tab2), ])[, 1]),
        lat1 = min(coordinates(us.map.county[which(us.map.county$STATEFP ==
                                                         input$state_tab2), ])[, 2]),
        lng2 = max(coordinates(us.map.county[which(us.map.county$STATEFP ==
                                                         input$state_tab2), ])[, 1]),
        lat2 = max(coordinates(us.map.county[which(us.map.county$STATEFP ==
                                                         input$state_tab2), ])[, 2])
      ) %>%
    addProviderTiles("Esri.WorldGrayCanvas") %>%
      addPolygons(data = us.map.county[which(us.map.county$STATEFP == input$state_tab2), ])
  })
  
  ######## GRAPHS AND PLOTS ########
  
  # Test barplot 1
  output$totalMarket <- renderPlot({
    req(input$value)
    state_total <- stateData() %>%
      arrange_at(desc(stateData()[, input$value, drop = TRUE]))
    
    top_10 <- tail(stateData()[, input$value, drop = TRUE], n = 10)
    labels <- tail(stateData()[, 1, drop = TRUE], n = 10)
    
    # Render a barplot
    par(mar = c(7, 5, 1, 1))
    barplot(
      as.numeric(top_10),
      main = "",
      xlab = "",
      col = wes_palette(11),
      names.arg = labels,
      las = 2
    )
  })
  
  # Test barplot 2
  output$totalPercent <- renderPlot({
    req(input$value)
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
  
  
  #### TAB 2: LHS, TOP_10_COUNTY #####
  
  
  output$TOP_10_COUNTY <- renderPlot({
    #req(input$state_tab2,cancelOutput = TRUE)
    #req(input$state_tab2)
    
    top_10_payers = head(county_ts()[ order(county_ts()[[3]], decreasing = TRUE),], 10)[[3]]
    labels_payers = head(county_ts()[ order(county_ts()[[3]], decreasing = TRUE),], 10)[[1]]
    #top_10_payers <- head(county_ts()[, 5, drop = TRUE], n = 10)
    #labels_payers <- head(county_ts()[, 4, drop = TRUE], n = 10)
    
    # Render a barplot
    par(mar = c(15, 5, 1, 1))
    #req(as.numeric(top_10_payers))
    if(req(as.numeric(top_10_payers))){
    barplot(
      as.numeric(top_10_payers),
      main = "",
      xlab = "",
      col = wes_palette(11),
      names.arg = labels_payers,
      las = 2
    )}
    
    
  })
  
})
