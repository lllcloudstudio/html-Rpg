# Install plumber if not installed
# install.packages("plumber")

library(plumber)

# Store last plot in memory for download
last_plot_path <- tempfile(fileext = ".png")

#* Generate plot from form data
#* @param x numeric vector (comma-separated)
#* @param y numeric vector (comma-separated)
#* @post /plot
#* @serializer contentType list(type="image/png")
function(x, y) {
  # Convert comma-separated strings to numeric
  x_vals <- as.numeric(unlist(strsplit(x, ",")))
  y_vals <- as.numeric(unlist(strsplit(y, ",")))

  # Validate input
  if (length(x_vals) != length(y_vals) || any(is.na(x_vals)) || any(is.na(y_vals))) {
    res <- plumber::forward()
    res$status <- 400
    return(charToRaw("Invalid input: x and y must be same length numeric vectors"))
  }

  # Save plot to file
  png(last_plot_path, width = 600, height = 400)
  plot(x_vals, y_vals, main = "Generated Plot", col = "blue", pch = 19)
  dev.off()

  # Return PNG bytes
  readBin(last_plot_path, "raw", n = file.info(last_plot_path)$size)
}

#* Download last generated plot
#* @get /download
#* @serializer contentType list(type="image/png")
function() {
  if (!file.exists(last_plot_path)) {
    res <- plumber::forward()
    res$status <- 404
    return(charToRaw("No plot generated yet"))
  }
  readBin(last_plot_path, "raw", n = file.info(last_plot_path)$size)
}
