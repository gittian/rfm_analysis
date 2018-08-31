#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("RFM Analysis"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      
       fileInput("data","Upload the data: "),
       
       sliderInput("bins","Number of bins: ",
                   min = 1, 
                   max = 100 , 
                   value = 50),
       
       sliderInput("scorebins","Break duration: ",
                   min = 10, 
                   max = 50 , 
                   value = 20),
       
       width = 3
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      tabsetPanel(type = "tabs",
                  
                  tabPanel("Overview"),
                  
                  tabPanel("Frequency table",
                           tags$style(type = "text/css", 
                                      "#freqDist {height: calc(100vh - 150px) !important;}"),
                           plotOutput("freqDist")),
                  
                  tabPanel("RFM Score histogram",
                           tags$style(type = "text/css", 
                                      "#scoreHist {height: calc(100vh - 150px) !important;}"),
                           plotOutput("scoreHist")),
                  
                  tabPanel("RFM output",
                            fluidRow("",
                                     splitLayout(
                                       cellWidths = c("50%","50%"),
                                       plotOutput("graph1"),
                                       plotOutput("graph4")),
                                     plotOutput("graph2"),
                                     plotOutput("graph3"),
                                     plotOutput("graph5"))
                           ),
                  
                  tabPanel("Segmentation",
                           fluidRow("",
                                    plotOutput("segment1"),
                                    plotOutput("segment2"))
                           
                          )
      )
    )
  )
))
