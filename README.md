# s3.tools
Tools for working with S3 buckets. 

### Usage
```r


library(s3tools)

paths <- find_s3_path("your_filename_search_string")
df <- s3_read_path_to_df(paths[[1]])


s3_dir('bucket/directory')

```
