library(plumber)
library(DBI)
library(RMariaDB)
library(DBI)
library(RMySQL)
library(tidyverse)
library(kableExtra)
library(knitr)
library(utils)
library(odbc)
library(mime)
library(htmlwidgets)
library(dygraphs)
library(widgetframe)

#* @apiTitle 
#* @apiDescription

#* Return HTML content print to R as HTML
#* @get /
#* @serializer html

function() {
  # Return HTML code with the log button
html_content <- '
<!DOCTYPE html>
<head>
</head>
<body>
<script>
function sendData() {
  const userInput = document.getElementById("inputData").value;

  // Send request to R Plumber
  fetch(`http://localhost:8000/my-endpoint?data=${encodeURIComponent(userInput)}`)
    .then(response => response.text())
    .then(data => {
      // Update the specific element by ID
      document.getElementById("resultDiv").innerHTML = data;
    })
    .catch(error => console.error("Error:", error));
}

</script>
<form id="myForm">
  <label for="inputData">Enter value:</label>
  <input type="text" id="inputData" name="inputData">
  <!-- Use type="button" to prevent default form submits -->
  <button type="button" onclick="sendData()">Submit</button>
</form>

<!-- This is the element we will update without reloading -->
<div id="resultDiv">Waiting for data...</div>



</body>
</html>
'
  return(html_content)
}




#* @get /my-endpoint
function(data) {
  # Perform your R computations here
  paste("Processed result from R:", toupper(data))
  print(paste("Processed result from R:", toupper(data)))
  #print(paste0("<h3>Success!</h3>","<p>Successfully inserted</p>",collapse=" "))


}



#* @title Interactive Widget
#* @serializer htmlwidget
#* @param inputData

function(req,res){
tryCatch({ 
  ts_widget <- dygraph(req,main="New Haven Temperatures")
  saveWidget(frameableWidgets(ts_widget),file="/Users/benja/OneDrive/Documents/dygraphLib_chart.html",selfcontained=TRUE)


},
  error = function(e){
    res$status <- 500
    return(e$message)
  })}




