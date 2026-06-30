library(plumber)
library(dplyr)
library(DBI)
library(RMySQL)
library(tidyverse)
library(kableExtra)
library(knitr)
library(utils)
library(httr)
library(DBI)
library(RSQLite)
library(readr)



#* @apiTitle 
#* @apiDescription

#* Return HTML content
#* @get /
#* @serializer html

function() {
  # Return HTML code with the log button
html_content <- '
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Download MySQL Query Result</title>
</head>
<body>
    <h2>Run SQL Query and Download CSV</h2>
    <input type="text" id="sqlQuery" placeholder="Enter SQL query" style="width:400px;">
    <button id="downloadBtn">Download CSV</button> 
    <button id= "viewTable" onclick="executeQuery"> View Table </button> <!-- not id="sqlQuery" -->

    <style>
      body { font-family: Arial, sans-serif; margin: 40px; background: #f4f4f9; }
      .container { max-width: 500px; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
      h2 { color: #333; }
      input[type=file] { margin: 20px 0; display: block; }
      button { background: #007bff; color: white; border: none; padding: 10px 20px; border-radius: 4px; cursor: pointer; }
      button:hover { background: #0056b3; }
    </style>

<!-- No button 1132 6/30:     <input type="text" id="uploaded_file_path" placeholder="Enter path to file" style="width:400px;">  --> 

<input type="file" id="fileUpload" >
<button id="fileUploadBtn" type=‘submit’>Upload and Save</button> <!-- Not nece. a button -->

<script>document.getElementById("fileUploadBtn").addEventListener("click", function() {
  if (fileInput.files.length > 0) {
    const file = fileInput.files[0];
    const reader = new FileReader();
    reader.onload = function(e) {
      const fileContent = e.target.result;
      console.log("File Content:", fileContent);
    };
    reader.readAsText(file);
  }
 });</script>


    <div class=‘container’>
      <h2>Upload CSV to Database</h2>
      <!— The enctype attribute is mandatory for file uploads —>
      <form action=‘/upload’ method=‘POST’ enctype=‘multipart/form-data’>
        <label for=‘csv_file’>Select a CSV file:</label>
        <input type=‘file’ id=‘csv_file’ name=‘file’ accept=‘.csv’ required />
        <button id="uploadBtn" type=‘submit’>Upload and Save</button>
      </form>
    </div>

<!-- path/to/file/upload not sqlQuery-->
    <script>
        document.getElementById("uploadBtn").addEventListener("click", function() {
            const file_0_contents = document.getElementById("sqlQuery").value.trim(); <!-- -->
        });
    </script>

    <script>
        document.getElementById("downloadBtn").addEventListener("click", function() {
            // 
            const query = document.getElementById("sqlQuery").value.trim();
            // Encode query for URL
            const encodedQuery = encodeURIComponent(query);
            // Trigger file download
            window.location.href = `http://localhost:8000/download?query=${encodedQuery}`;
        });
    </script>

    <script>
    // import {DataTable} from "simple-datatables";
    document.getElementById("viewTable").addEventListener("click", function() {
    const tableQuery = document.getElementById("sqlQuery").value.trim();
    const encodedTableQuery = encodeURIComponent(tableQuery);
    // ? download to downloadtablequery?
    window.location.href = `http://localhost:8000/downloadtablequery?tableQuery=${encodedTableQuery}`;
    });
    </script>


    <input type="text" id="csv_data" placeholder="Enter Comma Separated Values" style="width:600px;">







</body>
</html>
'
  return(html_content)
}

#* @get /download
#* @param query The SQL query to run
#* @serializer contentType list(type="text/csv")
function(query = "") {
#########################################
# Function to extract database name after 'USE ' until first semicolon
extract_db_name <- function(query) {
  # Validate input
  if (!is.character(query) || length(query) != 1) {
    stop("Input must be a single character string containing the SQL query.")
  }
  # Use regex: (?i) for case-insensitive, lookbehind for 'USE ', stop at first semicolon
  match <- regexpr("(?i)(?<=USE\\s)[^;]+", query, perl = TRUE)
  if (match == -1) {
    return(NA)  # No match found
  }
  
  # Extract and trim whitespace
  db_name <- trimws(regmatches(query, match))
  
  return(db_name)
}

# Function to extract everything after the first semicolon in a SQL query
extract_after_first_semicolon <- function(query) {
  # Validate input
  if (!is.character(query) || length(query) != 1) {
    stop("Input must be a single character string.")
  }
  
  # Find the position of the first semicolon
  semicolon_pos <- regexpr(";", query, fixed = TRUE)
  
  # If no semicolon found, return an empty string
  if (semicolon_pos == -1) {
    return("")
  }
  
  # Extract substring after the first semicolon
  result <- substr(query, semicolon_pos + 1, nchar(query))
  
  # Trim leading/trailing whitespace
  result <- trimws(result)
  
  return(result)
}
#########################################


#readRenviron("/Users/aflac/Documents/GitHub/.env")


#########################################
  # Connect to MySQL
  drv=MySQL()
  #con <- NULL # Initialize connection ?
  tryCatch({
    con <- dbConnect(
      drv,
      dbname   = extract_db_name(query), #sakila
      host     = "localhost",
      port     = 3306,
      user     = "root",
      password = "189999"
    )

#con=dbConnect(
  #drv,
  #host=Sys.getenv("DB_HOST"),
  #port=Sys.getenv("DB_PORT"),
  #user=Sys.getenv("DB_USER"),
  #password=Sys.getenv("DB_PASSWORD"),
  #dbname=Sys.getenv("DB_NAME")
#)
    
    # Run query
    df <- dbGetQuery(con, extract_after_first_semicolon(query)) # query

    ## review class and type non-functional
    #html_table=knitr::kable(df,"html",data.attr = 'id="myTable"')
    #html_table
    # return(as.character(html_table)) # as.character() returns download as .csv not .html (fix) and id not at the top of the table
    #return(html_table)

    # Convert to CSV in memory
    tmp <- tempfile(fileext = ".csv")
    write.csv(df, tmp, row.names = FALSE)
    
    # Return CSV as raw bytes
    readBin(tmp, "raw", n = file.info(tmp)$size)
    
  }, error = function(e) { # !!!!
    msg <- paste("Error:", e$message)
    return(charToRaw(msg))
  }, finally = {
    if (!is.null(con)) dbDisconnect(con)
  })
}

# instead /html at line 148, #* @get /downloadtablequery 
#* @get /downloadtablequery 
#* @param tableQuery The SQL query to run
#* @serializer contentType list(type="text/html")

function(tableQuery = "") {
#########################################
# Function to extract database name after 'USE ' until first semicolon
extract_db_name <- function(tableQuery) {
  # Validate input
  if (!is.character(tableQuery) || length(tableQuery) != 1) {
    stop("Input must be a single character string containing the SQL query.")
  }
  
  # Use regex: (?i) for case-insensitive, lookbehind for 'USE ', stop at first semicolon
  match <- regexpr("(?i)(?<=USE\\s)[^;]+", tableQuery, perl = TRUE)
  
  if (match == -1) {
    return(NA)  # No match found
  }
  
  # Extract and trim whitespace
  db_name <- trimws(regmatches(tableQuery, match))
  
  return(db_name)
}

# Function to extract everything after the first semicolon in a SQL query
extract_after_first_semicolon <- function(tableQuery) {
  # Validate input
  if (!is.character(tableQuery) || length(tableQuery) != 1) {
    stop("Input must be a single character string.")
  }
  
  # Find the position of the first semicolon
  semicolon_pos <- regexpr(";", tableQuery, fixed = TRUE)
  
  # If no semicolon found, return an empty string
  if (semicolon_pos == -1) {
    return("")
  }
  
  # Extract substring after the first semicolon
  result <- substr(tableQuery, semicolon_pos + 1, nchar(tableQuery))
  
  # Trim leading/trailing whitespace
  result <- trimws(result)
  
  return(result)
}

  # Connect to MySQL
  drv=MySQL()
  #con <- NULL # Initialize connection ?
  tryCatch({
    con <- dbConnect(
      drv,
      dbname   = extract_db_name(tableQuery), #sakila
      host     = "localhost",
      port     = 3306,
      user     = "root",
      password = "189999"
    )
    
    # Run query
    df <- dbGetQuery(con, extract_after_first_semicolon(tableQuery)) # query

    ## review class and type non-functional
    #html_table=knitr::kable(df,format="html", attr="id='id_1'")# table.attr = "class='table'")
    html_table=kable(df, format="html", table.attr="id='id_1'")
    #print(html_table) to R console
    #return(as.character(html_table)) # as.character() returns download as .csv not .html (fix) and id not at the top of the table
    return(html_table) # similar to ^^

    # Convert to CSV in memory
    tmp <- tempfile(fileext = ".csv")
    write.csv(df, tmp, row.names = FALSE)
    
    # Return CSV as raw bytes
    readBin(tmp, "raw", n = file.info(tmp)$size)
    
  }, error = function(e) { # !!!!
    msg <- paste("Error:", e$message)
    return(charToRaw(msg))
  }, finally = {
    if (!is.null(con)) dbDisconnect(con)
  })
}

####################################################################################

# Create/connect to SQLite DB (replace with MySQL/Postgres if needed)
#con <- dbConnect(RSQLite::SQLite(), "data_store.sqlite")
#con <- dbConnect(RSQLite::SQLite(), ":memory:")

# Ensure table exists (adjust schema to your CSV structure)
#dbExecute(con, "
#CREATE TABLE IF NOT EXISTS my_table (
    #id INTEGER PRIMARY KEY AUTOINCREMENT,
    #col1 TEXT,
    #col2 TEXT,
    #col3 TEXT
#)")

#* Upload CSV and save to DB
#* @param file The CSV file to upload
#* @post file
#* @serializer contentType list(type="text/html")
function(file) {
  tryCatch({
    # Save uploaded file temporarily
    tmp_path <- tempfile(fileext = ".csv")
    file.copy(file$datapath, tmp_path, overwrite = TRUE)
    print(file)
    print(file.copy(file$datapath, tmp_path, overwrite = TRUE))

    # Read CSV into R
    df <- read_csv(tmp_path, show_col_types = FALSE)

    # Validate columns (adjust as needed)
    #required_cols <- c("col1", "col2", "col3")
    #if (!all(required_cols %in% names(df))) {
      #stop("CSV missing required columns: ", paste(setdiff(required_cols, names(df)), collapse = ", "))
    #}

    # Insert into DB
    dbWriteTable(con, "my_table", df, append = TRUE, row.names = FALSE)

    # Optional: Call PHP script after saving
    php_url <- "https://example.com/action.php"
    res <- httr::POST(php_url, body = list(status = "success"), encode = "form")

    list(
      status = "success",
      rows_inserted = nrow(df),
      php_response = httr::content(res, as = "text")
    )
  }, error = function(e) {
    list(status = "error", message = e$message)
  })
}
