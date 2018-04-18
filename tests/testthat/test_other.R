context("Accessible files")


test_that("Test accessible files", {
  df <- s3tools::list_files_in_buckets(c("alpha-everyone", "alpha-fact"), "s3tools_tests/")
  expect_true('alpha-everyone/s3tools_tests/folder1/subfolder1/iris_subfolder1_1.csv' %in% df$path)
  expect_true(all(grepl('s3tools_tests/',df$path)))
  
  paths <- s3tools::list_files_in_buckets(c("alpha-everyone", "alpha-fact"), "s3tools_tests/", path_only = TRUE)
  expect_true('alpha-everyone/s3tools_tests/folder1/subfolder1/iris_subfolder1_1.csv' %in% paths)
  expect_true(all(grepl('s3tools_tests/',paths)))
  
})