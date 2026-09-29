library(fbsamplR)

design_raw <- list(
  schema_version = "0.2",
  project_id = "sp_audit_test",
  project_name = "Audit test",
  population = list(country = "US", description = "US adults age 18+", universe = "US population age 18+"),
  sample = list(n = 100),
  study_goal = list(type = "descriptive"),
  targets = list(
    list(
      variable = "sex",
      categories = list(
        list(label = "Male", target = 49, share = 0.49, population = 49),
        list(label = "Female", target = 51, share = 0.51, population = 51)
      )
    ),
    list(
      variable = "race",
      categories = list(
        list(label = "Asian alone", target = 7, share = 0.07, population = 7),
        list(label = "Other", target = 93, share = 0.93, population = 93)
      )
    )
  ),
  field_targets = list(
    list(
      variable = "race",
      category = "Asian alone",
      population_target_n = 7,
      field_target_n = 10,
      oversample_n = 3,
      basis = list(type = "subgroup_precision_reference")
    )
  ),
  warnings = list(),
  provenance = list()
)

design <- import_design(design_raw)

counts <- data.frame(
  variable = c("race", "sex"),
  category = c("Asian alone", "Male"),
  achieved_n = c(8, 50),
  stringsAsFactors = FALSE
)

audit <- audit_sample(design, counts, accepted_n = 95)
stopifnot(inherits(audit, "fbsamplr_audit"))
stopifnot(audit$planned_population_n == 100L)
stopifnot(audit$planned_field_n == 103L)
stopifnot(audit$accepted_total_gap_n == -8L)

asian <- audit$audit_table[audit$audit_table$variable == "race" & audit$audit_table$category == "Asian alone", ]
stopifnot(asian$population_target_n == 7L)
stopifnot(asian$field_target_n == 10L)
stopifnot(asian$achieved_n == 8L)
stopifnot(asian$needed_to_field_target_n == 2L)
stopifnot(asian$status == "short")

female <- audit$audit_table[audit$audit_table$variable == "sex" & audit$audit_table$category == "Female", ]
stopifnot(is.na(female$achieved_n))
stopifnot(female$status == "unknown")

responses <- data.frame(
  sex_col = c("Male", "Female", "Male"),
  race_col = c("Asian alone", "Other", "Other"),
  status = c("accepted", "accepted", "rejected"),
  stringsAsFactors = FALSE
)
raw_audit <- audit_sample(
  design,
  responses,
  variable_map = c(sex = "sex_col", race = "race_col"),
  status_col = "status",
  accepted_values = "accepted"
)
stopifnot(raw_audit$accepted_n == 2L)
stopifnot(raw_audit$audit_table$achieved_n[
  raw_audit$audit_table$variable == "race" & raw_audit$audit_table$category == "Asian alone"
] == 1L)
