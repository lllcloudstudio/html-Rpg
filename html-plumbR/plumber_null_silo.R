# plumber.R
library(plumber)
library(DBI)
library(RMySQL)

#* @apiTitle Dynamic Database Query API

#* Run a SQL query and return the table as JSON
#* @post /query
function(req, res) { # NO NULL
  body <- jsonlite::fromJSON(req$postBody)
  sql_query <- body$query
  drv=MySQL()
  # Connect to your MySQL database
  con <- dbConnect(drv, 
                   dbname = "reference",
                   host = "127.0.0.1",
                   user = "root",
                   password = "189999")
  
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
