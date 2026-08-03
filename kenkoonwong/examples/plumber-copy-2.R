
####################################################################
####################################################################
####################################################################
library(plumber)

#* Generate a plot based on the dropdown type and comma-separated values
#* @param titleInput Dropdown selection ("scatter", "line", or "histogram")
#* @param dataInput Comma-separated numeric values (e.g., "10,15,20,25,30")
#* @get /vector-plot
#* @serializer png
function(titleInput = "scatter", dataInput = "Default Plot Title") {
  
  # 1. Parse the comma-separated string into a numeric vector
  vals <- as.numeric(unlist(strsplit(dataInput, ",")))
  
  # 2. Handle missing or invalid inputs gracefully
  if (length(vals) == 0 || any(is.na(vals))) {
    plot.new()
    text(0.5, 0.5, "Invalid or empty input provided.", col = "red")
    return()
  }
  
  # 3. Create indices for X-axis (1 to N)
  x_vals <- seq_along(vals)
  
  # 4. Generate the plot based on dropdown selection
  if (titleInput == "scatter") {
    plot(x_vals, vals, main = "Scatter Plot", xlab = "Index", ylab = "Value", 
         pch = 19, col = "blue", type = "p", 
         xlim = c(0.5, length(vals) + 0.5))
         
  } else if (titleInput == "line") {
    plot(x_vals, vals, main = "Line Chart", xlab = "Index", ylab = "Value", 
         col = "red", type = "l", lwd = 3.3,lty=2,cex=2.3,# ,
         xlim = c(0.5, length(vals) + 0.5))
         ######################
  } else if (titleInput == "hist") {
    from=min(vals)
    to=max(vals)
    by=max(vals)/length(vals) # length.out=sum(vals)/length(vals)
    brks=seq(from,to,by)
    hist(vals,breaks=brks, main = "Histogram", xlab = "Value", col = "lightblue", 
         border = "black")
    abline(v=c(mean(vals),median(vals)),lty=c(2,3),lwd=2)
    legend("topright",legend=c("mean","median"),lty=c(2,3),lwd=2)
  } else if (titleInput == "density"){
    dens <- density(vals)

  # Plot density curve
  plot(dens,
     main = "Density Plot (Base R)",
     xlab = "Value",
     ylab = "Density",
     col = "blue",
     lwd = 3)

  # Add a rug plot to show actual data points
  rug(vals, col = "darkgray")

  }
    else if (titleInput == "stripchart"){
      stripchart(vals)
    }
    else if (titleInput == "boxplot"){
      boxplot(vals)
    }
    else {
    plot.new()
    text(0.5, 0.5, "Unknown plot type.", col = "red")
  }
}
