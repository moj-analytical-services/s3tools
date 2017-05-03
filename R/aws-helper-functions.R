#' Finds out what buckets are available to you
#'
#' @return a data frame of buckets you have access to
#' @export
#' @examples moj.s3.buckets()
#'
moj.s3.buckets <- function(){
  buckets <- function (b) {
    b.list <- aws.s3::bucketlist()
    b.list <- b.list$Bucket
    return(b.list)
  }

  check.access <-
    function(bucket_name){
      suppressMessages(aws.s3::bucket_exists(bucket_name)) %>%
        as.logical() -> access
      return(list(bucket = bucket_name, access= access))
    }

  bucket.list <- lapply(buckets(), check.access)

  data.frame(
    bucket = bucket.list %>% purrr::map_chr('bucket'),
    access = bucket.list %>% purrr::map_lgl('access'),
    stringsAsFactors = FALSE
  ) %>%
    dplyr::filter(access == TRUE) %>%
    dplyr::select(bucket) -> accessable.buckets

  return(accessable.buckets)
}





#' Return path of all accessable files
#'
#' @return data frame (tbl_df) with path of all files available to you in S3.
#' @export
#'
#' @import dplyr
#'
#'
#' @examples moj.s3.dir()
#'
moj.s3.dir <- function(){

  b.list<-
    as.character(moj.s3.buckets()$bucket)


  aws.s3.dir<-
    function(b){
      #Could this be silenced?
      x <- purrr::safely(aws.s3::get_bucket, quiet = TRUE)(b, parse_response=TRUE)
      return(x$result)
    }

  b.dir<-
    invisible(lapply(b.list,
                     invisible(aws.s3.dir)))

  b.dir %>%
    purrr::flatten(.) -> b.dir

  b.dir %>%
    purrr::map_chr("Key") %>%
    unname(.)-> keys

  b.dir %>%
    purrr::map_chr("Bucket") %>%
    unname(.)-> buckets

  b.dir %>%
    purrr::map_chr("Size") %>%
    unname(.)-> size

  return(
    tbl_df(
      data.frame(
        path = stringr::str_c(buckets, '/', keys), size = size, bucket = buckets,
        stringsAsFactors = FALSE)
    )
  )
}



