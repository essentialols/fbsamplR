create_response <- function(surveyID,
                            headers,
                            startDate = "2021-10-07T00:00:00Z",
                            endDate = "2021-10-07T00:00:00Z",
                            progress = 100,
                            duration = 10,
                            finished = 1,
                            locationLatitude = 0,
                            locationLongitude = 0,
                            distributionChannel = "preview",
                            userLanguage = "EN",
                            gender = 1, # numeric coding of gender; adjust this as needed
                            age = 18,
                            location = 1 # numeric coding of location; adjust this as needed
){

  mybody <- stringr::str_replace_all(paste0('{"values":{
  "startDate": "', startDate, '",
  "endDate": "', endDate, '",
  "progress": ', progress, ',
  "duration": ', duration, ',
  "finished": ', finished, ',
  "locationLatitude": "', locationLatitude, '",
  "locationLongitude": "', locationLongitude, '",
  "distributionChannel": "', distributionChannel, '",
  "userLanguage": "', userLanguage, '",
  "QID1": ', gender, ',
  "QID2_TEXT": ', age, ',
  "QID4": ', location, '}}'), "\n", "")

  res <- httr::POST(
    url = paste0(base_url, surveyID, "/responses"),
    httr::add_headers(headers),
    content_type_json(),
    # Q1 1= male, 2= female
    # Q2 age (integer)
    # Q4 state (1-50 alphabetically)
    body = mybody,
    encode = 'json'
  )
  return(content(res))
}
