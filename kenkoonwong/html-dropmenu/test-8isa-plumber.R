library(plumber)
library(DBI)
library(RMariaDB)
library(DBI)
library(RMySQL)
library(tidyverse)
library(kableExtra)
library(knitr)
library(utils)

#* @apiTitle 
#* @apiDescription

#* Return HTML content
#* @get /
#* @serializer html

function() {
  # Return HTML code with the log button
html_content <- '
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Dynamic MySQL Table Creator</title>
</head>
<body>
    <h2>Upload Comma-Delimited Data as a Table</h2>
    
    <form action="http://127.0.0.1:8000/upload" method="get">
        <!-- Input for the MySQL Table Name -->
        <label for="table_id">Desired MySQL Table Name:</label><br>
        <input type="text" id="table_id" name="table_id" required placeholder="e.g., customer_logs"><br><br>
        
        <!-- Input for the CSV text -->
        <label for="csv_data">Paste Comma-Delimited Data (Include Headers):</label><br>
        <textarea id="csv_data" name="csv_data" rows="10" cols="50" required placeholder="name,age,city&#10;Alice,30,New York&#10;Bob,25,London"></textarea>
        <br><br>
        
        <input type="submit" value="Create / Update Table in MySQL">
    </form>
</body>
</html>
'
  return(html_content)
}


#* Dynamically add/create a table in MySQL via GET Form Action
#* @param table_id:string The name of the MySQL table to create or update
#* @param csv_data:string The raw CSV text string
#* @get /upload
#* @serializer json
function(table_id = "", csv_data = "", res) {
  print(table_id)
  print(csv_data)

  # 1. Validate inputs are not empty
  if (nchar(trimws(table_id)) == 0 || nchar(trimws(csv_data)) == 0) {
    res$status <- 400
    return(list(status = "error", message = "Both Table Name and CSV data fields are required."))
  }
  
  # 2. Sanitize the table name to prevent SQL Injection
  # Removes any characters that are not alphanumeric or underscores
  clean_table_name <- gsub("[^a-zA-Z0-9_]", "", table_id)
  if (nchar(clean_table_name) == 0) {
    res$status <- 400
    return(list(status = "error", message = "Invalid table name. Use only letters, numbers, and underscores."))
  }
  
  # 3. Parse the comma-delimited text into an R Data Frame
  tryCatch({
    parsed_data <- readr::read_csv(csv_data, show_col_types = FALSE)
  }, error = function(e) {
    res$status <- 400
    return(list(status = "error", message = paste("Failed to parse CSV text:", e$message)))
  })
  
  # 4. Connect to MySQL database
  con <- dbConnect(
    RMariaDB::MariaDB(),
    host     = "127.0.0.1",
    port     = 3306,
    username = "root",
    password = "189999",
    dbname   = "REFERENCE"
  )
  on.exit(dbDisconnect(con))
  
  # 5. Dynamically write data as a table to MySQL
  tryCatch({
    dbWriteTable(
      conn = con, 
      name = clean_table_name,     # Dynamic table name from the form input
      value = parsed_data, 
      append = TRUE,               # Use append=TRUE to add rows, or overwrite=TRUE to drop and recreate the table
      row.names = FALSE
    )
    
    return(list(
      status = "success", 
      message = paste0("Successfully written data to table '", clean_table_name, "'. Rows inserted: ", nrow(parsed_data))
    ))
    
  }, error = function(e) {
    res$status <- 500
    return(list(status = "error", message = paste("MySQL Table generation failed:", e$message)))
  })
}

