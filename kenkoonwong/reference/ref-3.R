# plumber.R
library(plumber)
library(ggplot2)

#* @apiTitle Plot Generator API

#* Generate plot and return as PNG
#* @param x numeric vector (comma-separated)
#* @param y numeric vector (comma-separated)
#* @serializer contentType list(type="image/png")
#* @get /plot
function(x, y) {
  # Validate inputs
  if (missing(x) || missing(y)) {
    res <- png()
    plot.new()
    text(0.5, 0.5, "Missing data")
    dev.off()
    return(res)
  }
  
  # Convert to numeric
  x_vals <- as.numeric(unlist(strsplit(x, ",")))
  y_vals <- as.numeric(unlist(strsplit(y, ",")))
  
  if (length(x_vals) != length(y_vals) || any(is.na(x_vals)) || any(is.na(y_vals))) {
    res <- png()
    plot.new()
    text(0.5, 0.5, "Invalid data")
    dev.off()
    return(res)
  }
  
  # Create plot
  tmp <- tempfile(fileext = ".png")
  png(tmp, width = 600, height = 400)
  ggplot(data.frame(x = x_vals, y = y_vals), aes(x, y)) +
    geom_point(color = "blue", size = 3) +
    geom_line(color = "red") +
    theme_minimal()
  dev.off()
  
  readBin(tmp, "raw", n = file.info(tmp)$size)
}

#* Download plot as PNG file
#* @param x numeric vector (comma-separated)
#* @param y numeric vector (comma-separated)
#* @serializer contentType list(type="application/octet-stream")
#* @get /download
function(x, y) {
  x_vals <- as.numeric(unlist(strsplit(x, ",")))
  y_vals <- as.numeric(unlist(strsplit(y, ",")))
  
  tmp <- tempfile(fileext = ".png")
  png(tmp, width = 600, height = 400)
  ggplot(data.frame(x = x_vals, y = y_vals), aes(x, y)) +
    geom_point(color = "blue", size = 3) +
    geom_line(color = "red") +
    theme_minimal()
  dev.off()
  
  readBin(tmp, "raw", n = file.info(tmp)$size)
}
