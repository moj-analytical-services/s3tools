strtail <- function(s,n=1) {
  if(n<0) 
    substring(s,1-n) 
  else 
    substring(s,nchar(s)-n+1)
}


strhead <- function(s,n) {
  if(n<0) 
    substr(s,1,nchar(s)+n) 
  else 
    substr(s,1,n)
}

s3_file_exists <- function(s3_path) {
  p <- separate_bucket_path(s3_path)
  objs <- aws.s3::get_bucket(p$bucket, prefix = p$object, check_region=TRUE)
  return(length(objs)>0)
}

separate_bucket_path <- function(path) {
  
  if (substring(path, 1, 1) == "/") {
    path <- substring(path, 2)
  }
  
  parts <- strsplit(path, "/")[[1]]
  bucket <- parts[1]
  otherparts <- parts[2:length(parts)]
  object <-  paste(otherparts, collapse="/")
  list("object" = object, "bucket" = bucket )
}