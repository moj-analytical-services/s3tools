context("Read files tests ")


test_that("Test reading a csv", {
  iris_s3 <- s3tools::s3_path_to_full_df('alpha-everyone/s3tools_tests/folder2/iris_folder2_1.csv')
  iris$Species <- as.character(iris$Species)
  test1 <- all.equal(iris, iris_s3)
  expect_true(test1)
  
  iris_s3_head <- s3tools::s3_path_to_preview_df('alpha-everyone/s3tools_tests/folder2/iris_folder2_1.csv')
  iris_s3_head <- head(iris_s3_head)
  
  test2 <- all.equal(head(iris), iris_s3_head)
  expect_true(test2)
  
})

test_that("Test reading using read_using", {
  iris_s3 <- s3tools::read_using(readr::read_csv, 'alpha-everyone/s3tools_tests/folder2/iris_folder2_1.csv')
  test1 <- all.equal(iris$Sepal.Length, iris_s3$Sepal.Length)
  expect_true(test1)
})


test_that("Test downloading file using download_file_from_s3", {
  file_name <- tempfile()
  s3tools::download_file_from_s3("alpha-everyone/s3tools_tests/folder2/iris_folder2_1.csv", file_name, overwrite = TRUE)
  iris_s3 <- read.csv(file_name)
  iris_s3$Species <- as.character(iris_s3$Species)
  iris$Species <- as.character(iris$Species)
  test1<- all.equal(iris, iris_s3)
  expect_true(test1)
  
})


