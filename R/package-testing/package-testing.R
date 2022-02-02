# Package testing
#
#

library(qualtRics)
library(fbsamplR)

qualtrics_api_credentials(
  api_key = "YOUR_QUALTRICS_API_KEY",
  base_url = "iad1.qualtrics.com"
)

# STEP 1: Get the survey we want from qualtrics

# Retrieve a list of all surveys
surveys <- all_surveys()

# Retrieve a single survey
mysurvey1 <- fetch_survey(surveyID = surveys$id[3])

# # same
# mysurvey2 <- fetch_survey(
#   surveyID = surveys$id[3],
#   save_dir = tempdir(),
#   start_date = "2021-10-07",
#   end_date = "2021-10-07",
#   limit = 100,
#   label = TRUE,
#   unanswer_recode = 999,
#   verbose = TRUE
# )

mysurvey1$Age

# STEP 2: Load theoretical quota (from census) and get relative frequencies

data("us_quota")

us_quota_rel_freq <- get_rel_freq(us_quota,location = "state", freq_raw = "population") %>%
  mutate(age_group = as.character(age_group))

# STEP 2a: Compute the target number of respondents

respondents <- 1000
us_quota_rel_freq <- us_quota_rel_freq %>%
  mutate(target_num_resp = ifelse(round(rel_freq*respondents) >= 2, round(rel_freq*respondents), 2))

# STEP 3: Sort survey age variable into categories of census quota

a <- split_quota_age(us_quota, age_group)

# STEP 4: Aggregate the survey responses

library(purrr)
aggregate_survey_responses <- mysurvey1 %>%
  group_by(Location, Gender) %>%
  count(Age) %>%
  mutate(age_group = map_chr(Age, ~ sort_age_into_quota_groups(., a)),
         Gender = tolower(as.character(Gender))) %>%
  count(age_group) %>%
  ungroup()

# STEP 5: Combine the quota and the responses for easy comparison

left_join(us_quota_rel_freq, aggregate_survey_responses, by = c("state" = "Location", "sex" = "Gender", "age_group")) %>%
  mutate(n_survey = replace_na(n, 0)) %>%
  dplyr::select(-n) %>%
  group_by(state, sex, age_group) %>%
  mutate(sample_complete = ifelse(n_survey < target_num_resp, F, T))

############ SOMEWHERE WE NEED TO INSERT THE NAME OF THE ADSETS IN THE FORM
############ OF A DATAFRAME
############ MAYBE DOWNLOAD FROM FB?

# STEP 6: Enable or disable ads based on the sample_complete variable

fbsamplR:::fb_list_campaigns()

# create facebook ad in personal account to test some stuff

# Create campaign

asd <- fbsamplR:::fb_create_ad_campaign(ad_account_id = "78095590",
                                  name = "live-test",
                                  access_token = "YOUR_FACEBOOK_ACCESS_TOKEN")
asd_id <- content(asd)$id

# Activate Campaign

qwe <- fbsamplR:::fb_activate_campaign(campaign_id = "6267361326373",
                                       access_token = "YOUR_FACEBOOK_ACCESS_TOKEN")

content(qwe)

# get campaign adsets

zxc2b <- fbsamplR:::fb_view_campaign_adsets(campaign_id = "6267361326373",
                                            access_token = "YOUR_FACEBOOK_ACCESS_TOKEN")

rectangled_response <- content(zxc2b) %>%
  as_tibble_col() %>%
  unnest_longer(value) %>%
  unnest_wider(value) %>%
  unnest_wider(targeting) %>%
  unnest(genders) %>% unnest(genders) %>%
  unnest_wider(geo_locations) %>% unnest(6) %>%
  unnest_wider(6, names_sep = "_") %>%
  mutate(genders = case_when(genders == 1 ~ "male", genders == 2 ~ "female", TRUE ~ "other")) %>%
  dplyr::select(-location_types, -targeting_optimization,-brand_safety_content_filter_levels, -before, -after, -value_id) %>%
  filter(if_any(everything(), ~ !is.na(.)))

# Pause adset

zxc3 <- fbsamplR:::fb_pause_adset(adset_id = "6267361501973",
                                    access_token = "YOUR_FACEBOOK_ACCESS_TOKEN")

content(zxc3)

# Now
