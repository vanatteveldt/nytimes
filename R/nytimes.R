#' Convert nytimes json to tibble
#' @param doc the nytimes json
#' @return a tibble containing the relevant (for me) values
extract_doc = function(doc) {
  fixnull = function(x) ifelse(is.null(x), "", x)
  tibble::tibble(
    uri=doc$uri,
    url=doc$web_url,
    abstract=doc$abstract,
    date=doc$pub_date,
    source=doc$source,
    print_section=doc$print_section,
    print_page=doc$print_page,
    news_desk=doc$news_desk, section_name=doc$section_name,
    headline=doc$headline$main,
    print_headline=fixnull(doc$headline$print),
    byline=fixnull(doc$byline$original),
    lead=doc$lead_paragraph,
    NULL)
}

#' Get the API key from argument, option, or prompt
#' @param API_KEY The API key to use. If not given, will use NYTIMES_API_KEY option or prompt
#' @return the API key
check_key = function(API_KEY=NULL) {
  if (!is.null(API_KEY)) return(API_KEY)
  API_KEY = getOption("NYTIMES_API_KEY")
  if (!is.null(API_KEY)) return(API_KEY)
  API_KEY = rstudioapi::askForSecret("NYTimes API Key")
  if (is.null(API_KEY)) stop("No API key provided")
  options(NYTIMES_API_KEY=API_KEY)
  API_KEY
}

#' Conduct a single query (retrieving a single page)
#' @param API_KEY The API key to use. If not given, will use NYTIMES_API_KEY option or prompt
#' @param ... Options passed to API (see query_pages for more details)
#' @return A list with meta (list) and docs (tibble) keys
#' @export
query_page = function(API_KEY=NULL, ...) {
  API_KEY = check_key(API_KEY)
  query = list("api-key"=API_KEY, ...)
  r = httr::GET("https://api.nytimes.com/svc/search/v2/articlesearch.json", query=query)
  httr::stop_for_status(r)
  d = httr::content(r)
  docs = purrr::map_df(d$response$docs, extract_doc)
  list(docs=docs, meta=d$response$meta)
}

#' Conduct an article search query, iterating over all pages
#'
#' Search the nytimes api with the given search query.
#' This will automatically iterate over all pages, obeying the rate limit to 10 queries / 100 articles per minute
#'
#' To get an API key, please see https://developer.nytimes.com/.
#' For more information on the Article Search API, please see https://developer.nytimes.com/docs/articlesearch-product/1/overview.
#'
#' Example query to get front page articles mentioning Biden or Trump on the last days of the election:
#' query(fq='(biden OR trump) AND source:"The New York Times" AND print_section:A AND print_page:1',
#'       begin_date="2020-11-01", end_date="2020-11-03")
#'
#' @param API_KEY The API key to use. If not given, will use NYTIMES_API_KEY option or prompt
#' @param max_pages The maximum number of pages to retrieve (set NULL to get all pages)
#' @param ... Options passed to API (see above)
#' @return A list with meta (list) and docs (tibble) keys
#' @export
query = function(API_KEY=NULL, max_pages=10, ...) {
  API_KEY = check_key(API_KEY)
  res = query_page(API_KEY=API_KEY, ...)
  message(paste0("Found ", res$meta$hits, " results total"))
  maxpage = floor(res$meta$hits/10)
  if (!is.null(max_pages)) maxpage=min(maxpage, max_pages-1)
  if (maxpage <= 0) return(res$docs)
  pb = progress::progress_bar$new(total = maxpage, format=":spin Page :current / :total [:bar] :percent eta: :eta")
  docs = purrr::map_df(1:maxpage, function(p) {
    for (i in 1:10) {
      pb$tick(0.1)
      Sys.sleep(.6)
    }
    r = query_page(API_KEY=API_KEY, page=p, ...)
    r$docs
  })
  dplyr::bind_rows(res$docs, docs)
}

