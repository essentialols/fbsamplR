# Meta Marketing API v26: fbsamplR inventory and verification backlog
*Documentation-only assessment · 2026-10-21 · No application code, provider calls, tokens, or deployments modified.*

## Evidence standard — read this first

**Meta platform-specific claims below are UNVERIFIED pending direct access to first-party `developers.facebook.com` pages.** On October 21, 2026, this research environment could not fetch the [candidate v26 changelog](https://developers.facebook.com/docs/graph-api/changelog/version26.0/) or [candidate release announcement](https://developers.facebook.com/blog/post/2026/07/29/introducing-graph-api-v26-and-marketing-api-v26/); direct requests failed or returned HTTP 429. Search surfaced text from a **third-party mirror**, which is expressly *not an acceptable source* and is **not cited or relied upon as verification**.

Evidence labels in this document:
- **REPO-CONFIRMED** means the statement follows from the current `essentialols/fbsamplR` source code. This proves our code behavior, not current Meta API compatibility.
- **UNVERIFIED META CLAIM** means a release date, field deprecation, permission, support policy, API version, or objective/placement behavior must be independently checked from a readable original `developers.facebook.com` page. A link to an inaccessible official page is a *verification target*, not proof.
- **PROPOSED** means an engineering recommendation, not a reported Meta capability.

**Do not merge third-party changelog text into asserted product facts, and do not rely on the following unverified rows when planning a paid or automated campaign.**

## Executive decision

**REPO-CONFIRMED:** The R wrappers hardcode `https://graph.facebook.com/v12.0/`. They have no tested modern-API migration here. **PROPOSED:** Do not substitute `v26.0` for `v12.0` by global search/replace; first validate the exact currently supported Meta API version, request contracts, permitted campaign objectives, effective targeting, access rights, and readback behavior against official Meta documentation and a controlled read-only test account.

The priority remains read-only credential and account preflight. The neutral RecruitmentDesign/SampleLedger architecture does not require live Meta execution to deliver study planning or accepted-count audits.

## 1. Version and migration assertions requiring first-party proof

These are **candidate claims to verify**, not verified findings. They were stated too confidently in the first draft:

| Claim | Verification status | Required first-party document |
| --- | --- | --- |
| Graph API and Marketing API `v26.0` were released July 29, 2026 | **UNVERIFIED META CLAIM** | `developers.facebook.com` [v26 changelog](https://developers.facebook.com/docs/graph-api/changelog/version26.0/) or [release post](https://developers.facebook.com/blog/post/2026/07/29/introducing-graph-api-v26-and-marketing-api-v26/) |
| Marketing API `v24` sunset on October 6, 2026 (distinguish Graph API lifetime) | **UNVERIFIED META CLAIM** | [Version table](https://developers.facebook.com/docs/graph-api/changelog/versions/) and Marketing API version lifecycle |
| Several `v26` restrictions become effective on October 27, 2026 across older still-supported Marketing API versions | **UNVERIFIED META CLAIM** | [v26 changelog](https://developers.facebook.com/docs/graph-api/changelog/version26.0/) and endpoint-specific effective-date notes |
| `v26` is currently the newest supported version | **UNVERIFIED META CLAIM** | [Current version list](https://developers.facebook.com/docs/graph-api/changelog/versions/) checked directly on the date of action |
| "Ads Management Standard Access" was renamed to "Marketing API Access Tier" with Limited/Full tiers, distinct from the permission `ads_management` | **UNVERIFIED META CLAIM under this review's specified source rule** | [Meta App Features Reference](https://developers.facebook.com/docs/features-reference/) and currently maintained Marketing API permissions documentation |

For each claim, a local agent should open the original `developers.facebook.com` page in a logged-in browser if necessary, capture the precise heading, publication/effective date, and passage/endpoint, then update the status to **VERIFIED — first party** only if the original content genuinely supports it. Do not quote or cite content fetched from mirrors or SEO clones.

## 2. Reported v26 endpoint/field changes — ALL UNVERIFIED

**None of the rows below was independently confirmed on `developers.facebook.com` in this run.** These are hypotheses for manual first-party comparison, not promises about the current API.

| Proposed change to verify | Status | Implication *if* the official changelog confirms it |
| --- | --- | --- |
| Removal of `daily_outcomes_curve`, `budget_guardrail`, `estimate_dau` from delivery estimate, potentially across versions October 27 | **UNVERIFIED META CLAIM** | Do not build feasibility forecasting on removed fields; check both account/ad-set endpoints and replacements, if any |
| Removal of Instagram Explore Feed as a placement | **UNVERIFIED META CLAIM** | Validate any hard-coded placement before provisioning |
| Messenger Stories `messenger_positions: ["story"]` silently dropped from effective targeting | **UNVERIFIED META CLAIM** | Read back effective targeting after provider writes; don't equate HTTP success with requested placement |
| Poll ad creative fields `poll_spec` and `interactive_components_spec.type="poll"` no longer supported in new creatives | **UNVERIFIED META CLAIM** | No direct current fbsamplR impact, as no complete creative builder is present |
| Website/App combination rejects `applink_treatment=web_only` | **UNVERIFIED META CLAIM** | Avoid assuming an old destination field remains valid |
| Special ad categories require an explicit `advantage_audience` setting on new ad sets | **UNVERIFIED META CLAIM** | Validate policy and capability boundaries per category, rather than guessing |
| Expanded WhatsApp Status ad support and associated creative/targeting fields | **UNVERIFIED META CLAIM** | Defer this provider-specific surface unless a real survey workflow needs it |
| Eligible Shops campaign creatives default to `WEBSITE_AND_SHOP` | **UNVERIFIED META CLAIM** | No current reason to build Shops creatives into the sampler |

**Official source to consult for all eight:** [Graph/Marketing API v26 changelog on developers.facebook.com](https://developers.facebook.com/docs/graph-api/changelog/version26.0/). Link existence and contents must be verified from the original domain, not inferred from its URL.

## 3. Actual fbsamplR code facts (REPO-CONFIRMED)

A GitHub search of current `main` for `graph.facebook.com/v12.0` returned **13 wrapper files**:

- `R/fb_activate_adset.R`
- `R/fb_activate_campaign.R`
- `R/fb_create_ad_campaign.R`
- `R/fb_create_adset.R`
- `R/fb_delete_adset.R`
- `R/fb_delete_campaign.R`
- `R/fb_get_metric.R`
- `R/fb_list_campaigns.R`
- `R/fb_pause_adset.R`
- `R/fb_pause_campaign.R`
- `R/fb_view_campaign_adsets.R`
- `R/fb_view_campaign_details.R`
- `R/fb_view_campaigns.R`

Confirmed by source inspection:

1. [`fb_create_ad_campaign.R`](https://github.com/essentialols/fbsamplR/blob/main/R/fb_create_ad_campaign.R) posts to `/v12.0/act_<id>/campaigns`, defaulting the argument `objective="LINK_CLICKS"`. **Whether that argument is valid for any current objective is UNVERIFIED.** Candidate `OUTCOME_TRAFFIC` must not be substituted without official compatibility evidence.
2. [`fb_create_adset.R`](https://github.com/essentialols/fbsamplR/blob/main/R/fb_create_adset.R) defaults `optimization_goal="POST_ENGAGEMENT"`, accepts a caller-built JSON `targeting` string, and posts a paused ad set. **Current Meta compatibility and any algorithmic targeting expansion semantics are UNVERIFIED.**
3. [`fb_get_metric.R`](https://github.com/essentialols/fbsamplR/blob/main/R/fb_get_metric.R) interpolates the `access_token` into the request URL and indexes `content(response)$data[[1]][[1]]` with no check for empty results or error envelopes. This is a **confirmed code security/robustness gap**, independent of provider-version claims.
4. [`conditionally_enable_disable_ad.R`](https://github.com/essentialols/fbsamplR/blob/main/R/conditionally_enable_disable_ad.R) acts on a one-row `sample_complete` flag; it does not consume current accepted SampleLedger counts. Provider "complete" and explicit study acceptance are separate concepts.
5. The public package does **not** contain a tested complete campaign → ad set → creative → ad publish → accepted-survey response loop in the files inspected. This assessment has not accessed Meta accounts, issued tokens, or bought ads.

## 4. Access and authorization — currently UNVERIFIED as Meta claims

Potential requirements to establish directly on official Meta developer pages before any live integration:
- specific scopes (`ads_read`, `ads_management`) for exact read/write endpoints;
- which app-level review/tier is required for the user's own account versus accounts owned by others;
- token types, expiry, account authority, and operational quotas;
- current permissions and feature names versus historical labels;
- available campaign objectives, optimization goals, billing fields, geographic/demographic/policy constraints and placement behavior.

**Status for all of these: UNVERIFIED META CLAIM.** No amount of validating an OAuth/JWT token for ChatGPT substitutes for validating Meta's own account access. Candidate originals to consult: [Marketing API introduction](https://developers.facebook.com/docs/marketing-api/overview/), [permissions reference](https://developers.facebook.com/docs/permissions/reference/), [app features](https://developers.facebook.com/docs/features-reference/), and the individual campaign/ad-set endpoint references on `developers.facebook.com`.

## 5. Recommended follow-up engineering sequence (PROPOSED; no code in this PR)

**M0. Direct first-party evidence capture.** Open the official changelog, version list, reference endpoints, and permission docs in a browser that can actually read them. Record exact source passages and dates, identify platform change effects, and move each row out of **UNVERIFIED** individually. This must precede selecting a target API version or changing creation payloads.

**M1. Read-only preflight.** Centralize HTTP transport, version configuration, redacted token handling, error classification, pagination, request IDs, rate-limit metadata and read-only account discovery. Prefer Authorization-header transport over query-string secrets where documented by the endpoint. Never log bearer tokens or arbitrary response bodies.

**M2. Candidate recruitment dry run.** Keep study eligibility, benchmark population, desired field oversamples and accepted responses distinct. Produce a provider-specific *proposed* plan but do not write/activate paid campaigns.

**M3. Paused sandbox mutation only after explicit approval.** Verify supported objectives, account access and budget units first. Create only inactive/paused objects and read back provider state; do not touch live campaigns during compatibility testing.

**M4. Approved limited live pilot.** Only if institutional approvals/account permissions and hard budget caps exist; reconcile accepted SampleLedger state and actual remote ad state after each consequential provider action.

**M5. Qualtrics source adapter.** Ingest response observations with stable study-scoped IDs; explicit acceptance, status transitions and immutable historical audits. No inference that an external provider's completion state equals accepted study sample.

## 6. Exit criteria for local review

A future version of this document may describe Meta features as *verified* only if all are true:

- Directly opened `developers.facebook.com` original page, not a mirror, proxy, scraped clone, or AI summary.
- The original page supports the *specific field, endpoint, date, and version applicability* claimed.
- The passage or its exact heading plus canonical first-party URL and access date are recorded.
- The method distinguishes original Meta documentation from inference and actual repository source behavior.
- For live functionality claims, documentation verification is **not** substituted for a controlled authorized live API test.

**Result of this revision:** Every unretrievable v26/Marketing API platform assertion is expressly **UNVERIFIED**. The verified claims concern only source code in `essentialols/fbsamplR`. No third-party mirror is referenced as evidence. **This PR changes only this Markdown file.**
