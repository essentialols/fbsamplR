#' View Campaign Ad Sets
#'
#' Retrieves all ad sets associated with a Facebook campaign and returns them
#' as a tibble. Handles pagination automatically.
#'
#' @param campaign_id The Facebook campaign ID.
#' @param access_token Facebook API access token.
#'
#' @return A tibble where rows are ad sets and columns include `adset_id`,
#'   `name`, targeting fields, `configured_status`, and `effective_status`.
#'   If the API request fails, returns the raw `httr` response.
#' @export
#'
#' @examples
#' \dontrun{
#' fb_view_campaign_adsets(campaign_id = "123456789",
#'                         access_token = "your_token")
#' }
fb_view_campaign_adsets <- function(campaign_id,
                                   access_token) {
  url <- paste0(
    "https://graph.facebook.com/v12.0/",
    campaign_id,
    "/adsets?fields=id,name,targeting,configured_status,effective_status",
    "&access_token=", access_token
  )
  response <- httr::GET(url)

  if (length(names(response)) > 1 &&
      response$status_code == 200 &&
      is.data.frame(jsonlite::fromJSON(rawToChar(response$content))[[1]])) {

    apidata <- jsonlite::fromJSON(rawToChar(response$content))[[1]] %>%
      jsonlite::flatten(recursive = TRUE) %>%
      tidyr::unnest_wider(dplyr::everything(), names_sep = ".")

    next_url <- jsonlite::fromJSON(rawToChar(response$content))[[2]]

    data <- list()
    i <- 1
    data[[i]] <- apidata
    i <- i + 1

    while (!is.null(next_url$`next`)) {
      response <- httr::GET(next_url$`next`)
      apidata <- jsonlite::fromJSON(rawToChar(response$content))[[1]] %>%
        jsonlite::flatten(recursive = TRUE) %>%
        tidyr::unnest_wider(dplyr::everything(), names_sep = ".")
      next_url <- jsonlite::fromJSON(rawToChar(response$content))[[2]]
      data[[i]] <- apidata
      i <- i + 1
    }

    result <- dplyr::bind_rows(tibble::tibble(campaign_id = campaign_id), data)
    names(result) <- names(result) %>% stringr::str_remove("\\.\\d")
    result <- tibble::as_tibble(result, .name_repair = make.unique) %>%
      dplyr::rename(adset_id = id)
    return(result)
  } else {
    return(response)
  }
}
