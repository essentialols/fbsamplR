split_quota_age <- function(quota){
  library(magrittr)
  new_quota <- quota %>%
    ungroup() %>%
    distinct(age) %>%
    mutate(age_bounds  = strsplit(age, "\\-|\\+")) %>%
    unnest_wider(age_bounds) %>%
    suppressMessages() %>%
    rename("lower" = ...1, "upper"=...2) %>%
    mutate(lower = as.numeric(lower),
           upper = as.numeric(str_replace_na(upper, Inf)))
  return(new_quota)
}
