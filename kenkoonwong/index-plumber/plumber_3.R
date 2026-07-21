# Install plumber if not installed
# install.packages("plumber")

library(plumber)

#* @post /plot
#* @serializer contentType list(type="image/png")
function(values = "") {
  # Split CSV string into numeric vector
  print(values)
  nums <- as.numeric(unlist(strsplit(values, ",")))
print(nums)
  # Validate input
  if (length(nums) == 0 || any(is.na(nums))) {
    res <- plumber::forward()
    res$status <- 400
    return(charToRaw("Invalid numeric input"))
  }

  # Create plot and return as PNG
  tmp <- tempfile(fileext = ".png")
  png(tmp, width = 600, height = 400)
  plot(nums, type = "o", col = "blue", main = "R Plot from CSV",
       xlab = "Index", ylab = "Value")
  dev.off()

  # Return raw PNG bytes
  readBin(tmp, "raw", n = file.info(tmp)$size)
}

# Run API
# plumber::pr("api.R") %>% pr_run(port = 8000)
