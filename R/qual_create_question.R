qual_import_questions <- function(name, file, header){

    url <- "https://iad1.qualtrics.com/API/v3/surveys"
    # files <- '{
    #   "file": ("~/Downloads/testquestions.txt")
    # }'

    # data = '{ "name": "Test" }'

   res <- httr::POST(url,
         add_headers(header),
         body=upload_file(file, type = "text/csv"),
         )

    # res <- POST(url, encode="multipart", body=upload_file(paste(fileLocation)))
    return(res)
}
