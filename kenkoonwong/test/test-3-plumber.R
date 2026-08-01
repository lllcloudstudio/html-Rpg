library(plumber)
library(tidyverse)
library(magrittr)
library(dplyr)
library(DBI)
library(RMySQL)

#* @apiTitle iris web 
#* @apiDescription A simple API to iris data

#* Return HTML content
#* @get /
#* @serializer html

function() {
  
  # Return HTML code with the log button
  html_content <- '
     <!DOCTYPE html>
     <html>
     <head>
       <title>Migraine Logger</title>
     </head>
     <body>
       <h1>Migraine Logger</h1>
       <button id="submit">R iris data table</button>
       <div id="result" style="display: none;"></div>
       
      <script>
       document.getElementById("submit").onclick = function() {
          fetch("/log", {
            method : "post"
          })
          .then(response => response.json())
          .then(data => {
            const resultDiv = document.getElementById("result");
            resultDiv.textContent = data[0];
            resultDiv.style.display = "block";
          })
          .catch(error => {
            const resultDiv = document.getElementById("result");
            resultDiv.textContent = error.message
          })
       };
      </script>
      
     </body>
     </html>
     '
  return(html_content)
}



#* Download your query results as a CSV file NOT logging 
#* @serializer csv
#* @get /download
function(){
drv <- MySQL() # not postgre or RMariadb
# Connection parameters
host <- "localhost"   # or "localhost"
port <- 3306          # default MySQL port
user <- "root"
password <-'189999'  # 
dbname <- "sakila"
con <- tryCatch({
  dbConnect(
    drv,
    host = host,
    port = port,
    user = user,
    password = password,
    dbname = dbname
  )
}, error = function(e) {
  stop("Database connection failed: ", e$message)
})
query <- "SELECT * FROM actor" # example if actor
results <- NULL
tryCatch({
    results <- dbGetQuery(con, query)
    message("✅ Query executed successfully.")
}, error = function(e) {
    stop("❌ Query failed: ", e$message)
})
# Display results
print(results) # check
table.name='dbtable.csv'
list(paste0("sakila data table saved as ", table.name)) 
return(results)
}

