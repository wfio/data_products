library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Data Products - Final Project"),
  
  # Sidebar with a slider input for the number of bins
  sidebarLayout(
    sidebarPanel(
      helpText("Select some of the features of the histogram."),
      #call to server to change the bin range of the histogram
      sliderInput("bins", label = h4("Number of bins: ")
                  , min = 5
                  , max = 50
                  , value = 10),
      #call to server to change the color of plot lines
      radioButtons("radio-color", helpText(h5("Select a color for density plot.")),
                   choices = list("Salmon" = "salmon", "Black" = "black"
                                  ,"Red" = "red", "Dark Blue" = "darkblue"
                                  , "Dark Grey" = "darkgrey")
                   ,selected = "salmon"),
      helpText(h5("Select some plot overlays")),
      checkboxInput("checkCurve", label = "Curve", value = FALSE),  #plot curve
      checkboxInput("checkMean", label = "Mean", value = FALSE), #plot mean line
      checkboxInput("checkMed", label = "Median", value = FALSE), #plot med line
      helpText(h5("Generate time series summary statistics")),
      actionButton("tableButton", label = "Daily"),
      actionButton("tableButton2", label = "Monthly")#generate tbl of stats
    ),#end sideBarPanel
    
  # Show a plot of the generated distribution
    mainPanel(
      tabsetPanel(
        tabPanel(p(icon("bar-chart"), "Visualize Data"),
                 plotOutput("histPlot", height = "400px"),
                 plotOutput("cdfPlot", height = "442px"),
                 tableOutput("tableDays"),
                 tableOutput("tableMonths")
        ), #end viz tab
        tabPanel(p(icon("file-text-o"), "About"),
                 h1("About"),
                 h5("This application was built using my Fitbit step data generated
           by a Fitbit Charge HR for the period 01/01/2016 through 04/08/2016. 
As a user you simply need to click the buttons to change the color scheme of the
histogram or to plot abline summary statistics. The 'generate' button will plot
           a data table of the Daily step statistics.")
                 ),#end about tabPanel
        tabPanel(p(icon("table"), "Raw Data"),
                 dataTableOutput("raw-data")
                 )#end rawdataTabPanel
        )#end tabsetPanel
   )#End mainPanel
  )#End sidebarLayout
 )#End fluidPage
)#End ShinyUI
