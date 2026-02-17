#' Create a Qualtrics Survey
#'
#' Creates a new survey on the Qualtrics platform via the API.
#'
#' @param name Name for the new survey.
#' @param headers A named list of HTTP headers including the Qualtrics API
#'   token (e.g., `list("X-API-TOKEN" = "your_token")`).
#' @param base_url The Qualtrics API base URL
#'   (e.g., `"https://iad1.qualtrics.com/"`).
#'
#' @return An `httr` response object.
#' @export
qual_create_survey <- function(name = "My New Survey",
                               headers,
                               base_url = "https://iad1.qualtrics.com/") {
  survey <- httr::POST(
    paste0(base_url, "API/v3/survey-definitions"),
    httr::add_headers(.headers = headers),
    body = list(
      SurveyName = name,
      Language = "EN",
      ProjectCategory = "CORE"
    ),
    encode = "json"
  )
  return(survey)
}
