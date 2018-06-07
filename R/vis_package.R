#' Draws a network showing function dependencies within a package
#'
#' @param dir directory where package code resides (this will be changed to a more sensible system)
#'
#' @param pkg_name name of package to be analyzed
#'
#' @author Joyce Robbins \url{https://github.com/jtr13}
#'
#' @export
#'
#' @examples
#' \dontrun{
#' ## Package code must exist locally:
#' vis_package('~/Downloads/skimr')
#' }
#'





vis_package <- function(path = ".", external = FALSE, centralGravity = NULL, recalc = FALSE, overwrite = TRUE) {

  package <- devtools::as.package(path)$package
  
  nodefile <- paste0("data-raw/", package, "nodes")
  
  edgefile <- paste0("data-raw/", package, "edges")
  
  if (file.exists(nodefile) & file.exists(edgefile) &
      (!overwrite)) {
    load(nodefile)
    load(edgefile)
  } else {
    
    # get function dependencies
    mapped <- functionMap::map_r_package(path = path)
    
    nodes <- get_nodes(mapped)
    
    num_nodes <- nrow(nodes)
    
    if (!external) nodes <- nodes %>% 
      dplyr::filter(!external)
    
    edges <- get_edges(mapped) %>% 
      dplyr::filter(from %in% nodes$id) %>% 
      dplyr::filter(to %in% nodes$id)
    
    # save nodes and edges
    
    save(nodes, file = nodefile)
    save(edges, file = edgefile)
    
  }
  
  if(!recalc) {
    if (!is.null(centralGravity)) {
      message("Ignoring centralGravity since recalc=FALSE") }
  } else if (is.null(centralGravity)) {
          centralGravity <- .75
  }
  
  colors <- list("not\nexported" = "#4995d0", # blue
                 "exported" = "#ff7600",      # orange
                 "external" = "#2caa58")      # green
  
  icons <- list("not\nexported" = "f013",  # "cog"
                "exported" = "f072",       # "plane"       
                "external" = "f090")       # "sign-in"
  
  # get icon codes here: https://fontawesome.com/v4.7.0/icons/

  # draw network
  
  if (recalc) {
    # use visNetwork for layout
  
    basic_layout <- 
  visNetwork::visNetwork(nodes, edges, width = "90%", height = "700px",
              main = paste("Function dependencies for", package)) %>% 
      
      visNetwork::visLayout(randomSeed = 2018) %>% 
      
      visNetwork::visPhysics(solver = "barnesHut", 
                             barnesHut = list(centralGravity = centralGravity), stabilization = FALSE)
    
    } else {
                
    # use igraph for layout
    
    g <- igraph::graph_from_data_frame(edges, directed = TRUE, vertices = nodes)
  
    basic_layout <- visNetwork::visIgraph(g)
    }
  
  basic_layout %>% 
    visNetwork::visGroups(groupname = "not\nexported", 
                          shape = "icon",
                          icon = list(code = icons[["not\nexported"]],
                                      color = colors[["not\nexported"]])) %>%
    
    visNetwork::visGroups(groupname = "exported", 
                          shape = "icon",
                          icon = list(code = icons[["exported"]],
                                      color = colors[["exported"]])) %>%
    
    visNetwork::visGroups(groupname = "external", 
                          shape = "icon",
                          icon = list(code = icons[["external"]],
                                      color = colors[["external"]])) %>%

    visNetwork::visEdges(arrows = "to") %>% 
    
    visNetwork::visOptions(highlightNearest = list(enabled = TRUE, 
                                       degree = list(from = num_nodes, to = 0),
                                       algorithm = "hierarchical",
                                       hover = TRUE), nodesIdSelection = TRUE) %>%
    
    visNetwork::visLegend(width = .05, position = "right") %>% 
    
    visNetwork::addFontAwesome()
}
  

get_nodes <- function(mapped) {
  
  # get nodes, eliminate duplicates, eliminate "_"
  
  node_df <- mapped$node_df %>% 
    dplyr::filter(!duplicated(ID)) %>% 
    dplyr::filter(ID != "_") %>% 
    dplyr::arrange(ID)
  
  # create data frame of nodes for visNetwork
  data.frame(id = node_df$ID, 
             exported = node_df$exported,
             external = !node_df$own) %>% 
    dplyr::mutate(group = ifelse(external, "external",
                                 ifelse(exported, "exported", "not\nexported"))) %>% 
    dplyr::mutate(label = id,
                  font = "24px arial")
  
}

get_edges <- function(mapped) {
  
  # get edges and eliminate weird non-node stuff
  edge_df <- mapped$edge_df %>% 
    filter(from != "_")
  
  # eliminate duplicate edges since they're not meaningful in this context
  edge_df <- edge_df[!duplicated(edge_df[,c('from','to')]),] 
  
  # create data frame of edges for visNetwork
  edge_df[c("from", "to")]
  
}