library(plumber)
library(base64enc)

#* @parser form
#* @serializer html
#* @post /create-plot
function(req, res) {
  # 1. Extract data sent from the HTML form
  print(req)
  print(res)
  num_points <- as.numeric(req$body$points) ###################################!
  plot_color <- req$body$color ###!
  
  # Fallback defaults if form fields are empty
  if (is.na(num_points) || num_points <= 0) num_points <- 100
  if (is.null(plot_color) || plot_color == "") plot_color <- "skyblue"
  
  # 2. Generate the R Plot to a temporary file
  tmp_file <- tempfile(fileext = ".png")
  png(tmp_file, width = 600, height = 400)
  
  # Create your custom R chart
  rand_data <- rnorm(num_points)
  hist(rand_data, 
       main = paste("Histogram of", num_points, "Points"), 
       col = plot_color, 
       border = "white",
       xlab = "Value")
  
  dev.off() # Save and close the file device
  
  # 3. Convert the PNG image file into a Base64 string
  img_64 <- base64enc::base64encode(tmp_file)
  unlink(tmp_file) # Delete temporary file from disk
  
  # 4. Construct the HTML structure
  html_output <- sprintf('
  <!DOCTYPE html>
  <html>
  <head>
    <title>R Plumber Output</title>
    <style>
      body { font-family: sans-serif; text-align: center; margin: 40px; background: #fafafa; }
      .card { background: white; padding: 25px; display: inline-block; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.1); }
      img { border: 1px solid #ddd; border-radius: 4px; margin-top: 15px; }
      a { display: block; margin-top: 20px; color: #007bff; text-decoration: none; }
    </style>
  </head>
  <body>
    <div class="card">
      <h2>Success! Plot Generated</h2>
      <p>Rendered dynamically via POST method request.</p>
      <!-- Base64 Source String directly embeds image data -->
      <img src="data:image/png;base64,%s" alt="Generated R Plot">
      <a href="javascript:history.back()">← Go Back & Edit</a>
    </div>
  </body>
  </html>
  ', img_64)
  
  # 5. Return the payload with proper HTML header types
  res$status <- 200
  res$setHeader("Content-Type", "text/html; charset=utf-8")
  res$body <- html_output
  return(res)
}
