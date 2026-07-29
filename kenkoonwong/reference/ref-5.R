library(plumber)
library(DBI)
library(RMariaDB)
library(knitr)

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
