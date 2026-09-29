# fbsamplR Design Rules

## ELI10 TL;DR

- Keep the **meaning of the study** separate from provider plumbing: who is eligible, what population is the benchmark, what sample we want, what we actually have, and what providers did are different facts.
- Make the safe path easy: explicit state, predictable R objects, inspect-before-mutate, idempotent actions, and durable history.
- Build only the shared recruitment/control layer. Reuse mature R statistics packages and provider-native capabilities instead of rebuilding everything.

## Purpose

This file is the compact implementation rulebook distilled from two evidence stores:

- [fbsamplR Product Frontier Research](https://docs.google.com/spreadsheets/d/1lsU3w8uu1FVJIYZacH8X2d1I5P95-hXl_R4X8_5RY38/edit) — product, methodology, provider, and architecture research. References below use IDs such as `PF-03`.
- [Great R Packages Evidence for fbsamplR](https://docs.google.com/spreadsheets/d/1DsfuH529a73B_HIu0i65mIijJ4h5_8vuu1Dx4KE8K7c/edit) — API/package-design research. References below name exemplar packages.

Do **not** reread those workbooks for ordinary implementation. Start here. Go back to the evidence only when a rule is unclear, challenged, or being reconsidered.

Research analogies are evidence, not specifications. Product/domain invariants win over attractive package patterns.

## Strength levels

- **INVARIANT** — shared semantics or safety rule. Do not violate without deliberately changing the shared model.
- **DEFAULT** — expected design. Diverge only for a concrete documented reason.
- **HEURISTIC** — useful preference, not a contract.
- **DEFERRED** — evidence says this may matter, but it is intentionally not a current core responsibility.

## Five meta-rules

1. **Automate mechanics; do not automate away methodological choices.**
2. **Normalize shared semantics, not provider capabilities.**
3. **Store facts and history; derive views.**
4. **Keep planning pure and side effects explicit.**
5. **Keep the ordinary path simple; expose complexity only when the study needs it.**

---

## A. Shared study model

### FBR-01 — Keep study concepts separate
**INVARIANT.** Eligibility, benchmark population, population targets, deliberate field targets, and achieved sample state are different concepts. Never silently substitute one for another.

**Evidence:** PF-03, PF-07, PF-09; `survey`, `emmeans`.

**Reopen when:** the shared RecruitmentDesign model itself changes.

### FBR-02 — Provider status is not sample truth
**INVARIANT.** A provider saying “complete” or “valid” does not automatically mean a respondent counts. Sample state must support at least `provisional`, `accepted`, `rejected`, and `uncertain`.

**Evidence:** PF-03, PF-06, PF-09; `bupaR`.

**Reopen when:** respondent adjudication is intentionally removed from the product.

### FBR-03 — Unknown stays unknown
**INVARIANT.** Missing, refused, unmapped, invalid, out-of-scope, and unmatched values must not silently become zero or a guessed category.

**Evidence:** PF-03, PF-09; `naniar`, `readr`, `stringi`.

**Reopen when:** never for silent coercion; only the explicit classification vocabulary may evolve.

### FBR-04 — Identity is explicit and study-scoped
**INVARIANT.** Use stable study-scoped IDs for respondents/sample units, quota cells, and provider objects. Joins and mappings must name their keys and expected cardinality. Do not rely on natural joins or row position for consequential state.

**Evidence:** PF-09; `dplyr`, `collapse`, `tidygraph`, `countrycode`.

**Reopen when:** the shared identity model changes.

### FBR-05 — Current state can change; history cannot
**INVARIANT.** Current status may be updated, but meaningful transitions, design revisions, and saved audits remain addressable as historical facts. Later changes must not rewrite what an earlier audit used.

**Evidence:** PF-09; `targets`, `renv`, `bupaR`.

**Reopen when:** only if an explicit migration preserves the same historical meaning.

### FBR-06 — Keep secrets and PII out of the core by default
**INVARIANT.** Shared design, ledger, event, diagnostic, and support artifacts must not require names, emails, phone numbers, access tokens, auth headers, or raw sensitive provider payloads.

**Evidence:** PF-06, PF-09; `reprex`, `gargle`, `httr2`.

**Reopen when:** a specific feature genuinely requires sensitive data and has an explicit privacy contract.

### FBR-07 — Quota completion is not representativeness
**INVARIANT.** Filling quotas does not establish probability sampling, unbiasedness, valid weighting, or inferential precision.

**Evidence:** PF-07, PF-09; `survey`, `SamplingStrata`, `emmeans`.

**Reopen when:** never as a silent implication.

### FBR-08 — Store canonical facts; derive views
**DEFAULT.** Persist designs, identities, observations, accepted-state facts, revisions, and consequential events. Compute dashboards, summaries, gaps, recommended actions, and presentation tables from those facts rather than storing multiple competing truths.

**Evidence:** PF-09; `targets`, `bupaR`, `broom`, `reactable`.

**Reopen when:** a derived view is expensive enough to justify a cache; the cache must remain reproducible from source facts.

---

## B. Statistical boundary

### FBR-09 — Own recruitment design/control, not the whole statistics stack
**INVARIANT.** fbsamplR should own the shared recruitment design, accepted-sample state, recruitment control, audit handoff, and provider interoperability. Integrate with mature packages for probability sampling, weighting/calibration, complex-survey analysis, and broader inference.

**Evidence:** PF-07, PF-09.

**Reopen when:** real users repeatedly cannot complete an essential workflow through integration.

### FBR-10 — Make the reference population/estimand explicit before quota math
**DEFAULT.** Quota grids, supported cells, structural zeros, target weights, and collapse rules should be explicit objects or fields rather than implicit consequences of a data frame.

**Evidence:** PF-07; `emmeans`, `survey`, `SamplingStrata`.

**Reopen when:** a simpler representation proves equally explicit and safe.

### FBR-11 — Models may advise; observed accepted counts remain authoritative
**HEURISTIC.** Yield models, forecasts, partial pooling, and simulation may inform planning, but must not overwrite observed accepted sample facts.

**Evidence:** PF-05; `lme4`, `furrr`, `performance`.

**Reopen when:** never for historical observed facts; only advisory-model scope may expand.

### FBR-12 — Autonomous optimization comes later
**DEFERRED.** Keep cost, pace, quality, remaining time/budget, uncertainty, and feasibility observable now. Prefer transparent threshold/rule-based actions before continuous optimizers, bandits, or autonomous routing.

**Evidence:** PF-05, PF-09.

**Reopen when:** field data and backtests show a clear advantage over simpler policy.

---

## C. Provider architecture

### FBR-13 — Provider-neutral core, provider-specific adapters
**DEFAULT.** RecruitmentDesign, SampleLedger, audit semantics, and control policy must not encode Meta, Qualtrics, Prolific, Cint, or another vendor as domain concepts.

**Evidence:** PF-01, PF-03, PF-09; `DBI`, `parsnip`, `ellmer`.

**Reopen when:** a supposedly neutral concept only exists for one provider in real use.

### FBR-14 — Meta and Qualtrics may be privileged adapters
**DEFAULT.** Meta can be the best-supported recruitment adapter and Qualtrics the best-supported response adapter without becoming the shared model.

**Evidence:** PF-02, PF-03, PF-09.

**Reopen when:** adoption or maintenance cost makes another provider more important.

### FBR-15 — Normalize semantics, not every capability
**INVARIANT.** Define a small common lifecycle and capability model. Do not pretend every provider supports the same targeting, pricing, pacing, write operations, or response metadata.

**Evidence:** PF-01, PF-03; `DBI`, `parsnip`.

**Reopen when:** provider evidence shows a genuinely shared capability belongs in the common contract.

### FBR-16 — Native delegation is success
**DEFAULT.** If one provider can satisfy the study safely and transparently, the system may say `DELEGATE_NATIVE` instead of forcing orchestration.

**Evidence:** PF-08, PF-09.

**Reopen when:** native delegation prevents a user requirement the product is explicitly responsible for.

### FBR-17 — Keep the common provider contract small
**DEFAULT.** Standardize only the shared lifecycle, normalized observations/results, capabilities, errors, and idempotency behavior. Keep provider-only controls behind explicit adapter options/escape hatches.

**Evidence:** PF-01, PF-03; `DBI`, `parsnip`, `ellmer`.

**Reopen when:** repeated adapters implement the same extension and it has become truly common.

### FBR-18 — Centralize transport, auth, versioning, and provider errors
**DEFAULT.** Provider endpoint functions should not each reinvent base URLs, API versions, token handling, retries, throttling, redaction, and error parsing.

**Evidence:** `httr2`, `ragg`, `gargle`.

**Reopen when:** never for duplicated credential/transport logic; implementation technology may change.

### FBR-19 — Remote actions should converge safely
**DEFAULT.** A repeated request to reach the same desired provider state should normally become a no-op, not another blind mutation. Destructive actions require stronger explicitness.

**Evidence:** `usethis`, `targets`, `purrr`.

**Reopen when:** a provider fundamentally lacks readback/idempotency; record that limitation explicitly.

### FBR-20 — Intent and execution are separate
**INVARIANT.** Build/inspect/validate an intended plan or action set before paid or consequential provider mutation. Desired state and observed remote state remain separate, and writes are reconciled afterward.

**Evidence:** PF-05, PF-09; `future`, `shiny`, `brms`, `targets`.

**Reopen when:** never for consequential side effects.

---

## D. R API and artifact design

### FBR-21 — Use small typed domain objects
**DEFAULT.** Important shared concepts should have stable structure/class contracts, while remaining easy to inspect and convert to ordinary tibbles/data frames.

**Evidence:** `sf`, `survey`, `recipes`, `broom`.

**Reopen when:** the class adds ceremony without protecting meaning.

### FBR-22 — Return stable semantic results, not raw HTTP as the main API
**DEFAULT.** Public operations should return predictable typed rows/objects with IDs, requested/observed state, outcome, reason, and error information. Raw provider payloads may remain available for explicit diagnostics/provenance.

**Evidence:** `fs`, `broom`, `cli`, `purrr`.

**Reopen when:** a deliberately low-level escape hatch documents that it returns provider-native data.

### FBR-23 — Pure logic first; one explicit side-effect boundary
**DEFAULT.** Planning, normalization, diagnostics, audits, simulation, and recommended actions should be pure whenever practical. Provider mutation belongs behind an explicit apply/executor boundary.

**Evidence:** `future`, `testthat`, `furrr`, `plumber`.

**Reopen when:** only where the provider makes a read itself state-changing; isolate that fact.

### FBR-24 — Durable events and transient progress are different
**DEFAULT.** Consequential decisions/actions belong in durable structured history. Progress bars, console messages, and streaming status are disposable presentation signals and must not become the audit source of truth.

**Evidence:** `bupaR`, `cli`, `progressr`.

**Reopen when:** never by parsing console output into state.

### FBR-25 — Shared artifacts are versioned and language-neutral
**DEFAULT.** RecruitmentDesign, SampleLedger, SampleAudit, snapshots, and action/audit records should have explicit schema versions and serializable contracts usable by R, Sampling Planner, and future services.

**Evidence:** PF-09; `pins`, `arrow`, `renv`.

**Reopen when:** a new representation preserves migration and cross-language meaning.

### FBR-26 — Preserve existing public workflows while migrating internals
**DEFAULT.** Existing `fb_*` and `qual_*` functions may remain compatibility facades while new provider-neutral internals take over.

**Evidence:** PF-02, PF-09; `ragg`, `duckplyr`.

**Reopen when:** a compatibility path becomes unsafe or materially blocks the new contract; deprecate explicitly rather than breaking silently.

### FBR-27 — Design for reuse, do not pre-build the service
**HEURISTIC.** Core functions and artifacts should be service-safe and reusable from MCP/API/UI layers, but do not add hosted databases, routers, dashboards, or workflow infrastructure merely for architectural symmetry.

**Evidence:** PF-09; `plumber`, `pins`.

**Reopen when:** an actual product surface needs the infrastructure.

---

## E. Validation and evolution

### FBR-28 — Preflight before consequential mutation
**INVARIANT.** Validate required keys, unique mappings, provider capabilities, status values, freshness, budget/capacity constraints where relevant, and contradictory actions before execution. Fail with inspectable diagnostics.

**Evidence:** PF-05, PF-09; `pointblank`, `performance`, `dplyr`, `collapse`.

**Reopen when:** the exact checklist evolves; the preflight boundary remains.

### FBR-29 — Test contracts, not implementations
**DEFAULT.** Shared fixtures and conformance tests should prove observable behavior: parsing, status semantics, idempotency, unsupported capabilities, pagination/error shape, revision history, and JS/R agreement. Live-provider tests remain separately opt-in.

**Evidence:** `DBI`, `testthat`, `duckplyr`; PF-09.

**Reopen when:** adapters require additional provider-specific tests, not weaker common tests.

### FBR-30 — Meaning changes invalidate downstream decisions
**DEFAULT.** If field mappings, category normalization, design revision, acceptance policy, or provider binding changes materially, dependent counts/audits/action plans must be recomputed or explicitly tied to the old revision. Never keep a stale “still valid” decision by accident.

**Evidence:** FBR-05; `targets`, `recipes`, `workflows`, `renv`.

**Reopen when:** a dependency can be proven irrelevant to the derived result.

---

## How agents should use this

Before changing a shared model, provider-neutral behavior, or fbsamplR interoperability:

1. Read this file.
2. Identify which rule IDs the change touches.
3. Preserve every **INVARIANT**.
4. Follow **DEFAULTS** unless the implementation has a concrete reason to diverge.
5. Do not implement **DEFERRED** ideas merely because the research mentioned them.
6. If evidence suggests a rule itself is wrong, update the research/synthesis deliberately rather than quietly coding around it.

For ordinary bug fixes that do not touch these boundaries, do not turn this file into ceremony.
