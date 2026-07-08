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

#* @apiTitle 
#* @apiDescription

#* Return HTML content print to R as HTML
#* @get /
#* @serializer html

function() {
  # Return HTML code with the log button
html_content <- '
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>OnClick Submit Show Dropdown</title>
<!-- <style>
    /* Basic styling for dropdown */
    #dropdownMenu {
        display: none; /* Hidden by default */
        position: absolute;
        background-color: #f9f9f9;
        min-width: 160px;
        border: 1px solid #ccc;
        box-shadow: 0px 8px 16px rgba(0,0,0,0.2);
        z-index: 1;
    }
    #dropdownMenu a {
        display: block;
        padding: 8px 12px;
        text-decoration: none;
        color: black;
    }
    #dropdownMenu a:hover {
        background-color: #f1f1f1;
    }
</style> -->
</head>
<body>

<form id="myForm">
    <label for="username">Enter Name:</label>
    <input type="text" id="username" name="username" required>
    <button type="submit">Submit</button>
</form>

<!-- Dropdown menu -->
<div id="dropdownMenu">
    <a href="#">Option 1</a>
    <a href="#">Option 2</a>
    <a href="#">Option 3</a>
</div>

<script>
document.getElementById("myForm").addEventListener("submit", function(event) {
    event.preventDefault(); // Prevent form from reloading page

    const nameInput = document.getElementById("username").value.trim();
    if (!nameInput) {
        alert("Please enter your name.");
        return;
    }

    // Fetch the dropdown div
    const dropdown = document.getElementById("dropdownMenu");

    // Toggle visibility
    if (dropdown.style.display === "block") {
        dropdown.style.display = "none";
    } else {
        dropdown.style.display = "block";
    }
});
</script>

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
