library(plumber)
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
<html lang=“en”>
<head>
  <meta charset=“UTF-8”>
  <meta name=“viewport” content=“width=device-width, initial-scale=1.0”>
  <title>Hover Dropdown Navigation</title>
  <style>
  </style>
</head>
<body>

<form action=“http://localhost:8000/read_csv” method=“POST” enctype=“text/plain”>
  <label for=“csv-data”>Paste your CSV data here:</label><br>
  <textarea id=“csv-data” name=“csv_string” rows=“10” cols=“50” placeholder=“Id,Name,Value&#10;1,TestA,10.5&#10;2,TestB,20.0”></textarea>
  <br>
  <button id="BtnCSVtoR" type=“submit”>Send CSV to R</button>
</form>


<form method="GET" action="http://localhost:8000/echo.py">
<input type="color" name="color">
<input type="range" name="range" min="1" max="10">
<input type="time" name="time"><br>
<input type="url" name="url" size="54" required >
<p><input type="submit" value="Submit Form"></p>
</form>







<form method="GET" action="http://localhost:8000/echo.py">
<label for="services">Choose a service:</label>
<select id="services" name="services">
  <option value="" disabled selected> Select a choice ...</option>
  <option value="web-dev">Web Development</option>
  <option value="design">UI/UX Design</option>
  <option value="marketing">Digital Marketing</option>
</select>
</form>

<script>
    // csv-form is unique as Id ?
    document.getElementById("BtnCSVtoR").addEventListener("click", function(e) {
  e.preventDefault(); // Prevent page reload
  
  const csvText = document.getElementById("csv-data").value;
  
  fetch("http://localhost:8000/read_csv", {
    method: "POST",
    headers: { "Content-Type": "text/plain" },
    body: csvText
  })
  .then(response => response.json())
  .then(data => console.log(data))
  .catch(error => console.error("Error:", error));
});
</script>

</body>
</html>
'
  return(html_content)
}


#* @apiTitle CSV Textarea Read
#* @parser text
#* @param csvText
#* @post /read_csv
function(req) { # csvText or csv-data as parameter not function(req,res){}
  # req$postBody contains the raw CSV string from the textarea
  csv_string <- req$postBody # set R variable 
  
  # Read the CSV string into an R data frame
  df <- read.csv(textConnection(csv_string))
  
  # Perform your calculations or data manipulations here
  # Example: return the summary or structure
  return(list(
    message = "CSV successfully received and processed!",
    row_count = nrow(df),
    column_names = names(df)
  ))
}