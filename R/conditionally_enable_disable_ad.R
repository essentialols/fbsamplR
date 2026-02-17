#' Conditionally Enable or Disable a Facebook Ad Set
#'
#' Takes a one-row data frame containing a logical `sample_complete` column and
#' an `ad_set_id` column. If the quota for that ad set is complete, the ad set
#' is paused; otherwise it is activated.
#'
#' @param activation_decision_df A one-row data frame with at least columns
#'   `sample_complete` (logical) and `ad_set_id` (character).
#' @param access_token Facebook API access token.
#'
#' @return An `httr` response object from the pause or activate call.
#' @export
fb_conditionally_enable_disable_adset <- function(activation_decision_df,
                                                  access_token) {
  if (activation_decision_df$sample_complete) {
    response <- fb_pause_adset(activation_decision_df$ad_set_id, access_token)
  } else {
    response <- fb_activate_adset(activation_decision_df$ad_set_id, access_token)
  }
  return(response)
}
