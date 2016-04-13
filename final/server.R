library(shiny)
require(dplyr)
require(lubridate)
require(data.table)
require(DT)

#use data.table fread to pull extract the data and set NA strings as 0 values
dat <- fread("data/fitbit_data.csv", stringsAsFactors = FALSE, na.strings = "0")
dat$Date <- as.Date(dat$Date, format = "%m/%d/%Y")
dat$Day <- weekdays(dat$Date, abbreviate = FALSE)
dat$Month <- months(dat$Date, abbreviate = FALSE)
dat$Steps <- as.numeric(sub(",","",dat$Steps))
dat$Steps.Ordered <- sort(dat$Steps, na.last = TRUE)
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
    
    #summary statistics for all steps
    m <- mean(dat$Steps, na.rm = TRUE)
    s <- sqrt(var(dat$Steps, na.rm = TRUE))
    md <- median(dat$Steps, na.rm = TRUE)
    n <- length(dat$Steps)
    
    #parameters for plotting normal curve overlay
    xfit <- seq(min(dat$Steps, na.rm = TRUE)
                , max(dat$Steps, na.rm = TRUE), length = 40)
    yfit <- dnorm(xfit, mean = m, sd = s)
    yfit2 <- yfit*diff(h$mids[1:2])*length(dat$Steps)
    dat$Steps.Ordered <- sort(dat$Steps, na.last = TRUE)
    
   if(input$checkCurve == TRUE) {
          lines(xfit, yfit2, col = "darkblue", lwd = 2)
     }#end plot-curve if 
    if(input$checkMean == TRUE) {
       abline(v = m, lwd = 2, col = "blue")    
     }#end plot-mean-if
    if(input$checkMed == TRUE) {
      abline(v = md, lwd = 2, col = "red") 
     }#end plot-median-if
    })#end HistrenderPlot
  
  output$cdfPlot <- renderPlot({
  plot(dat$Steps.Ordered, (1:n)/n, type = 's', ylim = c(0,1), ylab = ''
       , xlab = 'Ordered Sum of Steps'
       , main = 'Cumulative Distribution of Steps')
  abline(v = 13500, h = .75, col = 'red', lwd = 1) #plot 3rd quartile
  legend(13500, 0.3, '3rd Quartile = 13,500', box.lwd = 0, cex = .75)
  legend(11490, .5, 'Median = 11,490', box.lwd = 0, cex = .75)
  mtext(text=expression(hat(F)[n](x)), side = 2, line = 2.5) #hat ylab
}) #end CDFRenderPlot

output$tableDays <- renderTable({
  if(input$tableButton%%2 == 0) {return()}
  else{
    dat %>%
      group_by(Day) %>%
      summarise(., total = sum(Steps, na.rm=TRUE)
                , avg = mean(Steps, na.rm=TRUE)
                , stdev = sd(Steps, na.rm = TRUE)
                , min = min(Steps, na.rm = TRUE)
                , max = max(Steps, na.rm = TRUE)
                , med = median(Steps, na.rm = TRUE))
  }#end else
})#end tableDays

output$tableMonths <- renderTable({
  if(input$tableButton2%%2 == 0) {return ()}
  else{
    dat %>%
      group_by(Month) %>%
      summarise(., total = sum(Steps, na.rm = TRUE)
                , avg = mean(Steps, na.rm = TRUE)
                , min = min(Steps, na.rm = TRUE)
                , max = max(Steps, na.rm = TRUE)
                , stdev = sqrt(var(Steps, na.rm = TRUE))
      ) #end monthlyTable
  }#end else
})#end tableMonths

output$`raw-data` <- renderDataTable({
  datatable(dat)
})
  
})#end shinyServer

