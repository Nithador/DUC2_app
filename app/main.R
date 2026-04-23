box::use(
  shiny[
    NS,
    fluidPage,
    mainPanel,
    moduleServer,
    tagList,
    tabPanel,
    tabsetPanel,
    tags,
    titlePanel
  ],
  app /
    logic /
    config[dto_colors, bioflow_url, bioflow_duc2_url, s3_bucket_seabass_url],
  app / logic / maps[make_base_map, make_env_wms_map],
  app / logic / stac_data[load_STAC_metadata],
  app / logic / seabass / gam_s3[load_acoustic_telemetry_GAM_s3],
  app /
    logic /
    seabass /
    telemetry_wrangle[build_monthyear_rds, prep_minicharts_inputs],
  app / view / home[mod_home_ui, mod_home_server],
  app / view / seabass / main[mod_seabass_ui, mod_seabass_server],
  app / view / porpoise[mod_porpoise_ui, mod_porpoise_server],
  app / view / environmental_data[mod_env_ui, mod_env_server]
)

shiny::addResourcePath(
  "assets",
  normalizePath(file.path("app", "static"), mustWork = TRUE)
)

load(file.path("data", "DTO_DUC2_PpData.Rdata"))
TEL_deployments <- readRDS(file.path("data", "TEL_deployments.rds"))

wms_layers <- load_STAC_metadata(
  metadata_csv = file.path("data", "EDITO_STAC_layers_metadata.csv")
)
telemetry_gam_s3 <- load_acoustic_telemetry_GAM_s3(
  s3_bucket_url = s3_bucket_seabass_url
)
etn_monthyear_individual_sum <- build_monthyear_rds(
  output_path = "etn_sum_seabass_monthyear_individual.rds",
  wms_layer_metadata = wms_layers,
  dataset_key = "seabass acoustic detections"
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  fluidPage(
    tags$head(
      tags$style(htmltools::HTML(glue::glue(
        "\
      :root {{
        --blue-light: {dto_colors$blue_light};
        --blue-medium: {dto_colors$blue_medium};
        --blue-dark: {dto_colors$blue_dark};
      }}
    "
      ))),
      tags$link(rel = "stylesheet", type = "text/css", href = "assets/app.css")
    ),
    titlePanel(
      "Marine life habitat use in potential offshore infrastructure areas"
    ),
    mainPanel(
      width = 12,
      tags$div(
        class = "top-tabs container-fluid",
        tags$a(
          href = bioflow_url,
          target = "_blank",
          rel = "noopener",
          class = "top-tabs-logo",
          tags$img(
            src = "assets/Logo_BIO-Flow2023_Final_Positive.png",
            height = "42px",
            alt = "DTO-Bioflow"
          )
        ),
        tabsetPanel(
          id = ns("tabsetPanelID"),
          type = "tabs",
          tabPanel(
            "Home",
            style = "font-size: 16px;",
            mod_home_ui(
              ns("home"),
              bioflow_url = bioflow_url,
              bioflow_duc2_url = bioflow_duc2_url,
              colors = dto_colors
            )
          ),
          tabPanel(
            title = tagList(
              tags$img(
                src = "assets/D_labrax_phylopic_CC0.png",
                height = "24px",
                style = "vertical-align:middle; margin-right:8px;"
              ),
              tags$span(
                "European seabass",
                style = "font-size: 16px; vertical-align:middle;"
              )
            ),
            class = "lower-level-tabs",
            mod_seabass_ui(ns("seabass"))
          ),
          tabPanel(
            title = tagList(
              tags$img(
                src = "assets/P_phocoena_phylopic_CC0.png",
                height = "24px",
                style = "vertical-align:middle; margin-right:8px;"
              ),
              tags$span(
                "Harbour porpoise",
                style = "font-size: 16px; vertical-align:middle;"
              )
            ),
            class = "lower-level-tabs",
            mod_porpoise_ui(ns("porpoise"))
          ),
          tabPanel(
            title = tags$span(
              "Environmental Layers",
              style = "font-size: 16px; vertical-align:middle;"
            ),
            class = "lower-level-tabs",
            mod_env_ui(
              ns("env"),
              base_map_fun = make_base_map,
              make_env_wms_map_fun = make_env_wms_map,
              wms_layers = wms_layers
            )
          )
        )
      )
    )
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    mod_home_server("home")
    mod_seabass_server(
      "seabass",
      TEL_deployments = TEL_deployments,
      etn_monthyear_individual_sum = etn_monthyear_individual_sum,
      base_map_fun = make_base_map,
      prep_minicharts_inputs_fun = prep_minicharts_inputs,
      make_env_wms_map_fun = make_env_wms_map,
      telemetry_gam_s3 = telemetry_gam_s3,
      wms_layers = wms_layers
    )
    mod_porpoise_server(
      id = "porpoise",
      SCANS_shape = SCANS_shape,
      POD_loc_sf = POD_loc_sf,
      PAM_data = PAM_data,
      PAM_grd = PAM_grd,
      POD_locations = POD_locations,
      base_map_fun = make_base_map
    )
    mod_env_server(
      id = "env",
      wms_layers = wms_layers,
      base_map_fun = make_base_map,
      make_env_wms_map_fun = make_env_wms_map
    )
  })
}
