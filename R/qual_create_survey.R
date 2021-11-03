qual_create_survey <- function(name = "My new Survey", headers){
  survey <- httr::VERB("POST",
                       paste0(base_url, "API/v3/survey-definitions"),
                       add_headers(headers),
                       body = list(SurveyName= "My New Survey",
                                   Language= "EN",
                                   ProjectCategory= "CORE"),
                       encode = "json")
  return(survey)
}
