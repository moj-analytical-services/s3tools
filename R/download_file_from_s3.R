#' Download a file from s3 to somewhere in your home directory
#'
#' @param s3_path character - the full path to the file in s3 e.g. alpha-everyone/iris.csv
#' @param local_path - character - the location you want to store the file locally e..g 
#' @param overwrite - boolean - if file exists locally, overwrite?
#'
#' @return NULL
#' @export 
#'
#' @examples s3tools:::download_file_from_s3("alpha-everyone/iris.csv", "iris.csv", overwrit =TRUE)
download_file_from_s3 <- function(s3_path, local_path, overwrite=FALSE) {
  
  credentials <- suppressMessages(get_credentials())
  suppressMessages(refresh(credentials))
  p <- separate_bucket_path(s3_path)
  
  if (!(file.exists(local_path)) || overwrite) {
    aws.s3:::save_object(object = p$object, bucket = p$bucket, file=local_path, check_region = TRUE)
  } else {
    stop("The file already exists locally and you didn't specify overwrite=TRUE")
  }
  
}