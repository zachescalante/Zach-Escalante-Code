#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(scales)

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  ######## REACTIVE OBJECTS ########
  
  pal <- reactive({
    colorQuantile("viridis", stateTotalsTab1()[, input$medicare.type, drop = TRUE], n = 9)
  })
  
  ### TAB 1 ###
  
  stateTotalsTab1 <- reactive({
    df %>%
      filter(County == 'TOTAL' &
               Year == input$year_us & Month == input$month_us)
  })
  
  stateTSTab1 <- reactive({
    df %>%
      filter(County == 'TOTAL' & GEOID == input$select_state)
  })
  
  #### PANEL: TAB 2, LHS, State Payer Time Series ####
  state.TS.Tab2 <- reactive({
    req(input$state.tab2)
    df_county %>%
      filter(State_FIPS == input$state.tab2) %>%
      group_by(Parent_Organization) %>%
      summarise_if(is.numeric, funs(sum))
      # filter(State_FIPS == input$state.tab2 & FIPS == input$county.tab2)
  })

  state.top.payer.ts.tab2 <- reactive({
    req(state.TS.Tab2())
    # Use dplyr to sort by last month's numbers
    county.df <- state.TS.Tab2() %>%
      arrange(desc(!! sym(colnames(state.TS.Tab2()[3])))) %>%  # sort based on last months' values
      select (-c(FIPS))
    # Make sure to drop unnecessary columns
    # Take the top-10 payers by market share
    county.df <- head(county.df, 10)
    
  })
  
  #### PANEL: TAB 2, RHS, County Payer Time Series ####
  county.ts.tab2 <- reactive({
    req(input$state.tab2)
    df_county %>%
      filter(State_FIPS == input$state.tab2 & FIPS == input$county.tab2) %>%
      group_by(Parent_Organization) %>%
      summarise_if(is.numeric, funs(sum))
  })
  
  county.top.payer.ts.tab2 <- reactive({
    req(county.ts.tab2())
    # Use dplyr to sort by last month's numbers
    county.df <- county.ts.tab2() %>%
      arrange(desc(!! sym(colnames(county.ts.tab2()[3])))) %>%  # sort based on last months' values
      select (-c(FIPS))
    # Make sure to drop unnecessary columns
    # Take the top-10 payers by market share
    county.df <- head(county.df, 10)
    
  })
  
  #### PANEL: TAB 3, Main Panel, State/County Payer Time Series ####
  state.county.ts.tab3 <- reactive({
    req(input$state.tab3)
    df_county %>%
      filter(State_FIPS == input$state.tab3 & FIPS == input$county.tab3) %>%
      group_by(Parent_Organization) %>%
      summarise_if(is.numeric, funs(sum))
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
    
    updateSelectizeInput(session, "medicare.type",
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
  
  #### PANEL: TAB 2, LHS, INPUT: "state.tab2", UPDATE: "county.tab2" #####
  observeEvent(input$state.tab2, {
    df_county_update <- df_county %>%
      filter(State_FIPS == input$state.tab2)
    
    df_county_update <- unique(df_county_update$FIPS)
    
    updateSelectizeInput(session, "county.tab2",
                         choices = unique(df_county_update),
                         server = TRUE)
  })
  
  #### PANEL: TAB 3, LHS, INPUT: "state.tab3", UPDATE: "county.tab3" #####
  observeEvent(input$state.tab3, {
    df_county_update <- df_county %>%
      filter(State_FIPS == input$state.tab3)
    
    df_county_update <- unique(df_county_update$FIPS)
    
    updateSelectizeInput(session, "county.tab3",
                         choices = unique(df_county_update),
                         server = TRUE)
  })
  
  ######## DATA TABLES ########
  
  ######## TAB 1, PANEL 1, RHS ######
  output$raw.state.totals.tab1 <- DT::renderDataTable({
    req(input$medicare.type)
    df <- stateTotalsTab1()[, c("State", input$medicare.type), drop = TRUE]
    
    DT::datatable(df,
                  options = list(pageLength = 8, dom = 'rtip')) %>%
      formatStyle(0,
                  target = 'row',
                  color = 'black',
                  lineHeight = '60%') %>%
      formatCurrency(
        input$medicare.type,
        currency = "",
        interval = 3,
        mark = ","
      )
  })
  
  ######## TAB 1, PANEL 2, LHS ######
  output$state.totals.ts.tab1 <- DT::renderDataTable({
    req(input$market_state)
    
    DT::datatable(stateTSTab1()[, c("Year", "Month", input$market_state)],
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
  
  output$state.payer.ts.table.tab2 <- DT::renderDataTable({
    req(input$state.tab2)
    DT::datatable(state.TS.Tab2())
  })
  
  output$state.top.payer.ts.table.tab2 <- DT::renderDataTable({
    req(state.top.payer.ts.tab2())
    DT::datatable(state.top.payer.ts.tab2())
  })
  
  output$state.county.ts.table.tab3 <- DT::renderDataTable({
    req(state.county.ts.tab3())
    data.frame <- state.county.ts.tab3()
    dates.len <- length(colnames(data.frame))
    raw.dates <- colnames(data.frame)[3:dates.len]
    formatted.dates <- as.character(as.Date( as.numeric (raw_dates),origin="1899-12-30"))
    colnames(data.frame)[3:dates.len] <- formatted.dates
    
    DT::datatable(data.frame,
                  options = list(dom = 'rltip')) %>%
                formatCurrency(
                    3:dates.len,
                    currency = "",
                    interval = 3,
                    mark = ","
                  ) %>%
      formatRound(3:dates.len, 0)

  })
  
  ######## LEAFLET MAPS ########
  
  output$us.map.tab1 <- renderLeaflet({
    req(input$medicare.type)
    medicare_market <-
      merge(us.map.state,
            stateTotalsTab1()[, c("State", input$medicare.type), drop = TRUE],
            by.x = "NAME",
            by.y = "State")
    
    leaflet() %>%
      setView(mean(coordinates(us.map.state)[, 1]), mean(coordinates(us.map.state)[, 2]), 4) %>%
      # This is where we adjust the basemap graphics
      addProviderTiles("Hydda.Base") %>%
      addPolygons(
        data = medicare_market,
        # mydf$medicare.type will be the variable passed from the user dropdown menu in Shiny
        fillColor = ~ pal()(medicare_market@data[, input$medicare.type, drop = TRUE]),
        stroke = FALSE,
        smoothFactor = 0.2,
        fillOpacity = 0.3,
        popup = paste(
          "Region: ",
          us.map.state$NAME,
          "<br>",
          "Value: ",
          medicare_market@data[, input$medicare.type, drop = TRUE]
        )
      )
  })
  
  output$stateMap <- renderLeaflet({
    req(input$state.tab2)
    leaflet() %>%
      fitBounds(
        lng1 = min(coordinates(us.map.county[which(us.map.county$STATEFP == input$state.tab2), ])[, 1]),
        lat1 = min(coordinates(us.map.county[which(us.map.county$STATEFP ==
                                                         input$state.tab2), ])[, 2]),
        lng2 = max(coordinates(us.map.county[which(us.map.county$STATEFP ==
                                                         input$state.tab2), ])[, 1]),
        lat2 = max(coordinates(us.map.county[which(us.map.county$STATEFP ==
                                                         input$state.tab2), ])[, 2])
      ) %>%
    addProviderTiles("Esri.WorldGrayCanvas") %>%
      addPolygons(data = us.map.county[which(us.map.county$STATEFP == input$state.tab2), ])
  })
  
  ######## GRAPHS AND PLOTS ########
  
  # Test barplot 1
  output$totalMarket <- renderPlot({
    req(input$medicare.type)
    state_total <- stateTotalsTab1() %>%
      arrange_at(desc(stateTotalsTab1()[, input$medicare.type, drop = TRUE]))
    
    top_10 <- tail(stateTotalsTab1()[, input$medicare.type, drop = TRUE], n = 10)
    labels <- tail(stateTotalsTab1()[, 1, drop = TRUE], n = 10)
    
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
    req(input$medicare.type)
    top_10 <- tail(mydf[, input$medicare.type, drop = TRUE], n = 10)
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
  
  #### TAB 2: LHS, top.10.payers.tab2 #####
  output$top.10.payers.tab2 <- renderPlot({
    
    top_10_payers = head(state.TS.Tab2()[ order(state.TS.Tab2()[[3]], decreasing = TRUE),], 10)[[3]]
    labels_payers = head(state.TS.Tab2()[ order(state.TS.Tab2()[[3]], decreasing = TRUE),], 10)[[1]]
    
    df <- data.frame(top.payers=top_10_payers,
                     payer.labels=labels_payers)
    
    p <- ggplot(data=df, aes(x=payer.labels, y=top.payers, fill=top.payers)) +
      geom_bar(stat="identity", width = 0.60) +
      ggtitle("Top Insureres by State") +
      scale_x_discrete(label = function(x) stringr::str_trunc(x, 12)) +  # truncate data names to 12 characters
      scale_y_continuous(labels=comma) +            # add commas to value labels
      theme_minimal() +                             # remove grey background
      scale_fill_viridis() +                        # add viridis color palette
      theme(axis.text.y = element_text(hjust=0),    # left justify labels
            axis.title.x=element_blank(),           # remove x title
            axis.title.y=element_blank(),           # remove y title
            legend.position="none",                 # remove legend
            plot.title = element_text(family = "Helvetica", face = "bold", size = (15), hjust = 0.5)) +
      coord_flip()
    p
    
  })
  
  #### TAB 2: RHS, top.10.payers.county.tab2 #####
  output$top.10.payers.county.tab2 <- renderPlot({
    
    top_10_payers = head(county.ts.tab2()[ order(county.ts.tab2()[[3]], decreasing = TRUE),], 10)[[3]]
    labels_payers = head(county.ts.tab2()[ order(county.ts.tab2()[[3]], decreasing = TRUE),], 10)[[1]]
    
    df <- data.frame(top.payers=top_10_payers,
                     payer.labels=labels_payers)
    
    p <- ggplot(data=df, aes(x=payer.labels, y=top.payers, fill=top.payers)) +
      geom_bar(stat="identity", width = 0.60) +
      ggtitle("Top Insureres by County") +
      scale_x_discrete(label = function(x) stringr::str_trunc(x, 12)) +  # truncate data names to 12 characters
      scale_y_continuous(labels=comma) +            # add commas to value labels
      theme_minimal() +                             # remove grey background
      scale_fill_viridis() +                        # add viridis color palette
      theme(axis.text.y = element_text(hjust=0),    # left justify labels
            axis.title.x=element_blank(),           # remove x title
            axis.title.y=element_blank(),           # remove y title
            legend.position="none",                 # remove legend
            plot.title = element_text(family = "Helvetica", face = "bold", size = (15), hjust = 0.5)) +
      coord_flip()
    p
    
  })
 
  #### TAB 2: LHS, state.top.payers.ts.graph #####
  output$state.top.payers.ts.graph <- renderPlot({
    req(state.top.payer.ts.tab2())
    
    # Melt the data frames
    state.data.melt <- melt(state.top.payer.ts.tab2(), id="Parent_Organization")
    state.data.melt$variable <- as.Date( as.numeric (as.character(state.data.melt$variable) ),origin="1899-12-30")
    
    # Create the plot
    ggplot(state.data.melt, aes(variable, value, group = Parent_Organization, color = str_trunc(Parent_Organization, 12, "right"))) +
     geom_line() + 
      geom_point() + 
      ggtitle("Time Series Analysis") +
      theme_minimal() +
      scale_y_continuous(labels=comma) +
      scale_colour_viridis_d() +
      guides(col = guide_legend(nrow = 3)) +
      theme(legend.position="bottom",
            legend.title=element_blank(),
            axis.title.x=element_blank(),
            axis.title.y=element_blank(),
            plot.title = element_text(family = "Helvetica", face = "bold", size = (15), hjust = 0.5))
  })
  
  #### TAB 2: RHS, county.top.payers.ts.graph #####
  output$county.top.payers.ts.graph <- renderPlot({
    req(state.top.payer.ts.tab2())
    
    # Melt the data frames
    county.data.melt <- melt(county.top.payer.ts.tab2(), id="Parent_Organization")
    county.data.melt$variable <- as.Date( as.numeric (as.character(county.data.melt$variable) ),origin="1899-12-30")
    
    # Create the plot
    ggplot(county.data.melt, aes(variable, value, group = Parent_Organization, color = str_trunc(Parent_Organization, 12, "right"))) +
      geom_line() + 
      geom_point() + 
      ggtitle("Time Series Analysis") +
      theme_minimal() +
      scale_y_continuous(labels=comma) +
      scale_colour_viridis_d() +
      guides(col = guide_legend(nrow = 3)) +
      theme(legend.position="bottom",
            legend.title=element_blank(),
            axis.title.x=element_blank(),
            axis.title.y=element_blank(),
            plot.title = element_text(family = "Helvetica", face = "bold", size = (15), hjust = 0.5))
  })
  
  #### TAB 2: LHS, state.ts.perc.chg.graph #####
  output$state.ts.perc.chg.graph <- renderPlot({
    req(state.top.payer.ts.tab2())
    
    # Create ggplot2 graph
    county.data.melt <- melt(state.top.payer.ts.tab2(), id="Parent_Organization")
    county.data.melt$variable <- as.Date( as.numeric (as.character(county.data.melt$variable) ),origin="1899-12-30")
    
    county.melt.pct <- county.data.melt %>% group_by(Parent_Organization) %>% mutate(lvar = 100*(lag(value) - value)/lag(value))
    
    # Create the plot
    ggplot(county.melt.pct, aes(variable, lvar, group = Parent_Organization, color = str_trunc(Parent_Organization, 12, "right"))) +
      geom_line() + 
      geom_point() + 
      ggtitle("Time Series Change (%)") +
      theme_minimal() +
      scale_colour_viridis_d() +
      scale_y_continuous(labels=comma) +
      guides(col = guide_legend(nrow = 3)) +
      theme(legend.position="bottom",
            legend.title=element_blank(),
            axis.title.x=element_blank(),
            axis.title.y=element_blank(),
            plot.title = element_text(family = "Helvetica", face = "bold", size = (15), hjust = 0.5))
  })
  
  #### TAB 2: RHS, county.ts.perc.chg.graph #####
  output$county.ts.perc.chg.graph <- renderPlot({
    req(state.top.payer.ts.tab2())
    
    # Create ggplot2 graph
    county.data.melt <- melt(county.top.payer.ts.tab2(), id="Parent_Organization")
    county.data.melt$variable <- as.Date( as.numeric (as.character(county.data.melt$variable) ),origin="1899-12-30")
    
    county.melt.pct <- county.data.melt %>% group_by(Parent_Organization) %>% mutate(lvar = 100*(lag(value) - value)/lag(value))
    
    # Create the plot
    ggplot(county.melt.pct, aes(variable, lvar, group = Parent_Organization, color = str_trunc(Parent_Organization, 12, "right"))) +
      geom_line() + 
      geom_point() + 
      ggtitle("Time Series Change (%)") +
      theme_minimal() +
      scale_colour_viridis_d() +
      scale_y_continuous(labels=comma) +
      guides(col = guide_legend(nrow = 3)) +
      theme(legend.position="bottom",
            legend.title=element_blank(),
            axis.title.x=element_blank(),
            axis.title.y=element_blank(),
            plot.title = element_text(family = "Helvetica", face = "bold", size = (15), hjust = 0.5))
  })
  
})
