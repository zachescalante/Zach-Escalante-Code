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
  c("Total MA Eligible",
    "Total MA Enrolled",
    "Total MA-C Enrolled",
    "Percent MA-C")

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
        'macroMarket', 'Select Demographic', choices = vars,
        options = list(
          placeholder = 'Please select an option below',
          onInitialize = I('function() { this.setValue(""); }')
        )
      )
    )
  ),
  tabPanel('Length menu',        DT::dataTableOutput('ex2'))
)

ui <- fluidPage(header)
