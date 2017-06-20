separate_bucket_path <- function(path) {
  parts <- strsplit(path, "/")[[1]]
  bucket <- parts[1]
  otherparts <- parts[2:length(parts)]
  object <-  paste(otherparts, collapse="/")
  list("object" = object, "bucket" = bucket )
}

#' Read a file from S3, using the full path to the file including the bucketname
#'
#' @param path a string -  the full path to the file including the bucketname
#'
#' @return a tibble (dataframe)
#'
#'
#' @examples df <- s3_read_path_to_df("alpha-moj-analytics-scratch/a/b/c/robins_temp.csv")
s3_path_to_df <- function(path, head=TRUE) {
  p <- separate_bucket_path(path)
  credentials <- aws.signature::get_credentials()
  if (head) {
    credentials$refresh()
    ob <- aws.s3::get_object(p$object, p$bucket,  headers = list(Range='bytes=0-12000'))
    df <- read.csv(text = rawToChar(ob))
    df <- head(df)
  } else {
    credentials$refresh()
    ob <- aws.s3::get_object(p$object, p$bucket)
    df <- read.csv(text = rawToChar(ob))
  }

  tibble::as_data_frame(df)
}


#' Preview the first 5 rows of a file from S3, using the full path to the file including the bucketname
#'
#' @param path a string -  the full path to the file including the bucketname
#'
#' @return a tibble (dataframe)
#' @export
#'
#'
#' @examples df <- s3_read_path_to_df("alpha-moj-analytics-scratch/a/b/c/robins_temp.csv")
s3_path_to_preview_df <- function(path) {
  s3_path_to_df(path)
}


#' Read a full file from S3, using the full path to the file including the bucketname
#'
#' @param path a string -  the full path to the file including the bucketname
#'
#' @return a tibble (dataframe)
#' @export
#'
#'
#' @examples df <- s3_read_path_to_df("alpha-moj-analytics-scratch/a/b/c/robins_temp.csv")
s3_path_to_full_df <- function(path) {
  s3_path_to_df(path, head=FALSE)
}

#' Preview the first few records of any dataset that matches a search
#'
#' @param pattern a string -  a regular expression representing the search
#'
#' @return a list of tibbles
#' @export
#'
#' @examples  search_and_preview_dfs('temp\\d')
search_and_preview_dfs <- function(pattern, maxreturns = 10) {
  paths <- find_s3_paths(pattern)

  bool <- stringr::str_detect(paths, "\\.tsv$|\\.csv$|\\.txt$")

  if (!(all(bool))) {
    failures <- paths[!(bool)]
    failures <- paste(failures, collapse=", ")
    warning(stringr::str_interp("Rejected the following files because they don't look like tabular data: ${paths[!bool]}"))
  }
  paths <- paths[bool]

  num_paths <- length(paths)
  if (num_paths > maxreturns) {
    paths <- paths[1:maxreturns]
    warning(stringr::str_interp("Found ${num_paths} paths, previewing only the first ${maxreturns}.  You may use the optional maxreturns argument to increase this number."))
  }

  paths %>%
    purrr::set_names(paths) %>%
    purrr::map(s3_path_to_preview_df)


}
