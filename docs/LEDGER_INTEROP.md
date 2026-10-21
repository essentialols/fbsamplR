# fbsamplR SampleLedger interoperability (v0.1.4)

**Status:** implementation branch. Run R tests before merging or releasing.

The goal is one researcher study in two runtimes. Sampling Planner owns the JSON SampleLedger v0.1 contract and revisioned, immutable audit history. fbsamplR imports the same respondent-level state, derives the same accepted counts and categories, and returns a normal fbsamplR audit.

## APIs

- `import_sample_ledger(x)`: validate and import a SampleLedger JSON file, URL, or R list. Preserve status, source references, attributes, and original transitions.
- `ledger_accepted_entries(x)`: return only sample units with current explicit `accepted` status.
- `audit_ledger(design, ledger)`: audit accepted state against RecruitmentDesign v0.2. Unknown variable memberships are separate from zero-filled known category counts; raw unmatched observed values are reported.
- `audit_sample(design, imported_ledger)`: calls `audit_ledger` for imported ledger objects while preserving every existing data-frame/aggregate path.

No live provider, credential, or customer data is required to use any of these functions.

## Start-to-finish example

    library(fbsamplR)
    design <- import_design("sampling-plan.json")
    ledger <- import_sample_ledger("respondents-ledger.json")
    stopifnot(identical(design$project_id, ledger$project_id))
    accepted <- ledger_accepted_entries(ledger)
    audit <- audit_sample(design, ledger)
    print(audit)
    audit$audit_table
    audit$unknown_membership_by_variable
    audit$unmatched_counts
    audit$source_ledger_revision

Only current accepted respondents count. Provider `complete` statuses are not accepted by default, and no marginal row totals are summed into a fabricated respondent count.

## Cross-language fixtures and tests

Both repositories contain the **same** `fixtures/sample-ledger-conformance-v0.1.json`. It includes:
- accepted, rejected and provisional records;
- an accepted record with explicitly missing race;
- observed categories outside the saved target labels;
- a multi-language respondent with a repeated category that must count once per category;
- an accepted-then-rejected status history and a further reclassification scenario;
- a separate field oversample from the population target.

The expected accepted total is **3** before late rejection and **2** afterward. Expected counts and unknown/unmatched memberships are in the JSON's `expected` object.

Run from the repository root after loading the new package source:

    Rscript -e 'devtools::load_all(".", quiet = TRUE); source("tests/ledger-conformance.R")'
    Rscript -e 'devtools::load_all(".", quiet = TRUE); source("tests/audit.R")'
    Rscript -e 'devtools::load_all(".", quiet = TRUE); source("tests/population-semantics.R")'

Run the matching JS test in `essentialols/sampling-planner`:

    node --test test/shared-ledger-conformance.test.js

Then compare results to the fixture and run `R CMD check` on the full package. Do not claim conformance if either runtime was not executed.

## Known boundaries

- The importer reads complete saved SampleLedger exports. It does not implement the ledger's create/upsert/transition persistence API or manage historical audits in R. Those remain in the Node/ChatGPT backend.
- Deliberately no new live Meta/Qualtrics calls or changes to ad set behavior.
- A SampleLedger stores study-scoped opaque IDs, not cross-study identities; never attach names, emails, or credentials.
- Shared contracts must be versioned before incompatible semantic changes.
- Historical audits remain immutable on the server. In R, the audit result is an immutable-in-practice ordinary snapshot object; callers may save it to disk for reproducibility.
