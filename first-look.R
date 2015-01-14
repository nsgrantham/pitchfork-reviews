
source("munge-data.R")

library(ggplot2)
library(lubridate)

# histogram of number of reviews by reviewer
summary(reviewer.names$n)
ggplot(data = reviewer.names, aes(x = n)) + geom_histogram(aes(y = ..count..))
reviewer.names$reviewer[which.max(reviewer.names$n)]  # Go Joe! Highest number of reviews

# boxplot of scores by year of review
ggplot(albums, aes(x = format(ymd(albums$published), format = '%Y'), y = score)) + 
  geom_boxplot() +
  scale_y_continuous("Score", breaks = seq(0, 10, by = 0.5)) +
  scale_x_discrete("Year of Published Review")

# scores by year
for (yr in 1999:2014) {
  df <- filter(albums, format(ymd(published), format = '%Y') == as.character(yr))
  p <- ggplot(df, aes(x = score))
  p <- p + geom_histogram(aes(y = ..count..))
  p <- p + geom_vline(xintercept = 8.0, color = "orange")
  p <- p + ggtitle(yr)
  p <- p + scale_x_continuous("Score", breaks = seq(0, 10, by = 0.5), limits = c(0, 10))
  p <- p + scale_y_continuous("Count", limits = c(0, 200))
  print(p)
  Sys.sleep(4)
}

# boxplot of scores by year of review
ggplot(albums, aes(x = format(ymd(albums$published), format = '%m'), y = score)) + 
  geom_boxplot() +
  scale_y_continuous("Score", breaks = seq(0, 10, by = 0.5)) +
  scale_x_discrete("Month of Published Review")

# scores by month
for (mth in 1:12) {
  df <- filter(albums, format(ymd(published), format = '%m') == sprintf("%02d", mth))
  p <- ggplot(df, aes(x = score))
  p <- p + geom_histogram(aes(y = ..count..))
  p <- p + geom_vline(xintercept = 8.0, color = "orange")
  p <- p + ggtitle(mth)
  p <- p + scale_x_continuous("Score", breaks = seq(0, 10, by = 0.5), limits = c(0, 10))
  p <- p + scale_y_continuous("Count", limits = c(0, 250))
  print(p)
  Sys.sleep(4)
}


earliest.bnm <- albums %>%
  filter(accolade == "Best New Music") %>%
  select(published) %>%
  summarise(date = min(ymd(published)))
earliest.bnm$date

earliest.bnr <- albums %>%
  filter(accolade == "Best New Reissue") %>%
  select(published) %>%
  summarise(date = min(ymd(published)))
earliest.bnr$date

best.new <- albums %>%
  filter(ymd(published) >= earliest.bnm$date) %>%
  group_by(reviewer) %>%
  summarise(n = n(), bnm = sum(accolade == "Best New Music")) %>%
  filter(n > 100)

ggplot(best.new, aes(x = n, y = bnm, label = reviewer)) + 
  geom_abline(intercept = 0, slope = 0.8, alpha = 0.8, size = 1.5) +
  geom_abline(intercept = 0, slope = 0.4, alpha = 0.8, size = 1) + annotate("text", x = 175, y = 70, label = "40%") +
  geom_abline(intercept = 0, slope = 0.2, alpha = 0.8) + annotate("text", x = 325, y = 65, label = "20%") +
  geom_abline(intercept = 0, slope = 0.1, alpha = 0.8, linetype = "dashed") + annotate("text", x = 500, y = 50, label = "10%") +
  geom_abline(intercept = 0, slope = 0.05, alpha = 0.8, linetype = "dotdash") + annotate("text", x = 600, y = 30, label = "5%") +
  geom_abline(intercept = 0, slope = 0.01, alpha = 0.8, linetype = "dotted") + annotate("text", x = 700, y = 7, label = "1%") +
  geom_point() + geom_text(size = 3, vjust = -1) +
  scale_x_continuous("Number of Album Reviews", breaks = seq(0, 800, by = 50)) + 
  scale_y_continuous("Number of 'Best New' Rated Albums", breaks = seq(0, 70, by = 5)) +
  ggtitle("'Best New' Accolades by Reviewers with >100 Album Reviews")


scores8.0plus <- albums %>% 
  group_by(reviewer) %>%
  summarise(n = n(), bnm = sum(score >= 8.0)) %>%
  filter(n > 100)

