credentials <- function (access_key, secret_key, token = NULL) {

    creds <- structure(new.env(), class = "credentials")
    creds$access_key <- access_key
    creds$secret_key <- secret_key
    creds$token <- token
    creds
}

refreshable_credentials <- function (access_key,
                                     secret_key,
                                     token,
                                     expiry,
                                     refresh,
                                     current_time = Sys.time,
                                     ...) {

    creds <- credentials(access_key, secret_key, token)

    creds$expiry_time <- expiry

    class(creds) <- "refreshable_credentials"

    creds$refresh_needed <- function () {

        if (is.null(creds$expiry_time)) {
            # No expiration, so assume we don't need to refresh.
            return(FALSE)
        }

        expiry <- as.POSIXct(creds$expiry_time, "%Y-%m-%dT%H:%M:%S", tz="UTC")
        remaining <- as.integer(difftime(expiry, current_time(), units="secs"))

        # refresh if less than 15 minutes until expiry
        remaining < 15 * 60
    }

    creds$refresh <- function () {

        if (creds$refresh_needed()) {
            fresh <- refresh(current_time = current_time)
            creds$access_key <- fresh$access_key
            creds$secret_key <- fresh$secret_key
            creds$token <- fresh$token
            creds$expiry_time <- fresh$expiry_time
            creds$refresh <- fresh$refresh
        }

        set_aws_credentials_env_vars(creds)
        creds
    }

    creds
}


#' Refresh AWS credentials
#'
#' Refresh a set of AWS credentials, if possible
#'
#' @param creds A credentials object
refresh <- function (creds) UseMethod("refresh", creds)

#' Refresh AWS credentials
#'
#' Refresh a set of AWS credentials, if possible
#'
#' @param creds A credentials object
refresh.credentials <- function (creds) {
    warning("These credentials cannot be refreshed")
    creds
}

#' Refresh AWS credentials
#'
#' Refresh a set of AWS credentials, if possible
#'
#' @param creds A credentials object
refresh.refreshable_credentials <- function (creds) {
    creds$refresh()
}

#' Is the object an AWS credentials object?
#'
#' @keywords internal
is.credentials <- function (x) {
    inherits(x, "credentials")
}

#' Is the object a refreshable AWS credentials object?
#'
#' @keywords internal
is.refreshable_credentials <- function (x) {
    inherits(x, "refreshable_credentials")
}
