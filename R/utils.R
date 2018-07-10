# check if a package is installed
check_if_installed <- function(package) {
  if (!requireNamespace(package, quietly = TRUE)) {
    stop(paste0(package, " is not installed"), call. = FALSE)
  }
}


#' @noRd

create_package_igraph <- function(path = ".", include_base = FALSE, directed = TRUE, external = FALSE) {
  mapped <- functionMap::map_r_package(path = path, include_base = include_base)

  # remove external functions if external == FALSE
  if (external) {
    node_df <- mapped$node_df
  } else {
    node_df <- mapped$node_df[mapped$node_df$own == TRUE, ]
  }

  # remove duplicate vertices

  node_df <- node_df[!duplicated(node_df$ID), ]

  # remove "_" which often appears as a vertex

  node_df <- node_df[node_df$ID != "_", ]

  # order vertices by ID (useful for selecting nodes)

  node_df <- node_df[order(node_df$ID), ]

  # verify that "to" vertices are in node list
  edge_df <- mapped$edge_df[mapped$edge_df$to %in% node_df$ID, ]

  # verify that "from" vertices are in node list
  edge_df <- edge_df[edge_df$from %in% node_df$ID, ]

  # eliminate duplicate edges
  edge_df <- edge_df[!duplicated(edge_df[, c("from", "to")]), ]

  igraph_obj <- igraph::graph_from_data_frame(edge_df, directed = directed, vertices = node_df)

  igraph::set_vertex_attr(igraph_obj, "exported", value = node_df$exported)
}

get_string_arguments <- function(funcs, package) {
  v <- get(funcs, envir = asNamespace(package))

  if (typeof(v) == "closure") {
    return(deparse(v)[1])
  } else {
    return("not a function")
  }
}
