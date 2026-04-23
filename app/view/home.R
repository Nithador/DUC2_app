box::use(
  shiny[NS, h2, h3, h4, h6, p, hr, br, tags, moduleServer],
  bslib[layout_columns],
  glue[glue],
  app / logic / config[dto_colors, bioflow_url, bioflow_duc2_url]
)

mod_home_ui <- function(
  id,
  bioflow_url = bioflow_url,
  bioflow_duc2_url = bioflow_duc2_url,
  colors = dto_colors
) {
  ns <- NS(id)

  layout_columns(
    tags$div(
      h2("Welcome! 👋"),
      p(
        "Do you want to learn more about marine life and how it may be influenced by offshore infrastructures? You're in the right place!"
      ),

      h3("How to use this app"),

      hr(),
      h4('European Seabass Data'),
      p("<explanations>", style = "margin-bottom: 200px;"),

      hr(),
      h4('Harbour Porpoise Data'),
      p(
        "Here one can visualize acoustic density data for the Harbour Porpoise. Data is visualized over time (days/weeks/months/years) and dirunal patterns.",
        br(),
        "Using the rectangle tool on the left side of the map, select which stations you would like to view the data from. Plots will be automatically generated.  You can add and remove stations as you go, as well as adjust the dates.",
        br(),
        "Note: You should have at least five stations collecting data simultaneously in a given area in order to infer any meaningful pattern from porpoise acoustic density. ",
        style = "margin-bottom: 200px;"
      ),

      h6("Want to learn more?"),
      p("Click the buttons below!"),

      tags$div(
        tags$a(
          "More info on DUC2",
          href = bioflow_duc2_url,
          target = "_blank",
          rel = "noopener",
          class = "btn btn-primary d-flex align-items-center justify-content-center",
          style = glue(
            "margin-bottom:25px;background-color:{dto_colors$blue_medium}; color:white;"
          )
        ),
        tags$br(),
        tags$a(
          tags$img(
            src = "assets/Logo_BIO-Flow2023_Final_Negative.png",
            height = "50px",
            style = "vertical-align:middle"
          ),
          href = bioflow_url,
          target = "_blank",
          rel = "noopener",
          class = "btn btn-primary bioflow-btn bioflow-btn--logo"
        )
      )
    ),
    col_widths = 12
  )
}

mod_home_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    # No server logic yet
  })
}
