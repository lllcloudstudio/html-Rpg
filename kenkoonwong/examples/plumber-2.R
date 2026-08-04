#* @apiTitle Dynamic R Vector Plotter API

#* Plot a single vector of numbers with a custom title
#* @param values A comma-separated string of numbers (e.g., "10,20,30")
#* @param title A single text string for the main plot header
#* @param type A single text string for the plot type (e.g., "scatter", "line")
#* @serializer png
#* @get /vector-plot
function(values = "1,2,3,4,5", title = "Default Plot Title", type = "scatter") {
  print(values)
  
  char_vector <- unlist(strsplit(values, split = ","))
  numeric_vector <- as.numeric(char_vector)
  numeric_vector <- na.omit(numeric_vector)
  
  if (length(numeric_vector) == 0) {
    plot(1, 1, type = "n", xaxt = "n", yaxt = "n", xlab = "", ylab = "", 
         main = "Error: No valid numeric data provided")
    return()
  }

  # Adjusted evaluations to match the new variable name 'type'
  if (type == "scatter") {
    plot(
      numeric_vector, 
      type = "b",          
      col = "#1a73e8",     
      lwd = 3,             
      pch = 19,            
      cex = 1.5,           
      main = title, 
      ylab = "Values", 
      xlab = "Index"
    )
    grid() 
  } else if (type == "line") {
    plot(numeric_vector, main = title, xlab = "Index", ylab = "Value", 
         col = "red", type = "l", lwd = 3.3, lty = 2, cex = 2.3)
         
  } else if (type == "hist") {
    from <- min(numeric_vector)
    to <- max(numeric_vector)
    by <- if(length(numeric_vector) > 1) (to - from) / length(numeric_vector) else 1
    if(by == 0) by <- 1 
    
    brks <- seq(from, to, by = by)
    hist(numeric_vector, breaks = brks, main = title, xlab = "Value", col = "lightblue", 
         border = "black")
    abline(v = c(mean(numeric_vector), median(numeric_vector)), lty = c(2,3), lwd = 2)
    legend("topright", legend = c("mean", "median"), lty = c(2,3), lwd = 2)
    
  } else if (type == "density") {
    if(length(unique(numeric_vector)) > 1) {
      dens <- density(numeric_vector)
      plot(dens, main = title, xlab = "Value", ylab = "Density", col = "blue", lwd = 3)
      rug(numeric_vector, col = "darkgray")
    } else {
      plot(1, 1, type = "n", main = "Error: Density needs variance")
    }

  } else if (type == "stripchart") {
    stripchart(numeric_vector, main = title)
    
  } else if (type == "boxplot") {
    boxplot(numeric_vector, main = title)
  }
}
