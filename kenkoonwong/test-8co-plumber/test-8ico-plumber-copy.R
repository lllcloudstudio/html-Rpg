library(plumber)
library(DBI)
library(RMySQL)
library(tidyverse)
library(kableExtra)
library(knitr)
library(utils)
library(graphics)

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

<h2>Enter comma‑separated numeric values</h2>
<!-- label for <input> <select> <textarea> -->
<form id="upload-form" action="http://127.0.0.1:8000/Rplot" method="get">
  <label for="user-text">Description:</label>
  <input type="text" id="user-text" name="my_text" required>
  
  <label for="csv-file">Upload CSV:</label>
  <input type="text" id="csv-file" name="csv_file" required>
  
  <button type="submit">Submit</button>
</form>



<script>
document.getElementById("upload-form").addEventListener("submit", async (e) => {
  e.preventDefault();
  
  const form = e.target;
  const formData = new FormData(form);

  try {
    const response = await fetch("http://localhost:8000/upload", {
      method: "POST",
      body: formData
    });
    
    const result = await response.json();
    console.log(result);
  } catch (error) {
    console.error("Error:", error);
  }
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

library(RMariaDB)
#########################################
  # Connect to MySQL
  drv=MySQL()
  #con <- NULL # Initialize connection ?
  tryCatch({
    con <- dbConnect(
      drv,
      dbname   = extract_db_name(query), #sakila
      host     = "localhost",
      port     = 3306, #3306 db connection
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
library(RMariaDB)
  # Connect to MySQL
  drv=MySQL() #drv=MariaDB() #

  tryCatch({
    con <- dbConnect(
      drv,
      dbname   = extract_db_name(tableQuery), #sakila
      host     = "localhost",
      port     = 3306, #3306 connection sql
      user     = "root",
      password = "189999"
    )
    options(RMariaDB.warn=FALSE)
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


####################################################################### test-8isa-plumber.R

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
    parsed_data <- read_csv(I(csv_data)) # readr:: , show_col_types = FALSE
    #parsed_data <- read_delim(I(csv_data), delim = ",")
  }, error = function(e) {
    res$status <- 400
    return(list(status = "error", message = paste("Failed to parse CSV text:", e$message)))
  })

  print(parsed_data)


  #########################
con <- dbConnect(RSQLite::SQLite(), ":memory:")

dbWriteTable(con, clean_table_name, parsed_data)
dbReadTable(con, clean_table_name)

  #########################

  
  # 4. Connect to MySQL database
  con <- dbConnect(
    MySQL(),
    host     = "127.0.0.1",
    port     = 3306,
    username = "root",
    password = "189999",
    dbname   = "REFERENCE"
  )
  #on.exit(dbDisconnect(con))
  
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
####################################### ok--
### @parser form
### not html serializer
#* @post /Rplot
#* @serializer png
function(req, res) {
  # 1. Extract data sent from the HTML form
  #print(req)
  #print(res)
  num_points <- req$body$csv ###################################!
  plot_type <- req$body$myDropDown ###!
  print(num_points)
  print(plot_type)
  #stripchart(as.numeric(num_points))
  avector=unlist(strsplit(num_points,split=","))
  vector=as.numeric(avector)
  stripchart(vector)

}

#* @apiTitle Multipart Form Data Upload
#* @apiVersion 1.0

#* @post /upload
#* @parser multi
function(req, res) {
  #pr_set_debug()
  # Extract the text parameter

  text_data <- req$body$my_text
  file_info <- req$body$csv_file

  return(list(
    message = "Successfully received text and CSV",
    received_text = text_data
  ))
  
  # Check if file was provided
  if (is.null(file_info)) {
    res$status <- 400
    return(list(error = "No CSV file uploaded"))
  }
  
  # Read the raw file content from its temporary path
  df <- read.csv(file_info$datapath)
  print(df)
  num_points <- req$body$csv_file ###################################!
  plot_type <- req$body$my_text ###!
  print(num_points)
  print(plot_type)
  
  #stripchart(as.numeric(num_points))
  avector=unlist(strsplit(num_points,split=","))
  vector=as.numeric(avector)
  stripchart(vector)
  
  # Do processing here...


}
