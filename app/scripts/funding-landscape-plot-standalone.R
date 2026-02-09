# ============================================================
# Funding Landscape Plot (interactive HTML)
# ------------------------------------------------------------
# Purpose:
#   Create an interactive 2D "funding landscape" plot from an Excel
#   data contract. Funding lines (ProgramLine) are positioned by two
#   numeric metrics (XY_*) and enriched with:
#     - FundingLevel (color + marker shape)
#     - StrategicTags (comma-separated; legend-based focus filter)
#     - Rationale (hover tooltip)
#
# Inputs:
#   - Excel workbook with one worksheet containing the plot table.
#   - Required columns: FundingLevel, ProgramLine, StrategicTags, Rationale
#   - Metric columns: any numeric columns starting with "XY_"
#
# Outputs:
#   - A Plotly object in the RStudio viewer
#   - A self-contained HTML file (default: "funding-landscape-plot.html")
#
# Side effects:
#   - Reads a local Excel file from disk
#   - Writes an HTML file to disk
# ============================================================

# ---------------------------
# 0) Libraries
# ---------------------------
# Install once if needed:
# install.packages(c("readxl","dplyr","stringr","plotly","htmlwidgets"))

library(readxl)
library(dplyr)
library(stringr)
library(plotly)
library(htmlwidgets)

# ---------------------------
# 1) Configuration (edit here)
# ---------------------------

excel_path <- "funding-data.xlsx"            # <-- set your file path
sheet_name <- "Funding landscape micro"     # <-- set your worksheet name

# Metric selection:
# Any numeric column starting with "XY_" is considered a plottable metric.
# If x_metric / y_metric are NULL, the script uses the first two XY_* columns found.
x_metric <- NULL
y_metric <- NULL

# Label wrapping (ProgramLine)
label_wrap_width <- 20

# Tooltip wrapping (Rationale)
hover_wrap_width <- 60

# Output file
output_html <- "funding-landscape-plot.html"

# Strategic tag separator (fixed by contract)
strategic_sep <- ","

# Optional: manual label position overrides for specific ProgramLine values
# (use exact ProgramLine strings as keys)
# Example:
# label_pos_overrides <- c(
#   "Some long program line" = "top center",
#   "Another program line"   = "bottom center"
# )
label_pos_overrides <- c()

# ---------------------------
# 2) Helper functions
# ---------------------------

#' Read plot table from Excel
#' @param path Excel file path
#' @param sheet Worksheet name (or index)
#' @return data.frame
read_plot_table <- function(path, sheet) {
  readxl::read_excel(path = path, sheet = sheet)
}

#' Detect metric columns (XY_*) and select X/Y
#' @param df data.frame
#' @param x_metric optional metric column name
#' @param y_metric optional metric column name
#' @return list(x_metric=..., y_metric=..., xy_cols=...)
select_metrics <- function(df, x_metric = NULL, y_metric = NULL) {
  xy_cols <- names(df)[stringr::str_detect(names(df), "^XY_")]

  if (length(xy_cols) < 2) {
    stop("Need at least two numeric columns starting with 'XY_' in the Excel sheet.", call. = FALSE)
  }

  if (is.null(x_metric)) x_metric <- xy_cols[1]
  if (is.null(y_metric)) y_metric <- xy_cols[2]

  if (!(x_metric %in% xy_cols) || !(y_metric %in% xy_cols)) {
    stop("x_metric and y_metric must match existing columns starting with 'XY_'.", call. = FALSE)
  }

  list(x_metric = x_metric, y_metric = y_metric, xy_cols = xy_cols)
}

#' Prepare data for plotting (labels, tooltip HTML, simple label de-overlap)
#' @param df input data.frame
#' @param x_metric x metric column name
#' @param y_metric y metric column name
#' @param label_wrap_width width for ProgramLine wrapping
#' @param hover_wrap_width width for Rationale wrapping
#' @param label_pos_overrides named character vector of textposition overrides
#' @return data.frame
prepare_plot_data <- function(df,
                              x_metric,
                              y_metric,
                              label_wrap_width = 20,
                              hover_wrap_width = 60,
                              label_pos_overrides = c()) {

  df_plot <- df %>%
    mutate(
      FundingLevel = as.factor(FundingLevel),
      # Wrap labels; existing line breaks in Excel are preserved.
      label = stringr::str_wrap(ProgramLine, width = label_wrap_width),
      Rationale_wrapped = stringr::str_wrap(Rationale, width = hover_wrap_width),
      Rationale_html = stringr::str_replace_all(Rationale_wrapped, "\n", "<br>")
    ) %>%
    arrange(FundingLevel, .data[[x_metric]], .data[[y_metric]]) %>%
    group_by(FundingLevel) %>%
    mutate(
      # Simple de-overlap: alternate label position
      text_pos = if_else(row_number() %% 2 == 0, "top center", "bottom center")
    ) %>%
    ungroup()

  # Apply manual overrides (if provided)
  if (length(label_pos_overrides) > 0) {
    df_plot <- df_plot %>%
      mutate(
        text_pos = if_else(
          ProgramLine %in% names(label_pos_overrides),
          unname(label_pos_overrides[ProgramLine]),
          text_pos
        )
      )
  }

  df_plot
}

