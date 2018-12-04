shared_credential_provider <- function (profile_name, filename = NULL, ...) {

    log <- get_logger(...)

    provider <- list()
    provider$method <- "shared-credentials-file"
    provider$load <- function (...) {

        if (is.null(filename)) {
            filename <- default_credentials_file()
        }

        creds <- try(aws.signature::read_credentials(filename)[[profile_name]], silent = TRUE)

        if (inherits(creds, "try-error")) {
            return(NULL)
        }

        log(sprintf("Found credentials stored in shared credentials file: %s", filename))
        credentials(creds[['AWS_ACCESS_KEY_ID']],
                    creds[['AWS_SECRET_ACCESS_KEY']],
                    creds[['AWS_SESSION_TOKEN']])
    }

    return(provider)
}

default_credentials_file <- function() {
    if (.Platform[["OS.type"]] == "windows") {
        home <- Sys.getenv("USERPROFILE")
    } else {
        home <- "~"
    }
    suppressWarnings(normalizePath(file.path(home, '.aws', 'credentials')))
}