#' Delete a Facebook Ad Campaign
#'
#' Permanently deletes a campaign.
#'
#' @param campaign_id The Facebook campaign ID.
#' @param access_token Facebook API access token.
#'
#' @return An `httr` response object.
#' @export
fb_delete_campaign <- function(campaign_id,
                               access_token = Sys.getenv("FACEBOOK_TOKEN")) {
  url <- paste0("https://graph.facebook.com/v12.0/", campaign_id)
  form_content <- list(access_token = access_token)
  response <- httr::DELETE(url, body = form_content)
  return(response)
}
