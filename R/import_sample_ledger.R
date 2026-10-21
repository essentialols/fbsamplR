#' Import and Validate a Provider-neutral SampleLedger
#'
#' Reads the same SampleLedger v0.1 JSON contract used by Sampling Planner.
#' Preserves study-scoped identities, source references, unknown attributes,
#' current status, and append-only transition history without converting
#' provider "complete" into acceptance.
#'
#' @param x A SampleLedger list, JSON string, local file path, or JSON URL.
#' @return A validated object of class fbsamplr_ledger with unmodified entries.
#' @export
import_sample_ledger <- function(x) {
  ledger <- read_recruitment_design(x)
  if (!is.list(ledger) || !identical(ledger$ledger_version, "0.1")) {
    stop("Expected SampleLedger v0.1 JSON.", call. = FALSE)
  }
  if (!is.character(ledger$project_id) || length(ledger$project_id) != 1L ||
      !grepl("^sp_[A-Za-z0-9_-]{8,}$", ledger$project_id)) {
    stop("SampleLedger project_id must be a valid study-scoped ID.", call. = FALSE)
  }
  revision <- ledger$ledger_revision
  if (!is.numeric(revision) || length(revision) != 1L || is.na(revision) ||
      revision < 0 || revision != floor(revision)) {
    stop("SampleLedger ledger_revision must be a non-negative integer.", call. = FALSE)
  }
  if (!is.list(ledger$entries)) stop("SampleLedger entries must be a list.", call. = FALSE)

  statuses <- c("provisional", "accepted", "rejected", "uncertain")
  states <- c("observed", "missing", "refused", "unmapped", "invalid", "out_of_scope", "unmatched")
  actors <- c("researcher", "system", "import", "provider", "api", "unknown")
  seen_ids <- character()
  seen_source_ids <- list()

  for (entry in ledger$entries) {
    if (!is.list(entry) || !is.character(entry$entry_id) || length(entry$entry_id) != 1L ||
        !grepl("^slu_[A-Za-z0-9_-]{8,}$", entry$entry_id)) {
      stop("Each SampleLedger entry needs a valid opaque entry_id.", call. = FALSE)
    }
    if (entry$entry_id %in% seen_ids) stop("Duplicate SampleLedger entry_id.", call. = FALSE)
    seen_ids <- c(seen_ids, entry$entry_id)

    if (length(entry$status) != 1L || !entry$status %in% statuses) {
      stop("Invalid SampleLedger status.", call. = FALSE)
    }
    if (!is.list(entry$attributes) || is.null(names(entry$attributes)) && length(entry$attributes)) {
      stop("SampleLedger attributes must be a keyed object.", call. = FALSE)
    }
    for (variable in names(entry$attributes)) {
      obs <- entry$attributes[[variable]]
      if (!nzchar(trimws(variable)) || !is.list(obs) || length(obs$state) != 1L ||
          !obs$state %in% states) {
        stop("Invalid SampleLedger attribute observation.", call. = FALSE)
      }
      if (obs$state != "observed" && !is.null(obs$value)) {
        stop("Non-observed attribute must keep original content in raw_value, not value.", call. = FALSE)
      }
    }

    refs <- entry$source_refs
    if (!is.null(refs) && !is.list(refs)) stop("source_refs must be an array.", call. = FALSE)
    for (ref in refs) {
      if (!is.list(ref) || any(vapply(c("source", "kind", "id"), function(k) {
        is.null(ref[[k]]) || length(ref[[k]]) != 1L ||
          !is.character(ref[[k]]) || !nzchar(trimws(ref[[k]]))
      }, logical(1)))) {
        stop("Every source reference needs source, kind, and id.", call. = FALSE)
      }
      composite <- paste(ref$source, ref$kind, ref$id, sep = "\u001f")
      existing_owner <- seen_source_ids[[composite]]
      if (!is.null(existing_owner) && !identical(existing_owner, entry$entry_id)) {
        stop("A source identifier maps to multiple entries.", call. = FALSE)
      }
      seen_source_ids[[composite]] <- entry$entry_id
    }

    history <- entry$status_history
    if (!is.list(history) || !length(history)) {
      stop("Every entry needs status_history.", call. = FALSE)
    }
    prior <- NULL
    for (i in seq_along(history)) {
      transition <- history[[i]]
      if (!is.list(transition) || length(transition$to) != 1L ||
          !transition$to %in% statuses ||
          !is.list(transition$actor) || length(transition$actor$type) != 1L ||
          !transition$actor$type %in% actors ||
          !is.character(transition$reason_code) ||
          length(transition$reason_code) != 1L ||
          !nzchar(trimws(transition$reason_code)) ||
          !is.character(transition$at) || length(transition$at) != 1L ||
          !nzchar(transition$at)) {
        stop("Invalid status transition.", call. = FALSE)
      }
      if (i == 1L && !is.null(transition$from)) {
        stop("Initial transition must have from=null.", call. = FALSE)
      }
      if (i > 1L && !identical(transition$from, prior)) {
        stop("Broken status transition chain.", call. = FALSE)
      }
      prior <- transition$to
    }
    if (!identical(prior, entry$status)) {
      stop("Current status must match last transition.", call. = FALSE)
    }
  }

  class(ledger) <- c("fbsamplr_ledger", "list")
  ledger
}

