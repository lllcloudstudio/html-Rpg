#
# This is a Plumber API. You can run the API by clicking
# the 'Run API' button above.
#
# Find out more about building APIs with Plumber here:
#
#    https://www.rplumber.io/
#
library(plumber)
library(DBI)
library(RMySQL)
library(tidyverse)
library(kableExtra)
library(knitr)
library(utils)
library(graphics)
#* @get /
#* @serializer html

function(){
  html_content <- '
<!DOCTYPE html>
<head>
</head>
<body>

<h2>Enter signature</h2>
<textarea id="csv" rows="4" cols="50">str 1, 2, 5, 8, 3</textarea><br><br>

<button onclick="sendData()">Generate Plot</button>

<h3>Output</h3>

<p id="plot"></p>


<script>
async function sendData() {
  const csv = document.getElementById("csv").value;

  try {
    const response = await fetch("http://localhost:8000/dbListTables", {
      method: "POST",
      headers: {
        "Content-Type": "text/plain"
      },
      body: csv
    });

    if (!response.ok) {
      alert("Error: " + await response.text());
      return;
    }

    const blob = await response.blob();
    const url = URL.createObjectURL(blob);
    document.getElementById("plot").src = url;

  } catch (err) {
    alert("Network error: " + err);
  }
}
</script>

</body>
</html>
'
return(html_content)
}



#png/text
#* Create a plot from CSV numeric values
#* @get /dbListTables
#* @serializer contentType list(type="text/html")
function(req) {
 # Connect to MySQL
  drv=MySQL()
  #con <- NULL # Initialize connection ?
  tryCatch({
    con <- dbConnect(
      drv,
      dbname   = "reference", #sakila
      host     = "localhost",
      port     = 3306, #3306 db connection
      user     = "root",
      password = "189999"
    )
  df <- dbListTables(con) 
 
    #html_table=kable(df, format="html", table.attr="id='id_1'")
    #return(html_table) # similar to ^^

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


