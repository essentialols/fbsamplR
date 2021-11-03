delete_survey <- function(surveyID, headers){
  survey <- httr::VERB("DELETE",
                       paste0(base_url, "/API/v3/surveys/",surveyID),
                       add_headers(headers))
  return(survey)
}
