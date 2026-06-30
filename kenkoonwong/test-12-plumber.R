library(plumber)
library(DBI)
library(RMySQL)
library(readr)



#* @apiTitle CSV Upload API
#* @apiDescription Upload a CSV file and save its contents to MySQL.
drv=MySQL()
# Database connection function
connect_db <- function() {
  tryCatch({
    dbConnect(
      drv,
      dbname   = "REFERENCE",
      host     = "localhost",
      port     = 3306,
      user     = "root",
      password = "189999"
    )
  }, error = function(e) {
    stop("Database connection failed: ", e$message)
  })
}

#* Upload CSV and insert into MySQL
#* @param file:file The CSV file to upload
#* @post /upload
function(file) {
  # Validate file input
  if (is.null(file) || file$size == 0) {
    return(list(error = "No file uploaded or file is empty."))
  }
  
  # Read CSV safely
  df <- tryCatch({
    read_csv(file$datapath, show_col_types = FALSE)
  }, error = function(e) {
    return(list(error = paste("Failed to read CSV:", e$message)))
  })
  
  if (is.list(df) && !is.data.frame(df)) {
    return(df) # Return error from above
  }
  
  # Connect to DB
  con <- connect_db()
  on.exit(dbDisconnect(con), add = TRUE)
  
  # Insert into MySQL
  tryCatch({
    dbWriteTable(con, "new_table", df, append = TRUE, row.names = FALSE) # your_table not new_table
    list(status = "success", rows_inserted = nrow(df))
  }, error = function(e) {
    list(error = paste("Database insert failed:", e$message))
  })
}
