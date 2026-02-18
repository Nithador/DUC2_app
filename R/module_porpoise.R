mod_porpoise_ui <- function(id) {
  ns <- NS(id)
  
  page_fillable(
    
    layout_columns(
      card(card_header("Map"), 
           leafletOutput(ns("map"), height = "100%"),   # ADD THIS
           fill=TRUE,
           width = "100%"
           
      ),
      navset_card_tab(
        nav_panel(title="Detection Positive Hours per Day",
                  plotOutput('dph_plot', height = '600px')),
        nav_panel(title = 'Daily Distribution of Detections',
                  plotOutput('diurnal_plot', height = '600px')),
        nav_panel(title = 'Pressure Curve?', p('TBD'))
      ),
      
      card(card_header("Station Details"),
           tableOutput("station_table")
      ),
      card(card_header('Settings'),
           sliderInput('YMselect',
                       'Dates:',
                       min = as.Date('2015-01-01', '%Y-%m-%d'),
                       max = as.Date(Sys.Date(), '%Y-%m-%d'),
                       value=c(as.Date('2015-01-01', '%Y-%m-%d'),as.Date(Sys.Date(), '%Y-%m-%d'))),
           imageOutput('logo'),
      ), ## Update this if older data is incorporated
      
      col_widths = c(6,6,8,4),
      row_heights = c(3,1)
    )
    
    
  )
}

mod_porpoise_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    m <- mapview(
      shape,
      zcol = 'density',
      legend = TRUE,
      alpha.regions = 0.6,   # fill transparency (optional)
      color = NA,            # removes gridlines
      lwd = 0,               # just to be safe
      layer.name = 'SCANS IV Porpoise Density'
    ) +
      mapview(
        loc_sf,
        col.regions = "red",
        cex = 4,
        layer.name = 'POD Location'
      )
    
    

    
    # Render map (if using editor)
    
    output$map <- leaflet::renderLeaflet({
      m@map
    })
    
    # Capture edits
    edits <- callModule(editMod, "editor", m@map)
    
    
    # Reactive expression for selected points
    selected_points <- reactive({
      req(edits()$finished)
      st_intersection(edits()$finished, loc_sf)
    })
    
    # Reactive expression for filtered data
    
    selected_data <- reactive({
      req(selected_points())
      selected_groups <- selected_points()$Station
      data=data %>%
        filter(Station %in% selected_groups) %>%
        select(Station, datetime, PPM)
      
      if (length(unique(data$Station)) < 5) {
        showNotification("Fewer than 5 stations selected. Data is not representative.", type = "warning")
      }
      
      data
    })
    
    filtered_data <- reactive({
      req(selected_data())
      data = selected_data() %>%
        
        filter(datetime >= input$YMselect[1],
               datetime <= input$YMselect[2])
      
      if (length(unique(data$Station)) < 5) {
        showNotification("Fewer than 5 stations selected. Data is not representative.", type = "warning")
      }
      
      data
      
      
    })
    
    selectLocs <- reactive({
      req(filtered_data())
      selected_groups <- unique(filtered_data()$Station)
      locations[locations$Station %in% selected_groups, ]
    })
    
    
    
    
    # Table output for station details
    output$station_table <- renderTable({
      req(selectLocs())
      
      selectLocs() %>%
        select(Station, long, lat) %>%
        mutate(
          
          long = format(round(long, 4), nsmall = 4),
          lat = format(round(lat, 4), nsmall = 4)
          
        )
      
      
    })
    
    
    # Example output: print selected data structure
    output$dph_plot <- renderPlot({
      req(filtered_data())
      #print(str(selected_data()))
      DPHpDPDplot(filtered_data())
      
    })
    
    output$diurnal_plot <- renderPlot({
      req(filtered_data())
      req(selectLocs)
      #print(str(selected_data()))
      diurnalPlot(filtered_data(), selectLocs())
      
    })
    
    output$logo <- renderImage({
      list(src = 'AU logo.png', height= '5%')
    }, deleteFile = FALSE)
  })
}
