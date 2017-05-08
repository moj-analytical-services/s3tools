The s3tools package contains a number of helper functions for the analytical platform which allows you to find the files you have access to, read them into R, and write files back out to Amazon S3.

In what follows I assume you've installed and read in the library:

``` r
# You only need to run the following two lines once, if you haven't already installed these packages
install.packages("devtools")
devtools::install_github("moj-analytical-services/s3tools")

# Once installed, this makes the library available for use
library(s3tools)
```

Which buckets do I have access to?
----------------------------------

You can find which buckets you have access to using the following code. It will return a character vector of buckets.

``` r
accessible_buckets()
```

    ## [1] "alpha-moj-analytics-scratch" "alpha-moj-analytics-source"

What files do I have access to?
-------------------------------

You can search for files that match a string (ora regex pattern) as follows:

``` r
find_s3_paths("random")
```

    ## [1] "alpha-moj-analytics-scratch/1g_random.csv"            
    ## [2] "alpha-moj-analytics-scratch/my_folder/10mb_random.csv"

The following function call returns a dataframe containing a list of all the files you have access to. Printed below is only the first two columns and five rows of the returned dataframe.

``` r
accessible_files_df()
```

| path                                                    | size\_readable |
|:--------------------------------------------------------|:---------------|
| alpha-moj-analytics-scratch/1g\_random.csv              | 1.3 GiB        |
| alpha-moj-analytics-scratch/a/b/c/robins\_temp.csv      | 16.0 B         |
| alpha-moj-analytics-scratch/my\_folder/10mb\_random.csv | 19.8 MiB       |
| alpha-moj-analytics-scratch/police-100.csv              | 21.7 KiB       |
| alpha-moj-analytics-scratch/robins\_temp.csv            | 16.0 B         |
| alpha-moj-analytics-scratch/test\_folder/               | 0.0 B          |

What's in the files I have access to?
-------------------------------------

If you know the full path that you'd like to access, you can read the file as follows:

``` r
df <-s3tools::s3_path_to_full_df("alpha-moj-analytics-scratch/my_folder/10mb_random.csv")
print(head(df))
```

    ## # A tibble: 6 × 21
    ##       X dis_0 dis_1 dis_2      con_0  cat_0  cat_1 dis_3     con_1
    ##   <int> <int> <int> <int>      <dbl> <fctr> <fctr> <int>     <dbl>
    ## 1     1    51    37    20 0.76804077      v      c    47 0.8376745
    ## 2     2    53    26    63 0.96385025      B      M    74 0.9578038
    ## 3     3    34    61     1 0.96509432      T      A    83 0.3236155
    ## 4     4    51    73    29 0.64653938      h      N    39 0.8834693
    ## 5     5    60    41    20 0.08806849      E      w    44 0.6785456
    ## 6     6     7    81    27 0.76697529      N      y    76 0.0911312
    ## # ... with 12 more variables: con_2 <dbl>, con_3 <dbl>, con_4 <dbl>,
    ## #   cat_2 <fctr>, cat_3 <fctr>, con_5 <dbl>, dis_4 <int>, con_6 <dbl>,
    ## #   cat_4 <fctr>, con_7 <dbl>, dis_5 <int>, con_8 <dbl>

If the file is very large, and you want to preview it before having to transfer it, you can do this:

``` r
df <- s3tools::s3_path_to_preview_df("alpha-moj-analytics-scratch/my_folder/10mb_random.csv")
print(df)
```

    ## # A tibble: 6 × 21
    ##       X dis_0 dis_1 dis_2      con_0  cat_0  cat_1 dis_3     con_1
    ## * <int> <int> <int> <int>      <dbl> <fctr> <fctr> <int>     <dbl>
    ## 1     1    51    37    20 0.76804077      v      c    47 0.8376745
    ## 2     2    53    26    63 0.96385025      B      M    74 0.9578038
    ## 3     3    34    61     1 0.96509432      T      A    83 0.3236155
    ## 4     4    51    73    29 0.64653938      h      N    39 0.8834693
    ## 5     5    60    41    20 0.08806849      E      w    44 0.6785456
    ## 6     6     7    81    27 0.76697529      N      y    76 0.0911312
    ## # ... with 12 more variables: con_2 <dbl>, con_3 <dbl>, con_4 <dbl>,
    ## #   cat_2 <fctr>, cat_3 <fctr>, con_5 <dbl>, dis_4 <int>, con_6 <dbl>,
    ## #   cat_4 <fctr>, con_7 <dbl>, dis_5 <int>, con_8 <dbl>

You can get a preview of all files matching a search string. This will only download the first few kilobytes of each dataframe, so will work quickly even if the underlying files are large.

``` r
search_and_preview_dfs("random")
```

    ## $`alpha-moj-analytics-scratch/1g_random.csv`
    ## # A tibble: 6 × 21
    ##       X  cat_0  cat_1 dis_0 dis_1     con_0  cat_2     con_1 dis_2  cat_3
    ## * <int> <fctr> <fctr> <int> <int>     <dbl> <fctr>     <dbl> <int> <fctr>
    ## 1     1      n      V    98    85 0.4595474      O 0.2321500    33      E
    ## 2     2      L      C    85    11 0.5462521      S 0.6762920    23      o
    ## 3     3      X      j    21    72 0.7756310      t 0.3904012    14      d
    ## 4     4      m      d    29    95 0.3945539      C 0.9699725    36      y
    ## 5     5      J      a    20    87 0.1046467      d 0.7935016    95      k
    ## 6     6      G      u    49    15 0.9882553      R 0.1146219    24      v
    ## # ... with 11 more variables: cat_4 <fctr>, dis_3 <int>, dis_4 <int>,
    ## #   cat_5 <fctr>, cat_6 <fctr>, dis_5 <int>, con_2 <dbl>, cat_7 <fctr>,
    ## #   con_3 <dbl>, dis_6 <int>, cat_8 <fctr>
    ## 
    ## $`alpha-moj-analytics-scratch/my_folder/10mb_random.csv`
    ## # A tibble: 6 × 21
    ##       X dis_0 dis_1 dis_2      con_0  cat_0  cat_1 dis_3     con_1
    ## * <int> <int> <int> <int>      <dbl> <fctr> <fctr> <int>     <dbl>
    ## 1     1    51    37    20 0.76804077      v      c    47 0.8376745
    ## 2     2    53    26    63 0.96385025      B      M    74 0.9578038
    ## 3     3    34    61     1 0.96509432      T      A    83 0.3236155
    ## 4     4    51    73    29 0.64653938      h      N    39 0.8834693
    ## 5     5    60    41    20 0.08806849      E      w    44 0.6785456
    ## 6     6     7    81    27 0.76697529      N      y    76 0.0911312
    ## # ... with 12 more variables: con_2 <dbl>, con_3 <dbl>, con_4 <dbl>,
    ## #   cat_2 <fctr>, cat_3 <fctr>, con_5 <dbl>, dis_4 <int>, con_6 <dbl>,
    ## #   cat_4 <fctr>, con_7 <dbl>, dis_5 <int>, con_8 <dbl>
