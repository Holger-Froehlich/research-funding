# R/transforms.R
# Kleine, testbare Transformationen ohne Shiny-Kontext

get_xy_vars <- function(fmic_df, prefix = "XY_") {
  grep(paste0("^", prefix), names(fmic_df), value = TRUE)
}

filter_na_for_xy <- function(df, x_var, y_var) {
  if (!x_var %in% names(df)) stop("TRANSFORMS: x_var not found: ", x_var)
  if (!y_var %in% names(df)) stop("TRANSFORMS: y_var not found: ", y_var)
  
  # Coerce to numeric if needed (validated as convertible in validate_xy_columns_numeric)
  x <- df[[x_var]]
  y <- df[[y_var]]
  
  if (!is.numeric(x)) {
    x_chr <- trimws(as.character(x)); x_chr[x_chr == ""] <- NA_character_
    suppressWarnings(df[[x_var]] <- as.numeric(x_chr))
  }
  if (!is.numeric(y)) {
    y_chr <- trimws(as.character(y)); y_chr[y_chr == ""] <- NA_character_
    suppressWarnings(df[[y_var]] <- as.numeric(y_chr))
  }
  
  keep <- !(is.na(df[[x_var]]) | is.na(df[[y_var]]))
  n_dropped <- sum(!keep)
  list(df = df[keep, , drop = FALSE], n_dropped = n_dropped)
}

axis_range_with_padding <- function(values) {
  v <- values
  if (!is.numeric(v)) {
    v_chr <- trimws(as.character(v)); v_chr[v_chr == ""] <- NA_character_
    suppressWarnings(v <- as.numeric(v_chr))
  }
  
  min_v <- min(v, na.rm = TRUE)
  max_v <- max(v, na.rm = TRUE)
  
  if (!is.finite(min_v) || !is.finite(max_v)) {
    stop("TRANSFORMS: axis_range_with_padding got no finite values.")
  }
  
  span <- max_v - min_v
  pad <- if (span == 0) 1 else max(0.10 * span, 0.25)
  c(min_v - pad, max_v + pad)
}

wrap_text <- function(x, width = 20) {
  if (is.null(x)) return(x)
  vapply(as.character(x), function(s) {
    s <- gsub("\u00A0", " ", s)
    paste(strwrap(s, width = width), collapse = "<br>")
  }, character(1))
}

parse_strategic_eignung <- function(x, sep = ",") {
  # returns list-column compatible character vectors (trimmed)
  x_chr <- as.character(x)
  lapply(x_chr, function(s) {
    if (is.na(s) || trimws(s) == "") return(character(0))
    parts <- unlist(strsplit(s, sep, fixed = TRUE), use.names = FALSE)
    trimws(parts[nzchar(trimws(parts))])
  })
}
