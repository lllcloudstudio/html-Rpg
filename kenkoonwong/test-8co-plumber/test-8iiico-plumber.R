library(plumber)
library(DBI)
library(RMySQL)
library(tidyverse)
library(kableExtra)
library(knitr)
library(utils)
library(graphics)
library(shiny)

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
    <style>
        body { font-family: system-ui, sans-serif; margin: 40px; background: #f9f9f9; }
        button { background: #007bff; color: white; border: none; padding: 10px 20px; border-radius: 4px; cursor: pointer; font-size: 16px; }
        button:hover { background: #0056b3; }
        .table-box { background: white; padding: 15px; border-radius: 6px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); margin-top: 20px; }
        table { border-collapse: collapse; width: 100%; margin-top: 10px; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
  <title>Plumber + Shiny</title>
</head>
<body>
    <h1>Run SQL Query and Download CSV</h1>


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



    <script>
    // import {DataTable} from "simple-datatables";
    document.getElementById("viewTable").addEventListener("click", function() {
    const tableQuery = document.getElementById("sqlQuery").value.trim();
    const encodedTableQuery = encodeURIComponent(tableQuery);
    // ? download to downloadtablequery?
    window.location.href = `http://localhost:8000/downloadtablequery?tableQuery=${encodedTableQuery}`;
    });
    </script>



    <h1>CSV text area Upload to MySQL</h1>
    <form action="http://127.0.0.1:8000/upload" method="get">
        <!-- Input for the MySQL Table Name -->
        <label for="table_id">Desired MySQL Table Name:</label><br>
        <input type="text" id="table_id" name="table_id" required placeholder="e.g., customer_logs"><br><br>
        
        <!-- Input for the CSV text -->
        <label for="csv_data">Paste Comma-Delimited Data (Include Headers):</label><br>
        <textarea id="csv_data" name="csv_data" rows="10" cols="50" required placeholder="name,age,city&#10;Alice,30,New York&#10;Bob,25,London"></textarea>
        <br><br>
        
        <input type="submit" value="Create Table in MySQL">
    </form>




<!-- -->
    <h1>File Upload (CSV) to MySQL</h1>
    <form action="http://127.0.0.1:8000/upload2" method="get">
        <!-- Input for the MySQL Table Name -->
        <label for="table_id2">Desired MySQL Table Name:</label><br>
        <input type="text" id="table_id2" name="table_id2" required placeholder="e.g., customer_logs"><br><br>
        
        <!-- Input for the CSV text -->
        <label for="csv_data2">Paste Comma-Delimited Data (Include Headers):</label><br>
        <input type="file" id="csv_data2" name="csv_data2">
        <br><br>
        <input type="submit" value="File Upload">
    </form>

<h1>Optional</h1> <!-- form = ? -->
<input type="file" id="fileUpload1" />
<button onclick="displayFilename()">Get Filename</button>
<p id="filenameDisplay1"></p>

<script>
  function displayFilename() {
    const fileUpload1 = document.getElementById("fileUpload1");
    const filenameDisplay1 = document.getElementById("filenameDisplay1");

    if (fileUpload1.value) {
      filenameDisplay1.textContent = "Selected Filename: " + fileUpload1.value;
    } else {
      filenameDisplay1.textContent = "No file selected.";
    }
  }
</script>

<form action="http://127.0.0.1:8000/submitHtml" method="POST"> <!-- sugg. use of filter cors Method not allowed -->
  <label for="html_content">Enter your HTML tags below:</label><br><br>
  
  <!— Use textarea to allow multi-line HTML code inputs —>
  <textarea id="html_content" name="html_content" rows="6" cols="50">
<div>
  <p>This is a paragraph inside a div.</p>
</div>
  </textarea>
  
  <br><br>
  <button type="submit">Send HTML via POST</button>
</form>









  <!--<div>-->
  <form id="playDrawDataSimulator" action="https://127.0.0.1:8000/playDrawDataSimulator" method="get">
  <!-- <iframe id="shiny-container" src="https://127.0.0.1:8081"></iframe>-->
  <input type="submit" value="Play Draw Data Simulator">
  <!-- <button onclick="playDrawDataSimulator()"> Draw Plot </button>-->
  </form>
  <!--</div>-->

<script>
</script>











    <h1>Vector data Plot </h1>
    <form action="http://127.0.0.1:8000/generate_plot" method="get">
 
<label for="plot_type2">Distribution Shape:</label>
<select id="plot_type2" name="plot_type2">
  <option value="" disabled selected> Select a choice ...</option>
  <option value="hist">Histogram</option>
  <option value="scatter">Scatter Plot</option>
  <option value="line">Line Plot</option>
  <option value="density">Density Plot</option>
  <option value="boxplot">Boxplot</option>
  <option value="stripchart">Stripchart</option>   
</select>
<br><br>
     
        <!-- Input for the CSV text -->
        <label for="csv_values2">Paste Comma-Delimited Data (Include Headers):</label><br>
        <textarea id="csv_values2" name="csv_values2" rows="10" cols="50" required placeholder="10,30,10,25"></textarea>
        <br><br>
        
        <input type="submit" value="Create R Plot">
    </form>





<form id="contactForm">
    <div>
      <label for="name">Name:</label>
      <input type="text" id="name" name="name" required>
    </div>
    <div>
      <label for="email">Email:</label>
      <input type="email" id="email" name="email" required>
    </div>
    <div>
      <label for="message">Message:</label>
      <textarea id="message" name="message" required></textarea>
    </div>
    <button type="submit">Send Message</button>
  </form>
  <!-- For feedback messages -->
  <div id="formMessage" style="margin-top: 20px;"></div>
 
  <script src="script.js"></script>









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

  # Connect to MySQL
  drv=MySQL()
  #con <- NULL # Initialize connection ?
  tryCatch({
    con <- dbConnect(
      drv,
      dbname   = extract_db_name(tableQuery), #sakila
      host     = "localhost",
      port     = 3306, #3306 connection sql
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

####################################################################
####################################################################
####################################################################
library(plumber)

#* Generate a plot based on the dropdown type and comma-separated values
#* @param plot_type2 Dropdown selection ("scatter", "line", or "histogram")
#* @param csv_values2 Comma-separated numeric values (e.g., "10,15,20,25,30")
#* @get /generate_plot
#* @serializer png
function(plot_type2 = "scatter", csv_values2 = "") {
  
  # 1. Parse the comma-separated string into a numeric vector
  vals <- as.numeric(unlist(strsplit(csv_values2, ",")))
  
  # 2. Handle missing or invalid inputs gracefully
  if (length(vals) == 0 || any(is.na(vals))) {
    plot.new()
    text(0.5, 0.5, "Invalid or empty input provided.", col = "red")
    return()
  }
  
  # 3. Create indices for X-axis (1 to N)
  x_vals <- seq_along(vals)
  
  # 4. Generate the plot based on dropdown selection
  if (plot_type2 == "scatter") {
    plot(x_vals, vals, main = "Scatter Plot", xlab = "Index", ylab = "Value", 
         pch = 19, col = "blue", type = "p", 
         xlim = c(0.5, length(vals) + 0.5))
         
  } else if (plot_type2 == "line") {
    plot(x_vals, vals, main = "Line Chart", xlab = "Index", ylab = "Value", 
         col = "red", type = "l", lwd = 3.3,lty=2,cex=2.3,# ,
         xlim = c(0.5, length(vals) + 0.5))
         ######################
  } else if (plot_type2 == "hist") {
    from=min(vals)
    to=max(vals)
    by=max(vals)/length(vals) # length.out=sum(vals)/length(vals)
    brks=seq(from,to,by)
    hist(vals,breaks=brks, main = "Histogram", xlab = "Value", col = "lightblue", 
         border = "black")
    abline(v=c(mean(vals),median(vals)),lty=c(2,3),lwd=2)
    legend("topright",legend=c("mean","median"),lty=c(2,3),lwd=2)
  } else if (plot_type2 == "density"){
    dens <- density(vals)

  # Plot density curve
  plot(dens,
     main = "Density Plot (Base R)",
     xlab = "Value",
     ylab = "Density",
     col = "blue",
     lwd = 3)

  # Add a rug plot to show actual data points
  rug(vals, col = "darkgray")

  }
    else if (plot_type2 == "stripchart"){
      stripchart(vals)
    }
    else if (plot_type2 == "boxplot"){
      boxplot(vals)
    }
    else {
    plot.new()
    text(0.5, 0.5, "Unknown plot type.", col = "red")
  }
}













####################################################################
####################################################################
####################################################################

#* Dynamic file upload a table in mySQL via GET Form Action
#* @param table_id2:string The name of the MySQL table to create or update
#* @param csv_data2:string The raw CSV text string
#* @get /upload2
#* @serializer json
function(table_id2 = "", csv_data2 = "", res) {# prints text
 #cat(table_id2,csv_data2)
 #cat("Original filename:", file_info$filename, "\n")
 
  # 1. Validate inputs are not empty
  if (nchar(trimws(table_id2)) == 0 || nchar(trimws(csv_data2)) == 0) {
    res$status <- 400
    return(list(status = "error", message = "Both Table Name and CSV data fields are required."))
  }
  
  # 2. Sanitize the table name to prevent SQL Injection
  # Removes any characters that are not alphanumeric or underscores
  clean_table_name <- gsub("[^a-zA-Z0-9_]", "", table_id2)
  if (nchar(clean_table_name) == 0) {
    res$status <- 400
    return(list(status = "error", message = "Invalid table name. Use only letters, numbers, and underscores."))
  }
  
  # 3. Parse the comma-delimited text into an R Data Frame
  tryCatch({

   parsed_data <- read_csv(I(csv_data2)) # 0 rows
    #parsed_data <- read_csv(I(csv_data2),col_names=TRUE) #0 rows
   #parsed_data <- read_csv() 
  }, error = function(e) {
    res$status <- 400
    return(list(status = "error", message = paste("Failed to parse CSV text:", e$message)))
  })

 #print(parsed_data)
 #parsed_data


  #########################
#con <- dbConnect(RSQLite::SQLite(), ":memory:")

#dbWriteTable(con, clean_table_name, parsed_data)
#dbReadTable(con, clean_table_name)

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
  #if (nrow(my_df) == 0) stop("No data to insert")
  dbExistsTable(con, clean_table_name)
  # 5. Dynamically write data as a table to MySQL
  tryCatch({
    dbWriteTable(
      conn = con, 
      name = clean_table_name,     # Dynamic table name from the form input
      value = parsed_data, 
      #append=TRUE, # or overwrite=TRUE,   
            # Use append=TRUE to add rows, or overwrite=TRUE to drop and recreate the table
      row.names = FALSE,
      overwrite=TRUE,# ok--
      verbose=TRUE#,field.types=TRUE
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



#* @get /playDrawDataSimulator
##### addition not compatible with runApp command line 675
#* @shiny /app/
#shiny::runApp("/Users/aflac/Downloads/app.R",port=3838,launch.browser=FALSE) # port 3838 8080 8081

# Error use plumber2: see /Users/aflac/Downloads/app.R
# Error in throw_if_func_is_not_a_function(private$func) : 
# `expr` did not evaluate to a function





#* Receive HTML tags from a web form
#* @param html_content The raw HTML string submitted by the user
#* @post /submitHtml
function(html_content = "") {
  # html_content will contain the raw string: "<div>\n  <p>...</p>\n</div>"
  
  # Example: Clean, parse, or log the tags safely
  message("Received HTML payload: ", html_content)
  
  list(
    status = "Success",
    received_length = nchar(html_content),
    preview = html_content
  )
}