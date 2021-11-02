#' Get relative frequencies
#'
#' This function takes a quota tibble or dataframe as its input and returns a tibble as its output. The function assumes that one column, the "location" column, includes the location of your quota, e.g. a country, county, or city. This can also just be a single value for all rows. The freq_raw argument encodes the raw number of people.
#'
#' @param quota dataframe or tibble
#' @param location factor or character
#' @param freq_raw numeric
#'
#' @return A tibble with relative frequencies for the gender-age combinations for each location.
#' @export
#'
#' @examples

get_rel_freq <- function(quota, location = name, freq_raw = value){
  location <- rlang::enquo(location)
  freq_raw <- rlang::enquo(freq_raw)
  quota_rel_freq <- quota %>%
    group_by(!!location) %>%
    mutate(rel_freq = !!freq_raw/sum(!!freq_raw)) %>%
    ungroup(!!location)
  return(quota_rel_freq)
}
