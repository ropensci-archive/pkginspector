
<!-- README.md is generated from README.Rmd. Please edit that file -->

[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Travis build
status](https://travis-ci.org/ropenscilabs/pkginspector.svg?branch=master)](https://travis-ci.org/ropenscilabs/pkginspector)
[![codecov](https://codecov.io/gh/ropenscilabs/pkginspector/branch/master/graph/badge.svg)](https://codecov.io/gh/ropenscilabs/pkginspector)

# pkginspector

The goal of pkginspector is to facilitate **rOpenSci** package reviews.

## Installation

You can install pkginspector from GitHub with:

``` r
# install.packages("devtools")
devtools::install_github("ropenscilabs/pkginspector")
```

## rOpenSci 2018: `pkginspector`

[Sam Albers](https://twitter.com/big_bad_sam), [Leonardo
Collado-Torres](https://twitter.com/fellgernon), [Mauro
Lepore](https://twitter.com/mauro_lepore), [Joyce
Robbins](https://twitter.com/jtrnyc), [Noam
Ross](https://twitter.com/noamross), [Omayma
Said](https://github.com/OmaymaS)

### Function calls

We add functionality to analyze function dependencies within a package
to `pkginspector` with `rev_fn_summary()`, which can be called on a
package or on an class of `igraph` returned by `create_package_igraph()`
in which functions are represented as nodes and function calls as
directed edges.

`rev_fn_summary()` returns a data frame with the following columns:

  - `f_args`: names of all package functions and default arguments

  - `called_by`: number of functions that directly depend on `f`

  - `calls`: number of functions directed called by `f`

  - `exported`: logical TRUE if the package exports `f`

  - `dependents`: number of functions that depend on `f` (functions that
    directly or indirectly call `f`)

For example, we run `rev_fn_summary()` on a default package
(`viridisLite`) included with
`pkginspector`:

``` r
res <- pkginspector::rev_fn_summary(params$pkgdir)
```

| f\_args                                                                 | called\_by | calls | exported | dependents |
| :---------------------------------------------------------------------- | ---------: | ----: | :------- | ---------: |
| cividis (n, alpha = 1, begin = 0, end = 1, direction = 1)               |          0 |     1 | TRUE     |          0 |
| inferno (n, alpha = 1, begin = 0, end = 1, direction = 1)               |          0 |     1 | TRUE     |          0 |
| magma (n, alpha = 1, begin = 0, end = 1, direction = 1)                 |          0 |     1 | TRUE     |          0 |
| plasma (n, alpha = 1, begin = 0, end = 1, direction = 1)                |          0 |     1 | TRUE     |          0 |
| viridis (n, alpha = 1, begin = 0, end = 1, direction = 1, option = “D”) |          4 |     0 | TRUE     |          4 |
| viridisMap (n = 256, alpha = 1, begin = 0, end = 1, direction = 1,      |          0 |     0 | FALSE    |          0 |

Note that in order to run `rev_fn_summary()`, the prebuilt package files
must exist locally. For packages that exist on GitHub, the easiest way
to get the files is to clone the repo that contains them. Another method
is to download and unzip the package source file, such as the one found
here: `https://cran.r-project.org/src/contrib/skimr_1.0.2.tar.gz`

The package must also be installed through traditional methods.

Example code for running `rev_fn_summary()` on an external package
(after downloading):

    ## Run rev_fn_summary() on the skimr package:
    > package_functions <- rev_fn_summary("~/Downloads/skimr")
    > package_functions

### Argument default usage

We introduced the `rev_args()` function that identifies all the
arguments used in the functions of a given package and it’s main feature
is a logical vector indicating if the default value of the argument is
consistent across all uses of the argument. The idea is that this
information can be useful to a reviewer because it is a proxy of the
complexity of the package and potential source of confusion to users.
Maybe the package uses the same argument name for two completely
different things. Or maybe it’s a logical flag that sometimes is set to
`TRUE` and others to
`FALSE`.

``` r
ra <- pkginspector::rev_args(params$pkgdir)$arg_df
```

| arg\_name | n\_functions | default\_consistent | default\_consistent\_percent |
| :-------- | -----------: | :------------------ | ---------------------------: |
| n         |            6 | FALSE               |                     83.33333 |
| alpha     |            6 | TRUE                |                    100.00000 |
| begin     |            6 | TRUE                |                    100.00000 |
| end       |            6 | TRUE                |                    100.00000 |
| direction |            6 | TRUE                |                    100.00000 |
| option    |            2 | TRUE                |                    100.00000 |

The following plot visualizes which arguments are used in which
functions.

![](tools/readme/README-rev_args_mat-1.png)<!-- -->

#### Details

The function `rev_args(path = '.', exported_only = FALSE)` takes two
arguments:

  - `path`: path to a package
  - `exported_only`: logical indicating whether to focus only on the
    exported functions or not.

`rev_args()` returns a list with two elements:

  - `arg_df`: a data.frame with columns
      - `arg_name`: name of the argument
      - `n_functions`: number of functions where the argument is used
      - `default_consistent`: logical, is the argument default value
        consistent across all usages
      - `default_consistent_percent`: \[0, 100\] indicating how
        consistent the default usage is when compared against the first
        use of the argument.
  - `arg_map`: a logical matrix with function names in the rows,
    argument names in the columns. It indicates where each argument is
    used.

#### Example output

``` r
## Install viridisLite if needed
install.packages('viridisLite')
```

``` r
## Identify the location of the test version of viridisLite that's included
path <- system.file('viridisLite', package = 'pkginspector', mustWork = TRUE)

## Run rev_args() on the example package viridisLite that is included in pkginspector
pkginspector::rev_args(path = path, exported_only = TRUE)
#> $arg_df
#>    arg_name n_functions default_consistent default_consistent_percent
#> 1         n           5               TRUE                        100
#> 2     alpha           5               TRUE                        100
#> 3     begin           5               TRUE                        100
#> 4       end           5               TRUE                        100
#> 5 direction           5               TRUE                        100
#> 6    option           1               TRUE                        100
#> 
#> $arg_map
#>            n alpha begin  end direction option
#> cividis TRUE  TRUE  TRUE TRUE      TRUE  FALSE
#> inferno TRUE  TRUE  TRUE TRUE      TRUE  FALSE
#> magma   TRUE  TRUE  TRUE TRUE      TRUE  FALSE
#> plasma  TRUE  TRUE  TRUE TRUE      TRUE  FALSE
#> viridis TRUE  TRUE  TRUE TRUE      TRUE   TRUE
```

In this example, the `n` argument doesn’t have a consistent default
value in all 5 functions where it’s used.

### Review dependency usage

New `rev_dependency_usage()` counts used functions from external
packages. You may want to remove dependency on packages from which you
use few functions.

``` r
pkginspector::rev_dependency_usage()
#> # A tibble: 13 x 3
#>    package         n functions                                            
#>    <chr>       <int> <chr>                                                
#>  1 ???             1 n                                                    
#>  2 devtools        1 as.package                                           
#>  3 dplyr           5 filter, group_by, summarize, data_frame, mutate      
#>  4 functionMap     1 map_r_package                                        
#>  5 igraph          6 V, ego, degree, vertex_attr, graph_from_data_frame, …
#>  6 magrittr        1 %>%                                                  
#>  7 purrr           1 map                                                  
#>  8 rmarkdown       1 render                                               
#>  9 stats           1 setNames                                             
#> 10 tidyr           1 separate                                             
#> 11 usethis         1 proj_get                                             
#> 12 utils           1 lsf.str                                              
#> 13 visNetwork      8 visNetwork, visLayout, visGroups, visEdges, visOptio…
```
