s3tools::get_credentials()

library(odbc)

con <- dbConnect(odbc::odbc(), "Athena")

sql <- 'select * from occupeye_db.sensors limit 10'

dbGetQuery(con, sql)

s3tools::s3_path_to_full_df("alpha-everyone/iris.csv")

buckets <- c("alpha-app-asdprioritisation", "alpha-app-coroner-stat-tool", 
  "alpha-app-feedback-app", "alpha-app-imb-tool", "alpha-app-laa-cwa-dashboard", 
  "alpha-app-pq-tool", "alpha-app-sentencing-policy-model", "blah", "blah-2")




current_path <- "alpha-app-asdprioritisation"

s3_dir2 <- function (current_path=NULL) {
  
  
  bucket <- sub("/.+","","alpha-app-asdprioritisation/Upload/AJAS-prioritisation-010218.xls")
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
s3_dir2("alpha-app-asdprioritisation/Upload")

#Subset to input folder
# file_list<-
#   file_list %>%
#   dplyr::filter(stringr::str_detect(path, current_path)) %>%
#   dplyr::mutate(path =
#                   stringr::str_sub(path,
#                                    start = stringr::str_length(current_path)+1))
# 
# s3_dir2 <- function(current_path=''){
#   #Get files
#   file_list <- accessible_files_df()
#   
#   #if path doesn't end with / then add it
#   current_path <- ifelse(stringr::str_sub(current_path, -1)!='/',
#                          stringr::str_c(current_path,'/'), current_path)
#   
#   current_path <- ifelse(current_path=='/', '', current_path)
#   
#   message(current_path)
#   
#   #Subset to input folder
#   file_list<-
#     file_list %>%
#     dplyr::filter(stringr::str_detect(path, current_path)) %>%
#     dplyr::mutate(path =
#                     stringr::str_sub(path,
#                                      start = stringr::str_length(current_path)+1))
#   
#   
#   #Make file tree
#   file_tree <-
#     stringr::str_split(file_list$path, '/')
#   
#   return(file_tree %>% purrr::map(1) %>% unlist() %>% unique())
# }
# 
# 
# 
# 
# 
# 
# 
# 
# accessible_files_df <- function() {
#   
#   ab <- accessible_buckets()
#   ab <- ab[1:10]
#   af <- do.call(rbind, lapply(ab, aws.s3::get_bucket_df))
#   
#   cols_to_keep <- c("Key", "LastModified","ETag","Size","StorageClass","Bucket")
#   af <- af[, cols_to_keep]
#   
#   af["size_readable"] <- humanReadable(as.double(af$Size))
#   
#   af["path"] = paste(af$Bucket, af$Key, sep = "/")
#   
#   af["filename"] <- sapply(strsplit(af$path, "/"), tail, n=1)
#   
#   names(af) <- tolower(names(af))
#   
#   start_cols <- c("filename", "path", "size_readable")
#   
#   end_cols_filter <- !(names(af) %in% start_cols)
#   end_cols <- names(af)[end_cols_filter]
#   
#   af <- af[,c(start_cols, end_cols)]
#   
#   af
# 
# }
# # 
# # af2 <- accessible_files_df2()
# # af <- accessible_files_df()


s3_dir3 <- function(current_path=''){
  #Get files
  file_list <- accessible_files_df('alpha-app-asdprioritisation')
  
  #if path doesn't end with / then add it
  current_path <- ifelse(stringr::str_sub(current_path, -1)!='/',
                         stringr::str_c(current_path,'/'), current_path)
  
  current_path <- ifelse(current_path=='/', '', current_path)
  
  message(current_path)
  
  
  #Subset to input folder
  file_list<-
    file_list %>%
    dplyr::filter(stringr::str_detect(path, current_path)) %>%
    dplyr::mutate(path =
                    stringr::str_sub(path,
                                     start = stringr::str_length(current_path)+1))
  
 
  #Make file free
  file_tree <-
    stringr::str_split(file_list$path, '/')
  print(file_tree)
  
  #Split it, take the unique root paths
  return(file_tree %>% purrr::map(1) %>% unlist() %>% unique())
}
s3_dir3('alpha-app-asdprioritisation')
