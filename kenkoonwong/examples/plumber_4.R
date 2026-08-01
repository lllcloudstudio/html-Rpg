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
const params = new URLSearchParams();
params.append("x_vals", "1,2,3,4,5");
params.append("y_vals", "10,15,13,17,20");

const url = "http://localhost:8000/plot?${params.toString()}";

fetch(url)
  .then(response => {
    if (!response.ok) throw new Error("Network response failed");
    return response.blob(); // Crucial: Extract the response as raw binary data
  })
  .then(imageBlob => {
    // Create a local, temporary DOM string URL from the blob object
    const imageObjectURL = URL.createObjectURL(imageBlob);
    
    // Inject it directly into an image element on your webpage
    const imgElement = document.getElementById("myPlumberPlot");
    imgElement.src = imageObjectURL;
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
function(x_vals, y_vals) {
  # Parse comma-separated strings back into numeric vectors
  x <- as.numeric(unlist(strsplit(x_vals, ",")))
  y <- as.numeric(unlist(strsplit(y_vals, ",")))
  
  df <- data.frame(x = x, y = y)
  
  # Create a plot (Plumber automatically captures this print statement)
  p <- ggplot(df, aes(x = x, y = y)) + 
         geom_point(size = 4, color = "blue") + 
         theme_minimal()
         
  print(p)
}