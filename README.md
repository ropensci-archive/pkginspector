
<!-- README.md is generated from README.Rmd. Please edit that file -->
[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental) [![Travis build status](https://travis-ci.org/ropenscilabs/revtools.svg?branch=master)](https://travis-ci.org/ropenscilabs/revtools) [![codecov](https://codecov.io/gh/ropenscilabs/revtools/branch/master/graph/badge.svg)](https://codecov.io/gh/ropenscilabs/revtools)

revtools
========

The goal of revtools is to facilitate **rOpenSci** package reviews.

Installation
------------

You can install revtools from GitHub with:

``` r
# install.packages("devtools")
devtools::install_github("ropenscilabs/revtools")
#> Downloading GitHub repo ropenscilabs/revtools@master
#> from URL https://api.github.com/repos/ropenscilabs/revtools/zipball/master
#> Installing revtools
#> "C:/PROGRA~1/R/R-35~1.0/bin/x64/R" --no-site-file --no-environ --no-save  \
#>   --no-restore --quiet CMD INSTALL  \
#>   "C:/Users/boshek/AppData/Local/Temp/RtmpKeq2Mz/devtools216c693341ce/ropenscilabs-revtools-55113ea"  \
#>   --library="C:/Users/boshek/Documents/R/win-library/3.5"  \
#>   --install-tests
#> 
#> Installation failed: Command failed (1)
```

rOpenSci 2018: `pkgtests` branch
--------------------------------

[Sam Albers](https://twitter.com/big_bad_sam), [Leonardo Collado-Torres](https://twitter.com/fellgernon), [Mauro Lepore](https://twitter.com/mauro_lepore), [Joyce Robbins](https://twitter.com/jtrnyc), [Noam Ross](https://twitter.com/noamross), [Omayma Said](https://github.com/OmaymaS)

### Function calls

We add functionality to analyze function dependencies within a package to `revtools` with `rev_fn_summary()`, which can be called on a package or on an class of `igraph` returned by `create_package_igraph()` in which functions are represented as nodes and function calls as directed edges.

`rev_fn_summary()` returns a data frame with the following columns:

-   `f_args`: names of all package functions and default arguments

-   `called_by`: number of functions that directly depend on `f`

-   `calls`: number of functions directed called by `f`

-   `exported`: logical TRUE if the package exports `f`

-   `all_called_by`: number of functions that depend on `f` (functions that directly or indirectly call `f`)

For example, we run `rev_fn_summary()` on a default package (`viridisLite`) included with `revtools`:

``` r
res <- revtools::rev_fn_summary(params$pkgdir)
```

| f\_args                                                                 |  called\_by|  calls| exported |  all\_called\_by|
|:------------------------------------------------------------------------|-----------:|------:|:---------|----------------:|
| cividis (n, alpha = 1, begin = 0, end = 1, direction = 1)               |           0|      1| TRUE     |                0|
| inferno (n, alpha = 1, begin = 0, end = 1, direction = 1)               |           0|      1| FALSE    |                0|
| magma (n, alpha = 1, begin = 0, end = 1, direction = 1)                 |           0|      1| TRUE     |                0|
| plasma (n, alpha = 1, begin = 0, end = 1, direction = 1)                |           0|      1| TRUE     |                0|
| viridis (n, alpha = 1, begin = 0, end = 1, direction = 1, option = "D") |           4|      0| TRUE     |                4|
| viridisMap (n = 256, alpha = 1, begin = 0, end = 1, direction = 1,      |           0|      0| TRUE     |                0|

Note that in order to run `rev_fn_summary()`, the prebuilt package files must exist locally. For packages that exist on GitHub, the easiest way to get the files is to clone the repo that contains them. Another method is to download and unzip the package source file, such as the one found here: `https://cran.r-project.org/src/contrib/skimr_1.0.2.tar.gz`

The package must also be installed through traditional methods.

Example code for running `rev_fn_summary()` on an external package (after downloading):

    ## Run rev_fn_summary() on the skimr package:
    > package_functions <- rev_fn_summary("~/Downloads/skimr")
    > package_functions

### Argument default usage

We introduced the `rev_args()` function that identifies all the arguments used in the functions of a given package and it's main feature is a logical vector indicating if the default value of the argument is consistent across all uses of the argument. The idea is that this information can be useful to a reviewer because it is a proxy of the complexity of the package and potential source of confusion to users. Maybe the package uses the same argument name for two completely different things. Or maybe it's a logical flag that sometimes is set to `TRUE` and others to `FALSE`.

``` r
ra <- revtools::rev_args(params$pkgdir)$arg_df
```

| arg\_name |  n\_functions| default\_consistent |  default\_consistent\_percent|
|:----------|-------------:|:--------------------|-----------------------------:|
| n         |             6| FALSE               |                      83.33333|
| alpha     |             6| TRUE                |                     100.00000|
| begin     |             6| TRUE                |                     100.00000|
| end       |             6| TRUE                |                     100.00000|
| direction |             6| TRUE                |                     100.00000|
| option    |             2| TRUE                |                     100.00000|

The following plot visualizes which arguments are used in which functions.

![](tools/readme/README-rev_args_mat-1.png)

#### Details

The function `rev_args(path = '.', exported_only = FALSE)` takes two arguments:

-   `path`: path to a package
-   `exported_only`: logical indicating whether to focus only on the exported functions or not.

`rev_args()` returns a list with two elements:

-   `arg_df`: a data.frame with columns
    -   `arg_name`: name of the argument
    -   `n_functions`: number of functions where the argument is used
    -   `default_consistent`: logical, is the argument default value consistent across all usages
    -   `default_consistent_percent`: \[0, 100\] indicating how consistent the default usage is when compared against the first use of the argument.
-   `arg_map`: a logical matrix with function names in the rows, argument names in the columns. It indicates where each argument is used.

#### Example output

``` r
## Install viridisLite if needed
> install.packages('viridisLite')

## Identify the location of the test version of viridisLite that's included
> path <- system.file('viridisLite', package = 'revtools', mustWork = TRUE)

## Run rev_args() on the example package viridisLite that is included in revtools
> arg_info_exported <- rev_args(path = path, exported_only = TRUE)

## Explore the output
> arg_info_exported
$arg_df
   arg_name n_functions default_consistent default_consistent_percent
1         n           5              FALSE                         80
2     alpha           5               TRUE                        100
3     begin           5               TRUE                        100
4       end           5               TRUE                        100
5 direction           5               TRUE                        100
6    option           2               TRUE                        100

$arg_map
              n alpha begin  end direction option
cividis    TRUE  TRUE  TRUE TRUE      TRUE  FALSE
magma      TRUE  TRUE  TRUE TRUE      TRUE  FALSE
plasma     TRUE  TRUE  TRUE TRUE      TRUE  FALSE
viridis    TRUE  TRUE  TRUE TRUE      TRUE   TRUE
viridisMap TRUE  TRUE  TRUE TRUE      TRUE   TRUE
```

In this example, the `n` argument doesn't have a consistent default value in all 5 functions where it's used.

### Review dependency usage

New `rev_dependency_usage()` counts used functions from external packages.

``` r
library(revtools)
library(dplyr, warn.conflicts = FALSE)
```

``` r
n_deps <- rev_dependency_usage()

# You may want to remove dependency on packages from which you use few functions
# As tibble truncates `functions` so they use no more than a single line
as_tibble(arrange(n_deps, n))
#> # A tibble: 20 x 3
#>    package         n functions                                            
#>    <chr>       <int> <chr>                                                
#>  1 ???             1 n                                                    
#>  2 base64enc       1 base64decode                                         
#>  3 devtools        1 as.package                                           
#>  4 functionMap     1 map_r_package                                        
#>  5 gh              1 gh                                                   
#>  6 magrittr        1 %>%                                                  
#>  7 revtools      1 rev_calls                                            
#>  8 purrr           1 map                                                  
#>  9 rmarkdown       1 render                                               
#> 10 stats           1 setNames                                             
#> 11 tidyr           1 separate                                             
#> 12 utils           1 lsf.str                                              
#> 13 whoami          1 gh_username                                          
#> 14 assertthat      2 assert_that, validate_that                           
#> 15 dplyr           3 filter, group_by, summarize                          
#> 16 httr            3 content, GET, http_error                             
#> 17 rstudioapi      3 isAvailable, openProject, getVersion                 
#> 18 usethis         5 create_project, use_template, use_git_hook, proj_get~
#> 19 git2r           6 clone, init, status, add, commit, discover_repository
#> 20 igraph          6 degree, vertex_attr, V, ego, graph_from_data_frame, ~
```

`kable()` lets you see al functions even if they don't fit in a single line.

``` r
knitr::kable(n_deps)
```

<table>
<thead>
<tr class="header">
<th style="text-align: left;">
package
</th>
<th style="text-align: right;">
n
</th>
<th style="text-align: left;">
functions
</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;">
???
</td>
<td style="text-align: right;">
1
</td>
<td style="text-align: left;">
n
</td>
</tr>
<tr class="even">
<td style="text-align: left;">
assertthat
</td>
<td style="text-align: right;">
2
</td>
<td style="text-align: left;">
assert\_that, validate\_that
</td>
</tr>
<tr class="odd">
<td style="text-align: left;">
base64enc
</td>
<td style="text-align: right;">
1
</td>
<td style="text-align: left;">
base64decode
</td>
</tr>
<tr class="even">
<td style="text-align: left;">
devtools
</td>
<td style="text-align: right;">
1
</td>
<td style="text-align: left;">
as.package
</td>
</tr>
<tr class="odd">
<td style="text-align: left;">
dplyr
</td>
<td style="text-align: right;">
3
</td>
<td style="text-align: left;">
filter, group\_by, summarize
</td>
</tr>
<tr class="even">
<td style="text-align: left;">
functionMap
</td>
<td style="text-align: right;">
1
</td>
<td style="text-align: left;">
map\_r\_package
</td>
</tr>
<tr class="odd">
<td style="text-align: left;">
gh
</td>
<td style="text-align: right;">
1
</td>
<td style="text-align: left;">
gh
</td>
</tr>
<tr class="even">
<td style="text-align: left;">
git2r
</td>
<td style="text-align: right;">
6
</td>
<td style="text-align: left;">
clone, init, status, add, commit, discover\_repository
</td>
</tr>
<tr class="odd">
<td style="text-align: left;">
httr
</td>
<td style="text-align: right;">
3
</td>
<td style="text-align: left;">
content, GET, http\_error
</td>
</tr>
<tr class="even">
<td style="text-align: left;">
igraph
</td>
<td style="text-align: right;">
6
</td>
<td style="text-align: left;">
degree, vertex\_attr, V, ego, graph\_from\_data\_frame, set\_vertex\_attr
</td>
</tr>
<tr class="odd">
<td style="text-align: left;">
magrittr
</td>
<td style="text-align: right;">
1
</td>
<td style="text-align: left;">
%&gt;%
</td>
</tr>
<tr class="even">
<td style="text-align: left;">
revtools
</td>
<td style="text-align: right;">
1
</td>
<td style="text-align: left;">
rev\_calls
</td>
</tr>
<tr class="odd">
<td style="text-align: left;">
purrr
</td>
<td style="text-align: right;">
1
</td>
<td style="text-align: left;">
map
</td>
</tr>
<tr class="even">
<td style="text-align: left;">
rmarkdown
</td>
<td style="text-align: right;">
1
</td>
<td style="text-align: left;">
render
</td>
</tr>
<tr class="odd">
<td style="text-align: left;">
rstudioapi
</td>
<td style="text-align: right;">
3
</td>
<td style="text-align: left;">
isAvailable, openProject, getVersion
</td>
</tr>
<tr class="even">
<td style="text-align: left;">
stats
</td>
<td style="text-align: right;">
1
</td>
<td style="text-align: left;">
setNames
</td>
</tr>
<tr class="odd">
<td style="text-align: left;">
tidyr
</td>
<td style="text-align: right;">
1
</td>
<td style="text-align: left;">
separate
</td>
</tr>
<tr class="even">
<td style="text-align: left;">
usethis
</td>
<td style="text-align: right;">
5
</td>
<td style="text-align: left;">
create\_project, use\_template, use\_git\_hook, proj\_get, use\_git\_ignore
</td>
</tr>
<tr class="odd">
<td style="text-align: left;">
utils
</td>
<td style="text-align: right;">
1
</td>
<td style="text-align: left;">
lsf.str
</td>
</tr>
<tr class="even">
<td style="text-align: left;">
whoami
</td>
<td style="text-align: right;">
1
</td>
<td style="text-align: left;">
gh\_username
</td>
</tr>
</tbody>
</table>
Created on 2018-05-22 by the [reprex package](http://reprex.tidyverse.org) (v0.2.0).
