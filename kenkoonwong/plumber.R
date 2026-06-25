library(plumber)
library(tidyverse)
library(magrittr)
library(dplyr)

file <- "migraine.csv"

if (file.exists(file)) {
  df <- read_csv(file)
} else {
df <- tibble(date=as.POSIXct(character()))
}

#* @apiTitle Migraine logger
#* @apiDescription A simple API to log migraine events

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
       <button id="submit">Oh No, Migraine Today!</button>
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
  date_now <- tibble(date=Sys.time())
  df <<- rbind(df,date_now)
  write_csv(df, "migraine.csv")
  list(paste0("you have logged ", date_now$date[1], " to migraine.csv"))
}

#* download data
#* @get /download
#* @serializer csv
function(){
  df
}