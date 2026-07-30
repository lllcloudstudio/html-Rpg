library(plumber)
library(DBI)
library(RMySQL)

#* @get /tables
#* @post /tables
function() {
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
  
  # Return as a comma-separated string or JSON
  paste(tables, collapse = ", ")
}
