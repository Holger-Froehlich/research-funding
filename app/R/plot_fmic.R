# R/plot_fmic.R
# Plot Engine (Funding micro) – v2 "parity" with funding-landscape-plot.R
# - Level legend (dummy traces)
# - Strategic focus legend (legendgroup; toggle by tag)
# - Colors/shapes by level
# - markers+text with alternating text positions
# - Hover HTML
# - PLUS: axis ranges with padding (Spec freeze)

plot_fmic <- function(fmic_df,
                      x_var,
                      y_var,
                      label_wrap_width = 20,
                      hover_wrap_width = 60,
                      strategic_sep = ",",
                      label_pos_overrides = c()) {
  
  # Packages (explicit, for copy-paste stability)
  if (!requireNamespace("plotly", quietly = TRUE)) stop("PLOT: install.packages('plotly')")
  if (!requireNamespace("stringr", quietly = TRUE)) stop("PLOT: install.packages('stringr')")
  if (!requireNamespace("dplyr", quietly = TRUE)) stop("PLOT: install.packages('dplyr')")
  
  # ---- 0) Column mapping (German spec vs. legacy English naming)
  lvl_col  <- if ("Ebene" %in% names(fmic_df)) "Ebene" else if ("FundingLevel" %in% names(fmic_df)) "FundingLevel" else NA_character_
  line_col <- if ("Foerderlinie" %in% names(fmic_df)) "Foerderlinie" else if ("ProgramLine" %in% names(fmic_df)) "ProgramLine" else NA_character_
  tag_col  <- if ("Strategische_Eignung" %in% names(fmic_df)) "Strategische_Eignung" else if ("StrategicTags" %in% names(fmic_df)) "StrategicTags" else NA_character_
  rat_col  <- if ("Begruendung" %in% names(fmic_df)) "Begruendung" else if ("Rationale" %in% names(fmic_df)) "Rationale" else NA_character_
  
  missing_cols <- c(lvl_col, line_col, tag_col, rat_col)
  if (any(is.na(missing_cols))) {
    stop("PLOT: Missing required columns. Need (Ebene/FundingLevel), (Foerderlinie/ProgramLine), (Strategische_Eignung/StrategicTags), (Begruendung/Rationale).")
  }
  
  # ---- 1) NA policy (Spec): filter + count (uses transforms.R)
  flt <- filter_na_for_xy(fmic_df, x_var, y_var)
  df0 <- flt$df
  n_dropped <- flt$n_dropped
  
  # ---- 2) Prepare plot data (parity with original script)
  df_plot <- df0 |>
    dplyr::mutate(
      FundingLevel   = as.factor(.data[[lvl_col]]),
      ProgramLine    = as.character(.data[[line_col]]),
      StrategicTags  = as.character(.data[[tag_col]]),
      Rationale      = as.character(.data[[rat_col]]),
      # label wrap: keep \n (plotly typically renders as line breaks for text)
      label          = stringr::str_wrap(ProgramLine, width = label_wrap_width),
      Rationale_wrap = stringr::str_wrap(Rationale, width = hover_wrap_width),
      Rationale_html = stringr::str_replace_all(Rationale_wrap, "\n", "<br>")
    ) |>
    dplyr::arrange(FundingLevel, .data[[x_var]], .data[[y_var]]) |>
    dplyr::group_by(FundingLevel) |>
    dplyr::mutate(
      # simple de-overlap: alternate label position
      text_pos = dplyr::if_else(dplyr::row_number() %% 2 == 0, "top center", "bottom center")
    ) |>
    dplyr::ungroup()
  
  # manual overrides (optional; parity feature)
  if (length(label_pos_overrides) > 0) {
    df_plot <- df_plot |>
      dplyr::mutate(
        text_pos = dplyr::if_else(
          ProgramLine %in% names(label_pos_overrides),
          unname(label_pos_overrides[ProgramLine]),
          text_pos
        )
      )
  }
  
  # ---- 3) Color + shape mapping by level (parity)
  level_colors <- c(
    "EU"         = "#005B82",
    "Bund"       = "#008F5A",
    "Land"       = "#76B900",
    "DFG"        = "#4E5968",
    "Stiftung"   = "#F5A623",
    "Wirtschaft" = "#B0003A",
    "Intern"     = "#7B6AA2"
  )
  
  level_shapes <- c(
    "EU"         = "triangle-down",
    "Bund"       = "circle",
    "Land"       = "square",
    "DFG"        = "diamond",
    "Stiftung"   = "triangle-up",
    "Wirtschaft" = "x",
    "Intern"     = "square-open"
  )
  
  df_plot <- df_plot |>
    dplyr::mutate(
      color        = unname(level_colors[as.character(FundingLevel)]),
      shape_plotly = unname(level_shapes[as.character(FundingLevel)])
    )
  
  df_plot$color[is.na(df_plot$color)] <- "#000000"
  df_plot$shape_plotly[is.na(df_plot$shape_plotly)] <- "circle"
  
  # ---- 4) Strategic tags (parity; comma-separated)
  extract_tags <- function(tags_vec, sep = ",") {
    all <- paste(tags_vec, collapse = sep)
    tags <- unlist(strsplit(all, sep, fixed = TRUE), use.names = FALSE)
    tags <- trimws(tags)
    unique(tags[nzchar(tags)])
  }
  all_tags <- extract_tags(df_plot$StrategicTags, sep = strategic_sep)
  
  # ---- 5) Axis ranges with padding (Spec freeze)
  x_range <- axis_range_with_padding(df_plot[[x_var]])
  y_range <- axis_range_with_padding(df_plot[[y_var]])
  
  # Axis titles: remove XY_ prefix (parity)
  x_title <- sub("^XY_", "", x_var)
  y_title <- sub("^XY_", "", y_var)
  
  # ---- 6) Build plotly object
  p <- plotly::plot_ly(showlegend = TRUE)
  
  # 6a) FundingLevel legend (dummy traces; parity)
  for (lvl in levels(df_plot$FundingLevel)) {
    col <- level_colors[lvl]; sym <- level_shapes[lvl]
    if (is.na(col)) col <- "#000000"
    if (is.na(sym)) sym <- "circle"
    
    p <- plotly::add_trace(
      p,
      x = 0, y = 0,
      type = "scatter",
      mode = "markers",
      marker = list(size = 10, color = col, symbol = sym),
      name = paste(lvl),#name = paste("Level:", lvl)
      showlegend = TRUE,
      hoverinfo = "none",
      visible = "legendonly"
    )
  }
  
  # 6b) Strategic focus filter — one legend entry per tag (parity)
  for (tag in all_tags) {
    df_tag <- df_plot |>
      dplyr::filter(stringr::str_detect(StrategicTags, stringr::fixed(tag)))
    
    if (nrow(df_tag) == 0) next
    
    # Hover text (parity)
    df_tag$hovertext <- paste0(
      "<b>", df_tag$ProgramLine, "</b><br>",
      "<b>Level:</b> ", df_tag$FundingLevel, "<br>",
      "<b>Strategic tags:</b> ", df_tag$StrategicTags, "<br>",
      "<b>Rationale:</b><br>", df_tag$Rationale_html
    )
    
    # Data trace (no legend)
    p <- plotly::add_trace(
      p,
      data = df_tag,
      x = df_tag[[x_var]],
      y = df_tag[[y_var]],
      type = "scatter",
      mode = "markers+text",
      text = df_tag$label,
      textposition = df_tag$text_pos,
      textfont = list(size = 12),
      marker = list(
        size   = 9,
        color  = df_tag$color,
        symbol = df_tag$shape_plotly,
        line   = list(color = "#FFFFFF", width = 1)
      ),
      name = paste0("data_", tag),
      showlegend = FALSE,
      hoverinfo = "text",
      hovertext = df_tag$hovertext,
      legendgroup = paste0("tag_", tag)
    )
    
    # Legend trace controlling the tag group visibility (parity)
    p <- plotly::add_trace(
      p,
      x = 0, y = 0,
      type = "scatter",
      mode = "markers",
      marker = list(
        size  = 9,
        color = "rgba(0,0,0,0)",
        line  = list(color = "#000000", width = 1)
      ),
      name = paste(tag),#name = paste("Focus:", tag),
      showlegend = TRUE,
      hoverinfo = "none",
      inherit = FALSE,
      legendgroup = paste0("tag_", tag),
      visible = "legendonly"
    )
  }
  
  # ---- 7) Layout (parity + ranges)
  p <- plotly::layout(
    p,
    xaxis = list(
      title     = x_title,
      range     = x_range,
      showgrid  = TRUE,
      gridcolor = "#E5E5E5",
      zeroline  = FALSE,
      titlefont = list(size = 16),
      tickfont  = list(size = 12)
    ),
    yaxis = list(
      title     = y_title,
      range     = y_range,
      showgrid  = TRUE,
      gridcolor = "#E5E5E5",
      zeroline  = FALSE,
      titlefont = list(size = 16),
      tickfont  = list(size = 12)
    ),
    plot_bgcolor  = "#FFFFFF",
    paper_bgcolor = "#FFFFFF",
    legend = list(
      orientation = "v",
      font = list(size = 12)
    )
  )
  
  list(
    plot = p,
    n_dropped_na = n_dropped,
    x_range = x_range,
    y_range = y_range,
    tags = all_tags,
    levels = levels(df_plot$FundingLevel)
  )
}
