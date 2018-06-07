#' Return a table with package functions call summary
#' 
#' @inheritParams functionMap::map_r_package 
#' @param igraph_obj igraph object for function calls dependencies returned by `create_package_igraph()`
#' 
#' @return a table with package functions call summary
#' @export
#' 
rev_fn_summary <- function(path = ".", igraph_obj = NULL){
  
  fn_igraph_obj <- create_package_igraph(path = path)
  
  ## get functions direct calls/called by count
  rev_calls_res <- rev_calls(path = path, igraph_obj = fn_igraph_obj)
  
  ## get functions recursive calls
  rev_rec_res <- rev_recursive(path = path, igraph_obj = fn_igraph_obj)
  
  package <- devtools::as.package(path)$package

  
  ## merge results
  res <- merge(rev_calls_res, rev_rec_res, all.x = TRUE)
  res[is.na(res)] <- 0  # rows with no dependents

  ##  if packaged is installed, get and merge function arguments
  
  if (requireNamespace(package, quietly = TRUE)) {
    rev_signature_res <- rev_signature(package = package)
    res <- merge(res, rev_signature_res, all.x = TRUE) %>% dplyr::select(f_name, f_args, calls, called_by, dependents)
  } else {
    message(c("Not including function arguments since\n", package, " is not installed."))
  }
  
  res

}

#' Create a dataframe of all functions in a package with the count of functions each one calls and called by
#' 
#' @inheritParams rev_fn_summary
#' 
#' @return A dataframe with the following columns:
#' * f_name: function name 
#' * called_by: number of functions that directly depend on the function 
#' * calls: number of functions directed called by the function 
#' * exported: logical TRUE if the package exports the function
#' @md
#' 
#' @export

rev_calls <- function(path = ".", igraph_obj = NULL){
  
  ## Get the name of the package
  package <- devtools::as.package(path)$package
  
  #check_if_installed(package = package) (not necessary here)
  
  if(is.null(igraph_obj)) igraph_obj <- create_package_igraph(path = path)
  
  ## 'Called by' data
  in_degree <- as.data.frame(igraph::degree(igraph_obj, mode = c("in")))
  in_degree$f_name <- rownames(in_degree)
  
  ## 'Calls' data
  out_degree <- as.data.frame(igraph::degree(igraph_obj, mode = c("out")))
  out_degree$f_name <- rownames(out_degree)
  
  ## Combine into one dataframe
  degree_df <- merge(in_degree, out_degree)
  
  colnames(degree_df) <- c("f_name","called_by", "calls")
  
  ## add exported flag to degree_df
  
  exported_df <- as.data.frame(igraph::vertex_attr(igraph_obj, "name"))
  
  exported_df$exported <- igraph::vertex_attr(igraph_obj, "exported")
  
  colnames(exported_df) <- c("f_name", "exported")

  degree_df <- merge(degree_df, exported_df)
  
  return(degree_df)
}

#' Extracts arguments of all functions in a package into a dataframe
#' 
#' @details 
#' The functions takes the name of an installed package
#' 
#' @inheritParams rev_fn_summary
#' 
#' @return A dataframe with the following columns:
#' * f_name: function name
#' * f_args: function arguements
#' @md
#' 
#' @examples 
#' rev_signature(package = "graphics")
#' 
#' @export
rev_signature <- function(package){
  # check_if_installed(package) check before calling rev_signature
  
  f_name <- unclass(utils::lsf.str(envir = asNamespace(package), all = TRUE))
  f_bare_args <- unlist(lapply(f_name, get_string_arguments, package = package))
  
  f_args <- paste0(f_name, " ", gsub("function ", "", f_bare_args))
  dplyr::data_frame(f_name, f_args)
}





