library(testthat)
library(s3tools)

test_check("s3tools")

# write.csv(iris, "inst/extdata/s3tools_testdata/folder3/subfolder3/iris_subfolder3_1.csv", row.names=FALSE)
# write.csv(iris, "inst/extdata/s3tools_testdata/folder2/iris_folder2_1.csv", row.names=FALSE)
# write.csv(iris, "inst/extdata/s3tools_testdata/folder2/iris_folder2_2.csv", row.names=FALSE)
# write.csv(iris, "inst/extdata/s3tools_testdata/folder1/iris_folder1_1.csv", row.names=FALSE)
# write.csv(iris, "inst/extdata/s3tools_testdata/folder1/subfolder1/iris_subfolder1_3.csv", row.names=FALSE)
# write.csv(iris, "inst/extdata/s3tools_testdata/folder1/subfolder1/iris_subfolder1_2.csv", row.names=FALSE)
# write.csv(iris, "inst/extdata/s3tools_testdata/folder1/subfolder1/iris_subfolder1_1.csv", row.names=FALSE)
# write.csv(iris, "inst/extdata/s3tools_testdata/iris_base.csv", row.names=FALSE)
# openxlsx::write.xlsx(iris, "inst/extdata/s3tools_testdata/iris_base.xlsx")

# names(iris) <- tolower(stringr::str_replace_all(names(iris), c(" " = "_" , "," = "", "\\." = "_" )))
# haven::write_sav(iris, "inst/extdata/s3tools_testdata/iris_base.sav")
# haven::write_dta(iris, "inst/extdata/s3tools_testdata/iris_base.dta")
# haven::write_sas(iris, "inst/extdata/s3tools_testdata/iris_base.sas7bdat")

#  Upload files to s3 that are required for the unit tests 

files <- c("folder3/subfolder3/iris_subfolder3_1.csv",
           "folder2/iris_folder2_1.csv",
           "folder2/iris_folder2_2.csv",
           "folder1/iris_folder1_1.csv",
           "folder1/subfolder1/iris_subfolder1_3.csv",
           "folder1/subfolder1/iris_subfolder1_2.csv",
           "folder1/subfolder1/iris_subfolder1_1.csv",
           "iris_base.csv",
           "iris_base.xlsx",
           "iris_base.sav",
           "iris_base.dta",
           "iris_base.sas7bdat"
           )

for (file in files) {
  path <- system.file("extdata", paste0("s3tools_testdata/",file), package="s3tools")
  s3tools::write_file_to_s3(path, paste0("alpha-everyone/s3tools_tests/",file), overwrite=TRUE)
}

aws.s3::put_folder(folder="s3tools_tests/empty_folder", bucket="alpha-everyone")

