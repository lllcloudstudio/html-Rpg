library(plumber)
library(DBI)
library(RMySQL)
library(tidyverse)
library(kableExtra)
library(knitr)
library(utils)
library(graphics)
library(jsonlite)

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
    <title>Title</title>
</head
<body>

    <h2>CSV text area Upload to MySQL</h2>
    <!-- <form action="https://127.0.0.1:8000/process" method="get"> -->
        <!-- Input for the MySQL Table Name -->
        <label for="word">Desired MySQL Table Name:</label><br>
        <input type="text" id="word" name="word" required placeholder="e.g., customer_logs"><br><br>
        
        <!-- Input for the CSV text -->
        <label for="values">Paste Comma-Delimited Data (Include Headers):</label><br>
        <textarea id="values" name="values" rows="10" cols="50" required placeholder="name,age,city&#10;Alice,30,New York&#10;Bob,25,London"></textarea>
        <br><br>
        <button onclick="sendData()">Generate Plot</button>
        <!-- <input type="submit" value="Create Table in MySQL">-->
     <!-- because form, </form> get ?-->

<p id="filenameDisplay1">
<img id="plot" style="border:1px solid #444; max-width:500px;">
</p>

<script>
async function sendData() {
    const values = document.getElementById("values").value //"1,2,3,4";
    const word = document.getElementById("word").value //"example";
    // const csv = document.getElementById("csv").value;

  try {
    const response = await fetch("https://127.0.0.1:8000/process", {
    method: "POST",
    headers: {
        "Content-Type": "application/json" // JSON format
    },
    body: JSON.stringify({
        csv: values,
        word: word
    });

    if (!response.ok) {
      alert("Error: " + await response.text());
      return;
    }
    //
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




## blank png img 
#* @post /process
#* serializer json
#* serializer png
function(req) {
    
  # Extract the raw POST body
  body <- req$postBody
  print(body)
  body <- jsonlite::fromJSON(req$postBody)
  
  # Basic validation
  if (is.null(body) || nchar(body) == 0) {
    stop("Empty input. Provide comma-separated values.")
  }
  print(nchar(body))
  # Split CSV and convert to numeric
  csvalues <- body$values
  print(csvalues)
  #strsplit(body, ",")[[1]]
  values <- trimws(values)
  
  # Validate numeric values
  nums <- suppressWarnings(as.numeric(values))
  if (any(is.na(nums))) {
    stop("Invalid numeric values. Ensure all entries are numbers.")
  }
  
  # Produce a simple plot
  plot(
    nums,
    type = "o",
    main = "Plot of Submitted Values",
    xlab = "Index",
    ylab = "Value"
  )
}
  # Parse JSON body into an R list
  #body <- jsonlite::fromJSON(req$postBody)
  #print(body)
  # Access a specific field
  #value <- body$foo
  #print(value)
  #list(
    #received_value = value,
    #all_data = body
  #)
#}
