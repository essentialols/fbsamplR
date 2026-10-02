#' Import a Sampling Planner Sample Ledger
#'
#' Reads a provider-neutral SampleLedger v0.1 JSON object produced by Sampling
#' Planner (or an equivalent list) and validates respondent-level state,
#' status-transition history, attributes, and source references.
#'
#' @param x A file path, URL, JSON string, or already-parsed R list.
#'
#' @return An object of class fbsamplr_ledger. Nested attributes, source
#'   references, status history, and additional provenance fields are preserved.
#' @export
import_sample_ledger <- function(x) {
  ledger <- read_sample_ledger(x)
  validate_sample_ledger(ledger)

  ledger$ledger_version <- as.character(ledger$ledger_version)
  ledger$project_id <- as.character(ledger$project_id)
  ledger$ledger_revision <- as.integer(ledger$ledger_revision)
  ledger$entries <- lapply(ledger$entries, normalize_sample_ledger_entry)
  class(ledger) <- c("fbsamplr_ledger", "list")
  ledger
}

#' @export
print.fbsamplr_ledger <- function(x, ...) {
  statuses <- vapply(x$entries, function(entry) entry$status, character(1))
  counts <- table(factor(statuses, levels = sample_ledger_statuses()))
  cat("<fbsamplr_ledger>", x$project_id, "\n")
  cat("Revision:", x$ledger_revision, "\n")
  cat("Entries:", length(x$entries), "\n")
  if (length(x$entries)) {
    cat(
      "Statuses:",
      paste(sprintf("%s %d", names(counts), as.integer(counts)), collapse = " · "),
      "\n"
    )
  }
  invisible(x)
}

