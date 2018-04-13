#' Return a dataframe all accessable files, including full path and filesize information
#' Note:  The listing includes folders as well as files - this enables us to derive a recursive dir structure
#'
#' @param bucket_filter return only buckets that match this character vector of bucket names 
#'
#' @return data frame (tbl_df) with path of all files available to you in S3.
#' @export
#' @examples accessible_files_df()
#'
accessible_files_df <- function(bucket_filter=NULL) {
  
  ab <- accessible_buckets()
  
  if (!(is.null(bucket_filter))) {  
    ab <- ab[ab %in% bucket_filter]
  }
  
  no_access <- bucket_filter[!(bucket_filter %in% ab)]
  
  if (length(no_access) > 0) {
    no_access_str <- paste(no_access, collapse = ", ")
    stop(paste("You don't have access to ", no_access_str))
  }
  
  af <- do.call(rbind, lapply(ab, aws.s3::get_bucket_df))
  
  cols_to_keep <- c("Key", "LastModified","ETag","Size","StorageClass","Bucket")
  af <- af[, cols_to_keep]
  
  af["size_readable"] <- humanReadable(as.double(af$Size))
  
  af["path"] = paste(af$Bucket, af$Key, sep = "/")
  
  af["filename"] <- sapply(strsplit(af$path, "/"), tail, n=1)
  
  names(af) <- tolower(names(af))
  
  start_cols <- c("filename", "path", "size_readable")
  
  end_cols_filter <- !(names(af) %in% start_cols)
  end_cols <- names(af)[end_cols_filter]
  
  af <- af[,c(start_cols, end_cols)]
  
  af
  
}

#' A directory function for s3
#' Returns the contents of the given path, including files and directories
#'
#' @param current_path a string with the path of the folder to query
#'
#' @return list of directories
#' @export
#' @importFrom magrittr %>%
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


#' Search all available files, return a vector of paths
#'
#' @return a vector of matching paths
#' @export
#' @examples find_s3_paths('temp\\d')
#'
find_s3_paths <- function(search_pattern){

  all_files <- accessible_files_df()
  
  f1 <- grepl(search_pattern, all_files$path)

  all_files <- all_files[f1,]
  
  all_files$path

}
