# Delete ad campaign
fb_delete_campaign <- function(access_token,
                            campaign_id){
  url <- paste0("https://graph.facebook.com/v12.0/", campaign_id)
  form_content <- list(access_token = access_token)
  response <- DELETE(url, body = form_content)
  return(response)
}
