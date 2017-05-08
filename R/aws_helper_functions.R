#' Finds out what buckets are available to you
#'
#' @param accessible Logial, accessible buckets only? FALSE to see all
#'
#' @return a character vector of buckets you have access to
#' @export
#' @examples s3.buckets()
#'
accessible_buckets <- function(accessible=TRUE){

  check_access <- function(bucket_name){
      suppressMessages(aws.s3::bucket_exists(bucket_name))[1]
  }

  bucket_list <- aws.s3::bucketlist()
  bucket_list <- bucket_list$Bucket
  access <- purrr::map_lgl(bucket_list, check_access)

  if (accessible) {
    return(bucket_list[access])
  } else {
    return(bucket_list)
  }
}


#' Return a dataframe all accessable files, including full path and filesize information
#'
#' @return data frame (tbl_df) with path of all files available to you in S3.
#' @export
#' @examples accessible_files_df()
#'
accessible_files_df <- function(){

  get_filename_nodir <- function(paths) {
    strsplit(paths, "/") %>%
      purrr::map_chr(tail, n=1)
  }

  bucket_contents_to_data_frame <- function (bucket_contents) {
    df <- bucket_contents %>%
      purrr::map(unclass) %>%
      purrr::map(dplyr::as_data_frame) %>%
      dplyr::bind_rows() %>%
      dplyr::mutate(path = paste(Bucket, Key, sep = "/")) %>%
      dplyr::mutate(size_readable = gdata::humanReadable(Size)) %>%
      dplyr::mutate(filename = get_filename_nodir(path)) %>%
      dplyr::select(filename, path, size_readable, dplyr::everything())

    names(df) <- tolower(names(df))
    df
  }

  accessible_buckets() %>%
    purrr::map(aws.s3::get_bucket) %>%
    purrr::keep(function(x) {length(x) > 0}) %>%
    purrr::map(bucket_contents_to_data_frame) %>%
    dplyr::bind_rows()
}

#' A directory function for s3
#'
#' @param current_path a string with the path of the folder to query
#'
#' @return list of directories
#' @export
#' @importFrom magrittr %>%
#'
#' @examples s3.dir('directory')
s3_dir <- function(current_path=''){
  #Get files
  file_list <- accessible_files_df()

  #if path doesn't end with / then add it
  current_path <- ifelse(stringr::str_sub(current_path, -1)!='/',
                         stringr::str_c(current_path,'/'), current_path)

  current_path <- ifelse(current_path=='/', '', current_path)

  message(current_path)

  #Subset to input folder
  file_list<-
    file_list %>%
    dplyr::filter(stringr::str_detect(path, current_path)) %>%
    dplyr::mutate(path =
                    stringr::str_sub(path,
                                     start = stringr::str_length(current_path)+1))


  #Make file free
  file_tree <-
    stringr::str_split(file_list$path, '/')

  return(file_tree %>% purrr::map(1) %>% unlist() %>% unique())
}


#' Search all available files, return a vector of paths
#'
#' @return a vector of matching paths
#' @export
#' @examples find_s3_paths('temp\\d')
#'
find_s3_paths <- function(search_pattern){

  all_files <- accessible_files_df()

  all_files %>%
    dplyr::filter(stringr::str_detect(path, search_pattern)) %>%
    .$path

}
