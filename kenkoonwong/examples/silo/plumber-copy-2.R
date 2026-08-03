
####################################################################
####################################################################
####################################################################
library(plumber)

#* Generate a plot based on the dropdown type and comma-separated values
#* @param titleInput Dropdown selection ("scatter", "line", or "histogram")
#* @param dataInput Comma-separated numeric values (e.g., "10,15,20,25,30")
#* @serializer png
#* @get /vector-plot
function(titleInput = "scatter", dataInput = "Default Plot Title") {
  
  # 1. Parse the comma-separated string into a numeric vector
  char_vector <- unlist(strsplit(dataInput, ","))
  numeric_vector <- as.numeric(char_vector)
  numeric_vector <- na.omit(numeric_vector)
  print(titleInput)
  #
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