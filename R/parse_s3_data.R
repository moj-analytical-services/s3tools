separate_bucket_path <- function(path) {
  parts <- strsplit(path, "/")[[1]]
  bucket <- parts[1]
  otherparts <- parts[2:length(parts)]
  object <-  paste(otherparts, collapse="/")
  list("object" = object, "bucket" = bucket )
}

#' Preview the first 5 rows of a file from S3, using the full path to the file including the bucketname
#'
#' @param path a string -  the full path to the file including the bucketname
#'
#' @return a tibble (dataframe)
#' @export
#'
#'
#' @examples df <- s3_read_path_to_df("alpha-moj-analytics-scratch/a/b/c/robins_temp.csv")
s3_path_to_preview_df <- function(path, ...) {
  s3_path_to_df(path, head=TRUE, ...)
}


#' Read a full file from S3, using the full path to the file including the bucketname
#' 
#' This function will attempt to read the file directly, as a dataframe. 
#' If this is not possible it will download the file to a temporary location and load it. 
#' At present the function supports direct reading of CSV, TSC, XLS, and XLSX file types. 
#' You can add options to the read function that are compatible with readxl::read_excel() and read.csv(). 
#' See their help files for more info. 
#' 
#' @param path a string -  the full path to the file including the bucketname
#'
#' @return a tibble (dataframe)
#' @export
#'
#'
#' @examples df <- s3_read_path_to_df("alpha-moj-analytics-scratch/folder/file.csv")
#' @examples df <- s3_read_path_to_df("alpha-moj-analytics-scratch/folder/file.tsv")
#' @examples df <- s3_read_path_to_df("alpha-moj-analytics-scratch/folder/file.xls")
#' @examples df <- s3_read_path_to_df("alpha-moj-analytics-scratch/folder/file.xls", sheet = 1)
#' @examples filelocation <- s3_read_path_to_df("alpha-moj-analytics-scratch/folder/file.png")
s3_path_to_full_df <- function(path, ...) {
  s3_path_to_df(path, head=FALSE, ...)
}

#' Preview the first few records of any dataset that matches a search
#'
#' @param pattern a string -  a regular expression representing the search
#'
#' @return a list of tibbles
#' @export
#'
#' @examples  search_and_preview_dfs('temp\\d')
search_and_preview_dfs <- function(pattern, maxreturns = 10) {
  paths <- find_s3_paths(pattern)
  
  bool <- stringr::str_detect(paths, "\\.tsv$|\\.csv$|\\.txt$")
  
  if (!(all(bool))) {
    failures <- paths[!(bool)]
    failures <- paste(failures, collapse=", ")
    warning(stringr::str_interp("Rejected the following files because they don't look like tabular data: ${paths[!bool]}"))
  }
  paths <- paths[bool]
  
  num_paths <- length(paths)
  if (num_paths > maxreturns) {
    paths <- paths[1:maxreturns]
    warning(stringr::str_interp("Found ${num_paths} paths, previewing only the first ${maxreturns}.  You may use the optional maxreturns argument to increase this number."))
  }
  
  paths %>%
    purrr::set_names(paths) %>%
    purrr::map(s3_path_to_preview_df)
  
}
