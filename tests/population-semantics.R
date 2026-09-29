library(fbsamplR)

design_raw <- list(
  schema_version = "0.2",
  project_id = "sp_semantics_test",
  project_name = "Population semantics test",
  eligibility = list(
    description = "US adults who bought an EV in the last 2 years",
    criteria = list("Bought an EV in the last 2 years"),
    source = "researcher_defined",
    benchmark_relation = "researcher_supplied_not_verified"
  ),
  population = list(
    role = "benchmark_population",
    country = "OTHER",
    description = "US EV buyers age 18+",
    universe = "US EV buyers age 18+",
    geography = "national",
    data_origin = "user_supplied_unverified"
  ),
  field_composition = list(
    mode = "population_targets",
    population_target_variables = list("age"),
    deliberate_field_targets = list()
  ),
  sample = list(n = 100),
  study_goal = list(type = "descriptive"),
  targets = list(
    list(
      variable = "age",
      categories = list(
        list(label = "18-39", target = 60, share = 0.60, population = 60),
        list(label = "40+", target = 40, share = 0.40, population = 40)
      )
    )
  ),
  field_targets = list(),
  warnings = list(),
  provenance = list()
)

design <- import_design(design_raw)
stopifnot(design$eligibility$description == "US adults who bought an EV in the last 2 years")
stopifnot(design$population$description == "US EV buyers age 18+")
stopifnot(design$field_composition$mode == "population_targets")

legacy <- design_raw
legacy$eligibility <- NULL
legacy$field_composition <- NULL
legacy$population$description <- "US adults age 18+"
legacy$population$universe <- "US population age 18+"
legacy$population$role <- NULL

legacy_design <- import_design(legacy)
stopifnot(legacy_design$eligibility$description == "US adults age 18+")
stopifnot(legacy_design$eligibility$source == "benchmark_population")
stopifnot(legacy_design$eligibility$benchmark_relation == "same_as_benchmark")
stopifnot(legacy_design$field_composition$mode == "population_targets")
