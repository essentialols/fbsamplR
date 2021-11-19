# Create adset

fb_create_adset <- function(ad_account_id,
                         name,
                         lifetime_budget,
                         optimization_goal = "POST_ENGAGEMENT",
                         billing_event = "IMPRESSIONS",
                         bid_amount,
                         targeting,
                         campaign_id,
                         end_time,
                         status = "PAUSED",
                         access_token){
  url <- paste0("https://graph.facebook.com/v12.0/act_", ad_account_id,"/adsets")
  form_content <- list(name = name,
                       lifetime_budget = lifetime_budget,
                       optimization_goal = optimization_goal,
                       billing_event = billing_event,
                       bid_amount = bid_amount,
                       targeting = targeting,
                       campaign_id = campaign_id,
                       end_time = end_time,
                       status = status,
                       access_token = access_token)

  response <- POST(url, body = form_content)
  return(response)
}
