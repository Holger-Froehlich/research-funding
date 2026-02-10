# app/app.R
library(shiny)
library(shinydashboard)

# --- Robust project root detection (works with .Rproj)
find_project_root <- function() {
  wd <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
  if (basename(wd) == "app") return(dirname(wd))
  
  cur <- wd
  for (i in 1:10) {
    rproj <- list.files(cur, pattern = "\\.Rproj$", full.names = TRUE)
    if (length(rproj) > 0) return(cur)
    parent <- dirname(cur)
    if (parent == cur) break
    cur <- parent
  }
  wd
}

PROJECT_ROOT <- find_project_root()
cat("PROJECT_ROOT:", PROJECT_ROOT, "\n")

# Serve assets/ via /assets/...
addResourcePath("assets", file.path(PROJECT_ROOT, "assets"))

# --- Source core modules (absolute paths)
source(file.path(PROJECT_ROOT, "R", "load_data.R"))
source(file.path(PROJECT_ROOT, "R", "validate.R"))
source(file.path(PROJECT_ROOT, "R", "transforms.R"))
source(file.path(PROJECT_ROOT, "R", "plot_fmic.R"))
source(file.path(PROJECT_ROOT, "R", "render_panels.R"))

EXCEL_PATH_DEFAULT <- file.path(PROJECT_ROOT, "data", "foerder_dashboard.xlsx")

# --- UI
ui <- dashboardPage(
  dashboardHeader(title = "Fördermittelberatung"),
  
  dashboardSidebar(
    div(
      style = "padding: 10px;",
      fileInput(
        "in_excel",
        "Excel laden (.xlsx)",
        accept = c(".xlsx")
      ),
      uiOutput("out_loaded_file"),
      tags$div(
        style = "font-size:12px; color:#777; margin-top:4px;",
        "Wenn keine Datei gewählt ist, wird die Default-Datei aus /data geladen."
      ),
      tags$hr(),
      uiOutput("out_validation_badge"),
      tags$hr(),
      uiOutput("out_validation_details")
    )
  ),
  
  dashboardBody(
    tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "assets/styles.css")),
    
    fluidRow(
      # --- LEFT: three panels stacked
      column(
        width = 5,
        div(
          class = "col-scroll",
          
          box(
            width = 12,
            title = "Rollen in der Fördermittelberatung",
            status = "info",
            uiOutput("out_role_tabs"),
            tags$hr(),
            uiOutput("out_role_panel")
          ),
          
          box(
            width = 12,
            title = "Werkzeuge der Informationsbeschaffung",
            status = "info",
            uiOutput("out_tool_panel")
          ),
          
          box(
            width = 12,
            title = "Beispiele",
            status = "info",
            uiOutput("out_example_panel")
          )
        )
      ),
      
      # --- RIGHT: plot + macro
      column(
        width = 7,
        div(
          class = "col-scroll",
          
          box(
            width = 12, title = "Förderlandschaft - Förderlinien", status = "primary",
            plotly::plotlyOutput("out_fmic_plot", height = "560px"),
            uiOutput("out_fmic_warning"),
            tags$hr(),
            uiOutput("out_xy_controls")
          ),
          
          box(
            width = 12, title = "Förderlandschaft - strategische Bedeutung", status = "info",
            uiOutput("out_macro_tabs"),
            tags$hr(),
            uiOutput("out_fmac_panel")
          )
        )
      )
    ),
    
    tags$div(
      class = "app-logo-topright",
      tags$img(src = "assets/logo.png", alt = "Logo")
    ),
    
    tags$div(
      class = "app-credits",
      "Credits: Holger L. Fröhlich & Jana Holland-Cunz (2026)"
    )
  )
)

