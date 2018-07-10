#' Pipe operator
#'
#' See \code{magrittr::\link[magrittr]{\%>\%}} for details.
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
#' @importFrom magrittr %>%
#' @usage lhs \%>\% rhs
NULL

# Silent CMD check note: "FUN: no visible binding for global variable VAR"
#' @importFrom rlang .data
#' @importFrom rmarkdown render
#' @importFrom devtools as.package
NULL

globalVariables(c(".data"))