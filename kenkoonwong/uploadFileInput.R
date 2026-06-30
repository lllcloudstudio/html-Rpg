library(plumber)
library(dplyr)
library(DBI)
library(RMySQL)
library(tidyverse)
library(kableExtra)
library(knitr)
library(utils)
library(httr)
library(DBI)
library(RSQLite)
library(readr)



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
  <title>File Input Length Example</title>
</head>
<body>
  <!-- Allow multiple file selection -->
  <input type="file" id="fileInput" multiple>

  <script>
    // Get the file input element
    const fileInput = document.getElementById("fileInput");

    // Listen for file selection changes
    fileInput.addEventListener("change", function () {
      try {
        // Get the number of selected files
        const fileCount = fileInput.files.length;

        console.log(`Number of files selected: ${fileCount}`);

        // Optional: list file names
        for (let i = 0; i < fileCount; i++) {
          console.log(`File ${i + 1}: ${fileInput.files[i].name}`);
        }
      } catch (err) {
        console.error("Error reading file input:", err);
      }
    });
  </script>
</body>
</html>
'
  return(html_content)
}

