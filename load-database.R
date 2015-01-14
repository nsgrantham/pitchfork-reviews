
rm(list = ls())  # fresh workspace

library(RSQLite)
library(DBI)

# Connect to database
con <- dbConnect(RSQLite::SQLite(), "pitchfork-reviews.db")

# Create R Dataframes from SQL Tables
fetch_and_store_results <- function(tab, env) {
  query <- paste("SELECT * FROM", tab)
  results <- dbSendQuery(con, query)
  assign(tab, dbFetch(results), envir = env)
  dbClearResult(results)
}
tables <- dbListTables(con)
sapply(tables, fetch_and_store_results, env = environment())

# Disconnect from the database
dbDisconnect(con)
rm(list = c("con", "tables", "fetch_and_store_results"))

