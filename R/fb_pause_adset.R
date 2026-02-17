#' Pause a Facebook Ad Set
#'
#' Sets the status of an ad set to `PAUSED`.
#'
#' @param adset_id The Facebook ad set ID.
#' @param access_token Facebook API access token.
#'
#' @return An `httr` response object.
#' @export
fb_pause_adset <- function(adset_id,
                           access_token = Sys.getenv("FACEBOOK_TOKEN")) {
  url <- paste0("https://graph.facebook.com/v12.0/", adset_id)
  form_content <- list(status = "PAUSED", access_token = access_token)
  response <- httr::POST(url, body = form_content)
  return(response)
}
