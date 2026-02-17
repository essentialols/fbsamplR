#' Delete a Qualtrics Survey Response
#'
#' Deletes a single response from a Qualtrics survey.
#'
#' @param surveyID The Qualtrics survey ID.
#' @param responseID The response ID to delete.
#' @param headers A named list of HTTP headers including the Qualtrics API
#'   token.
#' @param base_url The Qualtrics API base URL
#'   (e.g., `"https://iad1.qualtrics.com/API/v3/surveys/"`).
#'
#' @return Parsed response content from the Qualtrics API.
#' @export
qual_delete_response <- function(surveyID,
                                 responseID,
                                 headers,
                                 base_url = "https://iad1.qualtrics.com/API/v3/surveys/") {
  url <- paste0(base_url, surveyID, "/responses/", responseID)
  res <- httr::DELETE(url, httr::add_headers(.headers = headers))
  return(httr::content(res))
}
