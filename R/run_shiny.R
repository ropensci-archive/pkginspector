#' Run the pkginspector app
#'
#' Run the pkginspector app
#' @export
#' @param browse Logical. Use browser for running Shiny app.
#' @examples
#' \dontrun{
#' if(require(shiny)){
#'    shiny_inspect()
#' }
#' }
# modeled on https://github.com/ropenscilabs/roomba/blob/master/R/run_shiny.R
shiny_inspect <- function(browse=TRUE){
  shiny::runApp(system.file('shiny_pkginspector', package='pkginspector'), launch.browser = browse)
}