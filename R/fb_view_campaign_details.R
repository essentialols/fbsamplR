#' View Campaign Details
#'
#' Retrieves detailed information for a single Facebook campaign.
#'
#' @param campaign_id The Facebook campaign ID.
#' @param access_token Facebook API access token. Defaults to the
#'   `FACEBOOK_TOKEN` environment variable.
#'
#' @return An `httr` response object containing campaign details.
#' @export
fb_view_campaign_details <- function(campaign_id,
                                     access_token = Sys.getenv("FACEBOOK_TOKEN")) {
  fields <- paste0(
    c("id", "name", "account_id", "bid_strategy", "budget_remaining",
      "buying_type", "configured_status", "created_time", "daily_budget",
      "effective_status", "lifetime_budget", "objective", "start_time",
      "status", "stop_time", "updated_time"),
    collapse = ","
  )
  url <- paste0(
    "https://graph.facebook.com/v12.0/", campaign_id,
    "?fields=", fields,
    "&access_token=", access_token
  )
  response <- httr::GET(url)
  return(response)
}
