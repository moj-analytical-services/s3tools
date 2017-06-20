
#' Write an in-memory dataframe to a csv file stored in S3
#'
#' @param df - the dataframe you want to store in s3
#' @param filename a string -  the full path of where you want to store the file in s3, including any directory names
#' @param bucket a string - the name of the bucket you want to store the file in
#' @return Returns nothing
#' @export
#'
#' @examples write_df_to_csv_in_s3(df, "my_folder/my_csv.csv", "alpha-moj-analytics-scratch")
write_df_to_csv_in_s3 <- function(df, filename, bucket) {
  # write to an in-memory raw connection
  rc <- rawConnection(raw(0), "r+")
  write.csv(df, rc)

  # upload the object to S3
  credentials <- aws.signature::get_credentials()
  credentials$refresh()
  aws.s3::put_object(file = rawConnectionValue(rc),
                     bucket = bucket,
                     object = filename,
                     headers = c('x-amz-server-side-encryption' = 'AES256'))

  # close the connection
  close(rc)

}
