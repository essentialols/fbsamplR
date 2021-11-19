# View campaigns

fb_view_campaigns <- function(ad_account_id,
                              fields = list("id", "name"),
                              limit = 1,
                              filtering = "[{'field': 'name','operator':'CONTAIN', 'value': 'fb_api_test_campaign'}]",
                              access_token){
  fields <- paste0(unlist(fields), collapse = ",")
  url <- paste0("https://graph.facebook.com/v12.0/act_", ad_account_id,
                "/campaigns?fields=", fields,
                "&limit=", limit,
                "&filtering=", filtering,
                "&access_token=", access_token)
  encoded_url <- URLencode(url)
  response <- GET(encoded_url)
  return(response)
}
