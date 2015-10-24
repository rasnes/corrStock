# server.R

library(quantmod)
library(shiny)
library(ggplot2)
library(ggfortify)

shinyServer(function(input, output) {
    dataInput <- reactive({
        t1 <- toupper(input$tick_1)
        t2 <- toupper(input$tick_2)
        tick_1 <- getSymbols(t1, src = "yahoo", 
                            from = input$daterange[1],
                            to = input$daterange[2],
                            auto.assign = FALSE)
        tick_2 <- getSymbols(t2, src = "yahoo", 
                             from = input$daterange[1],
                             to = input$daterange[2],
                             auto.assign = FALSE)
        
        # Subset only data of interest (ticker.Adjusted)
        tick_1 <- tick_1[ , paste0(input$tick_1, ".Adjusted")]
        tick_2 <- tick_2[ , paste0(input$tick_2, ".Adjusted")]
        
        # Normalize data
        norm_tick_1 <- tick_1 / as.numeric(head(tick_1, 1)) - 1
        norm_tick_2 <- tick_2 / as.numeric(head(tick_2, 1)) - 1
        
        norm_tick <- merge.xts(norm_tick_1, norm_tick_2)
        
        ## Calculate correlation between stocks
        # Requires: std for each ticker, covariance, avg daily return
        
        daily_1 <- dailyReturn(tick_1)
        daily_2 <- dailyReturn(tick_2)
        avg_1 <- mean(daily_1)
        avg_2 <- mean(daily_2)
        
        cova <- sum((daily_1 - avg_1) * (daily_2 - avg_2)) / (length(norm_tick_1)-1)
        
        std_1 <- sqrt(sum((daily_1 - avg_1)^2) / length(norm_tick_1))
        std_2 <- sqrt(sum((daily_2 - avg_2)^2) / length(norm_tick_1))
        
        corr <- cova / (std_1 * std_2)
        
        return(list(norm_tick, corr))
        
    })
    
    output$plot <- renderPlot({
        autoplot(dataInput()[[1]], facets = F)
    })
    
    output$heading <- renderText({
        "Correlation: "
    })
    
    output$text <- renderText({
        round(dataInput()[[2]],2)
    })
    
    output$doc <- renderText({
"The corrStock app calculates the correlation between 
two stocks for a given time period.
        
Enter the ticker name of the stocks you are interested in
in the fields 'Symbol 1' and 'Symbol 2'. The ticker has to
be written exactly as on Yahoo Finance web pages; only 
capital letters will work. 

The date range defaults to yesterday minus one year until
yesterday. Any date range from 2008 until yesterday is valid.

The calculated correlation is given at the bottom of the left 
side panel. It indicates how much the two stocks moved in 
the same direction over the given time period.

A time series plot is also provided, to better visualize the
relationship between the two stocks.

Stock data source: Yahoo Finance."
    })
    
})