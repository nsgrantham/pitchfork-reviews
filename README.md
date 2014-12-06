# _Pitchfork_ Album Scores & Accolades

[Pitchfork](http://pitchfork.com) is the largest indie music review site on the Internet (at least in the English-speaking world) with   

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
`artists`|`id`|Unique artist identifier assigned by Pitchfork. e.g., Tennis is uniquely identified by 28984 as visible in their artist url `http://pitchfork.com/artists/28984-tennis/`
|`artist`|Name of the artist.
|`url`|Pitchfork URL of the artist.
`reviewers`|`id`|Unique artist identifier, auto-assigned as new reviewers enter the database.
|`reviewer`|Name(s) of reviewer(s).
|`url`|Pitchfork URL of the reviewer. If none, URL is simply `http://pitchfork.com/staff/`


## Loading the data into `R`

The `RSQLite` and `DBI` packages allow `R` to interact with `pitchfork-reviews.db` using SQLite syntax. As these data are not prohibitively large, the easiest option is to load the database into `R` in its entirety. )

##