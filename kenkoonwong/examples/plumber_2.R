#* Generate a plot via POST data
#* @param title The title text passed in the request body
#* @serializer png
#* @post /plot-secure
function(title = "Default Title") {
  plot(1:10, main = title)
}


### curl -X POST "http://localhost:8000/plot-secure" -H "Content-Type: application/json" -d '{"title":"My Custom Title"}' --output plot.png
## curl: (7) Failed to connect to localhost port 8000 after 0 ms: Could not connect to server