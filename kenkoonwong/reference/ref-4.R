# Install plumber if not installed
# install.packages("plumber")

library(plumber)

#* @apiTitle Plot API Example

#* Generate a plot and return as PNG
#* @param x numeric vector (comma-separated)
#* @get /plot
function(x = "1,2,3,4,5") {
  # Convert input to numeric
  nums <- as.numeric(unlist(strsplit(x, ",")))
  if (any(is.na(nums))) {
    nums <- 1:5
  }
  
  # Create a temporary file for the plot
  tmp <- tempfile(fileext = ".png")
  png(tmp, width = 600, height = 400)
  plot(nums, nums^2, type = "b", col = "blue", main = "y = x^2")
  dev.off()
  
  # Return the PNG
  plumber::include_file(tmp, content_type = "image/png")
}

#* Download plot as CSV
#* @param x numeric vector (comma-separated)
#* @get /download
function(x = "1,2,3,4,5") {
  nums <- as.numeric(unlist(strsplit(x, ",")))
  if (any(is.na(nums))) {
    nums <- 1:5
  }
  
  tmp <- tempfile(fileext = ".csv")
  write.csv(data.frame(x = nums, y = nums^2), tmp, row.names = FALSE)
  
  plumber::include_file(tmp, content_type = "text/csv")
}

# Run API
# Save this file as api.R and run:
# plumber::pr("api.R") %>% pr_run(port = 8000)
