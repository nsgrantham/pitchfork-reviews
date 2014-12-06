
rm(list = ls())  # fresh workspace

library(RSQLite)
library(DBI)

con <- dbConnect(RSQLite::SQLite(), "pitchfork-reviews.db")
dbListTables(con)

# You can fetch all results:
results <- dbSendQuery(con, "SELECT * FROM albums")
albums <- dbFetch(results)
dbClearResult(results)

# You can fetch all results:
results <- dbSendQuery(con, "SELECT * FROM artists")
artists <- dbFetch(results)
dbClearResult(results)

# You can fetch all results:
results <- dbSendQuery(con, "SELECT * FROM reviewers")
reviewers <- dbFetch(results)
dbClearResult(results)

# Disconnect from the database
dbDisconnect(con)

rm(list = c("con", "results"))

