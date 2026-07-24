# plumber.R
library(plumber)

#* @apiTitle Plot Viewer with Download Button

# Serve HTML page with plot and download link
#* @get /
#* @html
function(req, res) {
  html <- '
  <!DOCTYPE html>
  <html>
  <head>
    <title>Plot Viewer</title>
  </head>
  <body style="font-family: Arial; text-align: center;">
    <h2>My R Plot</h2>
    <img src="/plot" alt="R Plot" style="border:1px solid #ccc; max-width: 90%;"><br><br>
    <a href="/download" download="plot.png">
      <button style="padding:10px 20px; font-size:16px;">Download Plot</button>
    </a>
  </body>
  </html>
  '
  res$body <- html
  res
}

# Serve the plot as PNG
#* @get /plot
#* @serializer contentType list(type="image/png")
function() {
  tmp <- tempfile(fileext = ".png")
  png(tmp, width = 800, height = 600)
  plot(cars, main = "Speed vs Stopping Distance", col = "blue", pch = 19)
  dev.off()
  readBin(tmp, "raw", n = file.info(tmp)$size)
}

# Serve the plot as a downloadable file
#* @get /download
#* @serializer contentType list(type="image/png")
function(res) {
  tmp <- tempfile(fileext = ".png")
  png(tmp, width = 800, height = 600)
  plot(cars, main = "Speed vs Stopping Distance", col = "blue", pch = 19)
  dev.off()
  res$setHeader("Content-Disposition", 'attachment; filename="plot.png"')
  readBin(tmp, "raw", n = file.info(tmp)$size)
}
