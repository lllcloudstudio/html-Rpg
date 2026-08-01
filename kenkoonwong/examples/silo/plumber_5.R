library(plumber)
library(ggplot2)

#> .libPaths()
#[1] "C:/Users/aflac/AppData/Local/R/win-library/4.6"
#[2] "C:/Program Files/R/R-4.6.0/library"

#.libPaths(c("C:/Program Files/R/R-4.6.0/library", .libPaths())) 
library(plumber)
library(DBI)
library(RMySQL)
library(tidyverse)
library(kableExtra)
library(knitr)
library(utils)
library(graphics)

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
</head>
<body>
<img id="myPlumberPlot" style="border: 1px solid #444; max-width: 500px;">
<script>
//const params = new URLSearchParams();
//params.append("x_vals", "1,2,3,4,5");
//params.append("y_vals", "10,15,13,17,20");

//const url = "http://localhost:8000/plot?${params.toString()}";

fetch("https://127.0.0.1:8000/plot")
  .then(response => {
    //if (!response.ok) throw new Error("Network response failed");
    //return response.blob(); // Crucial: Extract the response as raw binary data
    console.log(response.headers.get("Content-Type")); // Log the Content-Type header
    if (!response.ok) throw new Error("Network response failed");
    return response.blob();
  })
  .then(blob => {
    // Create a local, temporary DOM string URL from the blob object
    const imageURL = URL.createObjectURL(blob);
    document.getElementById("myPlumberPlot").src = imageURL; //img#myPlumberPlot
    // Inject it directly into an image element on your webpage
    //const imgElement = document.getElementById("myPlumberPlot");
    //imgElement.src = imageObjectURL;
  })
  .catch(error => console.error("Error fetching the PNG:", error));
</script>

</body>
</html>
'
return(html_content)
}



#* Generate a scatter plot from parameters
#* @serializer png
#* @get /plot
function() {
    plot(rnorm(100), rnorm(100), main="Scatter Plot Example")
}