library(plumber)


#* Return HTML content
#* @get /
#* @serializer html

function() {
  # Return HTML code with the log button
html_content <- '
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Plumber Dynamic Plotter</title>
</head>
<body>
    <h2>Dynamic R Plotting</h2>

    <form id="plotForm">
        <label for="plot_type">Plot Type:</label>
        <select id="plot_type" name="plot_type">
            <option value="scatter">Scatter Plot</option>
            <option value="histogram">Histogram</option>
        </select>

        <br><br>

        <label for="csv_data">CSV Data:</label><br>
        <textarea id="csv_data" name="csv_data" rows="10" cols="40" placeholder="X,Y&#10;1,2&#10;2,4&#10;3,6&#10;4,8"></textarea>

        <br><br>
        <button type="submit">Generate Plot</button>
    </form>

    <br>
    <div id="plotContainer">
        <img id="resultPlot" src="" alt="Plot will appear here after submission" style="max-width: 600px; display: none;">
    </div>

    <script>
        document.getElementById("plotForm").addEventListener("submit", async function(e) {
            e.preventDefault(); // Prevent full page reload

            const formData = new FormData();
            const imgElement = document.getElementById("resultPlot");

            try {
                // Send POST request to local Plumber API
                const response = await fetch("http://127.0.0.1:8000/generate-plot", {
                    method: "GET",
                    body: formData
                });

                if (response.ok) {
                    // Convert binary response to a Blob and create an object URL
                    const blob = await response.blob();
                    const imageUrl = URL.createObjectURL(blob);
                    
                    // Display image
                    imgElement.src = imageUrl;
                    imgElement.style.display = "block";
                } else {
                    alert("Error generating plot from R");
                }
            } catch (error) {
                console.error("Fetch error:", error);
            }
        });
    </script>
    
</body>
</html>
'
  return(html_content)
}


#* Generate a plot based on CSV input and dropdown selection
#* @param plot_type:string The type of plot to generate (scatter/histogram)
#* @param csv_data:string The raw CSV text area content
#* @get /generate_plot
#* @serializer json
##* @serializer png
function(plot_type, csv_data,res) {
  # Parse the CSV text string
  df <- read.csv(text = csv_data)
  print(df)
  # Set up plot parameters
  par(bg = "white")
  
  # Plot dynamically based on the dropdown selection
  if (plot_type == "scatter") {
    plot(df[[1]], df[[2]], main = "Scatter Plot", xlab = "X", ylab = "Y", col = "blue")
  } else if (plot_type == "histogram") {
    hist(df[[1]], main = "Histogram", xlab = "Values", col = "lightblue")
  }
}
