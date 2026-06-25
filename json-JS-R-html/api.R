# Install packages if needed
# install.packages(c("plumber", "DBI", "RSQLite", "jsonlite"))

library(plumber)
library(DBI)
library(RSQLite)
library(jsonlite)

# ---- Create sample SQLite DB ----
db_file <- "sample.db"
if (!file.exists(db_file)) {
  conn <- dbConnect(SQLite(), db_file)
  dbExecute(conn, "CREATE TABLE people (id INTEGER PRIMARY KEY, name TEXT, age INTEGER)")
  dbExecute(conn, "INSERT INTO people (name, age) VALUES 
                  ('Alice', 30), ('Bob', 25), ('Charlie', 35)")
  dbDisconnect(conn)
}

#* @apiTitle People Search API

#* Search people by name
#* @param name The name or partial name to search
#* @get /search
function(name = "") {
  tryCatch({
    conn <- dbConnect(SQLite(), db_file)
    query <- "SELECT * FROM people WHERE name LIKE ?"
    res <- dbGetQuery(conn, query, params = paste0("%", name, "%"))
    dbDisconnect(conn)
    return(toJSON(res, pretty = TRUE, auto_unbox = TRUE))
  }, error = function(e) {
    return(toJSON(list(error = e$message)))
  })
}
