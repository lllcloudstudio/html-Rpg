#* Generate a customizable plot
#* @param num_points The number of data points to plot
#* @serializer png
#* @get /plot
function(num_points = 10) {
  # Convert character input from URL to numeric
  n <- as.numeric(num_points)
  
  # Generate the plot
  plot(1:n, main = paste("Plot of", n, "points"))
}

### type to browser: http://localhost:8000/plot?num_points=100