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


    <style>
      body { font-family: Arial, sans-serif; margin: 40px; background: #f4f4f9; }
      .container { max-width: 500px; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
      h2 { color: #333; }
      input[type=file] { margin: 20px 0; display: block; }
      button { background: #007bff; color: white; border: none; padding: 10px 20px; border-radius: 4px; cursor: pointer; }
      button:hover { background: #0056b3; }
    </style>

<!-- file POST -->
<input type="file" id="file" >
<button id="filefileUploadBtn" type=‘submit’>Upload and Save</button> <!-- Not nece. a button -->



<!-- csv_file POST-->
    <div class=‘container’>
      <h2>Upload CSV to Database</h2>
      <!— The enctype attribute is mandatory for file uploads —>
      <form action=‘/upload’ method=‘POST’ enctype=‘multipart/form-data’>
        <label for=‘csv_file’>Select a CSV file:</label>
        <input type=‘file’ id=‘csv_file’ name=‘file’ accept=‘.csv’ required />
        <button id="csv_fileuploadBtn" type=‘submit’>Upload and Save</button>
      </form>
    </div>


</body>
</html>
'
  return(html_content)
}


#* @apiTitle CSV Upload and Table Print API

#* Upload CSV and return HTML table with page break
#* @param file The CSV file to upload
#* @post /upload
function(file) {
  tryCatch({
    # Validate file
    if (is.null(file) || file$size == 0) {
      return(list(error = "No file uploaded or file is empty."))
    }
    
    # Read CSV
    df <- read_csv(file$datapath, show_col_types = FALSE)
    
    # Create HTML table with page break before it
    html_table <- df %>%
      kable("html", escape = TRUE) %>%
      kable_styling(full_width = FALSE) %>%
      add_header_above(c(" " = ncol(df))) %>%
      as.character()
    
    # Add CSS for page break
    html_output <- paste0(
      "<html><head><style>
       @media print { .page-break { page-break-before: always; } }
       </style></head><body>
       <div class='page-break'></div>",
      html_table,
      "</body></html>"
    )
    
    # Return HTML
    plumber::as_html(html_output)
    
  }, error = function(e) {
    list(error = paste("Processing failed:", e$message))
  })
}








#* @apiTitle CSV Upload and Table Print API

#* Upload CSV and return HTML table with page break
#* @param csv_file The CSV file to upload
#* @post /upload
function(file) {
  tryCatch({
    # Validate file
    if (is.null(file) || file$size == 0) {
      return(list(error = "No file uploaded or file is empty."))
    }
    
    # Read CSV
    df <- read_csv(file$datapath, show_col_types = FALSE)
    
    # Create HTML table with page break before it
    html_table <- df %>%
      kable("html", escape = TRUE) %>%
      kable_styling(full_width = FALSE) %>%
      add_header_above(c(" " = ncol(df))) %>%
      as.character()
    
    # Add CSS for page break
    html_output <- paste0(
      "<html><head><style>
       @media print { .page-break { page-break-before: always; } }
       </style></head><body>
       <div class='page-break'></div>",
      html_table,
      "</body></html>"
    )
    
    # Return HTML
    plumber::as_html(html_output)
    
  }, error = function(e) {
    list(error = paste("Processing failed:", e$message))
  })
}