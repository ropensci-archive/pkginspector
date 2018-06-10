#' Draws a network showing function dependencies within a package
#'
#' @param path  where package code resides (this will be changed to download package to a temporary directory)
#' 
#' @param centralGravity  controls how tightly nodes are pulled into the center of the network; higher numbers are more tight (default = .3)
#' 
#' @param external logical, if TRUE will include calls to functions external to the package (default = FALSE)
#' 
#' @param physics logical, if TRUE will recalculate network if a node is moved (default = FALSE)
#' 
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

vis_package <- function(path = ".", centralGravity = NULL, external = FALSE, physics = FALSE) {

  package <- devtools::as.package(path)$package
  

  igraph_obj <- create_package_igraph(path = path, external = TRUE)
  
  if(!external) igraph_obj <- igraph::induced.subgraph(igraph_obj, 
      which(igraph::V(igraph_obj)$own == TRUE))
  
  igraph::vertex_attr(igraph_obj, "group") <- ifelse(!igraph::V(igraph_obj)$own, "external", ifelse(igraph::V(igraph_obj)$exported, "exported", "not\nexported"))
  
  igraph::vertex_attr(igraph_obj, "font") <- "24px arial"
    
  num_nodes <- length(igraph_obj)
  
  if(!physics) {
    if (!is.null(centralGravity)) {
      message("Ignoring centralGravity since physics=FALSE") }
  } else if (is.null(centralGravity)) {
          centralGravity <- .3
  }
  
  colors <- list("not\nexported" = "#4995d0", # blue
                 "exported" = "#ff7600",      # orange
                 "external" = "#2caa58")      # green
  
  icons <- list("not\nexported" = "f013",  # "cog"
                "exported" = "f072",       # "plane"       
                "external" = "f090")       # "sign-in"
  
  # get icon codes here: https://fontawesome.com/v4.7.0/icons/

  # draw network
  
  visNetwork::visIgraph(igraph_obj, physics = physics) %>% 
    
    visNetwork::visPhysics(solver = "barnesHut", 
                           barnesHut = list(centralGravity = centralGravity), 
                           stabilization = FALSE) %>% 
    
    visNetwork::visLayout(randomSeed = 2018) %>% 
    
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
  

