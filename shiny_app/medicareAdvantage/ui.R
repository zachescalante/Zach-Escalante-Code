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
  c("Total MA Market" = "value_1",
    "MA Part C Market" = "value_2",
    "Total MA-C Enrolled" = "value_3",
    "Percent MA-C" = "value_4")

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
        'value', 'Select Demographic', choices = vars,
        options = list(
          placeholder = 'Choose an option',
          onInitialize = I('function() { this.setValue("value_1"); }')
        )
      )
    )
  ),
  tabPanel('Length menu',
           textOutput("TestText"),
           tableOutput("dataTable"),
           DT::dataTableOutput('ex2'))
)

ui <- fluidPage(header)
