##################################################################################
##################################################################################

# Author: Lotte Pohl
# Email: lotte.pohl@vliz.be
# Date: 2026-02-03
# Script Name: ~/DUC2_viewer_acoustic_telemetry/R/module_seabass_telemetry.R
# Script Description: make the Tab of seabass, containing a map on migration predictions,
#                     acoustic telemetry data and environmental layers

##################################################################################
##################################################################################

box::use(
  shiny[NS, moduleServer],
  bslib[navset_card_tab, nav_panel, page_fluid],
  app /
    view /
    seabass /
    migration[
      mod_seabass_migration_ui,
      mod_seabass_migration_server
    ],
  app /
    view /
    seabass /
    telemetry_data[
      mod_seabass_telemetry_ui,
      mod_seabass_telemetry_data_server
    ]
)

mod_seabass_ui <- function(id) {
  ns <- NS(id)
  page_fluid(
    navset_card_tab(
      nav_panel(
        "Migration predictions",
        mod_seabass_migration_ui(ns("migration"))
      ),
      nav_panel(
        "acoustic telemetry data",
        mod_seabass_telemetry_ui(ns("telemetry_data"))
      ),
    )
    # nav_panel("Environmental layers", mod_seabass_env_ui(ns("env")))
  )
}

mod_seabass_server <- function(
  id,
  TEL_deployments,
  etn_monthyear_individual_sum,
  base_map_fun,
  prep_minicharts_inputs_fun,
  make_env_wms_map_fun,
  telemetry_gam_s3,
  wms_layers
) {
  moduleServer(id, function(input, output, session) {
    # Migration submodule
    mod_seabass_migration_server(
      "migration",
      telemetry_gam_s3 = telemetry_gam_s3,
      base_map_fun = base_map_fun # Pass the parameter, not global function
    )

    # Prepare data for the leaflet minicharts (do this ONCE)
    prepped_data <- prep_minicharts_inputs_fun(
      TEL_deployments,
      etn_monthyear_individual_sum
    )

    # Telemetry submodule
    mod_seabass_telemetry_data_server(
      "telemetry_data",
      prepped_data = prepped_data,
      etn_monthyear_individual_sum = etn_monthyear_individual_sum,
      base_map_fun = base_map_fun
    )

    # # Environmental submodule
    # mod_seabass_env_server(
    #   "env",
    #   wms_layers = wms_layers,         # Use parameter name
    #   base_map_fun = base_map_fun,     # Use parameter name
    #   env_map_fun = make_env_wms_map_fun  # Use parameter name
    # )
  })
}
