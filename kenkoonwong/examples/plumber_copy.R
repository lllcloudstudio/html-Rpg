#* @apiTitle Dynamic R Vector Plotter API

#* Plot a single vector of numbers with a custom title
#* @param values A comma-separated string of numbers (e.g., “10,20,30”)
#* @param title A single text string for the main plot header
#* @param plot A single text string for the plot type (e.g., "scatter", "line")
#* @serializer png
#* @get /vector-plot
function(values = "1,2,3,4,5", title = "Default Plot Title", plot = "scatter") { # add plot not plotType 
  print(values)
  # 1. Split the comma-separated URL string into an R character vector
  char_vector <- unlist(strsplit(values, split = ","))
  
  # 2. Convert to numeric and strip out any spaces automatically
  numeric_vector <- as.numeric(char_vector)
  
  # 3. Clean out any missing or failed parsing values (e.g., letters)
  numeric_vector <- na.omit(numeric_vector)
  #############################################################
  # 4. Generate the plot inside the active graphics device
  if (length(numeric_vector) > 0 && plot == "scatter") { # add amperstand 
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
  } 
  #else {
    # Fallback error plot if user inputs invalid data
    #plot(1, 1, type = "n", xaxt = "n", yaxt = "n", xlab = "", ylab = "", 
         #main = "Error: No valid numeric data provided")
  #}



else if (plot == "line") {
    plot(x_vals, vals, main = "Line Chart", xlab = "Index", ylab = "Value", 
         col = "red", type = "l", lwd = 3.3,lty=2,cex=2.3,# ,
         xlim = c(0.5, length(vals) + 0.5))
    grid()
         ######################
  } else if (plot == "hist") {
    from=min(vals)
    to=max(vals)
    by=max(vals)/length(vals) # length.out=sum(vals)/length(vals)
    brks=seq(from,to,by)
    hist(vals,breaks=brks, main = "Histogram", xlab = "Value", col = "lightblue", 
         border = "black")
    abline(v=c(mean(vals),median(vals)),lty=c(2,3),lwd=2)
    legend("topright",legend=c("mean","median"),lty=c(2,3),lwd=2)
    grid()
  } else if (plot == "density"){
    dens <- density(vals)

  # Plot density curve
  plot(dens,
     main = "Density Plot (Base R)",
     xlab = "Value",
     ylab = "Density",
     col = "blue",
     lwd = 3)
    grid()
  # Add a rug plot to show actual data points
  rug(vals, col = "darkgray")

  }
    else if (plot == "stripchart"){
      stripchart(vals)
      grid()
    }
    else if (plot == "boxplot"){
      boxplot(vals)
      grid()
    }
}