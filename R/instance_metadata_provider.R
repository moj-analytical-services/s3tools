instance_metadata_provider <- function (...) {

    role_name <- NULL
    method <- "iam-role"

    log <- get_logger(...)

    fetch_creds <- function (role = NULL, current_time = Sys.time) {

        if (is.null(role)) {
            role <- aws.ec2metadata::metadata$iam_role_names()
        }

        if (!length(role)) {
            return(NULL)
        }

        role_name <<- role[1L]

        metadata <- aws.ec2metadata::metadata$iam_role(role[1L])

        refreshable_credentials(metadata$AccessKeyId,
                                metadata$SecretAccessKey,
                                metadata$Token,
                                metadata$Expiration,
                                refresh = fetch_creds,
                                method = method,
                                current_time = current_time)
    }

    provider <- list()
    provider$method <- method
    provider$load <- function (current_time = Sys.time) {

        creds <- fetch_creds(current_time = current_time)
        if (is.null(creds)) {
            return(NULL)
        }

        log(sprintf("Found credentials from IAM role: %s", role_name))

        return(creds)
    }

    return(provider)
}
