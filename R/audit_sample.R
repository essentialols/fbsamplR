#' Audit an Achieved Sample Against a Recruitment Design
#'
#' Compares accepted achieved respondents with the population and deliberate
#' field targets in a Sampling Planner RecruitmentDesign. Missing achieved
#' counts remain unknown rather than being treated as zero.
#'
#' @param design An object returned by [import_design()] or a RecruitmentDesign
#'   object that [import_design()] can read.
#' @param achieved Either an aggregated data frame with columns `variable`,
#'   `category`, and `achieved_n`, or a respondent-level data frame.
#' @param variable_map For respondent-level data, a named character vector
#'   mapping design variable names to columns in `achieved`, for example
#'   `c(age = "age_group", sex = "sex")`.
#' @param status_col Optional respondent-level column containing acceptance
#'   status. When supplied, only rows whose value is in `accepted_values`
#'   count toward the achieved sample.
#' @param accepted_values Values in `status_col` that count as accepted.
#' @param accepted_n Optional independently known total number of accepted
#'   respondents when `achieved` is already aggregated. Do not infer this by
#'   summing marginal counts.
#'
#' @return An object of class `fbsamplr_audit` with `audit_table`,
#'   `unmatched_counts`, `warnings`, and a compact `summary`.
#' @export
audit_sample <- function(
  design,
  achieved,
  variable_map = NULL,
  status_col = NULL,
  accepted_values = "accepted",
  accepted_n = NULL
) {
  if (!inherits(design, "fbsamplr_design")) design <- import_design(design)
  if (!is.data.frame(achieved)) {
    stop("`achieved` must be a data frame.", call. = FALSE)
  }

  warnings <- character()

  aggregated <- all(c("variable", "category", "achieved_n") %in% names(achieved))
  if (aggregated) {
    counts <- achieved[, c("variable", "category", "achieved_n"), drop = FALSE]
    counts$variable <- as.character(counts$variable)
    counts$category <- as.character(counts$category)
    counts$achieved_n <- as.numeric(counts$achieved_n)

    if (anyNA(counts$variable) || any(trimws(counts$variable) == "") ||
        anyNA(counts$category) || any(trimws(counts$category) == "") ||
        anyNA(counts$achieved_n) || any(counts$achieved_n < 0) ||
        any(counts$achieved_n != floor(counts$achieved_n))) {
      stop("Aggregated achieved counts need non-empty variable/category values and non-negative whole-number achieved_n values.", call. = FALSE)
    }
    if (!is.null(variable_map)) {
      stop("`variable_map` is only used with respondent-level achieved data.", call. = FALSE)
    }
    if (!is.null(status_col)) {
      stop("`status_col` is only used with respondent-level achieved data.", call. = FALSE)
    }
    if (!is.null(accepted_n)) {
      if (length(accepted_n) != 1L || is.na(accepted_n) || accepted_n < 0 || accepted_n != floor(accepted_n)) {
        stop("`accepted_n` must be a non-negative whole number.", call. = FALSE)
      }
      accepted_n <- as.integer(accepted_n)
    }
  } else {
    if (is.null(variable_map) || !length(variable_map) || is.null(names(variable_map)) || any(names(variable_map) == "")) {
      stop(
        "For respondent-level achieved data, provide a named `variable_map` from design variables to data columns.",
        call. = FALSE
      )
    }
    missing_cols <- setdiff(unname(variable_map), names(achieved))
    if (length(missing_cols)) {
      stop(sprintf("Achieved data is missing mapped column(s): %s", paste(missing_cols, collapse = ", ")), call. = FALSE)
    }

    accepted_rows <- rep(TRUE, nrow(achieved))
    if (!is.null(status_col)) {
      if (length(status_col) != 1L || !status_col %in% names(achieved)) {
        stop("`status_col` must name one column in achieved data.", call. = FALSE)
      }
      accepted_rows <- achieved[[status_col]] %in% accepted_values
    } else {
      warnings <- c(warnings, "No status_col was supplied, so every respondent row was treated as accepted.")
    }

    accepted_data <- achieved[accepted_rows, , drop = FALSE]
    accepted_n <- nrow(accepted_data)
    pieces <- list()
    idx <- 1L
    for (variable in names(variable_map)) {
      column <- variable_map[[variable]]
      values <- as.character(accepted_data[[column]])
      keep <- !is.na(values) & trimws(values) != ""
      tab <- table(values[keep], useNA = "no")
      if (!length(tab)) next
      pieces[[idx]] <- data.frame(
        variable = variable,
        category = names(tab),
        achieved_n = as.integer(tab),
        stringsAsFactors = FALSE
      )
      idx <- idx + 1L
    }
    counts <- if (length(pieces)) do.call(rbind, pieces) else data.frame(
      variable = character(),
      category = character(),
      achieved_n = integer(),
      stringsAsFactors = FALSE
    )
  }

  normalize <- function(x) tolower(gsub("[[:space:]]+", " ", trimws(as.character(x))))
  counts$key <- paste(normalize(counts$variable), normalize(counts$category), sep = "\r")
  if (anyDuplicated(counts$key)) {
    dup <- counts[duplicated(counts$key) | duplicated(counts$key, fromLast = TRUE), c("variable", "category"), drop = FALSE]
    stop(
      sprintf(
        "Duplicate achieved count rows found for: %s. Aggregate duplicates before auditing.",
        paste(unique(paste(dup$variable, dup$category, sep = ": ")), collapse = ", ")
      ),
      call. = FALSE
    )
  }

  quota <- design$quota_table
  if (!nrow(quota)) stop("The recruitment design has no quota rows to audit.", call. = FALSE)
  quota$key <- paste(normalize(quota$variable), normalize(quota$category), sep = "\r")
  lookup <- match(quota$key, counts$key)

  field_target <- quota$field_target_n
  field_target[is.na(field_target)] <- quota$population_target_n[is.na(field_target)]

  achieved_values <- rep(NA_integer_, nrow(quota))
  matched <- !is.na(lookup)
  achieved_values[matched] <- as.integer(counts$achieved_n[lookup[matched]])

  gap_population <- ifelse(is.na(achieved_values), NA_integer_, achieved_values - quota$population_target_n)
  gap_field <- ifelse(is.na(achieved_values), NA_integer_, achieved_values - field_target)
  needed <- ifelse(is.na(achieved_values), NA_integer_, pmax(0L, field_target - achieved_values))
  status <- ifelse(
    is.na(achieved_values),
    "unknown",
    ifelse(achieved_values < field_target, "short", ifelse(achieved_values == field_target, "met", "over"))
  )

  audit_table <- tibble::tibble(
    project_id = design$project_id,
    variable = quota$variable,
    category = quota$category,
    population_target_n = as.integer(quota$population_target_n),
    field_target_n = as.integer(field_target),
    deliberate_oversample_n = pmax(0L, as.integer(field_target) - as.integer(quota$population_target_n)),
    achieved_n = achieved_values,
    gap_to_population_n = as.integer(gap_population),
    gap_to_field_n = as.integer(gap_field),
    needed_to_field_target_n = as.integer(needed),
    status = status
  )

  unmatched <- counts[!counts$key %in% quota$key, c("variable", "category", "achieved_n"), drop = FALSE]
  unmatched <- tibble::as_tibble(unmatched)
  if (nrow(unmatched)) {
    warnings <- c(
      warnings,
      sprintf("%d achieved count row(s) did not match a variable/category in the saved design.", nrow(unmatched))
    )
  }
  unknown_n <- sum(audit_table$status == "unknown")
  if (unknown_n) {
    warnings <- c(
      warnings,
      sprintf("%d design cell(s) have no achieved count; they remain unknown rather than zero.", unknown_n)
    )
  }
  warnings <- c(
    warnings,
    "This audit compares accepted achieved counts with planned targets. Matching quotas does not by itself establish representativeness or replace appropriate weighting/inference."
  )

  explicit_oversample <- sum(pmax(0, as.integer(quota$field_target_n) - as.integer(quota$population_target_n)), na.rm = TRUE)
  planned_population_n <- as.integer(design$sample$n)
  planned_field_n <- planned_population_n + explicit_oversample

  out <- list(
    audit_version = "0.1",
    project_id = design$project_id,
    count_basis = "accepted",
    planned_population_n = planned_population_n,
    planned_field_n = planned_field_n,
    accepted_n = if (is.null(accepted_n)) NA_integer_ else as.integer(accepted_n),
    accepted_total_gap_n = if (is.null(accepted_n)) NA_integer_ else as.integer(accepted_n - planned_field_n),
    audit_table = audit_table,
    unmatched_counts = unmatched,
    warnings = warnings,
    summary = list(
      provided_count_rows = nrow(counts),
      matched_count_rows = nrow(counts) - nrow(unmatched),
      unmatched_count_rows = nrow(unmatched),
      audited_cells = nrow(audit_table),
      unknown_cells = sum(audit_table$status == "unknown"),
      short_field_cells = sum(audit_table$status == "short"),
      met_field_cells = sum(audit_table$status == "met"),
      over_field_cells = sum(audit_table$status == "over")
    )
  )
  class(out) <- c("fbsamplr_audit", "list")
  out
}

#' @export
print.fbsamplr_audit <- function(x, ...) {
  cat("<fbsamplr_audit>", x$project_id, "\n")
  cat("Planned field n:", x$planned_field_n, "\n")
  if (!is.na(x$accepted_n)) cat("Accepted n:", x$accepted_n, "\n")
  cat(
    "Cells: short", x$summary$short_field_cells,
    "· met", x$summary$met_field_cells,
    "· over", x$summary$over_field_cells,
    "· unknown", x$summary$unknown_cells, "\n"
  )
  invisible(x)
}
