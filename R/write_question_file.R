write_question_file <- function(question, responseOptions, questionType = "Question:MC:Dropdown"){
  question <- paste0("[[", questionType, "]]\n", question, "\n[[Choices]]\n", paste0(responseOptions, collapse = "\n"))
  return(question)
}
