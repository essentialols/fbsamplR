#' Create a Qualtrics Survey Response
#'
#' Inserts a synthetic or pre-collected response into a Qualtrics survey. This
#' is useful for seeding quota tracking or testing survey logic.
#'
#' @param surveyID The Qualtrics survey ID.
#' @param headers A named list of HTTP headers including the Qualtrics API
#'   token.
#' @param base_url The Qualtrics API base URL
#'   (e.g., `"https://iad1.qualtrics.com/API/v3/surveys/"`).
#' @param startDate Start date in ISO 8601 format.
#' @param endDate End date in ISO 8601 format.
#' @param progress Completion progress (0-100).
#' @param duration Duration in seconds.
#' @param finished Whether the response is finished (1 = yes, 0 = no).
#' @param locationLatitude Latitude of the respondent.
#' @param locationLongitude Longitude of the respondent.
#' @param distributionChannel Distribution channel label.
#' @param userLanguage Language code.
#' @param gender Numeric coding of gender (adjust to match your survey).
#' @param age Respondent age as integer.
#' @param location Numeric coding of location (adjust to match your survey).
#'
#' @return Parsed response content from the Qualtrics API.
#' @export
qual_create_response <- function(surveyID,
                                 headers,
                                 base_url = "https://iad1.qualtrics.com/API/v3/surveys/",
                                 startDate = "2021-10-07T00:00:00Z",
                                 endDate = "2021-10-07T00:00:00Z",
                                 progress = 100,
                                 duration = 10,
                                 finished = 1,
                                 locationLatitude = 0,
                                 locationLongitude = 0,
                                 distributionChannel = "preview",
                                 userLanguage = "EN",
                                 gender = 1,
                                 age = 18,
                                 location = 1) {
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
    httr::add_headers(.headers = headers),
    httr::content_type_json(),
    body = mybody,
    encode = "json"
  )
  return(httr::content(res))
}
