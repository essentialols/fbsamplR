# fbsamplR

An R package that integrates the **Facebook Marketing API** and the **Qualtrics API** to automate quota-based survey sampling at scale.

## The Problem

Running large-scale, demographically representative online surveys is expensive and labor-intensive. Researchers must manually create targeted Facebook ad campaigns for each demographic cell (age × gender × location), monitor incoming survey responses against census quotas, and pause ads for cells that have reached their target — often across dozens of countries simultaneously.

## What fbsamplR Does

fbsamplR automates this entire pipeline:

1. **Define quotas** from census data (included datasets for the US and Germany)
2. **Create and manage Facebook ad campaigns** programmatically via the Marketing API
3. **Create and manage Qualtrics surveys** via the Qualtrics API
4. **Monitor quota fulfillment** by comparing incoming survey responses to target distributions
5. **Automatically pause/activate ad sets** when demographic cells reach their quota

This closes the loop between ad spend and survey completion — no manual monitoring required.

## Installation

```r
# Install from GitHub
devtools::install_github("essentialols/fbsamplR")
```

## Setup

```r
library(fbsamplR)

# Set your Facebook API token (or set FACEBOOK_TOKEN env var)
fb_set_facebook_token("your_facebook_access_token")

# Qualtrics credentials are managed via the qualtRics package
qualtRics::qualtrics_api_credentials(
  api_key = "your_qualtrics_api_key",
  base_url = "yourdatacenter.qualtrics.com"
)
```

## Workflow

### Step 1: Prepare your census quota

```r
# Load included US census data
data("us_quota")

# Compute relative frequencies and target respondent counts
quota <- get_rel_freq(us_quota, location = state, freq_raw = population)

# Parse age groups into numeric bounds for matching
age_brackets <- split_quota_age(us_quota, age_group)
```

### Step 2: Create Facebook ad infrastructure

```r
# Create a campaign
campaign <- fb_create_ad_campaign(
  ad_account_id = "your_account_id",
  name = "Survey Recruitment Q1",
  objective = "LINK_CLICKS"
)

# Create targeted ad sets for each demographic cell
adset <- fb_create_adset(
  ad_account_id = "your_account_id",
  name = "US_male_18-24",
  lifetime_budget = 5000,
  bid_amount = 100,
  targeting = '{"age_min": 18, "age_max": 24, "genders": [1]}',
  campaign_id = "campaign_id",
  end_time = "2025-12-31T23:59:59-0000"
)
```

### Step 3: Monitor and adjust

```r
# Get current survey responses and compute empirical frequencies
survey <- qualtRics::fetch_survey(surveyID = "your_survey_id")
empirical <- get_empirical_freq(survey, location = State, gender = Gender, age = Age)

# Compare to quota targets
comparison <- compare_freq_quota(quota, empirical)

# Automatically pause ad sets that have met their quota
fb_conditionally_enable_disable_adset(comparison_row, access_token = "token")
```

## Function Reference

### Facebook Ad Management
| Function | Description |
|---|---|
| `fb_set_facebook_token()` | Store Facebook API credentials |
| `fb_create_ad_campaign()` | Create a new ad campaign |
| `fb_create_adset()` | Create a targeted ad set |
| `fb_activate_campaign()` | Unpause a campaign |
| `fb_activate_adset()` | Unpause an ad set |
| `fb_pause_campaign()` | Pause a campaign |
| `fb_pause_adset()` | Pause an ad set |
| `fb_delete_campaign()` | Delete a campaign |
| `fb_delete_adset()` | Delete an ad set |
| `fb_list_campaigns()` | List campaigns in an account |
| `fb_view_campaigns()` | View campaign details |
| `fb_view_campaign_details()` | View a single campaign's details |
| `fb_view_campaign_adsets()` | View all ad sets in a campaign |
| `fb_get_metric()` | Get a metric (spend, impressions, etc.) |
| `fb_conditionally_enable_disable_adset()` | Auto-pause/activate based on quota |

### Qualtrics Survey Management
| Function | Description |
|---|---|
| `qual_create_survey()` | Create a new survey |
| `qual_import_questions()` | Import questions from a file |
| `qual_create_response()` | Insert a response into a survey |
| `qual_delete_response()` | Delete a response |
| `qual_delete_survey()` | Delete a survey |
| `write_question_file()` | Format questions for Qualtrics import |

### Quota & Sampling
| Function | Description |
|---|---|
| `get_rel_freq()` | Compute relative frequencies from census data |
| `split_quota_age()` | Parse age group labels into numeric bounds |
| `sort_age_into_quota_groups()` | Match a respondent's age to a quota bracket |
| `get_empirical_freq()` | Compute observed frequencies from survey data |
| `compare_freq_quota()` | Join quota targets with observed counts |
| `create_asl()` | Simulate a synthetic age-sex-location sample |

### Included Datasets
| Dataset | Description |
|---|---|
| `us_quota` | US population by state, age group, and sex (2019 Census) |
| `germany_quota` | Germany population by age group and sex |

## Background

This package was developed as part of a research project that ran quota-based surveys across 46 countries with over 45,000 respondents recruited through Facebook ads. It was presented at the American Political Science Association (APSA) and Midwest Political Science Association (MPSA) annual meetings.

## License

MIT
