
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ubep.gpt

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![Codecov test
coverage](https://codecov.io/gh/UBESP-DCTV/ubep.gpt/branch/main/graph/badge.svg)](https://app.codecov.io/gh/UBESP-DCTV/ubep.gpt?branch=main)
[![R-CMD-check](https://github.com/UBESP-DCTV/ubep.gpt/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/UBESP-DCTV/ubep.gpt/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of ubep.gpt is to …

## Installation

You can install the development version of ubep.gpt like so:

``` r
# FILL THIS IN! HOW CAN PEOPLE INSTALL YOUR DEV PACKAGE?
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(ubep.gpt)

db <- data.frame(
  commenti = c(
    "Che barba, che noia!",
    "Un po' noioso, ma interessante",
    "Che bello, mi è piaciuto molto!"
  )
)

role <- "Sei l'assistente di un docente universitario."
context <- "State analizzando i commenti degli studenti dell'ultimo corso."

task <- "Il tuo compito è capire se sono soddisfatti del corso."
instructions <- "Analizza i commenti e decidi se sono soddisfatti o meno."
output <- "Riporta 'soddisfatto' o 'insoddisfatto', in caso di dubbio o impossibilità riporta 'NA'."
style <- "Non aggiungere nessun commento, restituisci solo ed esclusivamente una delle classificazioni possibile."

examples <- "
commento_1: 'Mi è piaciuto molto il corso; davvero interessante.'
classificazione_1: 'soddisfatto'
commento_2: 'Non mi è piaciuto per niente; una noia mortale'
classificazione_2: 'insoddisfatto'
"

res <- db |>
 query_gpt_on_column(
   "commenti",
   role = role,
   context = context,
   task = task,
   instructions = instructions,
   output = output,
   style = style,
   examples = examples
 )
#> • POST the query
#> ✔ POST the query
#> • Parse the response
#> ✔ Parse the response
#> • Check whether request failed and return parsed
#> ✔ Check whether request failed and return parsed
#> • POST the query
#> ✔ POST the query
#> • Parse the response
#> ✔ Parse the response
#> • Check whether request failed and return parsed
#> ✔ Check whether request failed and return parsed
#> • POST the query
#> ✔ POST the query
#> • Parse the response
#> ✔ Parse the response
#> • Check whether request failed and return parsed
#> ✔ Check whether request failed and return parsed
res
#> # A tibble: 3 × 2
#>   commenti                        gpt_res      
#>   <chr>                           <chr>        
#> 1 Che barba, che noia!            insoddisfatto
#> 2 Un po' noioso, ma interessante  insoddisfatto
#> 3 Che bello, mi è piaciuto molto! soddisfatto
```

## Code of Conduct

Please note that the ubep.gpt project is released with a [Contributor
Code of
Conduct](https://contributor-covenant.org/version/2/1/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.
