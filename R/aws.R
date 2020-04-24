#' Get a vector of the buckets (base folders) which the user has permission to read from 
#'
#' @return character
#' @export
#'
#' @examples accessible_buckets()
accessible_buckets <- function() {
  role_name <- aws.ec2metadata::metadata$iam_role_names()
  policy <- get_role_policy("s3-access", role_name)
  sort(
    Filter(
      function (name) { name != "" },
      unique(
        sapply(
          unlist(policy$document$Statement$Resource),
          bucket_name
        )
      )
    )
  )
}

bucket_name <- function(arn) {
  gsub("^arn:aws:s3:::|/?\\*$", "", arn)
}

get_role_policy <- function(policy_name, role_name) {
  request <- aws_request("GET", "iam", query = list(
    Action = "GetRolePolicy",
    PolicyName = policy_name,
    RoleName = role_name
  ))

  result <- request$execute()

  if (!is.null(result$Error)) {
    return(result)
  }

  result <- result$GetRolePolicyResponse$GetRolePolicyResult

  structure(
    list(
      document = jsonlite::fromJSON(URLdecode(result$PolicyDocument))
    ),
    class = "AWSRolePolicy"
  )
}

aws_request <- function(method,
                        service,
                        query,
                        region = "us-east-1",
                        uri = "/",
                        payload = "",
                        headers = list(),
                        version = "2010-05-08",
                        datetime = NULL,
                        creds = NULL) {

  if (is.null(creds)) {
    creds <- s3tools::get_credentials()
  }

  if (is.null(datetime)) {
    datetime <- format(Sys.time(), "%Y%m%dT%H%M%SZ", tz = "UTC")
  }

  host <- paste0(service, ".amazonaws.com")

  if (!("Version" %in% names(query))) {
    query[["Version"]] <- version
  }

  headers <- append(headers, list(
    host = host,
    `x-amz-date` = datetime
  ))

  request <- build_aws_request(
    method,
    uri,
    query,
    headers,
    payload,
    datetime,
    region,
    service
  )

  signature <- sign_aws_request(creds, request)

  headers[["Authorization"]] <- signature$header
  headers[["x-amz-content-sha256"]] <- request$body_hash
  headers[["x-amz-security-token"]] <- creds$token

  H <- do.call(httr::add_headers, headers)

  request <- structure(
    list(
      method = method,
      host = host,
      uri = uri,
      headers = H,
      query = query,
      body = payload
    ),
    class = "AWSRequest"
  )

  request$execute <- function () {
    method <- getExportedValue("httr", method)
    response <- method(
      paste0("https://", host, uri),
      H,
      query = query,
      body = payload
    )
    jsonlite::fromJSON(httr::content(response, "text", encoding = "UTF-8"))
  }

  request
}

build_aws_request <- function(method, uri, query, headers, payload, datetime, region, service) {
  structure(
    list(
      method = method,
      uri = uri,
      query = query,
      headers = headers,
      body = payload,
      body_hash = hash(payload),
      datetime = datetime,
      region = region,
      service = service
    ),
    class = "AWSRequest"
  )
}

sign_aws_request <- function(creds,
                             req,
                             alg = "AWS4-HMAC-SHA256",
                             expires = 60) {

  date <- substring(req$datetime, 1, 8)

  r <- canonical_request(
    req$method,
    req$uri,
    req$query,
    req$headers,
    req$body_hash)

  s <- string_to_sign(alg, req$datetime, req$region, req$service, r$hash)

  k <- signing_key(creds$secret_key, date, req$region, req$service)

  signature <- digest::hmac(k, s, "sha256")

  credential <- paste(
    creds$access_key,
    date,
    req$region,
    req$service,
    "aws4_request",
    sep = "/"
  )

  structure(
    list(
      header = paste(
        alg,
        paste(
          paste0("Credential=", credential),
          paste0("SignedHeaders=", r$signed_headers),
          paste0("Signature=", signature),
          sep = ", "
        )
      ),
      query_args = list(
        `X-Amz-Algorithm` = alg,
        `X-Amz-Credential` = credential,
        `X-Amz-Date` = date,
        `X-Amz-Expires` = expires,
        `X-Amz-SignedHeaders` = r$signed_headers,
        `X-Amz-Signature` = signature
      )
    ),
    class = "AWSV4Signature"
  )
}

canonical_request <- function(method, uri, query, headers, payload_hash) {
  headers <- normalize_headers(headers)

  request <- list(
    method = method,
    uri = uri,
    canonical_query = canonical_query(query),
    canonical_headers = canonical_headers(headers),
    signed_headers = signed_headers(headers),
    payload_hash = payload_hash
  )

  request[["text"]] <- paste(request, collapse = "\n")
  request[["hash"]] <- hash(request[["text"]])

  structure(request, class="AWSCanonicalRequest")
}

canonical_query <- function(query) {
  query_args <- unlist(query[order(names(query))])
  paste(
    paste0(
      sapply(names(query_args), URLencode, reserved = TRUE),
      "=",
      sapply(as.character(query_args), URLencode, reserved = TRUE)
    ),
    sep = "",
    collapse = "&"
  )
}

normalize_headers <- function(headers) {
  locale <- Sys.getlocale(category = "LC_COLLATE")
  Sys.setlocale(category = "LC_COLLATE", locale = "C")
  on.exit(Sys.setlocale(category = "LC_COLLATE", locale = locale))

  names(headers) <- tolower(names(headers))
  headers[order(names(headers))]
}

canonical_headers <- function(headers) {
  paste0(names(headers), ":", headers, "\n", collapse = "")
}

signed_headers <- function(headers) {
  paste(names(headers), sep = "", collapse = ";")
}

hash <- function(payload) {
  tolower(digest::digest(payload, algo = "sha256", serialize = FALSE))
}

string_to_sign <- function(algo = "AWS4-HMAC-SHA256", datetime, region, service, request_hash) {
  paste(
    algo,
    datetime,
    paste(
      substring(datetime, 1, 8),
      region,
      service,
      "aws4_request",
      sep = "/"
    ),
    request_hash,
    sep = "\n"
  )
}

signing_key <- function(key, date, region, service) {
  kDate <- digest::hmac(paste0("AWS4", key), date, "sha256", raw = TRUE)
  kRegion <- digest::hmac(kDate, region, "sha256", raw = TRUE)
  kService <- digest::hmac(kRegion, service, "sha256", raw = TRUE)
  digest::hmac(kService, "aws4_request", "sha256", raw = TRUE)
}
