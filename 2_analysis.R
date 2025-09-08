library(dplyr)
library(tidyr)
library(ggplot2)

ratings <- readRDS("ratings.rds")

# Basic checks
print(dim(ratings))
print(unique(ratings$rater))
print(unique(ratings$movie))

# table 
ratings_wide <- ratings %>%
  select(rater, movie, rating) %>%
  pivot_wider(names_from = movie, values_from = rating)

print(ratings_wide)

# Summaries by movie 
movie_summary <- ratings %>%
  group_by(movie) %>%
  summarise(
    n_ratings = n(),
    mean_rating = mean(rating, na.rm = TRUE),
    sd_rating = sd(rating, na.rm = TRUE)
  ) %>%
  arrange(desc(mean_rating))

print(movie_summary)

ratings_imputed <- ratings_wide
for (col in names(ratings_imputed)[-1]) {  # skip 'rater' column
  m <- movie_summary$mean_rating[movie_summary$movie == col]
  nas <- is.na(ratings_imputed[[col]])
  ratings_imputed[[col]][nas] <- m
}
print(ratings_imputed)

# Plo
par(mar = c(9, 4, 3, 1))  
barplot(
  height = movie_summary$mean_rating,
  names.arg = movie_summary$movie,
  las = 2,                
  ylab = "Average rating from 1 to 5",
  main = "Average Movie Ratings"
)

# Which movie is top?
best <- movie_summary[order(-movie_summary$mean_rating), ][1, ]
print(best)

# Export CSVs for submission
write.csv(ratings_wide, "ratings_wide.csv", row.names = FALSE)
write.csv(movie_summary, "movie_summary.csv", row.names = FALSE)

cat("Wrote ratings_wide.csv and movie_summary.csv\n")