ggplot(scores8.0plus, aes(x = n, y = bnm, label = reviewer)) + 
  geom_abline(intercept = 0, slope = 0.8, alpha = 0.8, size = 1.5) + annotate("text", x = 150, y = 60, label = "40%") +
  geom_abline(intercept = 0, slope = 0.4, alpha = 0.8, size = 1) + annotate("text", x = 475, y = 190, label = "40%") +
  geom_abline(intercept = 0, slope = 0.2, alpha = 0.8) + annotate("text", x = 600, y = 120, label = "20%") +
  geom_abline(intercept = 0, slope = 0.1, alpha = 0.8, linetype = "dashed") + annotate("text", x = 700, y = 70, label = "10%") +
  geom_abline(intercept = 0, slope = 0.05, alpha = 0.8, linetype = "dotdash") + annotate("text", x = 750, y = 37.5, label = "5%") +
  geom_abline(intercept = 0, slope = 0.01, alpha = 0.8, linetype = "dotted") + annotate("text", x = 800, y = 8, label = "1%") +
  geom_point() + geom_text(size = 3, vjust = -1) +
  scale_x_continuous("Number of Album Reviews", breaks = seq(0, 800, by = 50)) + 
  scale_y_continuous("Number of Albums Scored 8.0+", breaks = seq(0, 250, by = 25)) +
  ggtitle("8.0+ Scores by Reviewers with >100 Album Reviews")


bnm8.0plus <- albums %>% 
  filter(ymd(published) >= earliest.bnm$date, score >= 8.0) %>%
  group_by(reviewer) %>%
  summarise(n = n(), bnm = sum(accolade %in% c("Best New Music", "Best New Reissue"))) %>%
  filter(n > 25)

ggplot(bnm8.0plus, aes(x = n, y = bnm, label = reviewer)) + 
  geom_abline(intercept = 0, slope = 0.8, alpha = 0.8, size = 1.5) + annotate("text", x = 150, y = 60, label = "40%") +
  geom_abline(intercept = 0, slope = 0.4, alpha = 0.8, size = 1) + annotate("text", x = 150, y = 60, label = "40%") +
  geom_abline(intercept = 0, slope = 0.2, alpha = 0.8) + annotate("text", x = 181.25, y = 36.25, label = "20%") +
  geom_abline(intercept = 0, slope = 0.1, alpha = 0.8, linetype = "dashed") + annotate("text", x = 200, y = 20, label = "10%") +
  geom_abline(intercept = 0, slope = 0.05, alpha = 0.8, linetype = "dotdash") + annotate("text", x = 212.5, y = 10.625, label = "5%") +
  geom_abline(intercept = 0, slope = 0.01, alpha = 0.8, linetype = "dotted") + annotate("text", x = 225, y = 2.25, label = "1%") +
  geom_point() + geom_text(size = 3, vjust = -1) +
  scale_x_continuous("Number of Album Scored 8.0+", breaks = seq(0, 250, by = 25)) + 
  scale_y_continuous("Number of Albums Scored 8.0+ and Rated 'Best New'", breaks = seq(0, 70, by = 5)) +
  ggtitle("8.0+ Scored and 'Best New' Albums by Reviewers with >25 8.0+ Album Reviews")

#years <- format(ymd(albums$published), format = "%Y")
datetimes <- ymd(albums$published)
min.datetime <- min(datetimes)
max.datetime <- max(datetimes)
library(RColorBrewer)

# names of reviewers with over 100 reviews
over100 <- reviewer.names %>%
  filter(n > 100) %>%
  arrange(desc(n))

for (each in over100$reviewer) {
  # scores over time of top reviewers
  df <- filter(albums, reviewer == each)
  p <- ggplot(df, aes(x = ymd(published), y = score))
  #p <- p + geom_vline(xintercept = format(earliest.bnm$date, format = "%Y"))
  p <- p + geom_line(alpha = 0.5)
  p <- p + geom_point(data = filter(df, score >= 8.0), aes(colour = factor(accolade)), size = 3, alpha = 0.8)
  p <- p + scale_colour_manual("Accolade", values = brewer.pal(4, "Dark2")[c(2, 4, 3)], labels = c("8.0+", "Best New Music", "Best New Reissue"))
  p <- p + geom_smooth(method = "loess", formula = y ~ x, se = FALSE)
  p <- p + ggtitle(each)
  p <- p + scale_y_continuous("Score", breaks = seq(0, 10, by = 0.5), limits = c(0, 10))
#   p <- p + scale_x_datetime(#breaks = date_breaks("1 year"), format = "%Y",
#                             limits = c(min.datetime, max.datetime))
  print(p)
}

