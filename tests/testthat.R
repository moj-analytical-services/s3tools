library(testthat)
library(s3tools)

test_check("s3tools")

#  Upload files to s3 that are required for the unit tests 

files <- c("folder3/subfolder3/iris_subfolder3_1.csv",
           "folder2/iris_folder2_1.csv",
           "folder2/iris_folder2_2.csv",
           "folder1/iris_folder1_1.csv",
           "folder1/subfolder1/iris_subfolder1_3.csv",
           "folder1/subfolder1/iris_subfolder1_2.csv",
           "folder1/subfolder1/iris_subfolder1_1.csv",
           "iris_base.csv")

for (file in files) {
  path <- system.file("extdata", paste0("s3tools_testdata/",file), package="s3tools")
  s3tools::write_file_to_s3(path, paste0("s3tools_tests/",file),"alpha-everyone", overwrite=TRUE)
}

aws.s3::put_folder(folder="s3tools_tests/empty_folder", bucket="alpha-everyone")


