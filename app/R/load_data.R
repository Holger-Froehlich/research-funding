# R/load_data.R
# Loader: Excel -> Liste mit canonical data.frames

load_excel <- function(path) {
  if (!file.exists(path)) stop("LOAD: File not found: ", path)
  
  sheets <- readxl::excel_sheets(path)
  if (length(sheets) == 0) stop("LOAD: No sheets found in: ", path)
  
  # Canonical sheet keys (App-intern)
  canonical <- c(
    roles = "Roles",
    tools = "Tools",
    paths = "Paths",
    examples = "Examples",
    fmac = "Funding macro",
    fmic = "Funding micro",
    initial_info = "Initial_Information"
  )
  
  # erlaubte Varianten (case-insensitive)
  aliases <- list(
    roles = c("Roles", "Role", "Rollen"),
    tools = c("Tools", "Tool", "Werkzeuge"),
    paths = c("Paths", "Path", "Pfad", "Pfade"),
    examples = c("Examples", "Example", "Beispiele"),
    fmac = c("Funding macro", "Funding landscape macro", "Fmac", "Macro", "Funding_macro", "FundingMacro"),
    fmic = c("Funding micro", "Funding landscape micro", "Fmic", "Micro", "Funding_micro", "FundingMicro"),
    initial_info = c("Initial_Information", "Initial Information", "InitialInfo", "Initial_Info", "Initial")
  )
  
  # Hilfsfunktion: finde tatsächlichen Sheetnamen anhand von Aliases
  find_sheet <- function(key) {
    candidates <- aliases[[key]]
    hit <- sheets[tolower(sheets) %in% tolower(candidates)]
    if (length(hit) == 0) return(NA_character_)
    hit[[1]]
  }
  
  # Standardize colnames (sehr konservativ: nur trim + NBSP raus)
  standardize_colnames <- function(df) {
    nms <- names(df)
    nms <- stringr::str_replace_all(nms, "\u00A0", " ")     # NBSP -> space
    nms <- stringr::str_trim(nms)
    names(df) <- nms
    df
  }
  
  
  read_sheet <- function(sheet) {
    df <- readxl::read_excel(path, sheet = sheet, .name_repair = "minimal")
    df <- as.data.frame(df, stringsAsFactors = FALSE)
    standardize_colnames(df)
  }
  
  # Load all canonical pieces (wenn Sheet nicht gefunden: NULL; Validation stoppt später)
  out <- list(
    roles = NULL,
    tools = NULL,
    paths = NULL,
    examples = NULL,
    fmac = NULL,
    fmic = NULL,
    initial_info = NULL
  )
  
  found <- list()
  
  for (key in names(out)) {
    sheet <- find_sheet(key)
    found[[key]] <- sheet
    if (!is.na(sheet)) out[[key]] <- read_sheet(sheet)
  }
  
  attr(out, "meta") <- list(
    path = normalizePath(path, winslash = "/", mustWork = TRUE),
    sheets_in_file = sheets,
    sheets_mapped = found,
    canonical = canonical
  )
  
  out
}