#' Extract Only Currently Accepted Study Respondents
#'
#' @param ledger A SampleLedger import or compatible JSON/list.
#' @return A list of validated, accepted sample-unit entries.
#' @export
ledger_accepted_entries <- function(ledger) {
  if (!inherits(ledger, "fbsamplr_ledger")) ledger <- import_sample_ledger(ledger)
  Filter(function(e) identical(e$status, "accepted"), ledger$entries)
}

ledger_normalize_category <- function(value) {
  tolower(gsub("[[:space:]]+", " ", trimws(as.character(value))))
}

#' Audit a SampleLedger Against the Shared RecruitmentDesign
#'
#' Counts only current accepted entries. Missing or refused attributes are
#' recorded separately as unknown membership. Unmatched observed categories
#' are surfaced; multi-value categories count a respondent once per category.
#' This does not claim statistical representativeness.
#'
#' @param design An imported fbsamplR RecruitmentDesign or supported input.
#' @param ledger An imported SampleLedger or its JSON/list.
#' @return A fbsamplr_audit with unknown_membership_by_variable,
#'   unmatched_counts, source_ledger_revision and accepted_n.
#' @export
audit_ledger <- function(design, ledger) {
  if (!inherits(design, "fbsamplr_design")) design <- import_design(design)
  if (!inherits(ledger, "fbsamplr_ledger")) ledger <- import_sample_ledger(ledger)
  if (!identical(design$project_id, ledger$project_id)) {
    stop("SampleLedger and RecruitmentDesign project IDs differ.", call. = FALSE)
  }

  quota <- design$quota_table
  if (!nrow(quota)) stop("RecruitmentDesign has no quota rows.", call. = FALSE)
  normalized <- ledger_normalize_category(quota$category)
  variables <- unique(as.character(quota$variable))
  target_keys <- paste(quota$variable, normalized, sep = "\u001f")
  if (anyDuplicated(target_keys)) {
    stop("RecruitmentDesign contains duplicate normalized quota categories.", call. = FALSE)
  }
  counts <- integer(nrow(quota))
  unknown <- stats::setNames(integer(length(variables)), variables)
  unmatched <- list()

  accepted <- ledger_accepted_entries(ledger)
  for (entry in accepted) {
    for (variable in variables) {
      observation <- entry$attributes[[variable]]
      if (is.null(observation) || !identical(observation$state, "observed")) {
        unknown[[variable]] <- unknown[[variable]] + 1L
        next
      }
      values <- observation$value
      if (is.null(values)) values <- character()
      if (is.list(values)) values <- unlist(values, recursive = FALSE, use.names = FALSE)
      values <- as.character(values)
      normalized_values <- ledger_normalize_category(values)
      usable <- which(!is.na(normalized_values) & nzchar(normalized_values))
      if (!length(usable)) {
        unknown[[variable]] <- unknown[[variable]] + 1L
        next
      }

      seen <- character()
      for (i in usable) {
        value <- normalized_values[[i]]
        if (value %in% seen) next
        seen <- c(seen, value)
        matches <- which(quota$variable == variable & normalized == value)
        if (length(matches)) {
          counts[matches] <- counts[matches] + 1L
        } else {
          k <- paste(variable, value, sep = "\u001f")
          if (is.null(unmatched[[k]])) {
            unmatched[[k]] <- list(variable = variable, category = values[[i]], achieved_n = 0L)
          }
          unmatched[[k]]$achieved_n <- unmatched[[k]]$achieved_n + 1L
        }
      }
    }
  }
  achieved <- data.frame(
    variable = quota$variable,
    category = quota$category,
    achieved_n = counts,
    stringsAsFactors = FALSE
  )
  audit <- audit_sample(design, achieved, accepted_n = length(accepted))
  extras <- if (length(unmatched)) {
    do.call(rbind, lapply(unmatched, function(x) data.frame(
      variable = x$variable, category = x$category, achieved_n = x$achieved_n,
      stringsAsFactors = FALSE
    )))
  } else {
    data.frame(variable = character(), category = character(), achieved_n = integer())
  }
  audit$unmatched_counts <- tibble::as_tibble(extras)
  audit$unknown_membership_by_variable <- as.list(unknown)
  audit$summary$unmatched_count_rows <- nrow(extras)
  audit$summary$unknown_membership_by_variable <- as.list(unknown)
  audit$source_ledger_revision <- ledger$ledger_revision
  if (nrow(extras)) {
    audit$warnings <- c(audit$warnings, sprintf(
      "%d observed category/value(s) were unmatched to the saved design.", nrow(extras)
    ))
  }
  if (any(unknown > 0)) {
    audit$warnings <- c(audit$warnings, "Some accepted respondents have unknown membership for one or more variables; missing does not imply a zero cell.")
  }
  audit
}

#' @export
print.fbsamplr_ledger <- function(x, ...) {
  cat("<fbsamplr_ledger>", x$project_id, "\n")
  cat("Revision:", x$ledger_revision, "· entries:", length(x$entries),
      "· accepted:", length(ledger_accepted_entries(x)), "\n")
  invisible(x)
}
