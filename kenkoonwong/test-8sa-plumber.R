library(plumber)
library(DBI)
library(RMariaDB)

#* Upload comma-delimited text to MySQL
#* @param data The comma-delimited string (e.g., "apple,banana,cherry")
#* @get /upload_csv
function(data) {
  # 1. Split the comma-separated string into a vector
  parsed_data <- unlist(strsplit(data, ","))
  
  # Create a data frame (adjust column names to match your table)
  df <- data.frame(item = parsed_data, stringsAsFactors = FALSE)
  
  # 2. Connect to the MySQL database
  con <- dbConnect(
    MySQL(),
    dbname = "REFERENCE",
    host = "127.0.0.1",
    port = 3306,
    user = "root",
    password = "189999"
  )
  
  # Ensure connection closes when the function exits
  on.exit(dbDisconnect(con))
  
  # 3. Write data to the table
  dbWriteTable(con, name = "your_table_name", value = df, append = TRUE)
  
  return(list(
    status = "success", 
    message = paste("Successfully inserted", length(parsed_data), "items.")
  ))
}
