#' Conditionally Enable or Disable a Facebook Ad Set
#'
#' This function takes a dataframe which contains a logical decision column and ad set IDs to conditionally enable or disable an ad set, depending on the value of the decision column.
#' @param activation_decision_df A dataframe containing at least one column
#' @param access_token
#' @param ad_set_id = ad_set_id
#' @param sample_complete = sample_complete
#'
#' @return Returns an age bracket. If age argument is NA, the function returns NA of type character. #???? not sure that's what it does
#'
#' @keywords quota cleaning categorization
#' @export
#' @examples
#' sort_age_into_quota_groups(20, quota = us_quota) ### This might be the wrong quota

fb_conditionally_enable_disable_adset <- function(activation_decision_df, access_token, ad_set_id = ad_set_id, sample_complete = sample_complete){
  sample_complete <- ensym(sample_complete)
  ad_set_id <- ensym(ad_set_id)
  if(activation_decision_df$sample_complete){
    response <- fbsamplR:::fb_pause_adset(activation_decision_df$ad_set_id, access_token)}
  else{
    response <- fbsamplR:::fb_activate_adset(activation_decision_df$ad_set_id, access_token)
  }
  return(response)
}
