# Create ad campaign
fb_create_ad_campaign <- function(ad_account_id,
                               name,
                               objective = "LINK_CLICKS",
                               status = "PAUSED",
                               special_ad_categories = "[]",
                               access_token){
  url <- paste0("https://graph.facebook.com/v12.0/act_", ad_account_id,"/campaigns")
  form_content <- list(name = name,
                       objective = objective,
                       status = status,
                       special_ad_categories = special_ad_categories,
                       access_token = access_token)
  response <- POST(url, body = form_content)
  return(response)
}