each = "Ryan Schreiber"
df <- filter(albums, reviewer == each)
p <- ggplot(df, aes(x = ymd(published), y = score))
#p <- p + geom_hline(yintercept = 8.0, color = "orange")
p <- p + geom_line(alpha = 0.5)
p <- p + geom_point(data = filter(df, score >= 8.0), aes(colour = factor(accolade)), size = 3, alpha = 0.8)
p <- p + scale_colour_manual("Accolade", values = brewer.pal(4, "Dark2")[c(2, 4, 3)], labels = c("8.0+", "Best New Music", "Best New Reissue"))
p <- p + geom_smooth(method = "loess", formula = y ~ x, se = FALSE)
p <- p + ggtitle(each)
p <- p + scale_y_continuous("Score", breaks = seq(0, 10, by = 0.5), limits = c(0, 10))
#   p <- p + scale_x_datetime(#breaks = date_breaks("1 year"), format = "%Y",
#                             limits = c(min.datetime, max.datetime))
print(p)

# Let's look at score distribution by reviewer
scores.by.reviewer <- albums %>%
  select(reviewer, score) %>%
  group_by(reviewer) %>%
  filter(n() > 100)  # restrict to reviewers with over 100 reviews

ggplot(scores.by.reviewer, aes(x = score, colour = reviewer)) + 
  stat_density(alpha = 0, position = "identity") + guides(colour = FALSE) +
  scale_x_continuous("Score", breaks = seq(0, 10, by = 0.5)) + 
  scale_y_continuous("Density", breaks = seq(0, 0.8, by = 0.1)) +
  ggtitle("Density Estimates of Score By Reviewer (with >100 reviews)")


library(reshape2)
library(RColorBrewer)


## Let's look at score distribution by reviewer
tmp <- albums %>%
  select(reviewer, score) %>%
  group_by(reviewer) %>%
  filter(n() >= 100) %>%  # restrict to reviewers with over 100 reviews
  do(scores = table(factor(.$score, levels = rev(seq(0, 10, by = 0.1)))))

all.scores <- do.call(rbind, as.list(tmp$scores))
#all.scores <- all.scores / rowSums(all.scores)
scores.by.reviewer <- cbind.data.frame(tmp$reviewer, all.scores)[order(rowSums(all.scores), decreasing = TRUE), ]
rm(tmp)

scores.by.reviewer <- melt(scores.by.reviewer)
colnames(scores.by.reviewer) <- c("reviewer", "score", "count")

myPalette <- colorRampPalette(brewer.pal(9, "BuPu"), space="Lab")

zp1 <- ggplot(scores.by.reviewer,
              aes(x = score, y = reviewer, fill = count))
zp1 <- zp1 + geom_tile()
zp1 <- zp1 + scale_fill_gradientn(colours = myPalette(100))
zp1 <- zp1 + scale_x_discrete(expand = c(0, 0))
zp1 <- zp1 + scale_y_discrete(expand = c(0, 0))
zp1 <- zp1 + coord_equal()
zp1 <- zp1 + theme_bw()
print(zp1)


bins <- rep(0:9, each = 4) + seq(0, 0.8, by = 0.2)
tmp <- albums %>%
  select(reviewer, score) %>%
  group_by(reviewer) %>%
  filter(n() >= 100) %>%  # restrict to reviewers with over 100 reviews
  do(scores = table(cut(.$score, breaks = bins)))

all.scores <- do.call(rbind, as.list(tmp$scores))
all.scores <- all.scores / rowSums(all.scores)
scores.by.reviewer <- cbind.data.frame(tmp$reviewer, all.scores)[order(rowSums(all.scores), decreasing = TRUE), ]
rm(tmp)

scores.by.reviewer <- melt(scores.by.reviewer)
colnames(scores.by.reviewer) <- c("reviewer", "score", "count")

myPalette <- colorRampPalette(brewer.pal(9, "BuPu"), space="Lab")

zp1 <- ggplot(scores.by.reviewer,
              aes(x = score, y = reviewer, fill = count))
zp1 <- zp1 + geom_tile()
zp1 <- zp1 + scale_fill_gradientn(colours = myPalette(100))
zp1 <- zp1 + scale_x_discrete(expand = c(0, 0))
zp1 <- zp1 + scale_y_discrete(expand = c(0, 0))
zp1 <- zp1 + coord_equal()
zp1 <- zp1 + theme_bw()
print(zp1)
