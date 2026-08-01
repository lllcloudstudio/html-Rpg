library(plumber)
library(DBI)
library(RMySQL)
library(tidyverse)

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

    <script>
        document.getElementById("downloadBtn").addEventListener("click", function() {
            const query = document.getElementById("sqlQuery").value.trim();
            <!-- if (!query) {
                alert("Please enter a SQL query.");
                return;
            } eh not necessary where check? and error check at lines 85-91 at -->
            // Encode query for URL
            const encodedQuery = encodeURIComponent(query);
            // Trigger file download
            window.location.href = `http://localhost:8000/download?query=${encodedQuery}`;
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
  # Validate query
  #if (query == "") {
    #res <- "Error: No query provided."
    #return(charToRaw(res))
  #}
  
  # Prevent dangerous queries (basic check): eh not necessary
  #if (!grepl("^\\s*SELECT\\s", query, ignore.case = TRUE)) {
    #res <- "Error: Only SELECT queries are allowed."
    #return(charToRaw(res))
  #}
  
  # Connect to MySQL
  drv=MySQL()
  #con <- NULL # Initialize connection ?
  tryCatch({
    con <- dbConnect(
      drv,
      dbname   = "sakila",
      host     = "localhost",
      port     = 3306,
      user     = "root",
      password = "189999"
    )
    
    # Run query
    df <- dbGetQuery(con, query)
    
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

