qual_import_questions <- function(username,
                                  apiToken = Sys.getenv("QUALTRICS_API_KEY"),
                                  format = XML,
                                  surveyName,
                                  surveyID,
                                  ImportFormat = TXT,
                                  fileLocation){

    url = paste0("https://survey.qualtrics.com//WRAPI/ControlPanel/api.php?Version=2.4&Request=importSurvey",
                "&User=", username,
                "&Token=", Sys.getenv("QUALTRICS_API_KEY"),
                "&Format=", format,
                "&Name=", surveyName,
                # "&SID=", surveyID,
                "&ImportFormat=", ImportFormat)

    url <- URLencode(url)

    res <- POST(url, encode="multipart", body=upload_file(paste(fileLocation)))
    return(url)
}
