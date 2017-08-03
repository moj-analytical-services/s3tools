

assign_s3_file_class <- function(path){
  file_ext <- tools::file_ext(path)
  attr(path, "class") <- file_ext
  return(path)
}

s3_path_to_df <- function(path, ...){
  path <- assign_s3_file_class(path)
  UseMethod("s3_path_to_df", path)
}

s3_path_to_df.default <- function(path, ...){
  message('s3tools cannot parse this file automatically')
  file_location <- s3_download_temp_file(path, ...)
  message(stringr::str_c('your file is available at: ', file_location))
  rstudioapi::sendToConsole(stringr:::str_interp('\'${file_location}\''), execute = FALSE)
}

' Read a file from S3, using the full path to the file including the bucketname
#'
#' @param path a string -  the full path to the file including the bucketname
#'
#' @return a tibble (dataframe)
#'
#'
#' @examples df <- s3_read_path_to_df("alpha-moj-analytics-scratch/a/b/c/robins_temp.csv")
s3_path_to_df.csv <- function(path, head=TRUE, ...) {
  message('using csv (or similar) method, reading directly to R supported')
  
  p <- separate_bucket_path(path)
  credentials <- suppressMessages(get_credentials())
  if (head) {
    suppressMessages(refresh(credentials))
    ob <- aws.s3::get_object(p$object, p$bucket,  headers = list(Range='bytes=0-12000'))
    df <- read.csv(text = rawToChar(ob))
    df <- head(df)
  } else {
    suppressMessages(refresh(credentials))
    ob <- aws.s3::get_object(p$object, p$bucket)
    df <- read.csv(text = rawToChar(ob))
  }
  
  tibble::as_data_frame(df)
}

s3_path_to_df.tsv <- function(path, ...){
  s3_path_to_df.csv(path, ...)
}


s3_path_to_df.xlsx <- function(path, head, ...){
  message('using readxl package direct read is possible')
  
  if(is.logical(head) && head){
    message('Preview not supported for Excel files')
  }
  
  file_location <- s3_download_temp_file(path)
  
  message(stringr:::str_c('Temp file saved to: ', file_location))
  
  
  df <- readxl::read_excel(file_location, ...) 
  
  tibble::as_data_frame(df)
}

s3_path_to_df.xls <- function(path, ...){
  s3_path_to_df.xlsx(path, ...)
}


s3_download_temp_file <- function(path, ...){
  p <- separate_bucket_path(path)
  credentials <- suppressMessages(s3tools:::get_credentials())
  suppressMessages(refresh(credentials))
  
  file_ext <- paste('.', tools::file_ext(p$object), sep='')
  file_name <- tempfile(fileext = file_ext)
  file_location <- aws.s3:::save_object(object = p$object, bucket = p$bucket, file=file_name)
  return(file_location)
}
