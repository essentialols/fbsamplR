#' Get a Metric from a Facebook Ad Object
#'
#' Retrieves a single insight metric (e.g., spend, impressions, clicks) from
#' a campaign, ad set, or ad.
#'
#' @param ad_object_id The ID of the campaign, ad set, or ad.
#' @param metric The metric field to retrieve. Defaults to `"spend"`.
#' @param access_token Facebook API access token.
#'
#' @return The metric value, coerced to numeric if possible.
#' @export
fb_get_metric <- function(ad_object_id,
                          metric = "spend",
                          access_token = Sys.getenv("FACEBOOK_TOKEN")) {
  url <- paste0(
    "https://graph.facebook.com/v12.0/", ad_object_id,
    "/insights?fields=", metric,
    "&access_token=", access_token
  )
  response <- httr::GET(url)
  my_metric <- httr::content(response)$data[[1]][[1]]
  my_metric <- ifelse(
    suppressWarnings(!is.na(as.numeric(my_metric))),
    as.numeric(my_metric),
    my_metric
  )
  return(my_metric)
}
