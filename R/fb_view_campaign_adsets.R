#' View campaign adsets
#'
#' This function looks up all adsets associated with a campaign and returns them as a tibble.
#'
#' @return Returns a tibble of variable dimensions, whereas rows are adsets and columns are id, name, age_max, age_min, genders, countries (and regions if so specified), configured_status, and effective_status.
#'
#' @keywords facebook ad-sets
#' @export
#' @examples
#' fb_view_campaign_adsets(campaign_id = "123456789",
#'                                    access_token = "123456789")


fb_view_campaign_adsets <- function(campaign_id,
                                 access_token){
  url <- paste0("https://graph.facebook.com/v12.0/",
                campaign_id, "/adsets?fields=id,name,targeting,configured_status,effective_status&access_token=", access_token)
  response<- GET(url)
  rectangled_response <- content(response) %>%
    as_tibble_col() %>%
    unnest_longer(value) %>%
    unnest_wider(value) %>%
    unnest_wider(targeting) %>%
    unnest(genders) %>% unnest(genders) %>%
    unnest_wider(geo_locations) %>% unnest(6) %>%
    unnest_wider(6, names_sep = "_") %>%
    mutate(genders = case_when(genders == 1 ~ "male", genders == 2 ~ "female", TRUE ~ "other")) %>%
    dplyr::select(-location_types, -targeting_optimization,-brand_safety_content_filter_levels, -before, -after, -value_id) %>%
    filter(if_any(everything(), ~ !is.na(.)))
  return(rectangled_response)
}
