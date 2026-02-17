#' Delete a Facebook Ad Set
#'
#' Permanently deletes an ad set.
#'
#' @param adset_id The Facebook ad set ID.
#' @param access_token Facebook API access token.
#'
#' @return An `httr` response object.
#' @export
fb_delete_adset <- function(adset_id,
                            access_token = Sys.getenv("FACEBOOK_TOKEN")) {
  url <- paste0("https://graph.facebook.com/v12.0/", adset_id)
  form_content <- list(access_token = access_token)
  response <- httr::DELETE(url, body = form_content)
  return(response)
}
