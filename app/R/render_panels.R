# R/render_panels.R
if (!requireNamespace("htmltools", quietly = TRUE)) stop("RENDER: install.packages('htmltools')")

render_markdown_to_html <- function(text) {
  if (is.null(text) || length(text) == 0) return(htmltools::HTML(""))
  t <- paste(as.character(text), collapse = "\n")
  
  # auto-link bare URLs (optional)
  #t <- gsub("(https?://[^\\s<]+)", "[\\1](\\1)", t, perl = TRUE)
  
  if (requireNamespace("commonmark", quietly = TRUE)) {
    htmltools::HTML(commonmark::markdown_html(t, extensions = TRUE))
  } else {
    htmltools::HTML(paste0("<pre>", htmltools::htmlEscape(t), "</pre>"))
  }
}


kv_block <- function(...) {
  htmltools::tags$div(class = "kv", ...)
}

kv_row <- function(label, value_html) {
  htmltools::tagList(
    htmltools::tags$div(class = "kv-label", label),
    htmltools::tags$div(class = "kv-value", value_html)
  )
}

render_initial_panel <- function(initial_info, panel_id) {
  hit <- initial_info[initial_info$Panel_ID == panel_id, , drop = FALSE]
  if (nrow(hit) == 0) {
    return(htmltools::tags$em("Keine Überblicksinformationen vorhanden."))
  }
  
  text_md <- as.character(hit$Text[[1]])
  
  # Only add the icon for FMAC overview (panel_id == "Fmac").
  # For other panels, we just render markdown as before.
  if (!identical(panel_id, "Fmac")) {
    return(
      htmltools::tags$div(
        class = "panel-text",
        render_markdown_to_html(text_md)
      )
    )
  }
  
  # FMAC overview: icon inline at the start of the first line
  icon <- htmltools::tags$img(
    src   = "Fernrohr.png",
    class = "role-icon-inline",
    alt   = "FMAC Überblick",
    # force same size as role icons + baseline alignment (first text line)
    style = "height:56px; width:56px; display:inline-block; vertical-align:baseline; margin-right:12px;"
  )
  
  htmltools::tags$div(
    class = "panel-text",
    # IMPORTANT: no flex here; keep inline flow so icon aligns with first text line
    htmltools::tagList(
      icon,
      render_markdown_to_html(text_md)
    )
  )
}




# --- ROLE PANEL: icon row ABOVE role title (optional Icon_File column)
render_role_panel <- function(roles_df, selected_role_id) {
  r <- roles_df[as.character(roles_df$R_ID) == as.character(selected_role_id), , drop = FALSE]
  if (nrow(r) == 0) return(htmltools::tagList(htmltools::tags$em("Keine Rolle ausgewählt.")))
  
  role_name <- as.character(r$Rolle[[1]])
  
  icon_tag <- NULL
  if ("Icon_File" %in% names(r)) {
    icon_file <- as.character(r$Icon_File[[1]])
    icon_file <- trimws(icon_file)
    
    if (!is.na(icon_file) && nzchar(icon_file)) {
      # robust: encode special chars + absolute path
      icon_url <- paste0("role_icons/", utils::URLencode(icon_file, reserved = TRUE))
      #message("ICON DEBUG url=", icon_url)
      
      icon_tag <- htmltools::tags$img(
        src = icon_url,
        class = "role-icon-inline",
        alt = paste0("Icon ", role_name)
      )
    }
  }
  
  
  header <- htmltools::tags$h3(
    class = "panel-title role-title",
    if (!is.null(icon_tag)) icon_tag,
    htmltools::tags$span(role_name)
  )
  
  leitfrage <- as.character(r$Leitfrage[[1]])
  methode   <- as.character(r$Methode[[1]])
  
  content <- kv_block(
    kv_row("Leitfrage", render_markdown_to_html(leitfrage)),
    kv_row("Methode",   render_markdown_to_html(methode))
  )
  
  htmltools::tagList(
    header,
    htmltools::tags$div(class = "panel-text", content)
  )
}


