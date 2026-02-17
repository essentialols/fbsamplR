#' Create a Simulated Age-Sex-Location Sample
#'
#' Generates a synthetic data frame of respondents with random age, gender,
#' and location values. Useful for testing quota sampling workflows.
#'
#' @param n Number of respondents to simulate.
#' @param mf_ratio A numeric vector of length 2 giving the probability of
#'   male (1) and female (2). Defaults to `c(0.5, 0.5)`.
#' @param age_dist Optional probability weights for ages 18-100. If `NULL`,
#'   uniform sampling is used.
#' @param location_dist Optional probability weights for locations 1-50. If
#'   `NULL`, uniform sampling is used.
#'
#' @return A tibble with columns `gender`, `age`, and `location`.
#' @export
create_asl <- function(n,
                       mf_ratio = c(0.5, 0.5),
                       age_dist = NULL,
                       location_dist = NULL) {
  gender <- sample(1:2, n, TRUE, prob = mf_ratio)
  age <- sample(18:100, n, TRUE, prob = age_dist)
  location <- sample(1:50, n, TRUE, prob = location_dist)
  mytib <- tibble::tibble(gender = gender, age = age, location = location)
  return(mytib)
}
