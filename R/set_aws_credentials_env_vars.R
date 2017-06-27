#' Set AWS credentials env vars from credentials object
#'
#' @param creds A credentials or refreshable_credentials object
#' @export
set_aws_credentials_env_vars <- function (creds) {

    if (!is.null(creds$access_key)) {
        Sys.setenv("AWS_ACCESS_KEY_ID" = creds$access_key)
    }

    if (!is.null(creds$secret_key)) {
        Sys.setenv("AWS_SECRET_ACCESS_KEY" = creds$secret_key)
    }

    if (!is.null(creds$token)) {
        Sys.setenv("AWS_SESSION_TOKEN" = creds$token)
    }

    if (!is.null(creds$expiry_time)) {
        Sys.setenv("AWS_CREDENTIAL_EXPIRATION" = creds$expiry_time)
    }

}
