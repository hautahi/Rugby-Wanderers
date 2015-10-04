# rugby-wanderers

# Introduction
An ongoing and often heated debate among the rugby public and media concerns the extent to which international rugby teams "poach" players from other countries. The poaching allegations have largely relied on casual observations and anecdotes rather than any attempt to look at the evidence. The [New Zealand Herald](http://www.nzherald.co.nz/sport/news/article.cfm?c_id=4&objectid=11278276) provided a notable exception by compiling a dataset of the birthplace of every All Black.

The data contained in this repository is an attempt to provide further empirical rigor to the discussion by allowing cross-country comparisons of migrant rugby players.

## Contents
* Dataset is `final_data.csv`. It contains the names, playing statistics and birthplaces for every person to have played test match rugby for the major nations.

* `1.webscrape` directory contains the Python code used to scrape the player names, playing statistics and some birthplaces from the web. It also contains the Python data objects sorted according to country as well as the compiled scraped data to be cleaned.
  
  - `1.Scrape.py` script scrapes the raw player data from the [ESPN rugby](http://www.espn.co.uk/rugby/) website.
  - `2.Find_Country.py` script uses the [GeoPy](https://geopy.readthedocs.org/en/1.10.0/) package to identify the country in which players were born (the initial webscrape only yields the city or region).
  - `3.Gather.py` script compiles the resulting data from the above two programs into [`complete.csv`](./1.webscrape/complete.csv), to be cleaned by the R scripts.

* `2.clean` directory contains the R code used to clean and process the raw data from the webscrape, as well as incorporate manual adjustments to the data from my own research as well as the New Zealand Herald data.

  - `4.clean_up.R` script cleans and performs the adjustments to the raw data in order to produce the final dataset.
  - `5.analysis.R` script performs analysis on the data to be reported at a later date.

## Contributing to rugby-wanderers

To my knowledge, the player names and playing statistics are accurate, but the birthplace information remains a work in progress. Birthplace data is especially sparse for Canada, the USA and the Pacific Island countries. I welcome any contributions and corrections that can be pointed out. Feel free to create a pull request or to email me (hrk55@cornell.edu) with any help you can provide.


