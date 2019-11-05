#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
library(leaflet)

vars <-
  c(
    "ORIGINAL MEDICARE" = "OriginalMedicare",
    "MA-C & OTHER" = "MedAdvOther",
    "TOTAL MEDICARE" = "MedicareTotal"
  )

month <-
  c(
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  )

states <-
  c(
    "Alabama" = "01",
    "Alaska" = "02",
    "Arizona" = "04",
    "Arkansas" = "05",
    "California" = "06",
    "Colorado" = "08",
    "Connecticut" = "09",
    "Delaware" = "10",
    "Florida" = "12",
    "Georgia" = "13",
    "Hawaii" = "15",
    "Idaho" = "16",
    "Illinois" = "17",
    "Indiana" = "18",
    "Iowa" = "19",
    "Kansas" = "20",
    "Kentucky" = "21",
    "Louisiana" = "22",
    "Maine" = "23",
    "Maryland" = "24",
    "Massachusetts" = "25",
    "Michigan" = "26",
    "Minnesota" = "27",
    "Mississippi" = "28",
    "Missouri" = "29",
    "Montana" = "30",
    "Nebraska" = "31",
    "Nevada" = "32",
    "New Hampshire" = "33",
    "New Jersey" = "34",
    "New Mexico" = "35",
    "New York" = "36",
    "North Carolina" = "37",
    "North Dakota" = "38",
    "Ohio" = "39",
    "Oklahoma" = "40",
    "Oregon" = "41",
    "Pennsylvania" = "42",
    "Rhode Island" = "44",
    "South Carolina" = "45",
    "South Dakota" = "46",
    "Tennessee" = "47",
    "Texas" = "48",
    "Utah" = "49",
    "Vermont" = "50",
    "Virginia" = "51",
    "Washington" = "53",
    "West Virginia" = "54",
    "Wisconsin" = "55",
    "Wyoming" = "56"
  )

navbarPage(
  "Medicare Advantage",
  id = "nav",
  
  tabPanel(
    "Macro Analysis",
    div(
      class = "outer",
      
      tags$head(# Include our custom CSS
        includeCSS("style.css"),
        includeScript("gomap.js")),
      
      leafletOutput("myMap", width = "100%", height = "100%"),
      
      ######## ABSOLUTE PANELS ########
      
      ######## PANEL: TAB 1, LHS ########

        absolutePanel(
          id = "controls",
          class = "panel panel-default",
          fixed = TRUE,
          draggable = TRUE,
          top = 65,
          left = 55,
          right = "auto",
          bottom = "auto",
          width = 330,
          height = 560,
          
          h4("State Level Analysis"),
          radioButtons(
            inputId = "scale_state",
            label = "Type",
            choices = c("Count", "Percent"),
            inline = TRUE
          ),
          
          selectizeInput(
            'market_state',
            'Select Demographic',
            choices = vars,
            options = list(
              placeholder = 'Choose an option',
              onInitialize = I('function() { this.setValue(""); }')
            )
          ),
          selectizeInput(
            'select_state',
            'Select State',
            choices = states,
            options = list(
              placeholder = 'Choose an option',
              onInitialize = I('function() { this.setValue(""); }')
            )
          ),
          #textOutput("TestText"),
          div(DT::dataTableOutput('state_ts_tbl'), style = "font-size: 75%; width: 75%")
        ),
      
      ######## PANEL: TAB 1, RHS ########
      absolutePanel(
        id = "controls",
        class = "panel panel-default",
        fixed = TRUE,
        draggable = TRUE,
        top = 60,
        left = "auto",
        right = 10,
        bottom = "auto",
        width = 330,
        height = 560,#"auto",
        
        h4("Medicare Market Analysis"),
        radioButtons(
          inputId = "scale",
          label = "Type",
          choices = c("Count", "Percent"),
          inline = TRUE
        ),
        
        selectizeInput(
          'year_us',
          'Select year',
          choices = c("2018", "2019"),
          options = list(
            placeholder = 'Choose an option',
            onInitialize = I('function() { this.setValue("2019"); }')
          )
        ),
        
        selectizeInput(
          'month_us',
          'Select Month',
          choices = month,
          options = list(
            placeholder = 'Choose an option',
            onInitialize = I('function() { this.setValue("January"); }')
          )
        ),
        
        selectizeInput(
          'value',
          'Select Demographic',
          choices = vars,
          options = list(
            placeholder = 'Choose an option',
            onInitialize = I('function() { this.setValue(""); }')
          )
        ),
        plotOutput("totalMarket", height = 230, width = 250),
        div(DT::dataTableOutput('tbl2'), style = "font-size: 75%; width: 75%")
      )
    )
  ),
  tabPanel(
    'Analysis by State',
    leafletOutput("stateMap", width = "110vw", height = "100vh"),
    
    ######## PANEL: TAB 2, LHS ########
    absolutePanel(
      id = "controls",
      class = "panel panel-default",
      fixed = TRUE,
      draggable = TRUE,
      top = 65,
      left = 55,
      right = "auto",
      bottom = "auto",
      width = 330,
      height = 560,
      
      h2("Select State"),
      
      selectizeInput(
        'state_tab2',
        'Select State',
        choices = states,
        options = list(
          placeholder = "Choose an option",
          onInitialize = I('function() { this.setValue(""); }')
        )
      ),
      plotOutput("TOP_10_COUNTY", height = 300, width = 250)
      
    ),
    ######## PANEL: TAB 2, RHS ########
    absolutePanel(
      id = "controls",
      class = "panel panel-default",
      fixed = TRUE,
      draggable = TRUE,
      top = 65,
      left = "auto",
      right = 30,
      bottom = "auto",
      width = 330,
      height = 560,
      
      h2("Select County"),
      selectizeInput(
        "county_tab2",
        'Select County',
        choices = c("county A", "county B"),
        options = list(
          placeholder = "Choose an option",
          onInitialize = I('function() { this.setValue(""); }')
        )
      )
      ),
    DT::dataTableOutput('tbl_county')
  )
)

#ui <- fluidPage(header)
