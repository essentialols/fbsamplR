sort_age_into_quota_groups <- function(age, quota=quota){
  quota <- distinct(quota, age, .keep_all = T)
  age_in_age_group <- germany_quota[which(age >= quota$lower & age <= quota$upper), 2]
  return(age_in_age_group)
}
