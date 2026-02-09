# R/validate.R
# Validation: STOP (schema/XY) + WARN (FK integrity)

stop_validation <- function(msg) stop(paste0("VALIDATION: ", msg), call. = FALSE)

validate_required_sheets <- function(data) {
  missing <- names(data)[vapply(data, is.null, logical(1))]
  if (length(missing) > 0) {
    stop_validation(paste0("Missing required sheets (mapped): ", paste(missing, collapse = ", ")))
  }
  TRUE
}

validate_required_columns <- function(data) {
  schema <- list(
    roles = c("R_ID", "Rolle", "Leitfrage", "Methode"),
    tools = c("T_ID", "Werkzeugtyp", "Informationsart", "Zweck", "Werkzeugtyp_Beispiele"),
    paths = c("Path_ID", "R_ID", "T_ID"),
    examples = c("E_ID", "Path_ID", "E_Order", "Example_Text"),
    fmac = c("Fmac_ID", "Ebene", "Akteure", "Strategische_Bedeutung"),
    fmic = c("Fmic_ID", "Ebene", "Foerderlinie", "Strategische_Eignung", "Begruendung"),
    initial_info = c("Panel_ID", "Text")
  )
  
  for (nm in names(schema)) {
    df <- data[[nm]]
    req <- schema[[nm]]
    missing_cols <- setdiff(req, names(df))
    if (length(missing_cols) > 0) {
      stop_validation(paste0("Sheet '", nm, "' missing columns: ", paste(missing_cols, collapse = ", ")))
    }
  }
  TRUE
}

get_xy_vars <- function(fmic_df, prefix = "XY_") {
  grep(paste0("^", prefix), names(fmic_df), value = TRUE)
}

validate_xy_columns_count <- function(fmic_df, min_n = 2) {
  xy <- get_xy_vars(fmic_df)
  if (length(xy) < min_n) {
    stop_validation(paste0("Funding micro needs at least ", min_n, " XY_* columns; found: ", length(xy)))
  }
  TRUE
}

validate_xy_columns_numeric <- function(fmic_df) {
  xy <- get_xy_vars(fmic_df)
  bad <- c()
  
  for (col in xy) {
    v <- fmic_df[[col]]
    if (is.numeric(v)) next
    
    # Try coercion; fail only if there are non-empty values that cannot be numeric
    vv <- as.character(v)
    vv_trim <- stringr::str_trim(vv)
    vv_trim[vv_trim == ""] <- NA_character_
    
    suppressWarnings(num <- as.numeric(vv_trim))
    non_na <- !is.na(vv_trim)
    not_convertible <- non_na & is.na(num)
    
    if (any(not_convertible)) {
      ex <- unique(vv_trim[not_convertible])[1:min(3, length(unique(vv_trim[not_convertible])))]
      bad <- c(bad, paste0(col, " (e.g. ", paste(ex, collapse = " | "), ")"))
    } else {
      # ok: fully convertible -> you may later coerce in transforms/plot
      next
    }
  }
  
  if (length(bad) > 0) {
    stop_validation(paste0("Non-numeric values in XY_* columns: ", paste(bad, collapse = ", ")))
  }
  TRUE
}

validate_fk_integrity <- function(data) {
  warnings <- list()
  
  # Paths -> Roles/Tools
  miss_r <- setdiff(unique(data$paths$R_ID), unique(data$roles$R_ID))
  if (length(miss_r) > 0) warnings$paths_missing_roles <- miss_r
  
  miss_t <- setdiff(unique(data$paths$T_ID), unique(data$tools$T_ID))
  if (length(miss_t) > 0) warnings$paths_missing_tools <- miss_t
  
  # Examples -> Paths
  miss_p <- setdiff(unique(data$examples$Path_ID), unique(data$paths$Path_ID))
  if (length(miss_p) > 0) warnings$examples_missing_paths <- miss_p
  
  # Optional: Micro->Macro level consistency (only warn if both exist)
  if (!is.null(data$fmic) && !is.null(data$fmac)) {
    miss_level <- setdiff(unique(data$fmic$Ebene), unique(data$fmac$Ebene))
    if (length(miss_level) > 0) warnings$fmic_levels_missing_in_fmac <- miss_level
  }
  
  warnings
}

format_fk_warnings <- function(warnings) {
  if (length(warnings) == 0) return("FK: OK (no warnings)")
  lines <- c("FK WARNINGS:")
  for (nm in names(warnings)) {
    vals <- warnings[[nm]]
    vals <- vals[!is.na(vals)]
    show <- paste(head(vals, 20), collapse = ", ")
    more <- if (length(vals) > 20) paste0(" ... +", length(vals) - 20) else ""
    lines <- c(lines, paste0("- ", nm, ": ", show, more))
  }
  paste(lines, collapse = "\n")
}

validate_all <- function(data) {
  validate_required_sheets(data)
  validate_required_columns(data)
  validate_xy_columns_count(data$fmic, min_n = 2)
  validate_xy_columns_numeric(data$fmic)
  fk_warn <- validate_fk_integrity(data)
  list(ok = TRUE, fk_warnings = fk_warn)
}
