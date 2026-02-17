#' Create a Facebook Ad Campaign
#'
#' Creates a new ad campaign in the specified Facebook ad account.
#'
#' @param ad_account_id The Facebook ad account ID (without the `act_` prefix).
#' @param name Name for the campaign.
#' @param objective Campaign objective. Defaults to `"LINK_CLICKS"`.
#' @param status Initial status. Defaults to `"PAUSED"`.
#' @param special_ad_categories JSON string for special ad categories.
#'   Defaults to `"[]"`.
#' @param access_token Facebook API access token.
#'
#' @return An `httr` response object containing the new campaign ID.
#' @export
fb_create_ad_campaign <- function(ad_account_id,
                                  name,
                                  objective = "LINK_CLICKS",
                                  status = "PAUSED",
                                  special_ad_categories = "[]",
                                  access_token = Sys.getenv("FACEBOOK_TOKEN")) {
  url <- paste0("https://graph.facebook.com/v12.0/act_", ad_account_id, "/campaigns")
  form_content <- list(
    name = name,
    objective = objective,
    status = status,
    special_ad_categories = special_ad_categories,
    access_token = access_token
  )
  response <- httr::POST(url, body = form_content)
  return(response)
}
