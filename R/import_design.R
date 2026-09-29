#' Import a Sampling Planner Recruitment Design
#'
#' Reads a `RecruitmentDesign v0.2` JSON object produced by Sampling Planner
#' (or an equivalent list) and converts it into an R object with a tidy quota
#' table. Population targets and deliberate field targets remain separate.
#'
#' @param x A file path, URL, JSON string, or already-parsed R list containing
#'   a RecruitmentDesign object.
#'
#' @return An object of class `fbsamplr_design`. The original design is kept in
#'   `raw`; `quota_table` contains one row per variable/category.
#' @export
import_design <- function(x) {
  design <- read_recruitment_design(x)
  validate_recruitment_design(design)

  quota_table <- recruitment_design_quota_table(design)
  field_targets <- design$field_targets %||% list()
  eligibility <- design$eligibility %||% list(
    description = design$population$description %||% design$population$universe %||% "Unspecified",
    criteria = list(),
    source = "benchmark_population",
    benchmark_relation = "same_as_benchmark"
  )
  field_composition <- design$field_composition %||% list(
    mode = if (any(!is.na(quota_table$oversample_n) & quota_table$oversample_n > 0)) {
      "population_targets_plus_deliberate_oversamples"
    } else {
      "population_targets"
    },
    population_target_variables = unique(quota_table$variable),
    deliberate_field_targets = field_targets
  )

  out <- list(
    schema_version = design$schema_version,
    project_id = design$project_id,
    project_name = design$project_name %||% design$project_id,
    eligibility = eligibility,
    population = design$population,
    field_composition = field_composition,
    sample = design$sample,
    study_goal = design$study_goal,
    quota_table = quota_table,
    field_targets = field_targets,
    warnings = design$warnings %||% list(),
    provenance = design$provenance,
    raw = design
  )
  class(out) <- c("fbsamplr_design", "list")
  out
}

#' Extract the Quota Table from an Imported Recruitment Design
#'
#' @param design An object returned by [import_design()].
#'
#' @return A tibble with population targets and any separate field targets.
#' @export
design_quota_table <- function(design) {
  if (!inherits(design, "fbsamplr_design")) {
    stop("`design` must be an object returned by import_design().", call. = FALSE)
  }
  design$quota_table
}

#' @export
print.fbsamplr_design <- function(x, ...) {
  cat("<fbsamplr_design>", x$project_id, "\n")
  if (!is.null(x$eligibility$description)) cat("Eligibility:", x$eligibility$description, "\n")
  if (!is.null(x$population$description)) cat("Benchmark population:", x$population$description, "\n")
  if (!is.null(x$field_composition$mode)) cat("Field composition:", x$field_composition$mode, "\n")
  if (!is.null(x$sample$n)) cat("n:", x$sample$n, "\n")
  cat("Quota rows:", nrow(x$quota_table), "\n")
  invisible(x)
}

read_recruitment_design <- function(x) {
  if (is.list(x)) return(x)
  if (!is.character(x) || length(x) != 1L || is.na(x)) {
    stop("`x` must be a RecruitmentDesign list, file path, URL, or JSON string.", call. = FALSE)
  }

  text <- trimws(x)
  if (grepl("^https?://", text, ignore.case = TRUE)) {
    return(jsonlite::fromJSON(text, simplifyVector = FALSE))
  }
  if (file.exists(text)) {
    return(jsonlite::fromJSON(text, simplifyVector = FALSE))
  }
  if (startsWith(text, "{")) {
    return(jsonlite::fromJSON(text, simplifyVector = FALSE))
  }
  stop("Could not find a file or parse RecruitmentDesign JSON from `x`.", call. = FALSE)
}

validate_recruitment_design <- function(design) {
  if (!is.list(design)) stop("RecruitmentDesign must be a JSON object/list.", call. = FALSE)
  if (!identical(as.character(design$schema_version), "0.2")) {
    stop(
      sprintf("Unsupported RecruitmentDesign schema_version `%s`; fbsamplR currently imports v0.2.", design$schema_version %||% "missing"),
      call. = FALSE
    )
  }
  required <- c("project_id", "population", "sample", "study_goal", "targets", "warnings", "provenance")
  missing <- required[vapply(required, function(name) is.null(design[[name]]), logical(1))]
  if (length(missing)) {
    stop(sprintf("RecruitmentDesign is missing required field(s): %s", paste(missing, collapse = ", ")), call. = FALSE)
  }
  if (is.null(design$sample$n) || !is.numeric(design$sample$n) || length(design$sample$n) != 1L || design$sample$n < 1) {
    stop("RecruitmentDesign `sample$n` must be a positive number.", call. = FALSE)
  }
  if (!is.list(design$targets)) stop("RecruitmentDesign `targets` must be a list.", call. = FALSE)
  invisible(TRUE)
}

recruitment_design_quota_table <- function(design) {
  field_lookup <- list()
  for (target in design$field_targets %||% list()) {
    key <- paste(target$variable %||% "", target$category %||% "", sep = "\r")
    field_lookup[[key]] <- target
  }

  rows <- list()
  index <- 1L
  for (margin in design$targets) {
    variable <- margin$variable %||% NA_character_
    for (category in margin$categories %||% list()) {
      label <- category$label %||% NA_character_
      field <- field_lookup[[paste(variable, label, sep = "\r")]]
      rows[[index]] <- data.frame(
        project_id = design$project_id,
        variable = variable,
        category = label,
        population_target_n = as.integer(category$target %||% NA_integer_),
        population_share = as.numeric(category$share %||% NA_real_),
        population_count = as.numeric(category$population %||% NA_real_),
        field_target_n = as.integer(field$field_target_n %||% NA_integer_),
        oversample_n = as.integer(field$oversample_n %||% NA_integer_),
        source_dataset_id = margin$source_dataset_id %||% NA_character_,
        reference_date = margin$reference_date %||% NA_character_,
        universe = margin$universe %||% NA_character_,
        stringsAsFactors = FALSE
      )
      index <- index + 1L
    }
  }
  if (!length(rows)) return(tibble::tibble())
  tibble::as_tibble(do.call(rbind, rows))
}

`%||%` <- function(x, y) if (is.null(x)) y else x