# --- TOOL PANEL: strict field order as requested
render_tool_panel <- function(tools_df) {
  if (is.null(tools_df) || nrow(tools_df) == 0) {
    return(htmltools::tagList(htmltools::tags$em("Keine Werkzeuge für diese Rolle.")))
  }
  
  # erwartete Spalten (wie vereinbart)
  cols <- c("Informationsart", "Werkzeugtyp", "Zweck", "Werkzeugtyp_Beispiele")
  missing <- setdiff(cols, names(tools_df))
  if (length(missing) > 0) {
    return(htmltools::tagList(
      htmltools::tags$div(
        class = "alert alert-warning",
        paste0("Tools: Fehlende Spalten: ", paste(missing, collapse = ", "))
      )
    ))
  }
  
  cards <- lapply(seq_len(nrow(tools_df)), function(i) {
    t <- tools_df[i, , drop = FALSE]
    
    informationsart <- as.character(t$Informationsart[[1]])
    werkzeugtyp     <- as.character(t$Werkzeugtyp[[1]])
    zweck           <- as.character(t$Zweck[[1]])
    beispiele       <- as.character(t$Werkzeugtyp_Beispiele[[1]])
    
    # Header-Zeile (immer sichtbar)
    header_line <- paste0(
      if (!is.na(informationsart) && nzchar(informationsart)) informationsart else "—",
      " · ",
      if (!is.na(werkzeugtyp) && nzchar(werkzeugtyp)) werkzeugtyp else "—"
    )
    
    htmltools::tags$details(
      class = "tool-details",
      htmltools::tags$summary(
        class = "tool-summary",
        htmltools::tags$div(class = "card-title", header_line),
        htmltools::tags$div(class = "tool-summary-hint", "Details anzeigen")
      ),
      htmltools::tags$div(
        class = "card tool-card-body",
        htmltools::tags$div(
          class = "panel-text",
          kv_block(
            kv_row("Informationsart", htmltools::HTML(htmltools::htmlEscape(informationsart))),
            kv_row("Werkzeugtyp",     htmltools::HTML(htmltools::htmlEscape(werkzeugtyp))),
            kv_row("Zweck",           render_markdown_to_html(zweck)),
            kv_row("Werkzeugtyp_Beispiele", render_markdown_to_html(beispiele))
          )
        )
      )
    )
  })
  
  htmltools::tagList(cards)
}


# --- EXAMPLES PANEL: ordered, markdown cards
render_example_panel <- function(examples_df) {
  if (is.null(examples_df) || nrow(examples_df) == 0) {
    return(htmltools::tagList(htmltools::tags$em("Keine Beispiele für diese Auswahl.")))
  }
  
  if ("E_Order" %in% names(examples_df)) {
    examples_df <- examples_df[order(examples_df$E_Order), , drop = FALSE]
  }
  
  cards <- lapply(seq_len(nrow(examples_df)), function(i) {
    e <- examples_df[i, , drop = FALSE]
    title <- if ("E_Order" %in% names(e)) paste0("Beispiel ", e$E_Order[[1]]) else "Beispiel"
    
    htmltools::tags$div(
      class = "card",
      htmltools::tags$div(class = "card-title", title),
      htmltools::tags$div(class = "card-value", render_markdown_to_html(as.character(e$Example_Text)))
    )
  })
  
  htmltools::tagList(
#    htmltools::tags$h4(class = "panel-subtitle", "Beispiele"),
    htmltools::tagList(cards)
  )
}

# --- FMAC PANEL: headings as specified (Ebene, Akteure, Strategische Bedeutung)
render_fmac_panel <- function(fmac_df, ebene) {
  hit <- fmac_df[as.character(fmac_df$Ebene) == as.character(ebene), , drop = FALSE]
  if (nrow(hit) == 0) {
    return(htmltools::tagList(htmltools::tags$em(paste0("Kein Fmac-Eintrag für Ebene: ", ebene))))
  }
  h <- hit[1, , drop = FALSE]
  
  # Titles for the 4 toggles (comma-separated) in column "Überschrift"
  # Expected order: Organisation, Strategische Bedeutung, Einstiegspfade, Quellen und Referenzen
  titles_raw <- as.character(h$Überschrift[[1]])
  titles <- if (!is.na(titles_raw) && nzchar(titles_raw)) {
    trimws(unlist(strsplit(titles_raw, ",")))
  } else {
    c("Organisation", "Strategische Bedeutung", "Einstiegspfade", "Quellen und Referenzen")
  }
  if (length(titles) < 4) titles <- c(titles, rep("…", 4 - length(titles)))
  titles <- titles[1:4]
  
  # Always visible: Einleitung
  intro <- htmltools::tags$div(
    class = "panel-text",
    render_markdown_to_html(as.character(h$Einleitung[[1]]))
  )
  
  # Helper to create one toggle card (same look/chevron as Tools)
  toggle_card <- function(title, body_md) {
    htmltools::tags$details(
      class = "fmac-details tool-details",   # reuse tool styling
      htmltools::tags$summary(
        class = "tool-summary",              # reuse chevron-right styling
        htmltools::tags$div(class = "card-title", title)
      ),
      htmltools::tags$div(
        class = "card tool-card-body",
        htmltools::tags$div(class = "panel-text", render_markdown_to_html(body_md))
      )
    )
  }
  
  htmltools::tagList(
    # optional: keep Ebene headline if you want
    # htmltools::tags$h3(class="panel-title", as.character(h$Ebene)),
    intro,
    htmltools::tags$div(style="margin-top:10px;",
                        toggle_card(titles[[1]], as.character(h$Organisation[[1]])),
                        toggle_card(titles[[2]], as.character(h$Strategische.Bedeutung[[1]])),
                        toggle_card(titles[[3]], as.character(h$Einstiegspfade[[1]])),
                        toggle_card(titles[[4]], as.character(h$Quellen.und.Referenzen[[1]]))
    )
  )
}
