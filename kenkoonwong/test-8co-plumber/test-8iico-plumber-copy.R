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
    <meta charset="UTF-8">
    <title>Download MySQL Query Result</title>
    <style>
        body { font-family: system-ui, sans-serif; margin: 40px; background: #f9f9f9; }
        button { background: #007bff; color: white; border: none; padding: 10px 20px; border-radius: 4px; cursor: pointer; font-size: 16px; }
        button:hover { background: #0056b3; }
        .table-box { background: white; padding: 15px; border-radius: 6px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); margin-top: 20px; }
        table { border-collapse: collapse; width: 100%; margin-top: 10px; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
<h1>Vector data Plot </h1>
<form id="form1">
<label for="plot_type2">Distribution Shape:</label>
<select id="plot_type2" name="plot_type2">
  <option value="" disabled selected> Select a choice ...</option>
  <option value="hist">Histogram</option>
  <option value="scatter">Scatter Plot</option>
  <option value="line">Line Plot</option>
  <option value="density">Density Plot</option>
  <option value="boxplot">Boxplot</option>
  <option value="stripchart">Stripchart</option>   
</select>
<br><br>
        <label for="csv_values2">Paste Comma-Delimited Data (Include Headers):</label><br>
        <textarea id="csv_values2" name="csv_values2" rows="10" cols="50" required placeholder="10,30,10,25"></textarea>
        <br><br>
        <input type="submit" value="Create R Plot">
    </form>

    <img id="myPlumberPlot" style="border: 1px solid #444; max-width: 500px;">

    <script>
        document.getElementById("form1").addEventListener("submit", function(event) {// or e
        event.preventDefault(); // Stop page from reloading
        const form = document.querySelector("form1"); 
        const formData = new FormData(form);
        const queryString = new URLSearchParams(formData).toString();
        //const fullUrl= "http://localhost:8000/generate_plot?" + queryString;
        const fullUrl = "http://localhost:8000/generate_plot?${queryString}";
        //const fullUrl = "http://localhost:8000/generate_plot{queryString}";

        //const params = new URLSearchParams(new FormData(form));
        //const apiURL = "http://localhost:8000/generate_plot?" + params.toString();
        //const apiURL = "http://localhost:8000/generate_plot?${params.toString()}";

        try{const response = await fetch(fullUrl, {method: "POST", headers: { "Content-Type": "application/x-www-form-urlencoded"}, body: queryString}); // apiURL or fullUrl
            const result = await response.blob();
            console.log(result);
            
            const imageObjectURL = fullUrl.createObjectURL(imageBlob);
            const imgElement = document.getElementById("myPlumberPlot");
            imgElement.src = imageObjectURL;
        } catch (error) {
            console.error("Error fetching image:", error);
}
});
    </script>
</body>
</html>
'
  return(html_content)
}



#* Generate a plot based on the dropdown type and comma-separated values
#* @param plot_type2 Dropdown selection ("scatter", "line", or "histogram")
#* @param csv_values2 Comma-separated numeric values (e.g., "10,15,20,25,30")
#* @post /generate_plot
#* @serializer png
function(plot_type2 = "scatter", csv_values2 = "") {
  
  # 1. Parse the comma-separated string into a numeric vector
  vals <- as.numeric(unlist(strsplit(csv_values2, ",")))
  
  # 2. Handle missing or invalid inputs gracefully
  if (length(vals) == 0 || any(is.na(vals))) {
    plot.new()
    text(0.5, 0.5, "Invalid or empty input provided.", col = "red")
    return()
  }
  
  # 3. Create indices for X-axis (1 to N)
  x_vals <- seq_along(vals)
  
  # 4. Generate the plot based on dropdown selection
  if (plot_type2 == "scatter") {
    plot(x_vals, vals, main = "Scatter Plot", xlab = "Index", ylab = "Value", 
         pch = 19, col = "blue", type = "p", 
         xlim = c(0.5, length(vals) + 0.5))
         
  } else if (plot_type2 == "line") {
    plot(x_vals, vals, main = "Line Chart", xlab = "Index", ylab = "Value", 
         col = "red", type = "l", lwd = 3.3,lty=2,cex=2.3,# ,
         xlim = c(0.5, length(vals) + 0.5))
         ######################
  } else if (plot_type2 == "hist") {
    from=min(vals)
    to=max(vals)
    by=max(vals)/length(vals) # length.out=sum(vals)/length(vals)
    brks=seq(from,to,by)
    hist(vals,breaks=brks, main = "Histogram", xlab = "Value", col = "lightblue", 
         border = "black")
    abline(v=c(mean(vals),median(vals)),lty=c(2,3),lwd=2)
    legend("topright",legend=c("mean","median"),lty=c(2,3),lwd=2)
  } else if (plot_type2 == "density"){
    dens <- density(vals)

  # Plot density curve
  plot(dens,
     main = "Density Plot (Base R)",
     xlab = "Value",
     ylab = "Density",
     col = "blue",
     lwd = 3)

  # Add a rug plot to show actual data points
  rug(vals, col = "darkgray")

  }
    else if (plot_type2 == "stripchart"){
      stripchart(vals)
    }
    else if (plot_type2 == "boxplot"){
      boxplot(vals)
    }
    else {
    plot.new()
    text(0.5, 0.5, "Unknown plot type.", col = "red")
  }
}
