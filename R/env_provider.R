env_provider <- function(...) {

    method <- "env"

    log <- get_logger(...)

    partial_creds <- function(varname) {
        sprintf("Partial credentials found in %s: missing %s", method, varname)
    }

    fetch_creds <- function(require_expiry = TRUE, current_time = Sys.time) {

        vars <- Sys.getenv(c("AWS_ACCESS_KEY_ID",
                             "AWS_SECRET_ACCESS_KEY",
                             "AWS_SESSION_TOKEN",
                             "AWS_CREDENTIAL_EXPIRATION"))

        if (vars[["AWS_ACCESS_KEY_ID"]] == "") {
            stop(partial_creds("AWS_ACCESS_KEY_ID"))
        }

        if (vars[["AWS_SECRET_ACCESS_KEY"]] == "") {
            stop(partial_creds("AWS_SECRET_ACCESS_KEY"))
        }

        if (vars[["AWS_CREDENTIAL_EXPIRATION"]] == "") {

            if (isTRUE(require_expiry)) {
                stop(partial_creds("AWS_CREDENTIAL_EXPIRATION"))
            }

            return(credentials(vars[["AWS_ACCESS_KEY_ID"]],
                               vars[["AWS_SECRET_ACCESS_KEY"]],
                               vars[["AWS_SESSION_TOKEN"]]))
        }

        creds <- refreshable_credentials(vars[["AWS_ACCESS_KEY_ID"]],
                                         vars[["AWS_SECRET_ACCESS_KEY"]],
                                         vars[["AWS_SESSION_TOKEN"]],
                                         vars[["AWS_CREDENTIAL_EXPIRATION"]],
                                         refresh = fetch_creds,
                                         method = method,
                                         current_time = current_time)

        if (creds$refresh_needed()) {
            Sys.unsetenv("AWS_ACCESS_KEY_ID")
            return(get_credentials(current_time = current_time))
        }

        creds
    }

    provider <- list()
    provider$method <- method
    provider$load <- function (current_time = Sys.time) {

        if (!Sys.getenv('AWS_ACCESS_KEY_ID') == "") {
            log("Found credentials in environment variables")

            creds <- try(fetch_creds(require_expiry = FALSE,
                                     current_time = current_time))

            if (inherits(creds, "try-error")) {
                return(NULL)
            }

            return(creds)

        }

        return(NULL)
    }

    return(provider)
}