# --- Server
server <- function(input, output, session) {
  
  data_rv   <- reactiveVal(NULL)
  val_rv    <- reactiveVal(list(fk_warnings = list()))
  loaded_rv <- reactiveVal(list(src = "default", name = basename(EXCEL_PATH_DEFAULT), ts = Sys.time()))
  
  # Load default once at startup
  observeEvent(TRUE, {
    d <- load_excel(EXCEL_PATH_DEFAULT)
    v <- validate_all(d)
    data_rv(d); val_rv(v)
    loaded_rv(list(src = "default", name = basename(EXCEL_PATH_DEFAULT), ts = Sys.time()))
  }, once = TRUE)
  
  # Replace data when a user uploads a file (robust error handling)
  observeEvent(input$in_excel, {
    req(input$in_excel$datapath)
    tryCatch({
      d <- load_excel(input$in_excel$datapath)
      v <- validate_all(d)
      data_rv(d); val_rv(v)
      loaded_rv(list(src = "upload", name = input$in_excel$name, ts = Sys.time()))
      showNotification(paste0("Excel geladen: ", input$in_excel$name), type = "message", duration = 3)
    }, error = function(e) {
      showNotification(paste0("Excel NICHT geladen: ", conditionMessage(e)), type = "error", duration = NULL)
    })
  })
  
  # --- Validation badge/details (reactive)
  output$out_validation_badge <- renderUI({
    d <- data_rv()
    v <- val_rv()
    
    if (is.null(d)) return(tags$span(class = "label label-default", "NO DATA"))
    
    has_warn <- length(v$fk_warnings) > 0
    if (!has_warn) {
      tags$span(class = "label label-success", "VALIDATION: OK")
    } else {
      tags$span(class = "label label-warning", "VALIDATION: WARN (FK)")
    }
  })
  
  output$out_validation_details <- renderUI({
    d <- data_rv()
    v <- val_rv()
    if (is.null(d)) return(NULL)
    if (length(v$fk_warnings) == 0) return(NULL)
    tags$pre(style = "white-space: pre-wrap;", format_fk_warnings(v$fk_warnings))
  })
  
  output$out_loaded_file <- renderUI({
    x <- loaded_rv()
    tags$div(style = "font-size:12px; color:#777;",
             paste0("Aktiv: ", x$src, " | ", x$name, " | ", format(x$ts, "%H:%M:%S")))
  })
  
  # --- Role tabs (dynamic)
  output$out_role_tabs <- renderUI({
    d <- data_rv(); req(d)
    default_role <- d$roles$R_ID[[1]]
    
    tabs <- lapply(seq_len(nrow(d$roles)), function(i) {
      tabPanel(title = d$roles$Rolle[[i]], value = d$roles$R_ID[[i]])
    })
    
    do.call(tabsetPanel, c(list(id = "in_role", type = "tabs", selected = default_role), tabs))
  })
  
  # --- Macro tabs (dynamic; preserve table order by Fmac_ID)
  output$out_macro_tabs <- renderUI({
    d <- data_rv(); req(d)
    
    fmac_df <- d$fmac
    if ("Fmac_ID" %in% names(fmac_df)) {
      fmac_df <- fmac_df[order(as.character(fmac_df$Fmac_ID)), , drop = FALSE]
    }
    macro_levels <- unique(as.character(fmac_df$Ebene))
    
    tabs <- c(
      list(tabPanel(title = "Überblick", value = "__initial__")),
      lapply(macro_levels, function(lvl) tabPanel(title = lvl, value = lvl))
    )
    
    do.call(tabsetPanel, c(list(id = "in_macro_level", type = "tabs", selected = "__initial__"), tabs))
  })
  
  # --- XY controls (dynamic)
  output$out_xy_controls <- renderUI({
    d <- data_rv(); req(d)
    
    xy_vars <- get_xy_vars(d$fmic)
    xy_vars <- as.character(unlist(xy_vars))
    
    cur_x <- isolate(input$in_x_var)
    cur_y <- isolate(input$in_y_var)
    
    sel_x <- if (!is.null(cur_x) && cur_x %in% xy_vars) cur_x else xy_vars[[1]]
    sel_y <- if (!is.null(cur_y) && cur_y %in% xy_vars) cur_y else xy_vars[[min(2, length(xy_vars))]]
    
    fluidRow(
      column(6, selectInput("in_x_var", "X-Achse (XY_*)",
                            choices = xy_vars, selected = sel_x, multiple = FALSE)),
      column(6, selectInput("in_y_var", "Y-Achse (XY_*)",
                            choices = xy_vars, selected = sel_y, multiple = FALSE))
    )
  })
  
  # --- Plot (reactive on data + x/y)
  plot_res <- reactive({
    d <- data_rv(); req(d, input$in_x_var, input$in_y_var)
    plot_fmic(d$fmic, input$in_x_var, input$in_y_var)
  })
  
  output$out_fmic_plot <- plotly::renderPlotly({
    plot_res()$plot
  })
  
  output$out_fmic_warning <- renderUI({
    n <- plot_res()$n_dropped_na
    if (is.null(n) || n == 0) return(NULL)
    div(class = "alert alert-warning",
        paste0(n, " Einträge wegen fehlender Werte in X/Y ausgeblendet."))
  })
  
  # --- Role / Tools / Examples (reactive on data + selected role)
  paths_for_role <- reactive({
    d <- data_rv(); req(d, input$in_role)
    d$paths[d$paths$R_ID == input$in_role, , drop = FALSE]
  })
  
  tools_for_role <- reactive({
    d <- data_rv(); req(d)
    p <- paths_for_role()
    if (nrow(p) == 0) return(d$tools[0, , drop = FALSE])
    m <- merge(p, d$tools, by = "T_ID", all.x = TRUE)
    if ("T_Order" %in% names(m)) m <- m[order(m$T_Order), , drop = FALSE]
    m
  })
  
  examples_for_role <- reactive({
    d <- data_rv(); req(d)
    p <- paths_for_role()
    if (nrow(p) == 0) return(d$examples[0, , drop = FALSE])
    m <- merge(p, d$examples, by = "Path_ID", all.x = TRUE)
    if ("E_Order" %in% names(m)) m <- m[order(m$E_Order), , drop = FALSE]
    m
  })
  
  output$out_role_panel <- renderUI({
    d <- data_rv(); req(d, input$in_role)
    render_role_panel(d$roles, input$in_role)
  })
  
  output$out_tool_panel <- renderUI({
    render_tool_panel(tools_for_role())
  })
  
  output$out_example_panel <- renderUI({
    render_example_panel(examples_for_role())
  })
  
  # --- Macro panel (Fmac)
  output$out_fmac_panel <- renderUI({
    d <- data_rv(); req(d, input$in_macro_level)
    if (identical(input$in_macro_level, "__initial__")) {
      render_initial_panel(d$initial_info, panel_id = "Fmac")
    } else {
      render_fmac_panel(d$fmac, ebene = input$in_macro_level)
    }
  })
}

shinyApp(ui, server)
