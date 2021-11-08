README
================

# Simple R Package to query the NYTimes article search API.

Note: The `rtimes` packages was abandoned, and it seemed easier to write
a simple package to only query the AS API rather than taking over the
whole package.

## Installation

``` r
remotes::install_github("vanatteveldt/nytimes")
```

## API Key

To get an API key, visit <https://developer.nytimes.com/get-started>.
The first time you use this package, it will prompt you for the key and
store it. You can also store it manually using:

``` r
options(NYTIMES_API_KEY="<YOUR API KEY>")
```

## Using the API

The main function to use is the `query` function. Apart from an optional
API\_KEY and max\_pages argument, this passes all arguments directly to
the article search API. For example, to get the first 20 front page
articles of 2020 election news, you could use something like:

``` r
library(nytimes)
query(fq='(biden OR trump) AND source:"The New York Times" AND print_section:A AND print_page:1', begin_date="2020-01-01", end_date="2020-11-03",
      max_pages=2)
```

    ## Found 1118 results total

    ## # A tibble: 20 x 13
    ##    uri     url      abstract    date   source print_section print_page news_desk
    ##    <chr>   <chr>    <chr>       <chr>  <chr>  <chr>         <chr>      <chr>    
    ##  1 nyt://… https:/… Republican… 2020-… The N… A             1          Washingt…
    ##  2 nyt://… https:/… Democrats … 2020-… The N… A             1          Politics 
    ##  3 nyt://… https:/… From the b… 2020-… The N… A             1          Washingt…
    ##  4 nyt://… https:/… As it prai… 2020-… The N… A             1          Foreign  
    ##  5 nyt://… https:/… The corona… 2020-… The N… A             1          National 
    ##  6 nyt://… https:/… The admini… 2020-… The N… A             1          Climate  
    ##  7 nyt://… https:/… President … 2020-… The N… A             1          Politics 
    ##  8 nyt://… https:/… President … 2020-… The N… A             1          Washingt…
    ##  9 nyt://… https:/… Whether Pr… 2020-… The N… A             1          Washingt…
    ## 10 nyt://… https:/… New detail… 2020-… The N… A             1          Washingt…
    ## 11 nyt://… https:/… The top Se… 2020-… The N… A             1          Washingt…
    ## 12 nyt://… https:/… Russia’s h… 2020-… The N… A             1          Washingt…
    ## 13 nyt://… https:/… The Suprem… 2020-… The N… A             1          Washingt…
    ## 14 nyt://… https:/… In a more … 2020-… The N… A             1          Politics 
    ## 15 nyt://… https:/… When his s… 2020-… The N… A             1          Business 
    ## 16 nyt://… https:/… Propositio… 2020-… The N… A             1          Business 
    ## 17 nyt://… https:/… QAnon, wit… 2020-… The N… A             1          Politics 
    ## 18 nyt://… https:/… Democrats … 2020-… The N… A             1          Politics 
    ## 19 nyt://… https:/… President … 2020-… The N… A             1          Politics 
    ## 20 nyt://… https:/… No matter … 2020-… The N… A             1          Politics 
    ## # … with 5 more variables: section_name <chr>, headline <chr>,
    ## #   print_headline <chr>, byline <chr>, lead <chr>
