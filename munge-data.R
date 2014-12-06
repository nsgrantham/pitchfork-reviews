
source("load-database.R")

# time to get our hands dirty -- this data isn't properly cleaned

# some useful packages
library(dplyr)     # data manipulation: filter, select, mutate, group_by, summarise, ...

#-----  Reviewers  -------------------------

# reviewer names are not consistent over time!
reviewer.names <- albums %>%
  group_by(reviewer) %>%
  summarise(n = n())

reviewer.names  # notice Alex Lindhart and Alex Linhardt (the correct spelling)
                # even the full name: Alexander Lloyd Linhardt

# thankfully there are only ~300 reviewers so we can just manually locate
# any naming inconsistencies

# let's collect related names, where the first element of each char vector
# is the "preferred" name as denoted by the largest n count in reviewer.names
ll <- list()
ll[[1]]  <- c("Alex Linhardt", "Alex Lindhart", "Alexander Lloyd Linhardt", "Andy Linhardt")
ll[[2]]  <- c("Andy Beta", "Dr. Andy Beta")
ll[[3]]  <- c("Chris Weber", "Christopher Weber")
ll[[4]]  <- c("Cory D. Byrom", "Cory Byrom")
ll[[5]]  <- c("David Bevan", "David Bevan ")
ll[[6]]  <- c("Erin MacLeod", "Erin Macleod")
ll[[7]]  <- c("Grayson Currin", "Grayson Haver Currin")
ll[[8]]  <- c("Jeremy D. Larson", "Jeremy Larson")
ll[[9]]  <- c("Katherine St. Asaph", "Katherine St Asaph")
ll[[10]] <- c("Kim Shannon", "Kim Fing Shannon")
ll[[11]] <- c("Larry Fitzmaurice", "Larry FItzmaurice")
ll[[12]] <- c("Mark Richardson", "Mark Richard-San")  # seriously?
ll[[13]] <- c("Matthew Wellins", "Matt Wellins")
ll[[14]] <- c("Mia Clarke", "Mia Lily Clarke")
ll[[15]] <- c("Nate Patrin", "Nate Patrin ")
ll[[16]] <- c("Nick Sylvester", "Nicholas B. Sylvester")
ll[[17]] <- c("P.J. Gallagher", "PJ Gallagher")
ll[[18]] <- c("Patrick Sisson", "Patrick Sisson ")
ll[[19]] <- c("Sean Fennessey", "Sean Fennessy")
ll[[20]] <- c("Stephen M. Deusner", "Stephen M. Duesner", "Stephen Deusner")
ll[[21]] <- c("Stephen Troussé", "Stephen Trouss")

# now replace incorrect names with correct names in reviewers and albums tables
for (name.vector in ll) {
  reviewers$reviewer[reviewers$reviewer %in% name.vector] <- name.vector[1]
  albums$reviewer[albums$reviewer %in% name.vector]       <- name.vector[1]
}
# and remove duplicate entries from reviewers table
reviewers <- reviewers[!duplicated(reviewers$reviewer), ]
rm(ll, name.vector)

# let's check again
reviewer.names <- albums %>%
  group_by(reviewer) %>%
  summarise(n = n())

reviewer.names

#-----  Dates  -------------------------

# create year and month columns for when the review was published.

library(lubridate)  # ymd, format
albums <- albums %>% 
  mutate(year = format(ymd(published), format = "%Y"), 
         month = format(ymd(published), format = "%m"))

