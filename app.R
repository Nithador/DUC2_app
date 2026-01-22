library(shiny)
library(DT)
library(sass)
library(yaml)
library(memoise)

ui <- fluidPage(
  titlePanel("DUC2: Impact from offshore infrastructures on marine life"),
  mainPanel(
    tabsetPanel(
      id = "tabsetPanelID",
      type = "tabs",
      
      tabPanel(
        "Home",
        fluidRow(
          column(
            width = 12,
            h3("Welcome! 👋"),
            p("Do you want to learn more about marine life and how it is influenced by offshore infrastructures? You're in the right place!"),
            h4("How to use this app"),
            p("<explanations>", style = "margin-bottom: 200px;"),
            h4("Want to learn more?"),
            p("Click the buttons below!"),
            
            # --- Buttons (links styled as button) ---
            ## DUC2 website
            tags$div(
              #class = "d-flex gap-2 mt-1",  # flex row, small gap, margin-top
              tags$a(
                #HTML("<br>More info on DUC2"),
                "More info on DUC2",
                href = "https://dto-bioflow.eu/use-cases/duc-2-impact-offshore-infrastructures",
                target = "_blank",
                rel = "noopener",
                class = "btn btn-primary d-flex align-items-center justify-content-center",
                style = "margin-bottom:25px;"
              ),
              HTML("<br>"),
              # DTO-Bioflow website
              tags$a(
                tagList(
                  tags$img(
                    src = "Logo_BIO-Flow2023_Final_Negative.png",
                    height = "50px",
                    style = "vertical-align:middle"
                  ),
                  tags$span("", style = "vertical-align:middle;")
                ),
                href = "https://dto-bioflow.eu/",
                target = "_blank",
                rel = "noopener",
                class = "btn btn-primary",
                style = "height:60px;"
              )
            )
          )
        ),
      ),
      tabPanel(
        title = tagList(
          tags$img(
            src = "D_labrax_phylopic.png",
            height = "24px",
            style = "vertical-align:middle; margin-right:8px;"
          ),
          tags$span("European seabass", style = "font-size: 12px; vertical-align:middle;")
        ),
        tabsetPanel(
          tabPanel("Migration predictions", DTOutput("seabass_migration")),
          tabPanel("acoustic telemetry data", DTOutput("acoustic_telemetry")),
          tabPanel("Environmental layers", DTOutput("env_layers"))
        )
      ),
      
      tabPanel(
        title = tagList(
          tags$img(
            src = "P_phocoena_phylopic.png",
            height = "24px",
            style = "vertical-align:middle; margin-right:8px;"
          ),
          tags$span("Harbour porpoise", style = "font-size: 12px; vertical-align:middle;")
        ),
        tabsetPanel(
          tabPanel("PAM dashboard", DTOutput("PAM_dashboard")),
          tabPanel("PAM data", DTOutput("PAM_data")),
          tabPanel("Habitat suitability (Marco-Bolo)", DTOutput("HSM_porpoise"))
        )
      )
    )
  )
)

server <- function(input, output, session) {
  output$seabass_migration <- renderDT(iris)
  DTProxy1 <- dataTableProxy("seabass_migration")
  
  output$acoustic_telemetry <- renderDT(cars)
  DTProxy2 <- dataTableProxy("acoustic_telemetry")
  
  output$env_layers <- renderDT(head(iris, 3))
  DTProxy3 <- dataTableProxy("env_layers")
}

shinyApp(ui, server)
