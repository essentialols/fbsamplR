#' Sort Age into Quota Groups
#'
#' This function takes a user-supplied integer (age) and sorts it into the groups of the provided quota. This can be helpful if the quota aggregates the respondents' ages into age groups.
#' @param age A respondent's age of type integer which is to be placed into a user-supplied age group.
#' @param age_brackets A dataframe with the following columns: age_group (character or factor), lower (numeric), and upper (numeric)
#'
#' @return Returns an age bracket. #???? not sure that's what it does
#'
#' @keywords quota cleaning categorization
#' @export
#' @examples
#' sort_age_into_quota_groups(20, quota = us_quota) ### This might be the wrong quota

sort_age_into_quota_groups <- function(age, age_brackets){
  # quota <- distinct(quota, age, .keep_all = T)
  age_in_age_group <- age_brackets[which(age >= age_brackets$lower & age <= age_brackets$upper), 1]
  return(as.character(pull(age_in_age_group, 1))) # age bracket
}
