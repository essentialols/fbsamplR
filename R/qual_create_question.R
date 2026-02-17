#' Import Questions into a Qualtrics Survey
#'
#' Uploads a question file to create a new Qualtrics survey with the
#' specified questions.
#'
#' @param name Name for the survey (currently unused by the API endpoint).
#' @param file Path to a TXT file containing Qualtrics-formatted questions.
#'   See [write_question_file()] for generating this format.
#' @param header A named list of HTTP headers including the Qualtrics API
#'   token.
#'
#' @return An `httr` response object.
#' @export
qual_import_questions <- function(name, file, header) {
  url <- "https://iad1.qualtrics.com/API/v3/surveys"
  res <- httr::POST(
    url,
    httr::add_headers(.headers = header),
    body = httr::upload_file(file, type = "text/csv")
  )
  return(res)
}
