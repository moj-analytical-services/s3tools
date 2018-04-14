#' Write an in-memory dataframe to a csv file stored in S3
#'
#' @param df - the dataframe you want to store in s3
#' @param file_path a string -  the full path of where you want to store the file in s3, including any directory names, but excluding the bucket
#' @param bucket a string - the name of the bucket you want to store the file in
#' @param overwrite boolean - overwrite the file if it already exists
#' @return Returns nothing
#' @export
#'
#' @examples write_df_to_csv_in_s3(df, "my_folder/my_csv.csv", "alpha-moj-analytics-scratch")
write_df_to_csv_in_s3 <- function(df, file_path, bucket, overwrite=FALSE, ...) {
  # write to an in-memory raw connection
  rc <- rawConnection(raw(0), "r+")
  write.csv(df, rc, ...)

  # upload the object to S3
  credentials <- suppressMessages(get_credentials())
  suppressMessages(refresh(credentials))
  
  if (overwrite || !(s3_file_exists(bucket, file_path))) {
      
    return(aws.s3::put_object(file = rawConnectionValue(rc),
                       bucket = bucket,
                       object = file_path,
                       headers = c('x-amz-server-side-encryption' = 'AES256')))
  } else {
    stop("File already exists and you haven't set overwrite = TRUE, stopping")
  }

  # close the connection
  close(rc)

}


#' Write a file to s3
#'
#' @param local_file_path - the file you want to upload to s3
#' @param s3_file_path a string -  the full path of where you want to store the file in s3, including any directory names, but excluding the bucket name
#' @param bucket a string - the name of the bucket you want to store the file in
#' @param overwrite boolean - overwrite the file if it already exists
#' @return Returns nothing
#' @export
#'
#' @examples local_file_path("myfiles/mydata.csv", "my_folder/my_csv.csv", "alpha-moj-analytics-scratch")
write_file_to_s3 <- function(local_file_path, s3_file_path, bucket, overwrite=FALSE) {

  credentials <- suppressMessages(get_credentials())
  suppressMessages(refresh(credentials))
  
  if (overwrite || !(s3_file_exists(bucket, s3_file_path))) {
    
    return(aws.s3::put_object(file = local_file_path,
                       bucket = bucket,
                       object = s3_file_path,
                       headers = c('x-amz-server-side-encryption' = 'AES256')))
  } else {
    stop("File already exists and you haven't set overwrite = TRUE, stopping")
  }
  
}
