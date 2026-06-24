# plumber.R
library(plumber)
library(DBI)
library(RMySQL)

#* @apiTitle Dynamic Database Query API

#* Run a SQL query and return the table as JSON
#* @post /query
function(req, res) {
  body <- jsonlite::fromJSON(req$postBody)
  sql_query <- body$query
  
  # Connect to your MySQL database
  con <- dbConnect(RMySQL::MySQL(), 
                   dbname = "your_db_name",
                   host = "your_host",
                   user = "your_username",
                   password = "your_password")
  
  # Execute query (Basic error handling included)
  tryCatch({
    data <- dbGetQuery(con, sql_query)
    dbDisconnect(con)
    return(data)
  }, error = function(e) {
    dbDisconnect(con)
    res$status <- 500
    return(list(error = e$message))
  })
}
