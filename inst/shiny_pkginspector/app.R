library(shiny)
library(shinyFiles)
library(visNetwork)

ui <- fluidPage(
    
    sidebarLayout(
        
        sidebarPanel(
            
            h4("Select package location:"),
            
            shinyDirButton('directory', 'Choose folder', 'Please select a folder', buttonType = "success"), br(), 
            br(),
        
        checkboxInput("freeze", "Freeze non-selected nodes", TRUE),
        
        checkboxInput("external", "Include external functions", FALSE),
        
        conditionalPanel(condition = "input.freeze == false",
                         sliderInput("centralGravity",
                                     "centralGravity:",
                                     min = 0,
                                     max = 1,
                                     value = .3)
                         ),
        
        h4("Notes: "),
        p("* When plot renders, hover, click, or choose a function from the dropdown box to see reverse function dependencies. Right click in browser to save image."),
        p("* Large packages may take a minute or more to load."),
        p("* Misses functions called in purrr::map statements and similar (to be fixed)"),
        p("* For more info on rendering function, see:"),
        a("http://rpubs.com/jtr13/vis_package", href = "http://rpubs.com/jtr13/vis_package", target = "_blank")
        
        ),
            
        mainPanel(
    
    titlePanel("Function Dependency Explorer"),
    
    p("Package location:"),
    
    verbatimTextOutput('directorypath'), 
    
    visNetworkOutput("network")
        )
    )
)

server <- function(input, output) {
    
    volumes <- shinyFiles::getVolumes()
    
    shinyDirChoose(input, 'directory', roots = volumes)

    output$directorypath <- renderPrint({parseDirPath(volumes, input$directory)})

    
    observeEvent(input$directory, {
            
        path <- renderText({parseDirPath(volumes, input$directory)})    
            
        output$network <- renderVisNetwork({
            
            pkginspector::vis_package(path(),
                                  physics = !input$freeze, external = input$external, centralGravity = input$centralGravity, icons = FALSE)
        
        })
        
    })
    
    
}

# Run the application 
shinyApp(ui = ui, server = server)

