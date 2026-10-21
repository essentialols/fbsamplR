# Execute from the repository root after installing/loading fbsamplR 0.1.4:
# Rscript tests/ledger-conformance.R
library(fbsamplR)

# The shared JS/R fixture lives at the top level of the source repository and is
# excluded from the built package, so this script is a no-op under R CMD check.
fixture_candidates <- c(
  file.path("fixtures", "sample-ledger-conformance-v0.1.json"),
  file.path("..", "fixtures", "sample-ledger-conformance-v0.1.json")
)
fixture_path <- fixture_candidates[file.exists(fixture_candidates)][1]
if (is.na(fixture_path)) {
  cat("SampleLedger JS/R shared fixture not available here; skipping.\n")
  q(save = "no", status = 0L)
}

fixture <- jsonlite::fromJSON(fixture_path, simplifyVector = FALSE)
design <- import_design(fixture$design)
ledger <- import_sample_ledger(fixture$ledger)
stopifnot(inherits(ledger, "fbsamplr_ledger"))
stopifnot(length(ledger_accepted_entries(ledger)) == fixture$expected$accepted_n)

audit <- audit_ledger(design, ledger)
audit_via_existing_api <- audit_sample(design, ledger)
stopifnot(inherits(audit, "fbsamplr_audit"))
stopifnot(audit$accepted_n == fixture$expected$accepted_n)
stopifnot(audit_via_existing_api$accepted_n == audit$accepted_n)
stopifnot(audit$source_ledger_revision == ledger$ledger_revision)

read_count <- function(x, variable, category) {
  rows <- x$audit_table[x$audit_table$variable == variable &
                          x$audit_table$category == category, , drop = FALSE]
  stopifnot(nrow(rows) == 1L)
  rows$achieved_n[[1]]
}

for (expected in fixture$expected$achieved_counts) {
  stopifnot(read_count(audit, expected$variable, expected$category) == expected$achieved_n)
}
for (variable in names(fixture$expected$unknown_membership_by_variable)) {
  stopifnot(audit$unknown_membership_by_variable[[variable]] ==
              fixture$expected$unknown_membership_by_variable[[variable]])
}
stopifnot(nrow(audit$unmatched_counts) == 2L)
stopifnot(any(audit$unmatched_counts$variable == "race" &
              audit$unmatched_counts$category == "Unexpected" &
              audit$unmatched_counts$achieved_n == 1L))
stopifnot(any(audit$unmatched_counts$variable == "language" &
              audit$unmatched_counts$category == "French" &
              audit$unmatched_counts$achieved_n == 1L))
stopifnot(audit$audit_table$field_target_n[
  audit$audit_table$variable == "race" & audit$audit_table$category == "Asian alone"
] == 4L)

# Late accepted -> rejected transition, preserving the original audit snapshot.
new_ledger <- fixture$ledger
new_ledger$ledger_revision <- new_ledger$ledger_revision + 1L
new_ledger$entries[[2]]$status <- "rejected"
new_ledger$entries[[2]]$status_history <- c(
  new_ledger$entries[[2]]$status_history,
  list(list(
    at = "2026-10-21T12:01:00.000Z", from = "accepted", to = "rejected",
    actor = list(type = "researcher", id = "fixture"),
    reason_code = "late_quality_rejection"
  ))
)
after <- audit_ledger(design, import_sample_ledger(new_ledger))
stopifnot(after$accepted_n == fixture$expected$after_rejecting_fixture_2$accepted_n)
for (i in seq_along(fixture$expected$achieved_counts)) {
  row <- fixture$expected$achieved_counts[[i]]
  stopifnot(read_count(after, row$variable, row$category) ==
              fixture$expected$after_rejecting_fixture_2$achieved_counts[[i]])
}
stopifnot(audit$accepted_n == 3L) # immutable local audit object
stopifnot(read_count(audit, "sex", "Female") == 1L)

broken <- fixture$ledger
broken$entries[[3]]$status_history[[2]]$from <- "provisional"
stopifnot(inherits(try(import_sample_ledger(broken), silent = TRUE), "try-error"))

duplicate_source <- fixture$ledger
duplicate_source$entries[[2]]$source_refs <- duplicate_source$entries[[1]]$source_refs
stopifnot(inherits(try(import_sample_ledger(duplicate_source), silent = TRUE), "try-error"))

cat("SampleLedger JS/R shared fixture: R conformance assertions passed.\n")
