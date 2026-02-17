#' Compare Empirical Frequencies to Quota Targets
#'
#' Joins a quota data frame with observed survey frequencies to enable
#' comparison between target and actual sample distributions.
#'
#' @param quota A data frame of quota targets (e.g., from census data).
#' @param survey_freq A data frame of observed survey frequencies, as
#'   returned by [get_empirical_freq()].
#'
#' @return A joined data frame combining quota targets with observed counts.
#' @export
compare_freq_quota <- function(quota, survey_freq) {
  empirical_quota <- dplyr::left_join(quota, survey_freq)
  return(empirical_quota)
}
