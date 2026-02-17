#' Sort Age into Quota Groups
#'
#' Takes an integer age and matches it to the appropriate age bracket in a
#' quota data frame. Useful when census quotas use age ranges rather than
#' individual ages.
#'
#' @param age A respondent's age (integer).
#' @param age_brackets A data frame with columns `age_group` (character),
#'   `lower` (numeric), and `upper` (numeric). Can be generated using
#'   [split_quota_age()].
#'
#' @return The matching age group label as a character string, or
#'   `NA_character_` if no bracket matches.
#' @export
#'
#' @examples
#' \dontrun{
#' brackets <- split_quota_age(us_quota, age_group)
#' sort_age_into_quota_groups(25, brackets)
#' }
sort_age_into_quota_groups <- function(age, age_brackets) {
  age_in_age_group <- age_brackets[which(age >= age_brackets$lower & age <= age_brackets$upper), 1]
  age_in_age_group <- as.character(dplyr::pull(age_in_age_group, 1))
  age_in_age_group <- ifelse(length(age_in_age_group) == 0, NA_character_, age_in_age_group)
  return(age_in_age_group)
}
