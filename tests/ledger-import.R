library(fbsamplR)

make_transition <- function(from, to, at, reason_code = "test_transition") {
  list(
    at = at,
    from = from,
    to = to,
    actor = list(type = "researcher", id = "actor_test"),
    reason_code = reason_code,
    reason = "test"
  )
}

ledger_raw <- list(
  ledger_version = "0.1",
  project_id = "sp_ledger_test",
  ledger_revision = 3,
  updated_at = "2026-10-02T20:00:00Z",
  entries = list(
    list(
      entry_id = "slu_accepted_01",
      status = "accepted",
      attributes = list(
        sex = list(state = "observed", value = "Female"),
        race = list(state = "unmatched", raw_value = "Prefer to self-describe"),
        languages = list(state = "observed", value = list("English", "Spanish"))
      ),
      source_refs = list(
        list(source = "qualtrics", kind = "response_id", id = "R_123")
      ),
      status_history = list(
        make_transition(NULL, "provisional", "2026-10-02T19:00:00Z", "response_observed"),
        make_transition("provisional", "accepted", "2026-10-02T19:05:00Z", "researcher_accepted")
      ),
      created_at = "2026-10-02T19:00:00Z",
      updated_at = "2026-10-02T19:05:00Z",
      adapter_provenance = list(import_batch = "batch_1")
    ),
    list(
      entry_id = "slu_uncertain_02",
      status = "uncertain",
      attributes = list(age = list(state = "missing")),
      source_refs = list(),
      status_history = list(
        make_transition(NULL, "uncertain", "2026-10-02T19:10:00Z", "needs_review")
      ),
      created_at = "2026-10-02T19:10:00Z",
      updated_at = "2026-10-02T19:10:00Z"
    )
  ),
  source_snapshot = list(name = "fixture")
)

ledger <- import_sample_ledger(ledger_raw)
stopifnot(inherits(ledger, "fbsamplr_ledger"))
stopifnot(ledger$ledger_version == "0.1")
stopifnot(ledger$ledger_revision == 3L)
stopifnot(length(ledger$entries) == 2L)
stopifnot(ledger$entries[[1]]$status == "accepted")
stopifnot(ledger$entries[[1]]$attributes$race$state == "unmatched")
stopifnot(ledger$entries[[1]]$attributes$race$raw_value == "Prefer to self-describe")
stopifnot(identical(ledger$entries[[1]]$attributes$languages$value, list("English", "Spanish")))
stopifnot(ledger$entries[[1]]$source_refs[[1]]$source == "qualtrics")
stopifnot(length(ledger$entries[[1]]$status_history) == 2L)
stopifnot(ledger$entries[[1]]$status_history[[2]]$from == "provisional")
stopifnot(ledger$entries[[1]]$status_history[[2]]$to == "accepted")
stopifnot(ledger$entries[[1]]$adapter_provenance$import_batch == "batch_1")
stopifnot(ledger$source_snapshot$name == "fixture")

json <- jsonlite::toJSON(ledger_raw, auto_unbox = TRUE, null = "null")
ledger_from_json <- import_sample_ledger(json)
stopifnot(ledger_from_json$entries[[1]]$status == "accepted")
stopifnot(ledger_from_json$entries[[2]]$attributes$age$state == "missing")

expect_error <- function(expr, pattern) {
  message <- tryCatch({ force(expr); NULL }, error = function(e) conditionMessage(e))
  stopifnot(!is.null(message), grepl(pattern, message, fixed = TRUE))
}

bad_status <- ledger_raw
bad_status$entries[[1]]$status <- "complete"
expect_error(import_sample_ledger(bad_status), "Unsupported sample status")

bad_history <- ledger_raw
bad_history$entries[[1]]$status_history[[2]]$from <- "rejected"
expect_error(import_sample_ledger(bad_history), "continuous transition chain")

status_mismatch <- ledger_raw
status_mismatch$entries[[1]]$status <- "provisional"
expect_error(import_sample_ledger(status_mismatch), "Current status must equal the last status transition")

bad_attribute <- ledger_raw
bad_attribute$entries[[2]]$attributes$age$value <- 30
expect_error(import_sample_ledger(bad_attribute), "must not carry a normalized value")

duplicate_entry <- ledger_raw
duplicate_entry$entries[[2]]$entry_id <- duplicate_entry$entries[[1]]$entry_id
expect_error(import_sample_ledger(duplicate_entry), "Duplicate SampleLedger entry_id")

duplicate_source <- ledger_raw
duplicate_source$entries[[2]]$source_refs <- ledger_raw$entries[[1]]$source_refs
expect_error(import_sample_ledger(duplicate_source), "maps to more than one sample unit")

missing_from <- ledger_raw
missing_from$entries[[1]]$status_history[[1]] <-
  missing_from$entries[[1]]$status_history[[1]][
    setdiff(names(missing_from$entries[[1]]$status_history[[1]]), "from")
  ]
expect_error(import_sample_ledger(missing_from), "missing required field(s): from")

bad_version <- ledger_raw
bad_version$ledger_version <- "0.2"
expect_error(import_sample_ledger(bad_version), "Unsupported SampleLedger ledger_version")
