#' Split Quota Age Groups into Separate Columns
#'
#' Takes a quota data frame and splits the age group labels (e.g., `"18-24"`,
#' `"65+"`) into numeric `lower` and `upper` bound columns.
#'
#' @param quota A data frame containing an age group column with labels like
#'   `"18-24"` or `"65+"`.
#' @param age_variable Unquoted name of the age group column. Defaults to
#'   `age`.
#'
#' @return A data frame with columns `age_bracket`, `lower`, and `upper`.
#'   For open-ended groups (e.g., `"65+"`), `upper` is set to `Inf`.
#' @export
#'
#' @examples
#' \dontrun{
#' split_quota_age(us_quota, age_group)
#' }
split_quota_age <- function(quota, age_variable = age) {
  age_variable <- rlang::enquo(age_variable)
  new_quota <- quota %>%
    dplyr::ungroup() %>%
    dplyr::distinct(!!age_variable) %>%
    dplyr::mutate(age_bounds = strsplit(as.character(!!age_variable), "\\-|\\+")) %>%
    tidyr::unnest_wider(age_bounds) %>%
    suppressMessages() %>%
    dplyr::rename(age_bracket = !!age_variable, "lower" = ...1, "upper" = ...2) %>%
    dplyr::mutate(
      lower = as.numeric(lower),
      upper = as.numeric(stringr::str_replace_na(upper, Inf))
    )
  return(new_quota)
}
