#' US Census Quota Data
#'
#' Population counts by state, age group, and sex from the 2019 US Census.
#' Used as a sampling quota for demographically representative surveys.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{state}{US state name}
#'   \item{sex}{Gender (`"male"` or `"female"`)}
#'   \item{age_group}{Age range as a character string (e.g., `"18-24"`)}
#'   \item{population}{Population count}
#' }
#' @source US Census Bureau, 2019 American Community Survey.
"us_quota"

#' Germany Census Quota Data
#'
#' Population counts by age group and sex for Germany. Used as a sampling
#' quota for demographically representative surveys.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{age_group}{Age range as a character string (e.g., `"0-4"`)}
#'   \item{sex}{Gender (`"male"` or `"female"`)}
#'   \item{population}{Population count}
#' }
"germany_quota"
