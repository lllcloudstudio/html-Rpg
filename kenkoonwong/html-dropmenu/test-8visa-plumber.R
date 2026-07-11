#
# This is a Plumber API. You can run the API by clicking
# the 'Run API' button above.
#
# Find out more about building APIs with Plumber here:
#
#    https://www.rplumber.io/
#

library(plumber)

#* @get /
#* @serializer html

function(){
  html_content <- '
<!DOCTYPE html>
<head>
</head>
<body>

<h2>Enter comma‑separated numeric values</h2>
<textarea id="csv" rows="4" cols="50">1, 2, 5, 8, 3</textarea><br><br>

<button onclick="sendData()">Generate Plot</button>

<h3>Plot Output</h3>
<img id="plot" style="border:1px solid #444; max-width:500px;">

<script>
async function sendData() {
  const csv = document.getElementById("csv").value;

  try {
    const response = await fetch("http://localhost:8000/plot", {
      method: "POST",
      headers: {
        "Content-Type": "text/plain"
      },
      body: csv
    });

    if (!response.ok) {
      alert("Error: " + await response.text());
      return;
    }

    const blob = await response.blob();
    const url = URL.createObjectURL(blob);
    document.getElementById("plot").src = url;

  } catch (err) {
    alert("Network error: " + err);
  }
}
</script>

</body>
</html>
'
return(html_content)
}




#* Create a plot from CSV numeric values
#* @post /plot
#* @serializer png
function(req) {
  # Extract the raw POST body
  body <- req$postBody
  
  # Basic validation
  if (is.null(body) || nchar(body) == 0) {
    stop("Empty input. Provide comma-separated values.")
  }
  
  # Split CSV and convert to numeric
  values <- strsplit(body, ",")[[1]]
  values <- trimws(values)
  
  # Validate numeric values
  nums <- suppressWarnings(as.numeric(values))
  if (any(is.na(nums))) {
    stop("Invalid numeric values. Ensure all entries are numbers.")
  }
  
  # Produce a simple plot
  plot(
    nums,
    type = "o",
    main = "Plot of Submitted Values",
    xlab = "Index",
    ylab = "Value"
  )
}
