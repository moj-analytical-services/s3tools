#' Get AWS credentials
#'
#' Get AWS credentials from the first available source (passed arguments,
#' environment variables, specified file, default file, ec2 metadata iam role)
#'
#' @param key A character string specifying an AWS Access Key ID (optional)
#' @param secret A character string specifying an AWS Secret Access Key (optional)
#' @param token A character string specifying an AWS Session Token (optional)
#' @param ... Additional arguments passed to \code{credentials_resolver}
#' @export
#' @examples
#' \dontrun{
#' # build a credentials object
#' get_credentials(key = "AWS access key id", secret = "AWS secret access key")
#'
#' # fetch credentials from specified credentials file
#' get_credentials(filename = "credentials-file", profile = "default")
#'
#' # fetch credentials from environment variables, or default credentials file,
#' # or IAM role from EC2 metadata, respectively
#' get_credentials()
#'
#' # As above, but skip environment variables and fetch credentials for
#' # specified profile name
#' get_credentials(profile = "default")
#' }
get_credentials <- function(key = NULL, secret = NULL, token = NULL, ...) {
    if (is.null(key) || is.null(secret)) {
        load_credentials <- credentials_resolver(...)
        load_credentials(...)
    } else {
        credentials(key, secret, token)
    }
}


credentials_resolver <- function(profile = NULL, ...) {

    log <- get_logger(...)

    profile_name <- profile
    if (is.null(profile_name)) {
        profile_name <- "default"
    }

    providers <- list(env_provider(...),
                      shared_credential_provider(profile_name, ...),
                      instance_metadata_provider(...))

    if (!is.null(profile)) {
        providers <- providers[-1]

        log("Skipping environment variable credential check because profile name explicitly set")
    }

    function (current_time = Sys.time, ...) {
        creds <- NULL

        for (provider in providers) {
            log(sprintf("Looking for credentials via %s", provider$method))

            creds <- provider$load(current_time = current_time)

            if (!is.null(creds)) {
                break
            }
        }

        set_aws_credentials_env_vars(creds)
        creds
    }
}

get_logger <- function (verbose = FALSE, ...) {

    function (msg) {
        if (isTRUE(verbose)) {
            message(msg)
        }
    }
}
