get_empirical_freq <- function(survey, location, gender, age) {
  empirical_dist <- survey %>%
    rename(location = location, gender = gender,  age = age) %>%
    group_by(location, age, gender) %>%
    summarise(n = n()) %>%
    ungroup() %>%
    dplyr::select(location, gender, age, n)
  return(empirical_dist)
}
