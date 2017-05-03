#' Title
#'
#' @return
#' @export
#'
#' @examples
s3.search <- function(search.pattern){
  file.list <- s3.tool::moj.s3.dir()
  #Basic search
  as.data.frame(file.list[stringr::str_detect(file.list$path, search.pattern),])
}


fuzzysearch <- function(input.string, search.pattern){
  split.words <- stringr::str_split(input.string, '\\W')
  dist.calc <- function(x) stringdist::stringsim(search.pattern, x, method='jw')
  return(sum(as.data.frame(lapply(split.words,
       dist.calc))))
}

