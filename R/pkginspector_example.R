#' Get path to pkginspector example.
#' 
#' This function makes it easy to access the examples included in
#' __pkginspector__.
#'
#' @param path Path to example.
#' 
#' @return A character string giving an example's path.
#' @export
#'
#' @examples
#' path <- pkginspector_example("viridisLite")
#' path
#' dir(path)
pkginspector_example <- function(path) {
  system.file("extdata", path, package = 'pkginspector', mustWork = TRUE)
}
