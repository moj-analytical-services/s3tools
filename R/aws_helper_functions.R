#' Return a dataframe of accessable files, including full path and filesize information
#' Note:  The listing includes folders as well as files
#'
#' @param bucket_filter return only buckets that match this character vector of bucket names e.g. "alpha-everyone"
#' @param prefix filter files which begin with this prefix e.g. 'my_folder/'
#' @param path_only boolean - return the accessible paths only, as a character vector
#' @param max An integer indicating the maximum number of keys to return. The function will recursively access the bucket in case max > 1000. Use max = Inf to retrieve all objects.
#'
#' @export
#' @return data frame with path of all files available to you in S3.
#' @examples list_files_in_buckets(bucket_filter = "alpha-everyone", prefix = "GeographicData", path_only = FALSE, max = Inf)
#'
list_files_in_buckets <- function(bucket_filter=NULL, prefix=NULL, path_only=FALSE, max=NULL) {
  
  s3tools::get_credentials()
  
  if (is.null(bucket_filter)) {
    stop("You must provide one or more buckets e.g. accessible_files_df('alpha-everyone')  This function will list their contents")
  }
  
  has_access <- function(bucket_name) {
    result <- tryCatch(aws.s3::get_bucket_df(bucket_name, 'longprefix', check_region=TRUE), error = function(c) {"Cannot list bucket"})
    if (typeof(result) == 'character') {
      return (FALSE)
    } else 
      return (TRUE)
  }
  
  bucket_access_bool <- sapply(bucket_filter, has_access)
  
  if (!(all(bucket_access_bool))) {
    no_access_str <- paste(bucket_filter[!(bucket_access_bool)], collapse = ", ")
    stop(paste("You asked to list some buckets you don't have access to: ", no_access_str))
  }
  
  af <- do.call(rbind, lapply(bucket_filter, aws.s3::get_bucket_df, prefix=prefix, check_region=TRUE, max = max))
  
  if (nrow(af)==0) {
    return(NULL)

  }
  
  cols_to_keep <- c("Key", "LastModified","ETag","Size","StorageClass","Bucket")
  af <- af[, cols_to_keep]
  
  af["size_readable"] <- gdata::humanReadable(as.double(af$Size))
  
  af["path"] = paste(af$Bucket, af$Key, sep = "/")
  
  af["filename"] <- sapply(strsplit(af$path, "/"), tail, n=1)
  
  names(af) <- tolower(names(af))
  
  start_cols <- c("filename", "path", "size_readable")
  
  end_cols_filter <- !(names(af) %in% start_cols)
  end_cols <- names(af)[end_cols_filter]
  
  af <- af[,c(start_cols, end_cols)]
  
  if (path_only) {
    return(af$path)
  } else {
    return(af)
  }
  
}

#' A directory function for s3
#' Returns the contents of the given path, including files and directories
#'
#' @param current_path a string with the path of the folder to query
#'
#' @return list of directories
#'
#' @examples s3_dir('directory')
s3_dir <- function (current_path=NULL) {
  
  bucket <- sub("/.+","",current_path)
  
  file_list <- accessible_files_df(bucket)
  
  if (strtail(current_path,1) != "/") {
    current_path <- paste0(current_path, "/")
  }
  
  message(current_path)
  
  # Get only the files in the current folder (and not subfolders of this folder)
  #  i.e. entries which start with the current_path 
  f1 <- grepl(paste0("^", current_path), file_list$path)
  file_list <- file_list[f1,]
  
  # Get paths relative to current path
  file_list['relative_path'] <- gsub(current_path, "", file_list$path)
  
  # Remove items within directories within current path
  f1 <- grepl("/.{1,}", file_list$relative_path)
  file_list <- file_list[!f1,]
  
  file_list$relative_path
  
}
