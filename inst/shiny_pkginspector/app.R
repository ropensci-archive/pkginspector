library(shiny)
library(shinyFiles)
library(visNetwork)

ui <- fluidPage(
    
    titlePanel("Function Dependency Explorer"),
    
    p("Note: This is very rudimentary but it does work. The \"Can\'t find \'\'\" error message will disappear when you choose a package."),
    p("Large packages will take time to render and rerender."),
    p("To try a different package, refresh the app. (At the moment you can only choose a package location once.)"),
    
    shinyDirButton('directory', 'Choose package location', 'Please select a folder'),

    checkboxInput("freeze", "Freeze non-selected nodes", FALSE),
    
    checkboxInput("external", "Include external functions", FALSE),
    
    conditionalPanel(condition = "input.freeze == false",
                     sliderInput("centralGravity",
                                 "centralGravity:",
                                 min = 0,
                                 max = 1,
                                 value = .3)
                     ),
    
    h4("Package location:"),
    
    verbatimTextOutput('directorypath'),
    
    visNetworkOutput("network")
    
)

server <- function(input, output) {
    
    shinyDirChoose(input, 'directory', roots = c(home = '~'))

    output$directorypath <- renderPrint({parseDirPath(c(home='~'), input$directory)})
    
    output$network <- 
        
        renderVisNetwork({
            
        path <- renderText({parseDirPath(c(home='~'), input$directory)})    
            
            
        pkginspector::vis_package(path(),
                                  physics = !input$freeze, external = input$external, centralGravity = input$centralGravity)
            })

}

# Run the application 
shinyApp(ui = ui, server = server)

