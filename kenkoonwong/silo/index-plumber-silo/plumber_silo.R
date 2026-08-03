library(plumber)

#* Generate plot based on input form data
#* @serializer json
#* @post /get-plot
function(species_name = "setosa") {
  
  # Create temporary file for the plot
  tmp <- tempfile(fileext = ".png")
  png(tmp)
  
  # Generate plot (e.g., filtering iris dataset)
  df <- iris[iris$Species == species_name, ]
  plot(df$Sepal.Length, df$Sepal.Width, 
       main = paste("Sepal Dimensions for", species_name),
       xlab = "Sepal Length", ylab = "Sepal Width")
  
  dev.off()
  
  # Convert to Base64 to safely send through JSON
  img_b64 <- base64enc::base64encode(tmp)
  file.remove(tmp)
  
  # Return the base64 string
  list(plot_data = img_b64)
}
