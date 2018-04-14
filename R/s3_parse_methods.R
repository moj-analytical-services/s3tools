assign_s3_file_class <- function(path){
  file_ext <- tools::file_ext(path)
  attr(path, "class") <- file_ext
  return(path)
}


#' Read data from s3 with automatic processing 
#' 
#' Currently supports csv, tsv, xls, and xlsx files. 
#'
#' @param path path to the s3 file bucket/folder/file.csv 
#' @param ...  arguemtns passed to read.csv or read_excel. 
#'
#' @return dataframe
#'
#' @examples s3tools::s3_path_to_full_df("alpha-test-team/mpg.csv")
#' @examples s3tools::s3_path_to_preview_df("alpha-test-team/mpg.csv")
s3_path_to_df <- function(path, ...){
  path <- assign_s3_file_class(path)
  UseMethod("s3_path_to_df", path)
}

s3_path_to_df.default <- function(path, ...){
  message('s3tools cannot parse this file automatically')
  message('If you want to specify your own reading function see s3tools::read_using()')
  message('or use the file path provided by this function')
  file_location <- s3_download_temp_file(path, ...)
  message(stringr::str_c('your file is available at: ', file_location))
  rstudioapi::sendToConsole(stringr:::str_interp('\'${file_location}\''), execute = FALSE)
  file_location
}

s3_path_to_df.csv <- function(path, ..., head) {
  message('using csv (or similar) method, reading directly to R supported')
  
  p <- separate_bucket_path(path)
  credentials <- suppressMessages(get_credentials())
  if (head) {
    suppressMessages(refresh(credentials))
    ob <- aws.s3::get_object(p$object, p$bucket,  headers = list(Range='bytes=0-12000'))
    df <- read.csv(text = rawToChar(ob), stringsAsFactors = FALSE)
    df <- head(df)
  } else {
    suppressMessages(refresh(credentials))
    ob <- aws.s3::get_object(p$object, p$bucket)
    df <- read.csv(text = rawToChar(ob), stringsAsFactors = FALSE)
  }
  
}

s3_path_to_df.tsv <- function(path, ...){
  s3_path_to_df.csv(path, ..., head)
}


s3_path_to_df.xlsx <- function(path, ..., head){
  
  if(is.logical(head) && head){
    message('Preview not supported for Excel files')
  }
  file_location <- s3_download_temp_file(path)
  message(stringr:::str_c('Temp file saved to: ', file_location))
  
  df <- tryCatch({
          readxl::read_excel(path=file_location, ...)
          },
          error= function(cond){
             message("Attempted to read file using the readxl package, but it is not installed.  ")
             message("You can install this package by running install.packages('readxl')")
             
             stop("Cannot read file, stopping", call.=FALSE)
             })
  
  df
  
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
