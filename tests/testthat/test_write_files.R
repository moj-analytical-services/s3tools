context("Write files tests ")

test_that("Test writing a csv", {
  temp_iris_path <- 'alpha-everyone/s3tools_tests/folder_temp/iris.csv'
  s3tools::write_df_to_csv_in_s3(iris, temp_iris_path, overwrite = TRUE, row.names=FALSE)
  iris_s3 <- s3tools::s3_path_to_full_df(temp_iris_path)
  
  iris$Species <- as.character(iris$Species)
  test1 <- all.equal(iris, iris_s3)
  expect_true(test1)
  p <- separate_bucket_path(temp_iris_path)
  aws.s3::delete_object(p$object, p$bucket)
  
})

test_that("Test writing a csv to disk and uploading", {
  temp_iris_path <- 'alpha-everyone/s3tools_tests/folder_temp/iris.csv'
  file_name <- tempfile()
  write.csv(iris, file_name, row.names=FALSE)
  
  s3tools::write_file_to_s3(file_name, temp_iris_path, overwrite = TRUE)
  
  iris_s3 <- s3tools::s3_path_to_full_df(temp_iris_path)
  
  iris$Species <- as.character(iris$Species)
  test1 <- all.equal(iris, iris_s3)
  expect_true(test1)
  p <- separate_bucket_path(temp_iris_path)
  aws.s3::delete_object(p$object, p$bucket)
  
})