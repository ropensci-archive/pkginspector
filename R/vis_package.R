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


vis_package <- function(dir, pkg_name) {
  
  path <- file.path(dir, pkg_name)
  
  # get function dependencies
  mapped <- functionMap::map_r_package(path = path)
  
  # get nodes, eliminate duplicates
  node_df <- mapped$node_df[mapped$node_df$own == TRUE,] %>% 
    dplyr::filter(!duplicated(ID))
  
  # get edges (and eliminated weird non-node stuff)
  edge_df <- mapped$edge_df[mapped$edge_df$to %in% unique(node_df$ID),]
  
  # eliminated duplicate edges since they're not meaningful in this context
  edge_df <- edge_df[!duplicated(edge_df[,c('from','to')]),] 
  
  # create data frame of nodes for visNetwork
  nodes <- data.frame(id = node_df$ID, 
                      exported = node_df$exported) %>% 
    dplyr::mutate(group = ifelse(exported, "exported", "not\nexported"),
           label = id,
           font = "24px arial")
  
  num_nodes <- nrow(nodes)
  
  # create data frame of edges for visNetwork
  edges <- edge_df[c("from", "to")]
  
  # draw network
  visNetwork::visNetwork(nodes, edges, width = "90%", height = "700px",
             main = paste("Function dependencies for", pkg_name)) %>% 
    visNetwork::visLayout(randomSeed = 2018) %>% 
    visNetwork::visGroups(groupname = "exported", shape = "icon", 
              icon = list(code = "f072", color = "#FF7600")) %>%
    visNetwork::visGroups(groupname = "not\nexported", shape = "icon",
              icon = list(code = "f013", color = "#80bedd")) %>%
    visNetwork::visEdges(arrows = "to") %>% 
    visNetwork::visOptions(highlightNearest = list(enabled = TRUE, 
                                       degree = list(from = num_nodes, to = 0),
                                       algorithm = "hierarchical",
                                       hover = TRUE)) %>%
    visNetwork::visPhysics(solver = "barnesHut", 
               barnesHut = list(centralGravity = .75), stabilization = FALSE) %>% 
    visNetwork::visLegend(width = .05, position = "right") %>% 
    visNetwork::addFontAwesome()
}

