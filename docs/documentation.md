# Research Funding – Technical Documentation

**Authors:** Holger L. Fröhlich & Jana Holland-Cunz (2026)  
**Context:** HAW BW e.V. – Research & Transfer Service Unit  (Research Funding Advisory)

This document complements the repository `README.md` by focusing on how the Shiny dashboard works from both a **non-technical (Excel-driven)** and a **technical (maintainer)** perspective. It follows GitHub documentation best practices: concise sections, clear lists, and code blocks.

## Table of Contents
- [1. Introduction (how to read this documentation)](#1-introduction-how-to-read-this-documentation)
- [2. Rationale & advisory model](#2-rationale-advisory-model)
- [3. Non-technical user guide (Excel-driven configuration)](#3-non-technical-user-guide-excel-driven-configuration)
- [4. Excel data contract (workbook reference)](#4-excel-data-contract-workbook-reference)
- [5. Extending the dashboard via Excel (recipes)](#5-extending-the-dashboard-via-excel-recipes)
- [6. Technical reference (developers / maintainers)](#6-technical-reference-developers-maintainers)
- [7. Troubleshooting & FAQ](#7-troubleshooting-faq)
## 
## 1. Introduction (how to read this documentation)

This documentation describes the **Research Funding** repository and its Excel-driven Shiny dashboard for **research funding advisory**.

### 1.1 What this documentation is for

It serves two audiences:

- **Non-technical users (advisors / content owners):**  
  You can adapt and extend the dashboard by editing an Excel workbook that acts as the **single source of truth** (the “data contract”). You do not need to modify code to update texts, roles, tools, funding lines, metrics, or strategic tags.

- **Developers / maintainers (technical users):**  
  You can maintain and extend the app code, validation rules, and rendering logic, and you can operate the project in a reproducible environment using `renv`.

### 1.2 What the tool is (and what it is not)

The dashboard is a **structuring and navigation instrument** for advisory practice. It operationalizes a three-layer advisory model (roles → tools → funding landscape) and supports both:
- **macro-level orientation** (FMAC), and
- **micro-level interactive exploration** of funding lines (FMIC).

It is **not** an automated recommendation engine. The design goal is transparency: users can inspect how content, metrics, tags, and explanatory notes shape what is shown.

### 1.3 Reading guide (recommended paths)

**If you mainly work with Excel (non-technical path):**
1. Chapter 2 — Rationale & advisory model  
2. Chapter 3 — Non-technical user guide (how to work with the dashboard)  
3. Chapter 4 — Excel data contract (sheet-by-sheet reference)  
4. Chapter 5 — Recipes (typical extensions and customization patterns)

**If you maintain the code (technical path):**
1. Chapter 2 — Rationale & advisory model (conceptual grounding)  
2. Chapter 6 — Technical reference (architecture, pipeline, extension points)  
3. Chapter 7 — Troubleshooting & FAQ  
4. Chapter 4 — Data contract (when changing schema or validation rules)

### 1.4 Where to start (quick start pointer)

To run the dashboard locally, follow the repository README. In short, you will:
- install R and RStudio,
- restore dependencies via `renv`,
- start the app from the repository root.

### 1.5 Scope and limitations

This documentation describes the current MVP behavior of the tool and its Excel-driven configuration model. The shipped Excel workbook is provided as an **example**; operational use requires contextual review and ongoing maintenance of program information, links, and interpretations.

## 2. Rationale & advisory model

### 2.1 Why this tool exists

Research funding advisory work is characterized by a highly fragmented funding landscape, heterogeneous program logics, and a growing number of information channels. In practice, this creates avoidable complexity: advisors must simultaneously (a) clarify what they are doing in a given advisory situation, (b) decide how to obtain and assess the relevant information, and (c) navigate where in the funding system a project idea can realistically be positioned.

This repository addresses that problem by operationalizing a **three-layer advisory model** and providing a dashboard that makes the model usable and portable across institutions.

### 2.2 The three-layer model (roles → tools → funding landscape)

The model structures funding advisory work into three layers that form a coherent chain of impact:

1. **Roles (What we do):** roles describe the core modes of advisory work (e.g., scouting, fit analysis, curation, strategic advice, consortium development, quality assurance, horizon scanning). Roles provide orientation for team organization and for choosing an adequate advisory stance in a given case.

2. **Information tools (How we do it):** tools are the methodical bridge between advisory roles and the funding world. They provide the information access, analyses, networks, and curated knowledge required to perform roles professionally (e.g., call databases, success-rate/TRL evidence, partner search and networks, compliance resources, internal wikis/dashboards).

3. **Funding landscape (Where we advise towards):** the funding landscape is the orientation space. It helps answer “where should this project idea go” by placing funding levels and lines in a strategic context—e.g., suitability for early career researchers, infrastructure, industry collaboration, internationalization, or specific maturity levels (TRL ranges).

Across layers, the core logic is:

- Roles define *what* advisors need to accomplish.
- Tools determine *how* advisors can access and structure the necessary information.
- The funding landscape clarifies *where* to position a project and which pathways are strategically plausible.

Together, this creates a navigational system that makes tasks, information pathways, and individual proposal strategy transparent and manageable.

### 2.2.1 Process perspective: from research idea to call decision (professor) and decision enablement (advisory)

The three-layer model (roles → tools → funding landscape) can be understood as a navigation system that connects two processes:

**Professor process (user journey)**
1. **Research idea:** a topic, question, or application need emerges.
2. **Strategic framing:** clarify what the project is *for* (e.g., team building, infrastructure, transfer/prototyping, networking, publication profile) and what constraints apply (time, resources, partners).
3. **Seek advisory support:** bring the idea to advisory services to reduce search costs and avoid misalignment with program logics.
4. **Call / program decision:** select a plausible funding pathway and decide whether to pursue a specific call.

**Advisory process (service process)**
1. **Capture the case:** structure the request (goals, maturity/TRL proxy, constraints, strategic intent).
2. **Analyze and triangulate information:** use appropriate information tools (databases, contact points, evidence on competitiveness/success, partner search).
3. **Structure institutional knowledge:** curate and map funding options in a consistent landscape view (macro orientation + micro positioning).
4. **Enable decisions:** present a transparent set of plausible funding lines, trade-offs, and next steps (what to check, who to contact, how to proceed).

**Where they meet**
The key interface is the moment the professor *seeks advisory support* and the advisory service *enables the call decision*. The dashboard supports exactly this interface by:
- providing macro orientation (FMAC) before program selection,
- enabling micro-level exploration of plausible funding lines (FMIC) with interpretable metrics and strategic tags,
- and linking advisory roles and information tools to repeatable workflows.

### 2.3 Two views of the funding landscape: macro (FMAC) and micro (FMIC)

To support both strategic orientation and concrete program selection, the tool splits the funding landscape into:

- **FMAC (macro overview):** a synoptic, coarse-grained view that explains the *systemic contribution* of central funding levels (e.g., state, federal, DFG, EU, foundations) and links them to strategic functions in the university-of-applied-sciences context. It is intended to provide “strategic overall orientation” before moving to specific calls or programs.

- **FMIC (micro navigation / plot):** a structured view of concrete funding lines positioned by meaningful characteristics (e.g., TRL proxy, competitiveness, success indicators, strategic fit tags). This supports matching a project idea to plausible funding lines and exploring trade-offs interactively.

On the micro level (FMIC), **strategic tags** enable cohort-based exploration of funding lines (e.g., *newly appointed professors*, *infrastructure*, *transfer*), strengthening transparent segmentation and strategic matching in advisory conversations.

### 2.4 Portability via a data contract (Excel as single source of truth)

A central design principle is **portability**. The dashboard is driven by a documented Excel workbook used as a **single source of truth**. The app reads the workbook at startup and validates its schema and references. This allows institutions to adapt the tool by maintaining their own Excel file (roles, tools, mappings, texts, funding lines, metrics, tags) without modifying the code.

**Markdown-first content:** textual fields in the Excel workbook are intended to be authored in Markdown and rendered accordingly in the dashboard.

### 2.5 What this tool is (and is not)

This tool is designed as a **structuring and navigation instrument** for advisory practice: it makes advisory roles explicit, connects them to concrete information pathways, and provides strategic orientation in the funding landscape (macro + micro).

It is **not** an automated recommendation engine: the MVP explicitly avoids “black-box scoring” and focuses on transparent filtering, visualization, and structured interpretation.

## 3. Non-technical user guide (Excel-driven configuration)

### 3.1 How to work with this dashboard (in practice)

This dashboard is designed so that non-technical users can adapt and extend the content through **one Excel workbook**. You do **not** need to modify any R code to:

- update role descriptions and advisory guidance texts,
- add new roles, tools, and examples,
- add or update funding lines,
- add new metrics for interactive plotting,
- maintain strategic tags for filtering and segmentation.

In other words: **Excel is the configuration layer** (the “data contract”), and the app renders what is defined there.

### 3.2 The single source of truth: the Excel workbook

The workbook shipped with this repository (`app/data/foerder_dashboard.xlsx`) contains multiple sheets.

> **Note:** The Excel file shipped with this repository is provided as an **example workbook** to demonstrate the data contract and the dashboard behavior. It is not automatically “ready to use” for operational advisory work. Users should review and adapt the content to their context—especially the **currency and correctness** of program information, funding lines, and external references.

Each sheet controls a part of the user interface.

At startup, the app:
1. loads the workbook,
2. validates the schema (required sheets / required columns),
3. renders the dashboard from the workbook contents.

If you keep the required structure intact, you can freely change, add, and reorganize content.

### Live switching via in-app Excel upload

The dashboard includes a collapsible right-side panel with an **Excel upload button**. This allows you to load a different workbook **while the app is running**; the dashboard is then **re-rendered immediately** from the newly uploaded file.

This is particularly useful if you want to switch advisory perspectives within one session—for example, moving from an internal funding advisor view to a target-group-specific view (e.g., newly appointed professors), where roles, texts, tags, and funding-line selections may differ.

### 3.3 Markdown-first content (important)

Many text fields in the workbook are intended to be written in **Markdown**. This makes it possible to format advisory texts with headings, bullet points, emphasis, and links *without changing code*.

Use Markdown in the following fields:

- **Roles**: `Leitfrage`, `Methode`
- **Tools**: `Zweck`, `Typische Werkzeuge`
- **Examples**: `Example_Text`
- **Fmac**: `Einleitung`, `Organisation`, `Strategische.Bedeutung`, `Einstiegspfade`, `Quellen.und.Referenzen`
- **Fmic**: `Begruendung`

Recommended Markdown patterns:
- bullet lists for steps/checklists,
- short headings (`###`) for structure,
- links (`[title](url)`) for sources (especially in FMAC “Sources/Links”).

### 3.4 What changes create what effect (recipes)

This section summarizes common customization tasks and their expected effect in the UI. For details on sheet schemas and required columns, see Chapter 4 (Excel data contract).

#### Recipe A — Add a new advisory role (new tab in “Roles”)
**Goal:** introduce a new advisory role.  
**Excel change:** add one new row in sheet `Roles` (with a new unique `R_ID`).  
**Expected UI effect:** the dashboard shows a **new role tab**; its texts come from `Leitfrage` and `Methode`.  
**Common pitfalls:** missing/duplicate `R_ID`, missing icon file name, or empty role title.

#### Recipe B — Add a new tool and make it appear for a role
**Goal:** add a new information tool and assign it to a role.  
**Excel change:**
1. add a new row in sheet `Tools` with a new unique `T_ID`,
2. add a new row in sheet `Paths` linking `R_ID` ↔ `T_ID` (optional: set `T_Order` for ordering).
**Expected UI effect:** the tool appears in the linked role’s tool list.  
**Common pitfalls:** tool is not visible until it is linked via `Paths`.

#### Recipe C — Add examples for a role–tool path
**Goal:** provide concrete examples of how a tool is used.  
**Excel change:**
1. identify the relevant `Path_ID` in sheet `Paths`,
2. add row(s) to sheet `Examples` with `Path_ID`, `Example_Text`, and optional `E_Order`.
**Expected UI effect:** examples appear under the corresponding role/tool context in the dashboard.

#### Recipe D — Extend the macro funding landscape (FMAC)
**Goal:** add or update strategic overview texts for a funding level (e.g., EU, DFG, federal, state, foundations).  
**Excel change:** edit/add rows in sheet `Fmac` (key: `Ebene`).  
**Expected UI effect:** the FMAC panel shows updated texts for the respective funding level, including “sources/links” in the dedicated section.  
**Common pitfalls:** inconsistent `Ebene` spelling leads to content being shown under an unexpected tab or not found.

#### Recipe E — Add funding lines (FMIC) to the interactive plot
**Goal:** extend the set of funding lines shown in the plot.  
**Excel change:** add new rows to sheet `Fmic` (unique `Fmic_ID`, set `Foerderlinie`, provide values for the plotted metrics).  
**Expected UI effect:** new points appear in the plot (visible when the selected X/Y metrics have valid numeric values).  
**Common pitfalls:** missing values for the currently selected X/Y metrics; non-numeric formatting in metric columns.

#### Recipe F — Add a new selectable metric to the plot (XY_ columns)
**Goal:** introduce an additional metric that can be selected on X or Y axis.  
**Excel change:** add a **new numeric column** in `Fmic` with a name starting with `XY_` (e.g., `XY_NewMetric`). Fill values for at least some rows.  
**Expected UI effect:** the new metric becomes available in the X/Y dropdown selectors.  
**Common pitfalls:** mixed types (text + numbers) prevent numeric conversion; inconsistent decimal separators.

#### Recipe G — Add strategic tags for filtering (Strategische_Eignung)
**Goal:** tag funding lines for strategic cohorts (e.g., “early career”, “newly appointed professors”, “industry cooperation”).  
**Excel change:** in `Fmic`, column `Strategische_Eignung`, add comma-separated tags to relevant rows (e.g., `Neuberufene, Transfer, Postdocs`).  
**Expected UI effect:** tags become available as interactive legend / filter categories; users can focus on tagged subsets.  
**Common pitfalls:** inconsistent spelling (creates multiple near-duplicate tags); missing commas; leading/trailing spaces.

### 3.5 Working safely: do’s and don’ts

**Do**
- Keep `*_ID` columns stable and unique (`R_ID`, `T_ID`, `Path_ID`, `E_ID`, `Fmic_ID`, `Fmac_ID`).
- Use consistent naming for `Ebene` across sheets.
- Prefer Markdown for longer texts and links.
- Add new content first, then verify by running the dashboard.

**Don’t**
- Rename required sheets or required columns without also updating the schema (developer task).
- Mix text and numbers in `XY_*` metric columns.
- Create duplicate IDs (this breaks references between sheets).

### 3.6 Using the FMIC plot (interactive exploration)

The FMIC plot is designed for interactive exploration of funding lines:

- **Select X/Y metrics:** Use the dropdown selectors to choose which `XY_*` metrics are shown on the X and Y axes. This allows you to re-frame the landscape depending on your advisory question (e.g., maturity/TRL vs. competitiveness).

- **Filter by strategic tags (legend categories):** Funding lines can be tagged in Excel (`Fmic.Strategische_Eignung`). These tags become **filter/legend categories** in the plot and enable cohort-based exploration—for example, focusing on funding lines suitable for **newly appointed professors**, **infrastructure**, or **transfer/industry collaboration**.

- **Hover for details (tooltips):** Hover over a point to inspect additional information about a funding line. The tooltip is driven by the Excel rationale field (`Fmic.Begruendung`) and is intended to provide concise interpretation notes and constraints.

> Tip: If you want to switch between different advisory perspectives (e.g., target groups) during one session, use the in-app Excel upload to hot-swap the workbook and re-render the plot instantly (see Section 3.2).

## 4. Excel data contract (workbook reference)

This chapter documents the **Excel workbook schema** used as the dashboard’s single source of truth. The workbook is a **data contract**: if you keep the contract intact, the dashboard can be adapted without code changes.

> **Operational responsibility (important):** The Excel file shipped with this repository is an **example workbook** to demonstrate the data contract and the dashboard behavior. It may contain content that is outdated or not applicable to your institution. Users are responsible for reviewing, updating, and maintaining the **currency and correctness** of program information, funding lines, metrics, and external references before using it operationally.

> **File upload / hot-swap:** The dashboard includes an in-app Excel upload. Any uploaded workbook must follow this data contract (required sheets, required columns, join keys), otherwise the app will stop with validation errors or show incomplete content.

### 4.1 Contract overview (sheets → UI responsibility)

| Sheet | Purpose | Key(s) | Controls / renders |
|------|---------|--------|--------------------|
| `Roles` | Advisory roles | `R_ID` | Role tabs + role texts (Leitfrage/Methode) |
| `Tools` | Information tools catalog | `T_ID` | Tool cards/info used in role-specific tool lists |
| `Paths` | Role ↔ tool mapping | `Path_ID` (+ `R_ID`, `T_ID`) | Which tools appear for which roles; optional ordering |
| `Examples` | Examples per role–tool path | `E_ID` (+ `Path_ID`) | Example texts shown for a given path; optional ordering |
| `Fmac` | Funding landscape macro (levels) | `Fmac_ID` (+ `Ebene`) | Macro-level orientation texts per funding level |
| `Fmic` | Funding landscape micro (funding lines) | `Fmic_ID` | Micro plot points + metrics (`XY_*`) + strategic tags + rationale |
| `Initial_information` | Initial panel texts | `Panel_ID` | Introductory/help texts shown in panels |

### 4.2 Global rules and conventions

#### 4.2.1 Required sheets and allowed sheet name aliases
The loader accepts multiple aliases (case-insensitive) for sheet names. For portability, keep the shipped names if possible. If you rename sheets, ensure they still match one of the allowed aliases, otherwise the loader cannot map them.

#### 4.2.2 IDs and references (joins)
- IDs are treated as **stable identifiers**.
- Recommended: keep all `*_ID` values **unique** within a sheet.
- References must resolve:
  - `Paths.R_ID` must exist in `Roles.R_ID`
  - `Paths.T_ID` must exist in `Tools.T_ID`
  - `Examples.Path_ID` must exist in `Paths.Path_ID`

The app validates required columns and warns about broken references. Broken references typically result in missing tools/examples in the UI.

#### 4.2.3 Ordering fields
Some lists support optional ordering:
- `Paths.T_Order` sorts tools within a role.
- `Examples.E_Order` sorts examples within a path.
If ordering columns are empty, the app falls back to a default ordering.

#### 4.2.4 Markdown-first text fields
Several columns are intended to contain **Markdown** (see Chapter 3). These fields may include headings, bullet lists, and links. Keep links well-formed and avoid very long paragraphs where possible.

#### 4.2.5 Numeric metrics for plotting (`XY_*`)
In `Fmic`, any column whose name starts with `XY_` is treated as a **metric** and becomes selectable for the X/Y axes in the interactive plot.

Rules:
- `XY_*` columns must be numeric (or fully convertible to numeric).
- Use consistent numeric formatting (avoid mixing text with numbers).
- Provide at least **two** `XY_*` columns to enable X/Y plotting.

#### 4.2.6 Strategic tags (`Strategische_Eignung`)
`Fmic.Strategische_Eignung` contains comma-separated tags:
- Use commas as separators (e.g., `Neuberufene, Transfer, Postdocs`).
- Keep spelling consistent to avoid near-duplicate tag categories.
- Trim spaces around tags.

Tags are used for legend/filter behavior in the plot.

### 4.3 Sheet reference (required columns and meaning)

#### 4.3.1 `Roles`
**Required columns**
- `R_ID` (string): unique role identifier
- `Rolle` (string): role title (tab label)
- `Leitfrage` (markdown text): guiding question(s) for this role
- `Methode` (markdown text): methods/activities for this role
- `Icon_File` (string, optional but recommended): filename in `app/www/role_icons/`

**Creates in UI**
- One role tab per row in `Roles`.

**Common pitfalls**
- missing/duplicate `R_ID`
- icon filename does not match a file in `app/www/role_icons/`

#### 4.3.2 `Tools`
**Required columns**
- `T_ID` (string): unique tool identifier
- `Werkzeugkategorie` (string): tool category/type
- `Informationsart` (string): information type (classification)
- `Zweck` (markdown text): purpose/why the tool is used
- `Typische Werkzeuge` (markdown text): examples / how-to notes

**Creates in UI**
- Tool entries/cards that become visible once mapped via `Paths`.

#### 4.3.3 `Paths`
**Required columns**
- `Path_ID` (string): unique path identifier
- `R_ID` (string): role reference (FK → `Roles.R_ID`)
- `T_ID` (string): tool reference (FK → `Tools.T_ID`)
- `T_Order` (numeric/integer, optional): ordering of tools within a role

**Creates in UI**
- Role-specific tool lists (what tools appear under a role)

**Rule**
- A tool row in `Tools` will not appear in the dashboard unless it is linked via `Paths`.

#### 4.3.4 `Examples`
**Required columns**
- `E_ID` (string): unique example identifier
- `Path_ID` (string): path reference (FK → `Paths.Path_ID`)
- `E_Order` (numeric/integer): ordering within a path
- `Example_Text` (markdown text): example content

**Creates in UI**
- Example blocks shown for the corresponding role–tool path.

#### 4.3.5 `Fmac` (Funding landscape macro)
**Required columns (minimum schema)**
- `Fmac_ID` (string): unique macro entry identifier
- `Ebene` (string): funding level (used for tabs/sections)
- `Akteure` (string/text): main actors # deprecated
- `Strategische_Bedeutung` (text): short strategic significance (minimum field) # deprecated

**Additional columns present in the shipped workbook (recommended)**
- `Überschrift` (text): headline/title for the level
- `Einleitung` (markdown text): introduction
- `Organisation` (markdown text): how funding is organized / program logic
- `Strategische.Bedeutung` (markdown text): extended strategic meaning (note: dotted column name)
- `Einstiegspfade` (markdown text): entry paths / orientation
- `Quellen.und.Referenzen` (markdown text): links and references for further research

**Creates in UI**
- FMAC level overview texts per `Ebene`, including a section for sources/links.

**Common pitfalls**
- inconsistent spelling of `Ebene` across workbook → content may end up under unexpected level labels

#### 4.3.6 `Fmic` (Funding landscape micro)
**Required columns (minimum schema)**
- `Fmic_ID` (string): unique funding line identifier
- `Ebene` (string): funding level (for grouping/legend)
- `Foerderlinie` (string): funding line title/label
- `Strategische_Eignung` (comma-separated tags): strategic cohorts/tags
- `Begruendung` (markdown text): rationale / advisory interpretation notes

**Metrics (`XY_*`)**
The shipped workbook includes example metrics such as:
- `XY_Transfernähe (TRL-Skala als Proxy, Mittelwert)`
- `XY_Competitiveness`
- `XY_Erfolgsquote (%)`
- `XY_Prestige (1-5)`
- `XY_Fördersumme (max. €, z.T. geschätzt)`
- `XY_Förderdauer (max. Monate)`

Any additional `XY_*` column you add becomes selectable for X/Y plotting.

**Creates in UI**
- Each row becomes a funding line point (when selected X/Y metrics are available).
- Tags from `Strategische_Eignung` become filter/legend categories.

**Common pitfalls**
- non-numeric values in `XY_*` columns (breaks validation)
- missing values for the currently selected X/Y metrics (points will drop out)
- inconsistent tag spelling (creates duplicated categories)

#### 4.3.7 `Initial_information`
**Required columns**
- `Panel_ID` (string): identifier of a panel/section in the dashboard
- `Text` (markdown or plain text): introductory text shown in the dashboard

**Creates in UI**
- Initial/help content for panels.

### 4.4 Minimal compliance checklist (for new workbooks)

A workbook can be used with the dashboard (including in-app upload) if:
- all required sheets are present (or match allowed aliases),
- all required columns are present,
- `Fmic` has at least two numeric/convertible `XY_*` columns,
- foreign keys resolve (`Paths` → `Roles`/`Tools`, `Examples` → `Paths`),
- tags in `Strategische_Eignung` are comma-separated and consistently spelled.

## 5. Extending the dashboard via Excel (recipes)

This chapter provides practical “recipes” for extending the dashboard by editing the Excel workbook. It is intended for non-technical users who want predictable outcomes while keeping the data contract intact.

> Tip: After each change, re-load the workbook via the in-app upload (hot-swap) to verify the effect immediately.

### 5.1 Recipe: Add a new advisory role (new tab in “Roles”)

**Goal**  
Create a new role tab in the Roles panel.

**Excel change**  
In sheet `Roles`, add a new row with a new unique `R_ID` and fill:
- `Rolle` (tab label)
- `Leitfrage` (Markdown)
- `Methode` (Markdown)
- `Icon_File` (optional but recommended)

**Expected UI effect**  
A new role tab appears with your texts rendered.

**Common pitfalls**
- Duplicate or missing `R_ID`
- Icon filename does not match a file in `app/www/role_icons/`

### 5.2 Recipe: Add a new tool and assign it to a role (via `Paths`)

**Goal**  
Make a new tool visible under a specific role.

**Excel change**  
1) In `Tools`, add a new row with a new unique `T_ID` and fill:
- `Werkzeugkategorie`, `Informationsart`
- `Zweck` (Markdown)
- `Typische Werkzeuge` (Markdown)

2) In `Paths`, add a new row linking:
- `R_ID` (existing role)
- `T_ID` (your new tool)
- optional: `T_Order` to control ordering within the role

**Expected UI effect**  
The tool appears under the selected role.

**Common pitfalls**
- Tool not visible unless linked in `Paths`
- Typos in `T_ID` / `R_ID`

### 5.3 Recipe: Add examples to a role–tool path

**Goal**  
Provide concrete examples for a specific role/tool combination.

**Excel change**  
In `Examples`, add new row(s) with:
- `Path_ID` (from `Paths`)
- `Example_Text` (Markdown)
- `E_Order` (to order multiple examples)

**Expected UI effect**  
Examples appear in the corresponding role/tool context.

### 5.4 Recipe: Add a funding line (FMIC) to the micro plot

**Goal**  
Add additional funding lines as points in the FMIC plot.

**Excel change**  
In `Fmic`, add a new row with:
- `Fmic_ID` (unique)
- `Ebene`, `Foerderlinie`
- values for at least two `XY_*` metric columns
- `Strategische_Eignung` (optional tags)
- `Begruendung` (Markdown)

**Expected UI effect**  
The new funding line becomes available in the plot and appears as a point when the selected X/Y metrics have values.

**Common pitfalls**
- Missing numeric values for the currently selected X/Y metrics (the point will not display)
- Mixed text and numbers in `XY_*` columns

### 5.5 Recipe: Add a new selectable plot metric (`XY_*` columns)

**Goal**  
Make a new metric selectable on the X or Y axis.

**Excel change**  
In `Fmic`, add a new column whose name starts with `XY_` and fill numeric values for relevant rows.

**Expected UI effect**  
The metric becomes selectable in the X/Y dropdowns.

**Common pitfalls**
- Non-numeric values prevent conversion
- Inconsistent number formatting

### 5.6 Recipe: Use strategic tags to create advisory cohorts (filter/legend categories)

**Why this is powerful**  
Strategic tags turn a long list of funding lines into **interpretable cohorts**. This supports strategic advisory conversations by enabling segmentation such as:
- “Which funding lines are particularly suitable for **newly appointed professors**?”
- “Which lines are strong for **infrastructure** or **transfer/industry collaboration**?”
- “Which lines align with a specific strategic profile or target group?”

**Goal**  
Create (or extend) a tag category that you can use to focus the plot on a strategic subset.

**Excel change**  
In `Fmic`, column `Strategische_Eignung`, add comma-separated tags to the relevant funding lines, e.g.:
- `Neuberufene`
- `Infrastruktur`
- `Transfer`
(You can combine multiple tags: `Neuberufene, Transfer`)

**Expected UI effect**  
Tags become **legend/filter categories**. Users can focus on tagged subsets of funding lines.

**Common pitfalls**
- Inconsistent spelling creates near-duplicate tags (e.g., `Infrastruktur` vs `Infra`)
- Missing commas or trailing spaces

### 5.7 Recipe: Inspect additional information via hover (tooltips)

**Goal**  
Provide richer context per funding line beyond the plotted position.

**Excel change**  
In `Fmic`, write explanatory content in `Begruendung` (Markdown). Keep it concise and scannable (bullets work well).

**Expected UI effect**  
When users **hover** over a plot point, they can read additional information about the funding line (e.g., interpretation notes, strategic fit rationale, key constraints).

**Common pitfalls**
- Very long text becomes hard to scan; prefer short structure
- Missing `Begruendung` reduces interpretability of the plot

### 5.8 Recipe: Update FMAC macro overview texts and sources

**Goal**  
Adapt the macro-level funding landscape overview to your institution and keep references current.

**Excel change**  
In `Fmac`, update the Markdown fields:
- `Einleitung`, `Organisation`, `Strategische.Bedeutung`, `Einstiegspfade`, `Quellen.und.Referenzen`

**Expected UI effect**  
Users see updated strategic orientation texts per funding level, including updated sources/links.

**Common pitfalls**
- `Ebene` naming inconsistencies lead to unexpected grouping
- Stale links (review periodically as operational responsibility)

## 6. Technical reference (developers / maintainers)

This chapter documents the technical architecture of the Shiny dashboard, its data pipeline, and key extension points.

### 6.1 Runtime and entry points

- **Shiny app entry point:** `app/app.R`
- **Default data file (shipped example):** `app/data/foerder_dashboard.xlsx`
- **App startup (from repository root):**

```r
shiny::runApp("app")
```

The app is designed to be **Excel-driven**: UI content and many structural elements are derived from the workbook at runtime.

### 6.1.1 Path resolution and app directory detection (APP_DIR)

The app uses a robust directory detection helper (`find_app_dir()`) to locate the deployable `app/` unit.

**Supported start modes**
- Running from inside `app/` (working directory is `.../app`)
- Running from the repository root via `shiny::runApp("app")`

At startup the app prints:


```
APP_DIR: <absolute-path-to-research-funding/app>
```

All internal file references use `APP_DIR` as the anchor, including:
- sourcing modules from `APP_DIR/R/*.R`
- default Excel path: `APP_DIR/data/foerder_dashboard.xlsx`

This design keeps relative paths stable across machines and reduces “file not found” issues when the app is started from different working directories.

### 6.2 Code layout

- `app/app.R`  
    Wires the application together: loads data, validates schema, defines UI (tabs/panels), and defines server logic.
    
- `app/R/load_data.R`  
    Reads the Excel workbook and returns a structured list of data frames (one per sheet). May include tolerant mapping for sheet name variants.
    
- `app/R/validate.R`  
    Validates required sheets and required columns; checks numeric requirements for `XY_*` metrics; checks key/reference integrity (e.g., `Paths` ↔ `Roles/Tools`, `Examples` ↔ `Paths`).
    
- `app/R/transforms.R`  
    Helper transformations: detection of `XY_*` columns, numeric conversion policies, tag parsing (comma-separated), NA handling for plotting, etc.
    
- `app/R/plot_fmic.R`  
    Implements the FMIC micro-level plot: X/Y selection via `XY_*`, grouping/legend logic, strategic tag cohorts derived from `Strategische_Eignung`, and tooltip content (including rationale fields).
    
- `app/R/render_panels.R`  
    Renders markdown/text and builds UI fragments for panels such as Roles, Tools, Examples, FMAC texts, and initial information.
    
- `app/scripts/funding-landscape-plot-standalone.R`  
    Standalone rendering of the micro plot outside of Shiny (useful for generating an HTML plot artifact from the same Excel data contract).
    
### 6.2.1 Runtime data objects and meta information

`load_excel()` returns a list of data frames using canonical keys:

- `roles`
- `tools`
- `paths`
- `examples`
- `fmac`
- `fmic`
- `initial_info`

Additionally, the loader attaches metadata to the list via `attr(out, "meta")`, including:
- normalized file path
- sheets present in the file
- sheet-to-key mapping used (alias resolution)

Maintainers can use this meta information to debug workbook issues (e.g., unexpected sheet names).

### 6.3 Data pipeline (load → validate → transform → render)

At runtime, the app follows a consistent pipeline:

1. **Load**  
    The workbook is read into memory as a list of data frames.
    
2. **Validate**  
    The schema is checked (required sheets/columns) and critical constraints are enforced (notably numeric `XY_*` metrics). Key relationships are checked to prevent broken role–tool–example mappings.
    
3. **Transform**  
    Convenience transformations are applied to support UI choices:
    
    - identify available metrics (`XY_*`) for X/Y selectors,
        
    - parse strategic tags (`Strategische_Eignung`) into cohorts,
        
    - apply numeric conversion / filtering for plotting consistency.
        
4. **Render**  
    UI tabs and panels are generated dynamically from the data contract:
    
    - role tabs from `Roles`,
        
    - tool lists per role from `Paths` + `Tools`,
        
    - examples per path from `Examples`,
        
    - macro overview from `Fmac`,
        
    - micro plot from `Fmic` and selected X/Y metrics.
        

### 6.3.1 Execution flow (call graph light)

The runtime control flow is driven by two load events:

1) **Startup load (default workbook, once)**
- `load_excel(default_path)`
- `validate_all(d)`
- store data and validation output in reactive values

2) **Hot-swap load (user upload, on demand)**
- `load_excel(input$in_excel$datapath)`
- `validate_all(d)`
- update reactive values and show a notification

In pseudo-code:

```r
# once at startup
d <- load_excel(default_path)
v <- validate_all(d)
data_rv(d); val_rv(v)

# whenever a new file is uploaded
d <- load_excel(uploaded_path)
v <- validate_all(d)
data_rv(d); val_rv(v)
```

All UI rendering is downstream of `data_rv()` and therefore updates automatically after a successful upload (hot-swap).


### 6.3.2 Hot-swap mechanics and failure behavior

The Excel upload (`fileInput("in_excel", ...)`) supports **switching workbooks while the app is running**.

**Behavior**
- On successful load+validation: the dashboard is re-rendered immediately from the new workbook.
- On error: the app shows an error notification and keeps the previously loaded dataset active (no “partial state” update).

This provides a safe workflow for live sessions (e.g., switching between target-group-specific workbooks) without restarting the app.

### 6.4 Validation philosophy and failure modes

The app distinguishes between:

- **Hard failures (stop):** missing required sheets/columns; insufficient or non-numeric `XY_*` metrics; critical violations that would invalidate the UI or plot.
    
- **Warnings (continue):** broken references that lead to missing items (e.g., a `Paths.T_ID` not found in `Tools`); these typically degrade a specific panel but do not break the full app.
    

Maintainer recommendation: treat warnings as “data contract debt” and fix them in the Excel workbook.

### 6.4.1 Validation rules catalogue (explicit)

Validation is implemented in `validate_all()` and follows a strict “stop on schema/type issues, warn on reference issues” approach.

**Hard-stop validation (errors)**
- Missing required mapped sheets (any of: roles/tools/paths/examples/fmac/fmic/initial_info)
- Missing required columns per canonical sheet key:
  - `roles`: `R_ID`, `Rolle`, `Leitfrage`, `Methode`
  - `tools`: `T_ID`, `Werkzeugkategorie`, `Informationsart`, `Zweck`, `Typische Werkzeuge`
  - `paths`: `Path_ID`, `R_ID`, `T_ID`
  - `examples`: `E_ID`, `Path_ID`, `E_Order`, `Example_Text`
  - `fmac`: `Fmac_ID`, `Ebene`, `Akteure`, `Strategische_Bedeutung`
  - `fmic`: `Fmic_ID`, `Ebene`, `Foerderlinie`, `Strategische_Eignung`, `Begruendung`
  - `initial_info`: `Panel_ID`, `Text`
- FMIC must provide at least **two** `XY_*` metric columns
- Any `XY_*` column must be numeric or fully convertible; otherwise validation stops with example offending values

**Foreign-key integrity (warnings)**
- `Paths.R_ID` not found in `Roles.R_ID`
- `Paths.T_ID` not found in `Tools.T_ID`
- `Examples.Path_ID` not found in `Paths.Path_ID`
- Optional consistency warning: `Fmic.Ebene` values missing in `Fmac.Ebene`

Warnings degrade specific UI parts (missing tools/examples or missing macro coverage) but do not necessarily prevent the app from running.

### 6.5 Extension points (developer view)

Even though the app is Excel-driven, maintainers may extend behavior in code:

- **Adding new panels:** implement a renderer in `render_panels.R` and add wiring in `app.R`.
    
- **Adding new plot logic:** extend `plot_fmic.R` (e.g., additional encodings, alternative legends, new tooltip fields).
    
- **Changing the data contract:** update validation rules in `validate.R` and loader mapping in `load_data.R`. Document changes in Chapter 4.
    
### 6.5.1 FMIC plot specifics (tags, hover, NA-policy)

The FMIC plot (`plot_fmic()`) is designed as an interpretable navigation view:

**X/Y metrics**
- Axis choices are based on columns starting with `XY_`.
- Axis titles strip the `XY_` prefix for readability.

**NA policy (visibility rule)**
- A funding line is plotted only if it has valid numeric values for *both* selected X and Y metrics.
- Non-numeric but convertible values are coerced to numeric; truly non-convertible values are blocked by validation.

**Strategic tags as filter/legend categories**
- Tags are read from `Strategische_Eignung` (comma-separated).
- For each distinct tag, the plot creates a legend entry (initially `legendonly`) that controls a dedicated `legendgroup`.
- This enables cohort-based exploration (e.g., “Neuberufene”, “Infrastruktur”, “Transfer”) without changing code.

**Hover tooltips (deep context)**
- Hover text is rendered as HTML and includes:
  - program line title
  - funding level
  - strategic tags
  - rationale text (`Begruendung`), wrapped and converted to `<br>` line breaks

This design intentionally combines *position* (metrics) with *interpretation* (rationale and tags) to support advisory conversations.

### 6.6 Reproducible environment (renv)

This repository uses `renv` for reproducible dependency management.

- `renv.lock` defines pinned package versions.
    
- `renv::restore()` installs dependencies on a new machine.
    
- Recommended workflow for maintainers:
    
    - After adding/removing packages: `renv::snapshot()`
        
    - Before releases: verify with a fresh `renv::restore()` and `shiny::runApp("app")`
        

### 6.7 Standalone plot script (how it relates to the app)

The script `app/scripts/funding-landscape-plot-standalone.R` uses the same Excel data contract as the dashboard to render the micro-level funding landscape as a separate artifact. This supports reuse in contexts where Shiny is not desired (e.g., embedding a static HTML plot in documentation or presentations).

## 7. Troubleshooting & FAQ

This chapter collects the most common issues when running or customizing the dashboard.

### 7.1 Installation and environment (renv)

**Q: I cloned/downloaded the repo but packages are missing. What do I do?**  
A: Use `renv` to restore the pinned dependency set:
```r
install.packages("renv")
renv::restore()
shiny::runApp("app")
````

**Q: `renv::restore()` fails or stalls.**  
A: Common causes:

- Temporary network/package repository issues → try again later or switch CRAN mirror.
    
- Missing system libraries (especially on Linux/macOS) → install required OS dependencies for the failing package.
    
- Very restrictive corporate proxies → configure R to use the proxy or install packages via an approved internal mirror.
    

**Q: I see “lockfile is already up to date”. Is that good?**  
A: Yes. It means your `renv.lock` matches the currently detected project dependencies.

### 7.2 App start and working directory

**Q: The app does not start, or cannot find files.**  
A: Start the app from the repository root:

```r
shiny::runApp("app")
```

If you use RStudio, open `research-funding.Rproj` to ensure correct project context.

**Q: How do I verify which directory the app is using?**  
A: At startup the app prints `APP_DIR: ...`. Ensure it points to `.../research-funding/app`.

### 7.3 Excel data issues (schema, types, references)

**Q: The app errors after uploading a workbook.**  
A: The uploaded workbook must comply with the **Excel data contract** (Chapter 4). Typical problems:

- Missing required sheet(s)
    
- Missing required column(s)
    
- Wrong column names (typos or unexpected punctuation)
    
- Non-unique IDs
    
- Broken references between sheets (`Paths` ↔ `Roles/Tools`, `Examples` ↔ `Paths`)
    

**Q: I added a tool but it does not show up.**  
A: Tools must be linked via `Paths`:

- Add tool in `Tools` with a valid `T_ID`
    
- Add mapping row in `Paths` linking `R_ID` to `T_ID`
    

**Q: I added examples but they don’t appear.**  
A: Examples must reference an existing `Path_ID` (sheet `Paths`). Check:

- `Examples.Path_ID` exists in `Paths.Path_ID`
    

**Q: I added a funding line (FMIC) but it does not appear in the plot.**  
A: Most commonly:

- The selected X/Y metrics have missing values for that row.
    
- One of the selected `XY_*` columns contains non-numeric values that prevent conversion.
    
- The row is present but filtered out due to NA handling (only rows with both X and Y values can be plotted).
    

**Q: I added a new `XY_*` metric column, but it does not appear in the dropdown.**  
A: Check:

- Column name starts with `XY_`
    
- Values are numeric / fully convertible
    
- The workbook was reloaded (in-app upload or app restart)
    

**Q: My strategic tags create duplicates in the legend (e.g., “Transfer” and “transfer”).**  
A: Tags are treated as strings. Use consistent spelling and capitalization; remove leading/trailing spaces.

### 7.4 Markdown rendering and text formatting

**Q: My text shows raw Markdown symbols instead of formatting.**  
A: Ensure:

- You edited the intended Markdown fields (Chapter 3.3 / 4.2.4).
    
- The dashboard panel you are viewing renders Markdown (some fields may be shown as plain text depending on panel implementation).
    
- Your Markdown is valid (e.g., proper list syntax, proper link syntax).
    

**Q: Links in FMAC sources do not work or look broken.**  
A: Use standard Markdown links: `[Title](https://example.org)`. Avoid pasting malformed URLs with spaces.

### 7.5 Performance and stability

**Q: RStudio shows “Unable to establish connection with R session …”**  
A: This can happen when working in synchronized folders (e.g., OneDrive/SharePoint/Dropbox) that lock or modify files during runtime or package restores. Recommended mitigations:

- Move the repository to a non-synced local folder (e.g., `C:\Git\research-funding`) for development and `renv::restore()`.
    
- If you must stay in a synced location: pause sync during restore/run, or ensure files are fully local (“always keep on this device”).
    

**Q: The app feels slow after changing the workbook.**  
A: Large workbooks and heavy plots can slow down re-rendering. Keep text fields concise and avoid unnecessary sheet/row duplication.

### 7.6 “Is this workbook ready to use?”

**Q: Can I use the shipped Excel file operationally as-is?**  
A: Treat it as an **example workbook**. You should review and adapt it for your context, especially:

- currency and correctness of program descriptions,
    
- validity of links and references,
    
- correctness of metric values and interpretations.
    

### 7.7 Getting help

If you report issues, include:

- your OS (Windows/macOS/Linux),
    
- R version and RStudio version,
    
- the exact error message,
    
- and (if Excel-related) which sheet/columns were changed.
