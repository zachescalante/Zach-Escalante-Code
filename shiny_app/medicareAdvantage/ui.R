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
library(reshape2)

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

month_v2 <- c(
  "July-2019",
  "May-2019",
  "February-2019",
  "September-2018",
  "August-2018",
  "December-2018",
  "November-2018",
  "March-2019",
  "October-2018",
  "June-2019",
  "January-2019",
  "April-2019"
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
      
      leafletOutput("us.map.tab1", width = "100%", height = "100%"),
      
      ######## ABSOLUTE PANELS ########
      
      ######## PANEL: TAB 1, RHS ########
      
      absolutePanel(
        id = "controls",
        class = "panel panel-default",
        fixed = TRUE,
        draggable = TRUE,
        top = 65,
        left = "auto",
        right = 10,
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
        
        selectInput('date.tab1.rhs',
                    'Select a Month',
                    choices = month_v2),
        
        selectizeInput(
          'market.county',
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
        plotOutput("county.market", height = 230, width = 270),
        div(DT::dataTableOutput('county.totals.tab1'), style = "font-size: 75%; width: 75%")
      ),
      
      ######## PANEL: TAB 1, LHS ########
      absolutePanel(
        id = "controls",
        class = "panel panel-default",
        fixed = TRUE,
        draggable = TRUE,
        top = 60,
        left = 55,
        right = "auto",
        bottom = "auto",
        width = 330,
        height = 560,
        #"auto",
        
        h4("Medicare Market Analysis"),
        radioButtons(
          inputId = "scale",
          label = "Type",
          choices = c("Count", "Percent"),
          inline = TRUE
        ),
        
        selectInput('month_us',
                    'Select Month',
                    choices = month_v2),
        
        selectizeInput(
          'medicare.type',
          'Select Medicare Market',
          choices = vars,
          options = list(
            placeholder = 'Choose an option',
            onInitialize = I('function() { this.setValue(""); }')
          )
        ),
        plotOutput("state.market", height = 230, width = 270),
        div(DT::dataTableOutput('raw.state.totals.tab1'), style = "font-size: 90%; width: 90%")
      )
    )
  ),
  tabPanel(
    'Analysis by State',
    div(
      class = "outer",
      tags$head(includeCSS("style.css"),
                includeScript("gomap.js")),
      leafletOutput("stateMap", width = "100%", height = "100%"),
      
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
        width = 430,
        height = 560,
        
        selectizeInput(
          'state.tab2',
          h4("Select State"),
          choices = states,
          options = list(
            placeholder = "Choose an option",
            onInitialize = I('function() { this.setValue(""); }')
          )
        ),
        plotOutput("top.10.payers.tab2", height = 250, width = 370),
        plotOutput ('state.top.payers.ts.graph'),
        plotOutput ('state.ts.perc.chg.graph')
        
      ),
      ######## PANEL: TAB 2, RHS ########
      absolutePanel(
        id = "controls",
        class = "panel panel-default",
        fixed = TRUE,
        draggable = TRUE,
        top = 65,
        left = "auto",
        right = 10,
        bottom = "auto",
        width = 430,
        height = 560,
        
        
        selectizeInput(
          "county.tab2",
          h4("Select County"),
          choices = c("county A", "county B"),
          options = list(
            placeholder = "Choose an option",
            onInitialize = I('function() { this.setValue(""); }')
          )
        ),
        plotOutput(
          "top.10.payers.county.tab2",
          height = 250,
          width = 370
        ),
        plotOutput("county.top.payers.ts.graph"),
        plotOutput("county.ts.perc.chg.graph")
      )
    )
  ),
  ######## PANEL: TAB 3########
  tabPanel(
    'Enrollment Data',
    div(class = "outer",
        tags$head(
          includeCSS("style.css"),
          includeScript("gomap.js")
        )),
    absolutePanel(
      id = "controls",
      class = "panel panel-default",
      fixed = TRUE,
      draggable = FALSE,
      top = 65,
      left = "auto",
      right = 10,
      bottom = "auto",
      width = 250,
      height = 400,
      
      selectizeInput(
        "state.tab3",
        h4("Select State"),
        choices = states,
        options = list(
          placeholder = "Choose an option",
          onInitialize = I('function() { this.setValue(""); }')
        )
      ),
      
      selectizeInput(
        "county.tab3",
        h4("Select County"),
        choices = c("County A", "County B"),
        options = list(
          placeholder = "Choose an option",
          onInitialize = I('function() { this.setValue(""); }')
        )
      ),
      #h4("Health Insurers"),
      checkboxGroupInput(
        "insurance.payers",
        h4("Health Insurers"),
        choices = c("Choice A", "Choice B", "Choice C")
      )
    ),
    mainPanel(fluidRow(
      column(
        9,
        plotOutput(
          outputId = "county.top.payers.ts.tab3",
          width = "500px",
          height = "400px"
        )
      ),
      column(
        3,
        plotOutput(
          outputId = "county.ts.perc.chg.tab3",
          width = "500px",
          height = "400px"
        )
      )
    )),
    div(DT::dataTableOutput('state.county.ts.table.tab3')),
    style = "font-size: 75%; width: 75%"
  ),
  
  ######## PANEL: TAB 4########
  tabPanel(
    'Census Data',
    div(
      class = "outer",
      tags$head(includeCSS("style.css"),
                includeScript("gomap.js")),
      leafletOutput("censusMap", width = "100%", height = "100%"),
      
      absolutePanel(
        id = "controls",
        class = "panel panel-default",
        fixed = TRUE,
        draggable = FALSE,
        top = 65,
        left = "auto",
        right = 10,
        bottom = "auto",
        width = 350,
        height = 600,
        
        h4("Medicare Advantage Market"),
        radioButtons(
          inputId = "eligible.scale",
          label = "Type",
          choices = c("Eligibles", "Penetration"),
          inline = TRUE
        ),
        
        selectizeInput(
          'state.tab4',
          h4("Select State"),
          choices = states,
          options = list(
            placeholder = "Choose an option",
            onInitialize = I('function() { this.setValue(""); }')
          )
        ),
        selectizeInput(
          "county.tab4",
          h4("Select County"),
          choices = c("county A", "county B"),
          options = list(
            placeholder = "Choose an option",
            onInitialize = I('function() { this.setValue(""); }')
          )
        ),
        selectizeInput(
          "census.people",
          h4("Select Demographic"),
          choices = colnames(df.people)[4:length(colnames(df.people))],
          options = list(
            placeholder = 'Please select an option below',
            onInitialize = I('function() { this.setValue(""); }')
          )
        ),
        
        tags$h1(valueBoxOutput("people.census.tab4", width = 8), style =
                  "color:blue;"),
        selectizeInput(
          "census.income",
          h4("Select Income Measure"),
          choices = colnames(df.income)[4:length(colnames(df.income))],
          options = list(
            placeholder = 'Please select an option below',
            onInitialize = I('function() { this.setValue(""); }')
          )
        ),
        tags$h1(valueBoxOutput("people.income.tab4", width = 8), style =
                  "color:blue;")
      )
    )
  )
)

#ui <- fluidPage(header)
