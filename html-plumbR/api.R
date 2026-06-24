
install.packages("plumber")
library(plumber)
library(DBI)
library(RPostgres)

#* @filter cors
function(res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  plumber::forward()
}

#* Get data from Postgres
#* @get /data
function() {
  con <- dbConnect(RPostgres::Postgres(), dbname="db", host="localhost", user="user", password="pwd")
  data <- dbGetQuery(con, "SELECT user_text FROM your_table")
  dbDisconnect(con)
  return(data) # Automatically converts R dataframe to JSON
}

# Run this API in R using: plumber::plumb("api.R")$run(port=8000)