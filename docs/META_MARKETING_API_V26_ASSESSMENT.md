# Meta Marketing API v26.0: fbsamplR gap assessment
*Research-only; 2026-10-21. This document changes no application code or Meta campaigns.*

## Decision in one paragraph

**Do not change `v12.0` to `v26.0` with a global string replacement.** The current R package has real Meta HTTP wrappers, but has no verified end-to-end v26 recruitment flow. Its original create-campaign default (`LINK_CLICKS`), create-ad-set default (`POST_ENGAGEMENT`), targeting, quota-triggered stop/start functions, and metric extraction require an objective- and capability-aware migration, not only a newer version prefix. Meta-specific execution remains postponed behind the authenticated researcher beta and real sample-audit workflow. A narrow **read-only, no-spend preflight** should be the first later implementation.

## Evidence and dates

- **July 29, 2026:** Meta released Graph API and Marketing API v26.0. See [Meta official v26 changelog](https://developers.facebook.com/docs/graph-api/changelog/version26.0/) and [Meta's launch post](https://developers.facebook.com/blog/post/2026/07/29/introducing-graph-api-v26-and-marketing-api-v26/). The official Meta URLs sometimes deny automated fetching; the release details were cross-checked against an indexed copy of the same dated changelog and launch announcement on October 21, 2026.
- **October 6, 2026:** Marketing API v24 sunset; do not confuse this with Graph API v24's different expiration date. Marketing API v12.0 used in the package is far older and not a supported target.
- **October 27, 2026 (upcoming):** Meta rolls several v26 changes to *all still-supported Marketing API versions*. These include poll-ad creation, Messenger Stories placement, Web+App web-only destination, and three Delivery Estimate fields. Staying pinned to a supported older API will not avoid those changes.
- **May 4, 2026:** Meta renamed the separate **Ads Management Standard Access** feature to **Marketing API Access Tier** (Limited vs Full). This is **not** the same as the `ads_management` permission. [Meta's May 2026 announcement](https://developers.meta.com/blog/updates-to-ads-management-standard-access-feature/).

## v26 Marketing API changes: relevance to survey recruitment

| Change | Effective timing | Consequence for fbsamplR |
| --- | --- | --- |
| `daily_outcomes_curve`, `budget_guardrail`, `estimate_dau` removed from `delivery_estimate` | v26 immediately; all supported versions Oct 27 | No replacement. No direct use found in current wrappers, but don't design feasibility forecasts around them. |
| Instagram Explore Feed placement removed | v26 immediately | Explicit targeting of Explore errors; validate any future placement specification. |
| Messenger Stories: `messenger_positions: ["story"]` silently removed | v26 immediately; all versions Oct 27 | Write success does not guarantee requested effective placement; read back targeting before considering recruitment live. |
| Poll creative components discontinued | v26 immediately; all versions Oct 27 | No direct impact to current package, which has no ad creative builder. Future adapter should not use poll creative fields. |
| Website-and-App campaign creatives cannot use `applink_treatment=web_only` | v26 immediately; all versions Oct 27 | Relevant only if later creating linked Website+App creatives; avoid hard-coded legacy destinations. |
| Housing/Employment/Financial Products and Services special ad categories require explicit `advantage_audience` 0/1 on new ad-set creation | v26 | Validate category-specific semantics instead of relying on defaults. This does **not** mean the survey's actual demographic eligibility can be imposed through ad targeting. |
| WhatsApp Status placements enhanced | v26 | Not an early priority for survey recruitment. |
| Eligible Shops ads default creative destination to `WEBSITE_AND_SHOP` | v26 | Do not build ad-creative assumptions from older examples. |

Note: all-version enforcement dates apply only where Meta explicitly says so. These are *Marketing* API changes; unrelated Graph Commerce and Pages deprecations are not fbsamplR requirements.

## Repo source inventory (main as of October 21)

GitHub search for `graph.facebook.com/v12.0` finds **13 R wrappers**, all in `R/`:

`fb_activate_adset.R`, `fb_activate_campaign.R`, `fb_create_ad_campaign.R`, `fb_create_adset.R`, `fb_delete_adset.R`, `fb_delete_campaign.R`, `fb_get_metric.R`, `fb_list_campaigns.R`, `fb_pause_adset.R`, `fb_pause_campaign.R`, `fb_view_campaign_adsets.R`, `fb_view_campaign_details.R` and `fb_view_campaigns.R`.

Observed code-level modernization gaps:
1. `fb_create_ad_campaign()` posts directly to `/v12.0/act_<id>/campaigns`, defaults `objective="LINK_CLICKS"`. Meta's current simplified outcomes catalog uses objectives such as `OUTCOME_TRAFFIC`; the correct migration must also consider the conversion destination, ad set optimization, ad creation, and eligible placements, **not a blind enum renaming**.
2. `fb_create_adset()` defaults `optimization_goal="POST_ENGAGEMENT"`, which does not automatically match traffic to a survey landing page. It accepts caller-built JSON targeting without checking which settings are hard limits versus algorithmic suggestions.
3. `fb_get_metric()` interpolates `access_token` into a URL query string and assumes `content(response)$data[[1]][[1]]` exists; it has no explicit empty-result, API-error, status, or pagination handling.
4. `fb_conditionally_enable_disable_adset()` switches ad sets from a single logical `sample_complete` flag. Modern acceptance must be based on the **current accepted SampleLedger state**, not a raw Qualtrics "complete" flag or an ad delivery metric.
5. The package exposes campaign and ad-set wrappers but does **not** expose a complete tested campaign → ad set → creative → ad publishing workflow. Keep ad creation **paused** by default until each required step can be validated.
6. Provider API responses are returned raw or assumed to have a fixed shape; a later common transport module should classify permissions, retries, rate limits, token expiry, and ambiguous writes without logging credentials.
7. Nothing in this review establishes that the user's Meta app, business, ad account, authorization scopes or audience targeting entitlements are currently enabled.

## Meta credentials and capabilities that must be checked later

Meta's public [Marketing API Postman collection](https://www.postman.com/meta/facebook-marketing-api/collection/0zr4mes/facebook-marketing-api-mapi) identifies: developer app, valid access token, ad-account access, and `ads_read`/`ads_management` permissions according to the operation. Managing ad accounts belonging to third parties may require additional App Review / advanced permission access. Separately, the 2026 Marketing API Access Tier controls higher API quotas and system-user capacity; it is not an alias for `ads_management`. Never assume an app-level token is authorized on an ad account merely because token parsing succeeds.

Check the actual app permission grants and ad-account capabilities in the Meta dashboard, without storing tokens in GitHub or exposing them in ChatGPT messages.

## Future migration plan (NOT implemented by this document)

**M0. Pure discovery:** preserve `fb_*` compatibility entry points; map each wrapper to its current operation, required permission, API version, request/response structure and error states. Reconcile Meta changelog with actual endpoint reference and identify usable campaign objectives/optimization combinations for an ordinary survey landing page.

**M1. Read-only vertical slice:** one central transport/helper that takes a configured current API version and token via HTTP Authorization header, no query-string secrets. Implement `GET me/adaccounts` or equivalent allowed account discovery, list campaigns/ad sets, and a carefully bounded metrics query; classify errors, pagination and rate limits. Use a test account or approved read-only token. This must require **zero spending**.

**M2. Dry-run planned recruitment:** translate the provider-neutral RecruitmentDesign to Meta-*candidate* campaign/ad-set targeting, surface unsupported/expandable targeting, policy-gated special ad categories, expected budget and source provenance. No POST or paid mutation.

**M3. Paused sandbox write:** only with explicit human authorization and suitable ad account, create a paused campaign and paused ad set, then reconcile by reading them back. Do not activate, spend, delete, or mutate live campaigns merely to test compatibility.

**M4. Controlled live pilot:** after account permissions and appropriate research approval, allow explicitly approved campaign activation with spending limits and hard-stop controls; derive decisions from accepted sample counts and reconcile remote effective state after each request. Keep direct researcher/manual operation available.

**M5. Qualtrics bridge:** fetch research response snapshots separately, map stable study-scoped response IDs and acceptance policy into SampleLedger, reconcile repeatedly, preserve previous audits, and never assume provider "complete" means accepted.

## Conformance checklist for a local coding agent

- Current API version is discovered/configured centrally and validated; no `v12.0` URLs.
- Read-only preflight does not write anything remotely and does not require stored user PII.
- API response envelope validation handles errors/empty data/pagination/rate limiting/expired tokens.
- Account and authorization scopes checked independently of Marketing API Access Tier.
- Objective/optimization/placement combination checked against the ad account's actual capabilities.
- Budgets remain in account currency minor units with explicit upper limits and human approval for live writes.
- Meta source observations and accepted SampleLedger counts remain separate.
- No new account targeting, activation, pause, deletion, or spend changes without explicit approved execution.
- Tests mock the HTTP transport for permissions errors, timeout, duplicate call, ambiguity, missing metric and unexpected placement removal.
- First live validation reads back *effective* server state after each write; do not treat HTTP 200 as evidence that exact intended targeting persists.

## Sources

1. [Meta, Graph API v26.0 change log](https://developers.facebook.com/docs/graph-api/changelog/version26.0/), July 29 2026. Retrieval via indexed copy of Meta's page.
2. [Meta, v26 introduction](https://developers.facebook.com/blog/post/2026/07/29/introducing-graph-api-v26-and-marketing-api-v26/), July 29 2026. Retrieval via indexed copy.
3. [Meta, Marketing API Access Tier renaming](https://developers.meta.com/blog/updates-to-ads-management-standard-access-feature/), May 4 2026.
4. [Meta-maintained Marketing API Postman collection](https://www.postman.com/meta/facebook-marketing-api/collection/0zr4mes/facebook-marketing-api-mapi).
5. Current `fbsamplR` `main` branch source files cited above; no provider credentials or live campaigns accessed.

**This file is the whole PR. No R code or test files are changed.**
