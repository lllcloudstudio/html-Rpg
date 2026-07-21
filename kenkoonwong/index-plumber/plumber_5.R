library(plumber)

#* Generate a plot based on the dropdown type and comma-separated values
#* @param plot_type Dropdown selection ("scatter", "line", or "histogram")
#* @param csv_values Comma-separated numeric values (e.g., "10,15,20,25,30")
#* @get /generate_plot
#* @serializer png
function(plot_type = "scatter", csv_values = "") {
  
  # 1. Parse the comma-separated string into a numeric vector
  vals <- as.numeric(unlist(strsplit(csv_values, ",")))
  
  # 2. Handle missing or invalid inputs gracefully
  if (length(vals) == 0 || any(is.na(vals))) {
    plot.new()
    text(0.5, 0.5, "Invalid or empty input provided.", col = "red")
    return()
  }
  
  # 3. Create indices for X-axis (1 to N)
  x_vals <- seq_along(vals)
  
  # 4. Generate the plot based on dropdown selection
  if (plot_type == "scatter") {
    plot(x_vals, vals, main = "Scatter Plot", xlab = "Index", ylab = "Value", 
         pch = 19, col = "blue", type = "p", 
         xlim = c(0.5, length(vals) + 0.5))
         
  } else if (plot_type == "line") {
    plot(x_vals, vals, main = "Line Chart", xlab = "Index", ylab = "Value", 
         col = "red", type = "l", lwd = 2,
         xlim = c(0.5, length(vals) + 0.5))
         
  } else if (plot_type == "histogram") {
    hist(vals, main = "Histogram", xlab = "Value", col = "lightblue", 
         border = "black")
         
  } else {
    plot.new()
    text(0.5, 0.5, "Unknown plot type.", col = "red")
  }
}
