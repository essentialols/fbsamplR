# View campaign details

fb_view_campaign_details <- function(ad_account_id,
                                  campaign_id,
                                  access_token){
  fields <- paste0(c("id", "name", "account_id", "ad_strategy_id", "adlabels",
                     "bid_strategy", "boosted_object_id", "brand_lift_studies", "budget_rebalance_flag",
                     "budget_remaining", "buying_type", "can_create_brand_lift_study",
                     "can_use_spend_cap", "configured_status", "created_time", "daily_budget",
                     "effective_status", "is_skadnetwork_attribution", "issues_info",
                     "last_budget_toggling_time", "lifetime_budget", "objective",
                     "pacing_type", "promoted_object", "recommendations", "smart_promotion_type",
                     "source_campaign", "source_campaign_id", "special_ad_categories",
                     "special_ad_category", "special_ad_category_country", "spend_cap",
                     "start_time", "status", "stop_time", "topline_id", "updated_time"), collapse = ",")
  url <- paste0("https://graph.facebook.com/v12.0/",campaign_id, "?fields=",fields, "&access_token=", access_token)
  response <- GET(url)
  return(response)
}