read_sample_ledger <- function(x) {
  if (is.list(x)) return(x)
  if (!is.character(x) || length(x) != 1L || is.na(x)) {
    stop("x must be a SampleLedger list, file path, URL, or JSON string.", call. = FALSE)
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
  stop("Could not find a file or parse SampleLedger JSON from x.", call. = FALSE)
}

sample_ledger_statuses <- function() {
  c("provisional", "accepted", "rejected", "uncertain")
}

sample_ledger_attribute_states <- function() {
  c("observed", "missing", "refused", "unmapped", "invalid", "out_of_scope", "unmatched")
}

sample_ledger_actor_types <- function() {
  c("researcher", "system", "import", "provider", "api", "unknown")
}

validate_sample_ledger <- function(ledger) {
  if (!is.list(ledger)) stop("SampleLedger must be a JSON object/list.", call. = FALSE)
  if (!identical(as.character(ledger$ledger_version), "0.1")) {
    version <- if (is.null(ledger$ledger_version)) "missing" else as.character(ledger$ledger_version)
    stop(
      sprintf("Unsupported SampleLedger ledger_version %s; fbsamplR currently imports v0.1.", version),
      call. = FALSE
    )
  }
  project_id <- as.character(ledger$project_id)
  if (length(project_id) != 1L || is.na(project_id) ||
      !grepl("^sp_[A-Za-z0-9_-]{8,}$", project_id, perl = TRUE)) {
    stop("SampleLedger requires a valid study-scoped project_id beginning with sp_.", call. = FALSE)
  }
  revision <- suppressWarnings(as.numeric(ledger$ledger_revision))
  if (length(revision) != 1L || is.na(revision) || revision < 0 || revision != floor(revision)) {
    stop("SampleLedger ledger_revision must be a non-negative whole number.", call. = FALSE)
  }
  if (!is.list(ledger$entries)) {
    stop("SampleLedger entries must be an array/list.", call. = FALSE)
  }
  if (!is.null(ledger$updated_at)) {
    validate_ledger_datetime(ledger$updated_at, "SampleLedger updated_at")
  }

  entries <- lapply(ledger$entries, normalize_sample_ledger_entry)
  ids <- vapply(entries, function(entry) entry$entry_id, character(1))
  if (anyDuplicated(ids)) {
    stop(sprintf("Duplicate SampleLedger entry_id: %s.", ids[duplicated(ids)][1]), call. = FALSE)
  }

  seen_refs <- character()
  seen_entries <- character()
  for (entry in entries) {
    for (ref in entry$source_refs) {
      key <- paste(ref$source, ref$kind, ref$id, sep = "\r")
      prior <- match(key, seen_refs)
      if (!is.na(prior) && seen_entries[[prior]] != entry$entry_id) {
        stop(
          sprintf(
            "A provider/source identifier maps to more than one sample unit: %s / %s / %s.",
            ref$source, ref$kind, ref$id
          ),
          call. = FALSE
        )
      }
      seen_refs <- c(seen_refs, key)
      seen_entries <- c(seen_entries, entry$entry_id)
    }
  }
  invisible(TRUE)
}

normalize_sample_ledger_entry <- function(entry) {
  if (!is.list(entry)) stop("Each SampleLedger entry must be an object/list.", call. = FALSE)

  required <- c("entry_id", "status", "attributes", "status_history", "created_at", "updated_at")
  missing <- setdiff(required, names(entry))
  if (length(missing)) {
    stop(sprintf("SampleLedger entry is missing required field(s): %s", paste(missing, collapse = ", ")), call. = FALSE)
  }

  entry_id <- as.character(entry$entry_id)
  if (length(entry_id) != 1L || is.na(entry_id) ||
      !grepl("^slu_[A-Za-z0-9_-]{8,}$", entry_id, perl = TRUE)) {
    stop("SampleLedger entry_id must be an opaque study-scoped ID beginning with slu_.", call. = FALSE)
  }

  status <- as.character(entry$status)
  if (length(status) != 1L || is.na(status) || !status %in% sample_ledger_statuses()) {
    stop(sprintf("Unsupported sample status: %s.", status), call. = FALSE)
  }

  if (!is.list(entry$attributes)) {
    stop("SampleLedger attributes must be an object keyed by explicit variable name.", call. = FALSE)
  }
  attributes <- entry$attributes
  if (length(attributes)) {
    if (is.null(names(attributes)) || any(is.na(names(attributes)) | trimws(names(attributes)) == "")) {
      stop("SampleLedger attribute variable names must be non-empty.", call. = FALSE)
    }
    attributes <- lapply(attributes, normalize_sample_ledger_attribute)
  }

  source_refs <- if (is.null(entry$source_refs)) list() else entry$source_refs
  if (!is.list(source_refs)) stop("SampleLedger source_refs must be an array/list.", call. = FALSE)
  source_refs <- lapply(source_refs, normalize_sample_ledger_source_ref)

  history <- entry$status_history
  if (!is.list(history) || !length(history)) {
    stop("Each SampleLedger entry requires non-empty status_history.", call. = FALSE)
  }
  normalized_history <- vector("list", length(history))
  previous <- NULL
  for (i in seq_along(history)) {
    normalized_history[[i]] <- normalize_sample_ledger_transition(history[[i]], previous, i)
    previous <- normalized_history[[i]]$to
  }
  if (!identical(previous, status)) {
    stop(
      sprintf(
        "Current status must equal the last status transition for %s (status=%s, last transition=%s).",
        entry_id, status, previous
      ),
      call. = FALSE
    )
  }

  validate_ledger_datetime(entry$created_at, sprintf("SampleLedger %s created_at", entry_id))
  validate_ledger_datetime(entry$updated_at, sprintf("SampleLedger %s updated_at", entry_id))

  entry$entry_id <- entry_id
  entry$status <- status
  entry$attributes <- attributes
  entry$source_refs <- source_refs
  entry$status_history <- normalized_history
  entry$created_at <- as.character(entry$created_at)
  entry$updated_at <- as.character(entry$updated_at)
  entry
}

normalize_sample_ledger_attribute <- function(observation) {
  if (!is.list(observation)) stop("Each ledger attribute must be an observation object/list.", call. = FALSE)
  state <- as.character(observation$state)
  if (length(state) != 1L || is.na(state) || !state %in% sample_ledger_attribute_states()) {
    stop(sprintf("Unsupported ledger attribute state: %s.", state), call. = FALSE)
  }
  if (!identical(state, "observed") && !is.null(observation$value)) {
    stop(
      sprintf(
        "Attribute state %s must not carry a normalized value; preserve source material in raw_value instead.",
        state
      ),
      call. = FALSE
    )
  }
  observation$state <- state
  observation
}

normalize_sample_ledger_source_ref <- function(ref) {
  if (!is.list(ref)) stop("Each SampleLedger source reference must be an object/list.", call. = FALSE)
  required <- c("source", "kind", "id")
  if (!all(required %in% names(ref))) {
    stop("Each SampleLedger source reference requires source, kind, and id.", call. = FALSE)
  }
  values <- lapply(required, function(name) trimws(as.character(ref[[name]])))
  if (any(vapply(values, function(value) length(value) != 1L || is.na(value) || value == "", logical(1)))) {
    stop("Each SampleLedger source reference requires non-empty source, kind, and id.", call. = FALSE)
  }
  for (i in seq_along(required)) ref[[required[[i]]]] <- values[[i]]
  ref
}

normalize_sample_ledger_transition <- function(transition, previous_status, index) {
  if (!is.list(transition)) stop("Each SampleLedger status_history item must be an object/list.", call. = FALSE)
  required <- c("at", "from", "to", "actor", "reason_code")
  missing <- setdiff(required, names(transition))
  if (length(missing)) {
    stop(
      sprintf("SampleLedger status transition is missing required field(s): %s", paste(missing, collapse = ", ")),
      call. = FALSE
    )
  }

  to <- as.character(transition$to)
  if (length(to) != 1L || is.na(to) || !to %in% sample_ledger_statuses()) {
    stop(sprintf("Unsupported ledger transition status: %s.", to), call. = FALSE)
  }
  from <- transition$from
  if (!is.null(from)) {
    from <- as.character(from)
    if (length(from) != 1L || is.na(from) || !from %in% sample_ledger_statuses()) {
      stop(sprintf("Unsupported ledger transition prior status: %s.", from), call. = FALSE)
    }
  }
  if (index == 1L && !is.null(from)) {
    stop("The initial SampleLedger status transition must have from = NULL.", call. = FALSE)
  }
  if (index > 1L && !identical(from, previous_status)) {
    stop(
      sprintf("SampleLedger status history must form a continuous transition chain at transition %d.", index),
      call. = FALSE
    )
  }

  actor <- transition$actor
  if (!is.list(actor)) stop("A SampleLedger status transition requires an actor object/list.", call. = FALSE)
  actor_type <- as.character(actor$type)
  if (length(actor_type) != 1L || is.na(actor_type) || !actor_type %in% sample_ledger_actor_types()) {
    stop(sprintf("Unsupported ledger actor type: %s.", actor_type), call. = FALSE)
  }
  actor$type <- actor_type
  if (!is.null(actor$id)) actor$id <- as.character(actor$id)

  reason_code <- trimws(as.character(transition$reason_code))
  if (length(reason_code) != 1L || is.na(reason_code) || reason_code == "") {
    stop("Each SampleLedger status transition requires a non-empty reason_code.", call. = FALSE)
  }
  validate_ledger_datetime(transition$at, "SampleLedger status transition at")

  transition$at <- as.character(transition$at)
  transition$from <- from
  transition$to <- to
  transition$actor <- actor
  transition$reason_code <- reason_code
  if (!is.null(transition$reason)) transition$reason <- as.character(transition$reason)
  transition
}

validate_ledger_datetime <- function(value, label) {
  if (!is.character(value) || length(value) != 1L || is.na(value) || trimws(value) == "") {
    stop(sprintf("%s must be a valid date-time string.", label), call. = FALSE)
  }
  parse_value <- sub("([+-][0-9]{2}):([0-9]{2})$", "\\1\\2", value, perl = TRUE)
  parsed <- suppressWarnings(as.POSIXct(
    parse_value,
    tz = "UTC",
    tryFormats = c("%Y-%m-%dT%H:%M:%OSZ", "%Y-%m-%dT%H:%M:%OS%z", "%Y-%m-%d %H:%M:%OS")
  ))
  if (is.na(parsed)) stop(sprintf("%s must be a valid date-time string.", label), call. = FALSE)
  invisible(TRUE)
}
