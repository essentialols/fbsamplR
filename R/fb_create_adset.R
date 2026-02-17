#' Create a Facebook Ad Set
#'
#' Creates a new ad set within an existing campaign, specifying budget,
#' targeting, and scheduling parameters.
#'
#' @param ad_account_id The Facebook ad account ID (without the `act_` prefix).
#' @param name Name for the ad set.
#' @param lifetime_budget Total budget for the ad set's lifetime (in cents).
#' @param optimization_goal Optimization goal. Defaults to `"POST_ENGAGEMENT"`.
#' @param billing_event Billing event. Defaults to `"IMPRESSIONS"`.
#' @param bid_amount Bid amount (in cents).
#' @param targeting A JSON string specifying the targeting criteria.
#' @param campaign_id The parent campaign ID.
#' @param end_time End time in ISO 8601 format.
#' @param status Initial status. Defaults to `"PAUSED"`.
#' @param access_token Facebook API access token.
#'
#' @return An `httr` response object containing the new ad set ID.
#' @export
fb_create_adset <- function(ad_account_id,
                            name,
                            lifetime_budget,
                            optimization_goal = "POST_ENGAGEMENT",
                            billing_event = "IMPRESSIONS",
                            bid_amount,
                            targeting,
                            campaign_id,
                            end_time,
                            status = "PAUSED",
                            access_token = Sys.getenv("FACEBOOK_TOKEN")) {
  url <- paste0("https://graph.facebook.com/v12.0/act_", ad_account_id, "/adsets")
  form_content <- list(
    name = name,
    lifetime_budget = lifetime_budget,
    optimization_goal = optimization_goal,
    billing_event = billing_event,
    bid_amount = bid_amount,
    targeting = targeting,
    campaign_id = campaign_id,
    end_time = end_time,
    status = status,
    access_token = access_token
  )
  response <- httr::POST(url, body = form_content)
  return(response)
}