#' Extract unique strategic focus tags from StrategicTags
#' @param tags_vec character vector
#' @param sep separator (comma)
#' @return character vector of unique tags (trimmed)
extract_tags <- function(tags_vec, sep = ",") {
  all <- paste(tags_vec, collapse = sep)
  tags <- unlist(strsplit(all, sep, fixed = TRUE))
  tags <- trimws(tags)
  unique(tags[nzchar(tags)])
}

# ---------------------------
# 3) Read data
# ---------------------------

# Minimal file existence check (keep it lightweight)
if (!file.exists(excel_path)) {
  stop(paste0("Excel file not found: ", excel_path), call. = FALSE)
}

df <- read_plot_table(excel_path, sheet_name)

# ---------------------------
# 4) Select metrics (XY_*)
# ---------------------------

m <- select_metrics(df, x_metric, y_metric)
x_metric <- m$x_metric
y_metric <- m$y_metric

# ---------------------------
# 5) Prepare plot data
# ---------------------------

# NOTE: This assumes the Excel data contract uses these column names:
#   FundingLevel, ProgramLine, StrategicTags, Rationale, and numeric XY_* columns.
# If your current Excel sheet still uses German column names, rename them there first.

df_plot <- prepare_plot_data(
  df = df,
  x_metric = x_metric,
  y_metric = y_metric,
  label_wrap_width = label_wrap_width,
  hover_wrap_width = hover_wrap_width,
  label_pos_overrides = label_pos_overrides
)

# ---------------------------
# 6) Color + shape mapping by FundingLevel
# ---------------------------

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

df_plot <- df_plot %>%
  mutate(
    color        = level_colors[as.character(FundingLevel)],
    shape_plotly = level_shapes[as.character(FundingLevel)]
  )

# Fallbacks for unknown FundingLevel values
df_plot$color[is.na(df_plot$color)] <- "#000000"
df_plot$shape_plotly[is.na(df_plot$shape_plotly)] <- "circle"

# ---------------------------
# 7) Strategic focus tags (comma-separated)
# ---------------------------

all_tags <- extract_tags(df_plot$StrategicTags, sep = strategic_sep)

# ---------------------------
# 8) Build Plotly object
# ---------------------------

p <- plot_ly(showlegend = TRUE)

# 8a) FundingLevel legend (colors + shapes) — dummy traces
for (lvl in levels(df_plot$FundingLevel)) {
  col <- level_colors[lvl]
  sym <- level_shapes[lvl]
  if (is.na(col)) col <- "#000000"
  if (is.na(sym)) sym <- "circle"

  p <- add_trace(
    p,
    x = 0, y = 0,
    type = "scatter",
    mode = "markers",
    marker = list(size = 10, color = col, symbol = sym),
    name = paste("Level:", lvl),
    showlegend = TRUE,
    hoverinfo = "none",
    visible = "legendonly"
  )
}

# 8b) Strategic focus filter — one legend entry per tag
# Data are replicated per tag to enable legendgroup filtering (as in your current approach).
for (tag in all_tags) {

  df_tag <- df_plot %>%
    filter(stringr::str_detect(StrategicTags, fixed(tag)))

  if (nrow(df_tag) == 0) next

  # Data trace (no legend)
  p <- add_trace(
    p,
    data  = df_tag,
    x     = ~.data[[x_metric]],
    y     = ~.data[[y_metric]],
    type  = "scatter",
    mode  = "markers+text",
    text  = ~label,
    textposition = ~text_pos,
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
    hovertext = ~paste0(
      "<b>", ProgramLine, "</b><br>",
      "<b>Level:</b> ", FundingLevel, "<br>",
      "<b>Strategic tags:</b> ", StrategicTags, "<br>",
      "<b>Rationale:</b><br>", Rationale_html
    ),
    legendgroup = paste0("tag_", tag)
  )

  # Legend trace controlling the tag group visibility
  p <- add_trace(
    p,
    x = 0, y = 0,
    type = "scatter",
    mode = "markers",
    marker = list(
      size  = 9,
      color = "rgba(0,0,0,0)",
      line  = list(color = "#000000", width = 1)
    ),
    name = paste("Focus:", tag),
    showlegend = TRUE,
    hoverinfo = "none",
    inherit = FALSE,
    legendgroup = paste0("tag_", tag),
    visible = "legendonly"
  )
}

# ---------------------------
# 9) Layout
# ---------------------------

# Axis titles: show metric names without the "XY_" prefix
x_title <- sub("^XY_", "", x_metric)
y_title <- sub("^XY_", "", y_metric)

p <- layout(
  p,
  xaxis = list(
    title     = x_title,
    showgrid  = TRUE,
    gridcolor = "#E5E5E5",
    zeroline  = FALSE,
    titlefont = list(size = 16),
    tickfont  = list(size = 12)
  ),
  yaxis = list(
    title     = y_title,
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

# Display in RStudio viewer
p

# ---------------------------
# 10) Save HTML
# ---------------------------

htmlwidgets::saveWidget(
  widget = p,
  file   = output_html,
  selfcontained = TRUE
)

message("Saved interactive plot to: ", output_html)
