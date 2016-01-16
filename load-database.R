
rm(list = ls())  # fresh workspace

library(RSQLite)
library(DBI)

# Connect to database
con <- dbConnect(RSQLite::SQLite(), "pitchfork-reviews.db")

# Create R Dataframes from SQL Tables
tables <- dbListTables(con)
for (tab in tables) {
  assign(tab, dbReadTable(con, tab), env = environment())
}

# Disconnect from the database
dbDisconnect(con)
rm(list = c("con", "tables", "tab"))

