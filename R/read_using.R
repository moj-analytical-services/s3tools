#' Read from S3 using a particular function
#'
#' @param FUN a function to parse the data into
#' @param ... arguments for said function 
#' @param path path to the s3 file bucket/folder/file.txt
#'
#' @return whatever the function returns
#' @export 
#'
#' @examples s3tools:::read_using(FUN=readxl::read_excel, path="alpha-test-team/mpg.xlsx")
read_using <- function(FUN, ..., path){
  tmp <- s3_download_temp_file(path)
  return(FUN(tmp, ...))
}
