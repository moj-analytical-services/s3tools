context("AWS v4 request signing")


test_that("canonical query string is correctly formatted", {
  query <- list()
  query[["foo"]] <- 1
  query[["bar"]] <- 2

  expected <- "bar=2&foo=1"

  expect_identical(canonical_query(query), expected)
})

test_that("canonical headers string is correctly formatted", {
  headers <- list()
  headers[["Foo"]] <- 1
  headers[["Bar"]] <- 2

  expected <- "bar:2\nfoo:1\n"

  expect_identical(canonical_headers(normalize_headers(headers)), expected)
})

test_that("signed headers string is correctly formatted", {
  headers <- list()
  headers[["Foo"]] <- 1
  headers[["Bar"]] <- 2

  expected <- "bar;foo"

  expect_identical(signed_headers(normalize_headers(headers)), expected)
})

test_that("payload hash is correctly calculated", {
  payload <- ""

  expected <- "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

  expect_identical(hash(payload), expected)
})

test_that("canonical request is correctly formatted", {
  request <- canonical_request(
    method = "GET",
    uri = "/",
    query = list(
      Action = "ListUsers",
      Version = "2010-05-08"
    ),
    headers = list(
      `content-type` = "application/x-www-form-urlencoded; charset=utf-8",
      host = "iam.amazonaws.com",
      `x-amz-date` = "20150830T123600Z"
    ),
    payload = hash("")
  )

  expected <- "GET
/
Action=ListUsers&Version=2010-05-08
content-type:application/x-www-form-urlencoded; charset=utf-8
host:iam.amazonaws.com
x-amz-date:20150830T123600Z

content-type;host;x-amz-date
e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

  expect_identical(request$text, expected)
})

test_that("string to sign is correctly formatted", {
  s <- string_to_sign(
    datetime = "20150830T123600Z",
    region = "us-east-1",
    service = "iam",
    request_hash = "f536975d06c0309214f805bb90ccff089219ecd68b2577efef23edd43b7e1a59")

  expected <- "AWS4-HMAC-SHA256
20150830T123600Z
20150830/us-east-1/iam/aws4_request
f536975d06c0309214f805bb90ccff089219ecd68b2577efef23edd43b7e1a59"

  expect_identical(s, expected)
})

test_that("signing key is correctly calculated", {
  key <- paste0(signing_key(
    key = "wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY",
    date = "20150830",
    region = "us-east-1",
    service = "iam"), collapse = "")

  expected <- "c4afb1cc5771d871763a393e44b703571b55cc28424d1a5e86da6ed3c154a4b9"

  expect_identical(key, expected)
})

test_that("signature is correctly calculated", {
  creds <- structure(list(
    access_key = "AKIDEXAMPLE",
    secret_key = "wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY"
  ), class = "AWSCredentials")
  request <- build_aws_request(
    method = "GET",
    uri = "/",
    query = list(
      Action = "ListUsers",
      Version = "2010-05-08"
    ),
    headers = list(
      Host = "iam.amazonaws.com",
      `Content-Type` = "application/x-www-form-urlencoded; charset=utf-8",
      `X-Amz-Date` = "20150830T123600Z"
    ),
    payload = "",
    datetime = "20150830T123600Z",
    region = "us-east-1",
    service = "iam")

  signature <- sign_aws_request(creds, request)

  expected <- "5d672d79c15b13162d9279b0855cfba6789a8edb4c82c400e06b5924a6f2b5d7"

  expect_identical(signature$query_args[["X-Amz-Signature"]], expected)
})

test_that("signing information is added to request", {
  creds <- structure(list(
    access_key = "AKIDEXAMPLE",
    secret_key = "wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY"
  ), class="AWSCredentials")

  request <- aws_request(
    "GET",
    "iam",
    list(
      Action = "ListUsers"
    ),
    headers = list(
      `content-type` = "application/x-www-form-urlencoded; charset=utf-8"
    ),
    datetime = "20150830T123600Z",
    creds = creds
  )

  expected <- "AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE/20150830/us-east-1/iam/aws4_request, SignedHeaders=content-type;host;x-amz-date, Signature=5d672d79c15b13162d9279b0855cfba6789a8edb4c82c400e06b5924a6f2b5d7"

  expect_identical(request$headers$headers[['Authorization']], expected)
})
