# ui.R

shinyUI(fluidPage(
    titlePanel("corrStock"),
    
    sidebarLayout(
        sidebarPanel(
            textInput("tick_1", label = h3("Symbol 1:"),
                      value = "SPY"),
            textInput("tick_2", label = h3("Symbol 2:"),
                      value = "QQQ"),
            dateRangeInput("daterange", label = h3("Date range:"),
                           start = Sys.Date()-366,
                           end = Sys.Date()-1,
                           max = Sys.Date()-1,
                           min = "2008-01-01"),
            h3(textOutput("heading")),
            h4(textOutput("text"))
        ),
        
        mainPanel(
            tabsetPanel(
                tabPanel("Time series plot", plotOutput("plot")),
                tabPanel("Documentation", verbatimTextOutput("doc"))
            )
            
        )
    )
))