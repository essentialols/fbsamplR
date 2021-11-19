# Get metric

fb_get_metric <- function(ad_object_id,
                       metric = "spend",
                       access_token){
  url <- paste0("https://graph.facebook.com/v12.0/", ad_object_id,"/insights?fields=", metric, "&access_token=", access_token)
  response <- GET(url)
  my_metric <- content(response)$data[[1]][[1]]
  my_metric <- ifelse(suppressWarnings(!is.na(as.numeric(my_metric))), as.numeric(my_metric), my_metric)
  return(my_metric)
}
