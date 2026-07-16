#* Generate a plot based on form data
#* @serializer png
#* @post /generate_plot
function(species = "setosa") {
  data(iris)
  filtered_data <- subset(iris, Species == species)
  
  # Initialize graphics device
  par(bg = "white") 
  plot(filtered_data$Sepal.Length, filtered_data$Sepal.Width,
       main = paste("Iris:", species), xlab = "Sepal Length", ylab = "Sepal Width")
}
