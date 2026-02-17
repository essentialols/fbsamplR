#' Pause a Facebook Ad Campaign
#'
#' Sets the status of a campaign to `PAUSED`.
#'
#' @param campaign_id The Facebook campaign ID.
#' @param access_token Facebook API access token.
#'
#' @return An `httr` response object.
#' @export
fb_pause_campaign <- function(campaign_id,
                              access_token = Sys.getenv("FACEBOOK_TOKEN")) {
  url <- paste0("https://graph.facebook.com/v12.0/", campaign_id)
  form_content <- list(status = "PAUSED", access_token = access_token)
  response <- httr::POST(url, body = form_content)
  return(response)
}
