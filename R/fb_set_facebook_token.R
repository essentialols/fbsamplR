#' Set Facebook API Credentials
#'
#' Stores a Facebook API access token in the `FACEBOOK_TOKEN` environment
#' variable for use by other `fb_*` functions.
#'
#' @param api_token A Facebook Marketing API access token. If not supplied,
#'   reads from the `FACEBOOK_TOKEN` environment variable.
#'
#' @return Invisibly returns the token string.
#' @export
fb_set_facebook_token <- function(api_token = Sys.getenv("FACEBOOK_TOKEN")) {
  if (nchar(api_token) == 0) {
    stop("Facebook API token is empty or undefined. ",
         "Supply it directly or set the FACEBOOK_TOKEN environment variable.",
         call. = FALSE)
  }
  Sys.setenv(FACEBOOK_TOKEN = api_token)
  invisible(api_token)
}
