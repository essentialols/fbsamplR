# Activate (unpause) adset

fb_activate_adset <- function(access_token,
                           adset_id){
  url <- paste0("https://graph.facebook.com/v12.0/", adset_id)
  form_content <- list(status = "ACTIVE",
                       access_token = access_token)
  response <- POST(url, body = form_content)
  return(response)
}
