instance_metadata_provider <- function (...) {

    role_name <- NULL

    log <- get_logger(...)

    fetch_creds <- function (role = NULL) {

        if (is.null(role)) {
            role <- aws.ec2metadata::metadata$iam_role_names()
        }

        if (!length(role)) {
            return(NULL)
        }

        role_name <<- role

        metadata <- aws.ec2metadata::metadata$iam_role(role[1L])

        list(
            "access_key" = metadata$AccessKeyId,
            "secret_key" = metadata$SecretAccessKey,
            "token" = metadata$Token,
            "expiry_time" = metadata$Expiration
        )
    }

    provider <- list()
    provider$method <- "iam-role"
    provider$load <- function (current_time = Sys.time) {

        creds <- fetch_creds()
        if (is.null(creds)) {
            return(NULL)
        }

        log(sprintf("Found credentials from IAM role: %s", role_name ))

        refreshable_credentials(creds$access_key,
                                creds$secret_key,
                                creds$token,
                                creds$expiry_time,
                                refresh = fetch_creds,
                                method = provider$method,
                                current_time = current_time)
    }

    return(provider)
}
