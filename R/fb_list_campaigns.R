#' List Facebook Ad Campaigns
#'
#' Retrieves a list of all campaigns for a given ad account.
#'
#' @param ad_account_id The Facebook ad account ID (numeric string, without
#'   the `act_` prefix).
#' @param limit Maximum number of campaigns to return. Defaults to 25.
#' @param access_token Facebook API access token. Defaults to the
#'   `FACEBOOK_TOKEN` environment variable.
#'
#' @return An `httr` response object containing campaign data.
#' @export
fb_list_campaigns <- function(ad_account_id,
                              limit = 25,
                              access_token = Sys.getenv("FACEBOOK_TOKEN")) {
  url <- paste0(
    "https://graph.facebook.com/v12.0/act_", ad_account_id,
    "/campaigns?fields=id,name,status,objective,created_time",
    "&limit=", limit,
    "&access_token=", access_token
  )
  response <- httr::GET(URLencode(url))
  return(response)
}
