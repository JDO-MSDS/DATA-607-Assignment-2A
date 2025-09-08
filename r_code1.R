library(DBI)
library(RPostgres)
library(dplyr)
library(tidyr)
library(ggplot2)


host <- "localhost"
port <- 5432
dbname <- "data607_assignment2A"  
user <- "postgres"         

#i am not sure about this
pwd <- Sys.getenv("PGPASSWORD", "")
if (pwd == "") {
  if (!requireNamespace("askpass", quietly = TRUE)) install.packages("askpass")
  pwd <- askpass::askpass("Postgres password")
}


# Connect
con <- dbConnect(
  Postgres(),
  host = host,
  port = port,
  dbname = dbname,
  user = user,
  password = password
)


dbGetQuery(con, "
  SELECT table_name
  FROM information_schema.tables
  WHERE table_schema = 'movieratings'
  ORDER BY table_name;
")

# Pull the ratings view into R
ratings <- dbGetQuery(con, "
  SELECT rater, movie, release_year, rating, rated_at
  FROM movieratings.v_ratings
  ORDER BY rater, movie;
")

# Peek
print(head(ratings))

# Save for the analysis script
saveRDS(ratings, file = "ratings.rds")

# Disconnect
dbDisconnect(con)

cat('Saved ratings to ratings.rds\n')
