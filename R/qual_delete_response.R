delete_response <- function(surveyID,
                            responseID,
                            headers){
  url <- paste0(base_url, "/", surveyID, "/responses/", responseID)
  res <- DELETE(url,
                add_headers(headers))
  return(content(res))
}
