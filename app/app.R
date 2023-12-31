library(shiny)
library(paws)


svc <- batch(
    config = list(
        credentials = list(
            creds = list(
                access_key_id = Sys.getenv("AWS_ACCESS_KEY_ID"),
                secret_access_key = Sys.getenv("AWS_SECRET_ACCESS_KEY")
            ),
            profile = "redoak-retriever"
        ),
        endpoint = "https://batch.us-east-1.amazonaws.com",
        region = "us-east-1"
    )
)


ros_submit_batch_job <- function(job_name, job_queue, job_definition, ...){
    
    submit <- svc$submit_job(jobName = job_name,
                             jobQueue = job_queue,
                             jobDefinition = job_definition)
    return(submit)
}


message <- "Click to Launch Penguin Project"


ui <- fluidPage(
    actionButton("penguins", "Click to Launch Penguin Project"),
    hr(),
    textOutput("message"),
    htmlOutput("googleSheet")
)

server <- function(input, output){
    v <- reactiveValues(data = NULL)
    
    observeEvent(input$penguins, {
        
        ros_submit_batch_job(job_name = "r-in-production-call", job_queue = "fargate-test-job-queue", job_definition = "r-in-production-example")
        
        output$message <- renderText({expr = "Penguin Project Launched"})
    })
    
    output$googleSheet <- renderUI({
        tags$iframe(id = "googleSheet",
                    src = "https://docs.google.com/spreadsheets/d/1IN5LTDoweEBBcHRUFI64_eslLy2gBxNFBL2Q_kKB4GE",
                    width = 1400,
                    height = 800,
                    frameborder = 0,
                    marginheight = 0)
    })
    
}

shinyApp(ui, server)
