# View campaign adsets

view_campaign_adsets <- function(campaign_id,
                                 access_token){
  url <- paste0("https://graph.facebook.com/v12.0/", campaign_id, "/adsets?fields=id,configured_status,effective_status&access_token=", access_token)
  response<- GET(url)
  return(response)
}
