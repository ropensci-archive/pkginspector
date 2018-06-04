# check if a package is installed
check_if_installed <- function(package){
  if(!requireNamespace(package, quietly = TRUE)){
    stop(paste0(package, " is not installed"), call. = FALSE)
  }
} 


#' @noRd

create_package_igraph <- function(path = ".", include_base = FALSE, directed = TRUE,
                                  external = FALSE){
  
  mapped <- functionMap::map_r_package(path = path, include_base = include_base)
  
  node_df <- mapped$node_df[mapped$node_df$own == TRUE,]
  
  edge_df <- mapped$edge_df[mapped$edge_df$to %in% unique(node_df$ID),]
  edge_df <- edge_df[!duplicated(edge_df[,c('from','to')]),] ## include unique edges 
  
  unique_nodes <- node_df[!duplicated(node_df$ID),]

  igraph_obj <- igraph::graph_from_data_frame(edge_df, directed = directed, vertices = unique_nodes)
  
  igraph::set_vertex_attr(igraph_obj, "exported", value = node_df$exported)
  
}

get_string_arguments <- function(funcs, package){
  v <- get(funcs, envir = asNamespace(package))
  
  if(typeof(v) == "closure"){
    return(deparse(v)[1])
  } else{
    return("not a function")
  }
}


