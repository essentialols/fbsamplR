#' Split Quota Age Groups into Separate Columns
#'
#' This function takes a quota and the name of the age_group variable and splits the age group into two columns, one for the lower bound of the age group, one for the upper bound.
#' @param quota A dataframe with the following columns: location (character or factor), gender (character or factor), age group (character or factor), and population (numeric)
#' @param age_variable The name of the age_variable from which to extract the lower and upper bounds
#'
#' @return Returns the same dataframe as before but now with columns "lower" and "upper", which contain the bounds of the age variable.
#'
#' @keywords quota cleaning
#' @export
#' @examples
#' split_quota_age(us_quota, age_variable = age)

split_quota_age <- function(quota, age_variable = age){
  age_variable <- enquo(age_variable) # quote with enquo
  new_quota <- quota %>%
    ungroup() %>%
    distinct(!!age_variable) %>% # unquote with !!
    mutate(age_bounds  = strsplit(as.character(!!age_variable), "\\-|\\+")) %>%
    unnest_wider(age_bounds) %>%
    suppressMessages() %>%
    rename(age_group = !!age_variable, "lower" = ...1, "upper"=...2) %>%
    mutate(lower = as.numeric(lower),
           upper = as.numeric(str_replace_na(upper, Inf)))
  return(new_quota)
}
