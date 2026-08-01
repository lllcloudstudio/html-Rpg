library(ggplot2)
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

<form id="renderForm">
  <input type="text" name="chartTitle" value="My Dynamic Plot">
  <input type="color" name="plotColor" value="#ff0000">
  <input type="file" name="csvFile" accept=".csv">
  <button type="submit">Generate Plot</button>
</form>

<img id="resultPlot" alt="Generated plot will appear here" style="display:none; max-width:100%;">

<script>
document.getElementById("renderForm").addEventListener("submit", async (e) => {
  e.preventDefault();
  
  const formElement = e.target;
  const formData = new FormData(formElement); // Automatically grabs all inputs

  try {
    const response = await fetch("https://localhost:8000/generate-plot", {
      method: "POST",
      body: formData // Let the browser automatically set multi-part headers
    });

    if (!response.ok) throw new Error("Failed to generate image");

    // 1. Read the response stream as raw binary data (Blob)
    const imageBlob = await response.blob();
    
    // 2. Create a secure local URL pointing to that memory block
    const imageUrl = URL.createObjectURL(imageBlob);
    
    // 3. Display it in your DOM
    const img = document.getElementById("resultPlot");
    img.src = imageUrl;
    img.style.display = "block";

  } catch (error) {
    console.error("Error fetching plot:", error);
  }
});
</script>


</body>
</html>
'


return(html_content)
}

#* @filter cors
function(res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  res$setHeader("Access-Control-Allow-Headers", "Content-Type")
  plumber::forward()
}

#* Generate a PNG from submitted text parameters and CSV data
#* @post /generate-plot
#* @parser multi
#* @parser csv
#* @serializer png
function(req) {
  # 1. Safely extract your parameters from the request body
  title_text <- req$body$chartTitle$value
  chosen_color <- req$body$plotColor$value
  uploaded_df <- req$body$csvFile$parsed

  # Fallback data if no CSV was selected in the form
  if (is.null(uploaded_df)) {
    uploaded_df <- data.frame(x = 1:10, y = rnorm(10)) ### R feature
    p <- boxplot(uploaded_df$y)
    #p <- ggplot(uploaded_df, aes(x = .data[[names(uploaded_df)[1]]], y = .data[[names(uploaded_df)[2]]])) +
    #geom_point(color = chosen_color, size = 3) +
    #geom_line(color = chosen_color, alpha = 0.5) +
    #labs(title = title_text) +
    #theme_minimal()
    #p
    print(p)
  }
  
  # Assumes your CSV has columns named ‘x’ and ‘y’
  # 2. Build your R plot
  p <- ggplot(uploaded_df, aes(x = .data[[names(uploaded_df)[1]]], y = .data[[names(uploaded_df)[2]]])) +
    geom_point(color = chosen_color, size = 3) +
    geom_line(color = chosen_color, alpha = 0.5) +
    labs(title = title_text) +
    theme_minimal()

  # 3. Print the plot object. The @serializer png handles the actual device rendering
  print(p)
}