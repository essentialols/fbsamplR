#' Get Empirical Frequencies from Survey Data
#'
#' Computes the observed frequency of respondents for each combination of
#' location, age, and gender in a survey data frame.
#'
#' @param survey A data frame of survey responses.
#' @param location Unquoted name of the location column.
#' @param gender Unquoted name of the gender column.
#' @param age Unquoted name of the age column.
#'
#' @return A tibble with columns `location`, `gender`, `age`, and `n`
#'   (the count of respondents in each cell).
#' @export
get_empirical_freq <- function(survey, location, gender, age) {
  location <- rlang::ensym(location)
  gender <- rlang::ensym(gender)
  age <- rlang::ensym(age)

  empirical_dist <- survey %>%
    dplyr::rename(
      location = !!location,
      gender = !!gender,
      age = !!age
    ) %>%
    dplyr::group_by(location, age, gender) %>%
    dplyr::summarise(n = dplyr::n(), .groups = "drop") %>%
    dplyr::select(location, gender, age, n)

  return(empirical_dist)
}
