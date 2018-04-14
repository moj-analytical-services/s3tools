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
#' @examples df <- s3_read_path_to_df("alpha-moj-analytics-scratch/folder/file.csv")
#' @examples df <- s3_read_path_to_df("alpha-moj-analytics-scratch/folder/file.tsv")
#' @examples df <- s3_read_path_to_df("alpha-moj-analytics-scratch/folder/file.xls")
#' @examples df <- s3_read_path_to_df("alpha-moj-analytics-scratch/folder/file.xls", sheet = 1)
#' @examples filelocation <- s3_read_path_to_df("alpha-moj-analytics-scratch/folder/file.png")
s3_path_to_full_df <- function(path, ...) {
  s3_path_to_df(path, head=FALSE, ...)
}