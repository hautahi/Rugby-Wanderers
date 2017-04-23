# Rugby-Wanderers

Code for webscraping rugby player statistics.

## Contents
* Dataset is [`1.main_data.csv`](https://github.com/hautahi/Rugby-Wanderers/blob/master/data/1.main_data.csv). It contains the names, playing statistics and birthplaces for every person to have played test match rugby for the major nations.

* `1.webscrape` directory contains the Python code used to scrape the player names, playing statistics and some birthplaces from the web. It also contains the Python data objects sorted according to country as well as the compiled scraped data to be cleaned.
  
  - `1.Scrape.py` script scrapes the raw player data from the [ESPN rugby](http://www.espn.co.uk/rugby/) website.
  - `2.Find_Country.py` script uses the [GeoPy](https://geopy.readthedocs.org/en/1.10.0/) package to identify the country in which players were born (the initial webscrape only yields the city or region).
  - `3.Gather.py` script compiles the resulting data from the above two programs to be cleaned by the R scripts.

* `2.clean` directory contains the R code used to clean and process the raw data from the webscrape, as well as incorporate manual adjustments to the data from my own research and the [New Zealand Herald](http://www.nzherald.co.nz/sport/news/article.cfm?c_id=4&objectid=11278276) data.

  - `4.clean_up.R` script cleans and performs the adjustments to the raw data in order to produce the final dataset.

* `3.update` directory contains code used to update the data by only scraping the most recent player data.

  - `1.newscrape.py` script scrapes raw player data for most recent players.
  - `2.merge.R` merges the newly scraped data with the original data.

* `Notes` directory contains the code used to create the blog post at http://hautahi.com/rugbywanderers

  - `blog_code.R` analyzes the scraped dataset.
  - `BlogArticle.Rmd` is the markdown script used to write the blog post.

## Contributing to Rugby-Wanderers

To my knowledge, the player names and playing statistics are accurate, but the birthplace information remains a work in progress. Birthplace data is especially sparse for Canada, the USA and the Pacific Island countries. I welcome any contributions and corrections that can be pointed out. Feel free to create a pull request or to email me (hautahikingi@gmail.com) with any help you can provide.


