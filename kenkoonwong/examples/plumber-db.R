library(plumber)
library(DBI)
library(RMySQL)

#* Enable CORS so your frontend can talk to the API
#* @filter cors
function(res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  forward()
}

#* Get list of tables
#* @get /tables
#* @serializer text
function(db_name = "reference") { # default since no form to specify ok-- now input to just reference
  # Connect to the database specified in the GET query
  drv=MySQL()
  con <- dbConnect(
    drv,
    host     = "127.0.0.1",
    port     = 3306,
    username = "root",
    password = "189999",
    dbname   = "reference"
  )
  tables <- dbListTables(con)
  dbDisconnect(con)
  
  if (length(tables) == 0) {
    return("No tables found in this database.")
  }
  
  # Return tables as a clean comma-separated string
  paste(tables, collapse = ", ")
}
