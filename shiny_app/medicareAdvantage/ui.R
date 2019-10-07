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
    "Total MA Market" = "value_1",
    "MA Part C Market" = "value_2",
    "Total MA-C Enrolled" = "value_3",
    "Percent MA-C" = "value_4"
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

header <- navbarPage(
  title = 'Medicare Advantage',
  tabPanel(
    'Macro Anaysis',
    
    div(class = "outer",
        tags$head(
          # Include our custom CSS
          includeCSS("style.css"),
          includeScript("gomap.js")
        )),
    
    #tags$style(type = "text/css", "#myMap {width: 100vw !important; height: calc(100vh - 44px) !important;}"),
    leafletOutput("myMap", width = "110vw", height = "100vh"),
    
    absolutePanel(
      id = "controls",
      class = "panel panel-default",
      fixed = TRUE,
      draggable = TRUE,
      top = 80,
      left = "auto",
      right = 80,
      bottom = "auto",
      width = 330,
      height = "auto",
      h2("Medicare Advantage Part C"),
      
      selectizeInput(
        'value',
        'Select Demographic',
        choices = vars,
        options = list(
          placeholder = 'Choose an option',
          onInitialize = I('function() { this.setValue("value_1"); }')
        )
      )
    )
  ),
  tabPanel(
    'Length menu',
    textOutput("TestText"),
    leafletOutput("stateMap", width = "110vw", height = "100vh"),
    absolutePanel(
      id = 'controls',
      class = "panel panel-default",
      fixed = TRUE,
      draggable = TRUE,
      top = 80,
      left = "auto",
      right = 80,
      bottom = "auto",
      width = 330,
      height = "auto",
      h2("Select State"),
      selectizeInput(
        "state",
        'Select State',
        choices = states,
        options = list(
          placeholder = "Choose an option",
          onInitialize = I('function() { this.setValue(""); }')
        )
      )
    )
  ),
  tableOutput("dataTable"),
  DT::dataTableOutput('ex2')
)

ui <- fluidPage(header)
