#' Write a Qualtrics Question File
#'
#' Formats a question and its response options into Qualtrics TXT import
#' format. The output can be saved to a file and uploaded via
#' [qual_import_questions()].
#'
#' @param question The question text.
#' @param responseOptions A character vector of response choices.
#' @param questionType The Qualtrics question type string. Defaults to
#'   `"Question:MC:Dropdown"`.
#'
#' @return A formatted question string in Qualtrics TXT import format.
#' @export
#'
#' @examples
#' write_question_file(
#'   "What is your gender?",
#'   c("Male", "Female", "Other")
#' )
write_question_file <- function(question,
                                responseOptions,
                                questionType = "Question:MC:Dropdown") {
  question <- paste0(
    "[[", questionType, "]]\n",
    question, "\n",
    "[[Choices]]\n",
    paste0(responseOptions, collapse = "\n")
  )
  return(question)
}
