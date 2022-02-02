# View campaigns

fb_view_campaigns <- function(ad_account_id,
                              limit = 2,
                              filtering = "[{'field': 'name','operator':'CONTAIN', 'value': 'fb_api_test_campaign'}]",
                              access_token = Sys.getenv("FACEBOOK_TOKEN")){
  campaign_fields <- c("id", "account_id", "ad_strategy_id", "adlabels", "bid_strategy",
                       "boosted_object_id", "brand_lift_studies", "budget_rebalance_flag",
                       "budget_remaining", "buying_type", "can_create_brand_lift_study",
                       "can_use_spend_cap", "configured_status", "created_time", "daily_budget",
                       "effective_status", "is_skadnetwork_attribution", "issues_info",
                       "last_budget_toggling_time", "lifetime_budget", "name", "objective",
                       "pacing_type", "promoted_object", "recommendations", "smart_promotion_type",
                       "source_campaign", "source_campaign_id", "special_ad_categories",
                       "special_ad_category", "special_ad_category_country", "spend_cap",
                       "start_time", "status", "stop_time", "topline_id", "updated_time")
  campaign_fields <- paste0(unlist(campaign_fields), collapse = ",")
  url <- paste0("https://graph.facebook.com/v12.0/act_", ad_account_id,
                "/campaigns?fields=", campaign_fields,
                "&limit=", limit,
                "&filtering=", filtering,
                "&access_token=", access_token
                # "&filtering={'field':'effective_status','operator':'IN','value':['ACTIVE','PAUSED','PENDING_REVIEW']}")
                )
  encoded_url <- URLencode(url)
  response <- GET(encoded_url)
  return(response)
  # master <- list()
  # master <- append(master, response$result$elements)
  # while (!is.null(response$result$nextPage)) {
  #   response <- response <- GET(response$result$nextPage)
  #   master <- append(master, response$result$elements)
  # }
  # d <- bind_rows(master)
  # mycontent <- content(response)$data
  # mycontent <- map_dfr(mycontent, unlist)
  # return(d)
}

