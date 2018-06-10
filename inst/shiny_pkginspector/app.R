library(shiny)
library(shinyFiles)
library(visNetwork)

ui <- fluidPage(
    
    titlePanel("Function Dependency Explorer"),
    
    p("This is very rudimentary but it does work. Be aware that large packages may take some time to render and rerender."),
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
    
    network <- eventReactive(input$directory, {
            
        path <- renderText({parseDirPath(c(home='~'), input$directory)})    
            
        pkginspector::vis_package(path(),
                                  physics = !input$freeze, external = input$external, centralGravity = input$centralGravity)
        })
    
    output$network <- 
        
        visNetwork::renderVisNetwork({
            network()
        })
    

}

# Run the application 
shinyApp(ui = ui, server = server)

