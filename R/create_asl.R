create_asl <- function(n,
                       mf_ratio = c(0.5, 0.5),
                       age_dist = NULL,
                       location_dist = NULL){
  gender <- sample(1:2, n, T, prob = mf_ratio)
  age <- sample(18:100, n, T, prob = age_dist)
  location <- sample(1:50, n, T, prob = location_dist)
  mytib <- tibble(gender = gender, age = age, location = location)
  return(mytib)
}
