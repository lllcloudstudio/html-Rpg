library(plumber)
library(tidyverse)
library(magrittr)
library(dplyr)
#library(DBI)
#library(RMySQL)

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

#* logging 
#* @post /log
function(){

con <- dbConnect(RSQLite::SQLite(), ":memory:")

dbWriteTable(con, "iris", iris)
table=dbGetQuery(con, "SELECT * FROM iris WHERE Species == 'setosa'")
table.name='dbtable.csv'
write_csv(table, table.name)

#dbDisconnect(con) # error src
  #date_now <- tibble(date=Sys.time())
  #df <<- rbind(df,date_now)
  #write_csv(df, "migraine.csv")
  list(paste0("R iris data table saved as ", table.name)) 
# Always disconnect after use # not at line 69

}

#* download data
#* @get /download
#* @serializer csv
function(){
  table #df
  # An exception occurrs:
  #if (!is.null(con)) {
    #dbDisconnect(con)
    #message("🔌 Disconnected from database.")
#}
}

