# [Analysis of Pitchfork album reviews](http://nsgrantham.github.io/pitchfork-reviews)

[Pitchfork](http://pitchfork.com) is the largest indie music site on the Internet (in the English-speaking world, at least), updating its pages daily with the latest indie music rumblings, interviews with budding artists, sneak previews of new albums and artist collaborations, and, most notably, a suite of music reviews by dedicated music critics forming Pitchfork's staff. I follow Pitchfork's album reviews religiously and I am not alone in feeling that their 'Best New Music' category routinely captures the best that modern music has to offer. But how do these data behave?

## Acquiring the data

It is necessary to scrape Pitchfork's webpages and parse the relevant information for each album. This is accomplished by `scrape-and-parse.py` which uses the `python` module `sqlite3` to produce a SQL database `pitchfork-reviews.db` with the following tables:

Table|Variable|Description
-----|--------|-----------
`albums`|`id`|Unique album identifier assigned by Pitchfork. e.g., Mac DeMarco's Salad Days album is uniquely identified by 19170 as visible in its album review url `http://pitchfork.com/reviews/albums/19170-mac-demarco-salad-days/`
 |`album`|Name of the album.
 |`artist`|Name of the album's artist.
 |`label`|Name of the label that produced the album.
 |`released`|Year the album was released. (May be missing)
 |`reviewer`|Name(s) of the album's Pitchfork reviewer(s)
 |`score`|Score given to the album: 0.0 to 10.0 in increments of 0.1
 |`accolade`|"Best New Music" or "Best New Reissue"
 |`published`|Date the review was published. YYYY-MM-DD
 |`url`|Pitchfork URL of the album review.
`artists`|`id`|Unique artist identifier assigned by Pitchfork. e.g., Warpaint is uniquely identified by 28034 as visible in their artist url `http://pitchfork.com/artists/28034-warpaint/`
 |`artist`|Name of the artist.
 |`url`|Pitchfork URL of the artist.
`reviewers`|`id`|Unique reviewer identifier, auto-assigned as new reviewers enter the database.
 |`reviewer`|Name(s) of reviewer(s).
 |`url`|Pitchfork URL of the reviewer. If none, URL is simply `http://pitchfork.com/staff/`


## Loading the data into `R`

The `RSQLite` and `DBI` packages allow `R` to interact with `pitchfork-reviews.db` using SQLite syntax. As these data are not prohibitively large, the easiest option is to load the database into `R` in its entirety. This is accomplished by `load-data.R`. These data are current as of January 14, 2015.

## Munging the data
Following execution of `load-data.R`, the `munge-data.R` file [munges](http://en.wikipedia.org/wiki/Data_wrangling) the raw data into a more usable form, including reviewer name corrections and helpful date information via `lubridate`.

## Data analysis
Finally, `2014-01-14-pitchfork-reviews.Rmd` presents a fully reproducible data analysis of these Pitchfork album review data, making use of several helpful `R` packages including `dplyr`, `magrittr`, and `ggplot2`. Opening this file in `RStudio` and "knitting" the document with `knitr` produces an `html`, `pdf`, or `docx`. The following is a link to the analysis hosted on my webpage:

[http://nsgrantham.github.io/pitchfork-reviews](https://nsgrantham.github.io/pitchfork-reviews)