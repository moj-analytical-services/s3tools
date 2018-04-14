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

s3_file_exists <- function(bucket, file_path) {
  objs <- aws.s3::get_bucket(bucket, prefix = file_path)
  return(length(objs)>0)
}
