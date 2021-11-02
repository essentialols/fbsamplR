get_rel_freq <- function(quota, location = name, freq_raw = value){
  location <- rlang::enquo(location)
  freq_raw <- rlang::enquo(freq_raw)
  quota_rel_freq <- quota %>%
    group_by(!!location) %>%
    mutate(rel_freq = !!freq_raw/sum(!!freq_raw)) %>%
    ungroup()
  return(quota_rel_freq)
}
