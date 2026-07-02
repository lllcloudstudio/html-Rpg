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
<head>
    <meta charset="UTF-8">
    <!-- NOT VISIBLE <title>Download MySQL Query Result</title> -->
</head>
<body>
    <h2>Run SQL Query and Download CSV</h2>

<form action="http://127.0.0" method="GET"> <!-- http://127.0.0.1:8000/upload_csv -->
    <label for="csv_input">Enter comma delimited data:</label><br>
    <input type="text" id="csv_input" name="data" placeholder="value1,value2,value3">
    <button type="submit">Upload Data</button>
</form>


</body>
</html>
'
  return(html_content)
}

#* Upload comma-delimited text to MySQL Return HTML content
#* @param csv_input The comma-delimited string (e.g., "apple,banana,cherry")
#* @serializer csv
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
  dbWriteTable(con, name = "titanic_datasciencedojo", value = df, append = TRUE)
  
  return(list(
    status = "success", 
    message = paste("Successfully inserted", length(parsed_data), "items.")
  ))
}
