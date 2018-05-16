The `s3tools` package allows you to read and write files from the Analytical Platform's data store in Amazon S3. It allows you to find the files you have access to, read them into R, and write files back out to Amazon S3.

Which buckets do I have access to?
----------------------------------

You can find which buckets you have access to using the following code. It will return a character vector of buckets.

``` r
s3tools::accessible_buckets()
```

What files do I have access to?
-------------------------------

``` r
## List all the files in the alpha-everyone bucket
s3tools::list_files_in_buckets('alpha-everyone')

## You can list files in more than one bucket:
s3tools::list_files_in_buckets(c('alpha-everyone', 'alpha-dash'))

## You can filter by prefix, to return only files in a folder
s3tools::list_files_in_buckets('alpha-everyone', prefix='s3tools_tests')

## The 'prefix' argument is used to filter results to any path that begins with the prefix. 
s3tools::list_files_in_buckets('alpha-everyone', prefix='s3tools_tests', path_only = TRUE)

## For more complex filters, you can always filter down the dataframe using standard R code:
library(dplyr)

## All files containing the string 'iris'
s3tools::list_files_in_buckets('alpha-everyone') %>% 
  dplyr::filter(grepl("iris",path)) # Use a regular expression

## All excel files containing 'iris;
s3tools::list_files_in_buckets('alpha-everyone') %>% 
  dplyr::filter(grepl("iris*.xls",path)) 
```

Reading files
-------------

Once you know the full path that you'd like to access, you can read the file as follows.

### `csv` files

For `csv` files, this will use the default `read.csv` csv reader:

``` r
df <-s3tools::s3_path_to_full_df("alpha-everyone/s3tools_tests/folder1/iris_folder1_1.csv")
print(head(df))
```

For large csv files, if you want to preview the first few rows without downloading the whole file, you can do this:

``` r
df <- s3tools::s3_path_to_preview_df("alpha-moj-analytics-scratch/my_folder/10mb_random.csv")
print(df)
```

### Other file types

For xls, xlsx, sav (spss), dta (stata), and sas7bdat (sas) file types, s3tools will attempt to read these files if the relevant reader package is installed:

``` r
df <-s3tools::s3_path_to_full_df("alpha-everyone/s3tools_tests/iris_base.xlsx")  # Uses readxl if installed, otherwise errors

df <-s3tools::s3_path_to_full_df("alpha-everyone/s3tools_tests/iris_base.sav")  # Uses haven if installed, otherwise errors
df <-s3tools::s3_path_to_full_df("alpha-everyone/s3tools_tests/iris_base.dta")  # Uses haven if installed, otherwise errors
df <-s3tools::s3_path_to_full_df("alpha-everyone/s3tools_tests/iris_base.sas7bdat")  # Uses haven if installed, otherwise errors
```

If you have a different file type, or you're having a problem with the automatic readers, you can specify a file read function:

``` r
s3tools::read_using(FUN=readr::read_csv, path = "alpha-everyone/s3tools_tests/iris_base.csv")
```

If you're interested in adding support for additional file types, feel free to add some code to [this file](https://github.com/moj-analytical-services/s3tools/blob/master/R/s3_parse_methods.R) and raise a pull request against the [s3tools repo](https://github.com/moj-analytical-services/s3tools/).

Downloading files
-----------------

``` r
df <- s3tools::download_file_from_s3("alpha-everyone/s3tools_tests/iris_base.csv", "my_downloaded_file.csv")

# By default, if the file already exists you will receive an error.  To override:
df <- s3tools::download_file_from_s3("alpha-everyone/s3tools_tests/iris_base.csv", "my_downloaded_file.csv", overwrite =TRUE)
```

Writing data to s3
------------------

### Writing files to s3

``` r
s3tools::write_file_to_s3("my_downloaded_file.csv", "alpha-everyone/delete/my_downloaded_file.csv")

# By default, if the file already exists you will receive an error.  To override:
s3tools::write_file_to_s3("my_downloaded_file.csv", "alpha-everyone/delete/my_downloaded_file.csv", overwrite =TRUE)
```

### Writing a dataframe to s3 in `csv` format

``` r
s3tools::write_df_to_csv_in_s3(iris, "alpha-everyone/delete/iris.csv")

# By default, if the file already exists you will receive an error.  To override:
s3tools::write_file_to_s3(iris, "alpha-everyone/delete/iris.csv", overwrite =TRUE)
```
