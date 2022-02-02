# Set Facebook credentials

fb_set_facebook_opts <- function(api_token = Sys.getenv("FACEBOOK_TOKEN")){
    if (nchar(api_token) == 0)
      stop(crayon::red("token variable is undefined"), call. = FALSE)
  Sys.setenv(FACEBOOK_TOKEN = api_token)
  }
