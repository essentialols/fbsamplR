#' Get Relative Frequencies from a Quota
#'
#' Computes relative frequencies (proportions) from a quota data frame. Each
#' row's population value is divided by the total to produce the share of the
#' sample that cell should represent.
#'
#' @param quota A data frame or tibble containing population counts.
#' @param location Unquoted name of the location column. Defaults to `name`.
#' @param freq_raw Unquoted name of the raw frequency/population column.
#'   Defaults to `value`.
#'
#' @return The input tibble with an additional `rel_freq` column containing
#'   relative frequencies.
#' @export
#'
#' @examples
#' \dontrun{
#' get_rel_freq(us_quota, location = state, freq_raw = population)
#' }
get_rel_freq <- function(quota, location = name, freq_raw = value) {
  freq_raw <- rlang::ensym(freq_raw)
  quota_rel_freq <- quota %>%
    dplyr::mutate(rel_freq = !!freq_raw / sum(!!freq_raw))
  return(quota_rel_freq)
}
