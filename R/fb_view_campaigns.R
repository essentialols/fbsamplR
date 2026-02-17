#' View Facebook Ad Campaigns
#'
#' Retrieves detailed information about campaigns in an ad account, with
#' optional filtering by name.
#'
#' @param ad_account_id The Facebook ad account ID (without the `act_` prefix).
#' @param limit Maximum number of campaigns to return. Defaults to 25.
#' @param filtering A JSON-formatted filter string for the API. Defaults to
#'   no filtering.
#' @param access_token Facebook API access token. Defaults to the
#'   `FACEBOOK_TOKEN` environment variable.
#'
#' @return An `httr` response object containing campaign details.
#' @export
fb_view_campaigns <- function(ad_account_id,
                              limit = 25,
                              filtering = NULL,
                              access_token = Sys.getenv("FACEBOOK_TOKEN")) {
  campaign_fields <- paste0(
    c("id", "account_id", "bid_strategy", "budget_remaining", "buying_type",
      "configured_status", "created_time", "daily_budget", "effective_status",
      "lifetime_budget", "name", "objective", "start_time", "status",
      "stop_time", "updated_time"),
    collapse = ","
  )
  url <- paste0(
    "https://graph.facebook.com/v12.0/act_", ad_account_id,
    "/campaigns?fields=", campaign_fields,
    "&limit=", limit,
    "&access_token=", access_token
  )
  if (!is.null(filtering)) {
    url <- paste0(url, "&filtering=", filtering)
  }
  response <- httr::GET(URLencode(url))
  return(response)
}
