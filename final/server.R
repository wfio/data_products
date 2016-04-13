library(shiny)
require(dplyr)
require(lubridate)
require(data.table)

dat <- fread("data/fitbit_data.csv", stringsAsFactors = FALSE, na.strings = "0")
dat$Day <- weekdays(x = as.Date(dat$Date, "%m/%d/%Y"
                                ,label = TRUE, abbr = FALSE))
dat$Date <- as.Date(dat$Day, "%m/%d/%Y")
dat$Steps <- as.numeric(sub(",","",dat$Steps))
dat$`Calories Burned` <- as.numeric(sub(",","",dat$`Calories Burned`))
dat$`Minutes Sedentary` <- as.numeric(sub(",","",dat$`Minutes Sedentary`))
dat$`Activity Calories` <- as.numeric(sub(",","",dat$`Activity Calories`))

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  output$histPlot <- renderPlot({
    steps <- dat$Steps
    bins <- seq(min(steps, na.rm = TRUE), max(steps, na.rm = TRUE)
                , length.out = input$bins + 1)
    
    h <- hist(dat$Steps, breaks = bins, density = 45, col = input$`radio-color`
         , xlim = c(500, 25000)
         , ylim = c(0, 25)
         , xlab = "# of Steps"
         , ylab = "Frequency"
         , main = "Histogram of Steps")
    
    m <- mean(dat$Steps, na.rm = TRUE)
    s <- sqrt(var(dat$Steps, na.rm = TRUE))
    md <- median(dat$Steps, na.rm = TRUE)
    xfit <- seq(min(dat$Steps, na.rm = TRUE)
                , max(dat$Steps, na.rm = TRUE), length = 40)
    yfit <- dnorm(xfit, mean = m, sd = s)
    yfit2 <- yfit*diff(h$mids[1:2])*length(dat$Steps)
    
   if(input$checkCurve == TRUE) {
          lines(xfit, yfit2, col = "darkblue", lwd = 2)
     }#end plot-curve if 
    if(input$checkMean == TRUE) {
       abline(v = m, lwd = 2, col = "blue")    
     }#end plot-mean-if
    if(input$checkMed == TRUE) {
      abline(v = md, lwd = 2, col = "red") 
     }#end plot-median-if
    })#end renderPlot
 
output$table <- renderTable({
  if(input$tableButton == 0) {return()}
  else{
    dat %>%
      group_by(Day) %>%
      summarise(., total = sum(Steps, na.rm=TRUE)
                , avg = mean(Steps, na.rm=TRUE)
                , stdev = sd(Steps, na.rm = TRUE)
                , min = min(Steps, na.rm = TRUE)
                , max = max(Steps, na.rm = TRUE)
                , med = median(Steps, na.rm = TRUE))
  }
})
        
  
})#end shinyServer

