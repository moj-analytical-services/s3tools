#' Write an in-memory dataframe to a csv file stored in S3
#'
#' @param df - the dataframe you want to store in s3
#' @param file_path a string -  the full path of where you want to store the file in s3, including any directory names, but excluding the bucket
#' @param bucket a string - the name of the bucket you want to store the file in
#' @param overwrite boolean - overwrite the file if it already exists
#' @return Returns nothing
#' @export
#'
#' @examples write_df_to_csv_in_s3(df, "alpha-everyone/delete/my_csv.csv")
write_df_to_csv_in_s3 <- function(df, s3_path, overwrite=FALSE, ...) {
  # write to an in-memory raw connection
  rc <- rawConnection(raw(0), "r+")
  write.csv(df, rc, ...)

  # upload the object to S3
  credentials <- suppressMessages(get_credentials())
  suppressMessages(refresh(credentials))
  
  p <- separate_bucket_path(s3_path)
  
  if (overwrite || !(s3_file_exists(s3_path))) {
    rcv <- rawConnectionValue(rc)
    close(rc)
    return(aws.s3::put_object(file = rcv,
                       bucket = p$bucket,
                       object = p$object,
                       check_region = TRUE,
                       headers = c('x-amz-server-side-encryption' = 'AES256')))
  } else {
    close(rc)
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
#' @examples local_file_path("myfiles/mydata.csv", "alpha-everyone/delete/my_csv.csv")
write_file_to_s3 <- function(local_file_path, s3_path, overwrite=FALSE) {

  credentials <- suppressMessages(get_credentials())
  suppressMessages(refresh(credentials))
  
  p <- separate_bucket_path(s3_path)
  
  if (overwrite || !(s3_file_exists(s3_path))) {
    
    return(aws.s3::put_object(file = local_file_path,
                       bucket = p$bucket,
                       object = p$object,
                       check_region = TRUE,
                       headers = c('x-amz-server-side-encryption' = 'AES256')))
  } else {
    stop("File already exists and you haven't set overwrite = TRUE, stopping")
  }
  
}


#' Write an in-memory data frame to a csv file stored in S3
#'
#' @description This function is similar to \code{\link{write_df_to_csv_in_s3}} but uses \code{\link[utils]{write.table}} to write the data frame to a csv as opposed to \code{\link[utils]{write.csv}}. This allows the following additional arguments to be passed to \code{\link[utils]{write.table}}: \code{append}, \code{col.names}, \code{sep}, \code{dec}, \code{qmethod}.
#'
#' @param df A data frame you want to upload to S3.
#' @param s3_path A character string containing the full path to where the file should be stored in S3, including any directory names and the bucket name.
#' @param overwrite A logical indicating whether to overwrite the file if it already exists.
#' @param multipart A logical indicating whether to use multipart uploads. See \url{http://docs.aws.amazon.com/AmazonS3/latest/dev/mpuoverview.html}. If \code{df} is less than 100 MB when written to csv, this is ignored.
#' @param sep A string used to separate values within each row of \code{df}.
#' @param ... Additional arguments passed to \code{write.table}.
#' @return Returns nothing
#' @export
#'
#' @examples write_df_to_table_in_s3(df, "alpha-everyone/delete/my_csv.csv")
write_df_to_table_in_s3 <- function(df, s3_path, overwrite=FALSE, multipart=TRUE, sep=",", ...) {
  # write to an in-memory raw connection
  rc <- rawConnection(raw(0), "r+")
  write.table(df, rc, sep=sep, ...)

  # upload the object to S3
  credentials <- suppressMessages(get_credentials())
  suppressMessages(refresh(credentials))
  
  p <- separate_bucket_path(s3_path)
  
  if (overwrite || !(s3_file_exists(s3_path))) {
    rcv <- rawConnectionValue(rc)
    close(rc)
    return(aws.s3::put_object(file = rcv,
                       bucket = p$bucket,
                       object = p$object,
                       check_region = TRUE,
                       multipart = TRUE,
                       headers = c('x-amz-server-side-encryption' = 'AES256')))
  } else {
    close(rc)
    stop("File already exists and you haven't set overwrite = TRUE, stopping")
  }

  # close the connection
  close(rc)

}
