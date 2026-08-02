#* @apiTitle Dynamic R Vector Plotter API

#* Plot a single vector of numbers with a custom title
#* @param values A comma-separated string of numbers (e.g., “10,20,30”)
#* @param title A single text string for the main plot header
#* @serializer png
#* @get /vector-plot
function(values = "1,2,3,4,5", title = "Default Plot Title") {
  
  # 1. Split the comma-separated URL string into an R character vector
  char_vector <- unlist(strsplit(values, split = ","))
  
  # 2. Convert to numeric and strip out any spaces automatically
  numeric_vector <- as.numeric(char_vector)
  
  # 3. Clean out any missing or failed parsing values (e.g., letters)
  numeric_vector <- na.omit(numeric_vector)
  
  # 4. Generate the plot inside the active graphics device
  if (length(numeric_vector) > 0) {
    # Customizing the base R plot style
    plot(
      numeric_vector, 
      type = "b",          # Both points and lines
      col = "#1a73e8",     # Clean blue color
      lwd = 3,             # Line width
      pch = 19,            # Solid circle points
      cex = 1.5,           # Point size
      main = title, 
      ylab = "Values", 
      xlab = "Index"
    )
    grid() # Add a subtle background grid
  } else {
    # Fallback error plot if user inputs invalid data
    plot(1, 1, type = "n", xaxt = "n", yaxt = "n", xlab = "", ylab = "", 
         main = "Error: No valid numeric data provided")
  }
}