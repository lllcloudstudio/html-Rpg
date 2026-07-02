# plumber.R
library(plumber)
library(ggplot2)

#* @apiTitle Dropdown Plot API

#* Generate a plot based on dropdown selections
#* @param category The category to plot
#* @param color The color for the plot
#* @serializer contentType list(type="image/png")
#* @get /plot
function(category = "A", color = "blue") {
  # Validate inputs
  valid_categories <- c("A", "B", "C")
  valid_colors <- colors()

  if (!(category %in% valid_categories)) {
    category <- "A"
  }
  if (!(color %in% valid_colors)) {
    color <- "blue"
  }

  # Example dataset
  df <- data.frame(
    category = rep(valid_categories, each = 10),
    x = rep(1:10, times = 3),
    y = rnorm(30)
  )

  # Filter based on selection
  df <- df[df$category == category, ]

  # Create plot
  p <- ggplot(df, aes(x, y)) +
    geom_line(color = color, size = 1.2) +
    ggtitle(paste("Category:", category, "| Color:", color))

  # Output as PNG
  tmp <- tempfile(fileext = ".png")
  png(tmp, width = 600, height = 400)
  print(p)
  dev.off()

  readBin(tmp, "raw", n = file.info(tmp)$size)
}
