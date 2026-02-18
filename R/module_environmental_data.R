mod_env_ui <- function(id,
                       base_map_fun,
                       make_env_wms_map_fun,
                       wms_layers
) {
  ns <- NS(id)
  leafletOutput(ns("env_map"), height = 600)
}


mod_env_server <- function(id, wms_layers, base_map_fun, make_env_wms_map_fun) {
  moduleServer(id, function(input, output, session) {
    output$env_map <- renderLeaflet({
      make_env_wms_map_fun(base_map = base_map_fun(), wms_layers = wms_layers)
    })
  })
}

# 
# mod_env_server< function(id,
#  # "env", 
#   wms_layers,         # Use parameter name
#   base_map_fun,     # Use parameter name
#   make_env_wms_map_fun)  # Use parameter name) 
# {
#   moduleServer(id, function(input, output, session) {
#     output$env_map <- renderLeaflet({
#       make_env_wms_map_fun(base_map = base_map_fun(), wms_layers = wms_layers)
#     })
#   })
# }


