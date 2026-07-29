library(plumber)
library(DBI)
library(RMariaDB)
library(knitr)
library(RMySQL)

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
    <title>MySQL Tables Viewer</title>
    <!-- Load htmx to handle ajax swaps without writing JavaScript -->
    <script src="https://unpkg.com"></script>
    <style>
        body { font-family: system-ui, sans-serif; margin: 40px; background: #f9f9f9; }
        button { background: #007bff; color: white; border: none; padding: 10px 20px; border-radius: 4px; cursor: pointer; font-size: 16px; }
        button:hover { background: #0056b3; }
        .table-box { background: white; padding: 15px; border-radius: 6px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); margin-top: 20px; }
        table { border-collapse: collapse; width: 100%; margin-top: 10px; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>

    <h1>Database Dashboard</h1>
    
    <!-- This triggers a POST request to Plumber and targets the <p> tag below -->
    <button hx-post="http://localhost:8000/fetch_tables" hx-target="#table-container">
        Load MySQL Tables
    </button>

    <!-- The exact <p> tag where the list of tables will be inserted -->
    <p id="table-container">
        <em>Tables have not been loaded yet. Click the button above.</em>
    </p>

</body>
</html>
'
  return(html_content)
}

#* @filter cors
function(req, res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  res$setHeader("Access-Control-Allow-Headers", "Content-Type")
  plumber::forward()
}

#* Process POST request and return HTML tables inside the <p> container
#* @post /fetch_tables
#* @serializer html
function() {
  
  # 1. Establish MySQL database connection
  drv=MySQL()
  con <- dbConnect(
    drv,
    host     = "localhost",
    user     = "root",
    password = "189999",
    dbname   = "reference",
    port     = 3306
  )
  on.exit(dbDisconnect(con))
  
  # 2. Fetch list of tables
  table_list <- dbListTables(con)
  
  # 3. Create an empty character vector to build our HTML string fragment
  html_fragment <- c()
  
  # 4. Loop through each table name, fetch data, and structure layout
  for (tbl_name in table_list) {
    # Fetch first 5 entries
    query <- paste0("SELECT * FROM `", tbl_name, "` LIMIT 5;")
    df_data <- dbGetQuery(con, query)
    
    # Generate clean HTML structure using kable
    html_table <- kable(df_data, format = "html")
    
    # Append structured table wrapper blocks to our HTML fragment string
    html_fragment <- c(
      html_fragment, 
      "<div class='table-box'>",
      paste0("<h3>Table Asset: ", tbl_name, "</h3>"), 
      html_table,
      "</div>"
    )
  }
  
  # 5. Return the raw string to insert directly inside the <p> target tag
  return(paste(html_fragment, collapse = "\n"))
}
