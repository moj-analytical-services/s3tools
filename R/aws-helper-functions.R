#' Finds out what buckets are available to you
#'
#' @param accessible Logial, accessible buckets only? FALSE to see all
#'
#' @return a data frame of buckets you have access to
#' @export
#' @examples s3.buckets()
#'
s3.buckets <- function(accessible=TRUE){
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
    dplyr::filter(access == accessible) %>%
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
#' @examples s3.fetch.files()
#'
s3.fetch.files <- function(){

  b.list<-
    as.character(s3.buckets()$bucket)


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

#' A directory function for s3
#'
#' @param current.path a string with the path of the folder to query
#'
#' @return list of directories
#' @export s3.dir
#' @import dplyr
#' @importFrom magrittr %>%
#'
#' @examples s3.dir('directory')
s3.dir <- function(current.path=''){
  #Get files
  file.list <- s3.fetch.files()

  #if path doesn't end with / then add it
  current.path <- ifelse(stringr::str_sub(current.path, -1)!='/',
                         stringr::str_c(current.path,'/'), current.path)

  current.path <- ifelse(current.path=='/', '', current.path)

  message(current.path)

  #Subset to input folder
  file.list<-
    file.list %>%
    dplyr::filter(stringr::str_detect(path, current.path)) %>%
    dplyr::mutate(path =
                    stringr::str_sub(path,
                                     start = stringr::str_length(current.path)+1))


  #Make file free
  file.tree <-
    stringr::str_split(file.list$path, '/')

  return(file.tree %>% purrr::map(1) %>% unlist() %>% unique())
}


