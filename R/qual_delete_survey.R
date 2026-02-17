#' Delete a Qualtrics Survey
#'
#' Permanently deletes a survey from the Qualtrics platform.
#'
#' @param surveyID The Qualtrics survey ID to delete.
#' @param headers A named list of HTTP headers including the Qualtrics API
#'   token.
#' @param base_url The Qualtrics API base URL
#'   (e.g., `"https://iad1.qualtrics.com/"`).
#'
#' @return An `httr` response object.
#' @export
qual_delete_survey <- function(surveyID,
                               headers,
                               base_url = "https://iad1.qualtrics.com/") {
  survey <- httr::DELETE(
    paste0(base_url, "API/v3/surveys/", surveyID),
    httr::add_headers(.headers = headers)
  )
  return(survey)
}
