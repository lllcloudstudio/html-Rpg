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
<input type="file" id="filePicker" accept=".csv"> <!-- ALT 1 /> -->
<input type="text" id="textField" value="Project File"> <!-- ALT 1 /> -->


<h2>Plot Output</h2>
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

<!-- 2 input boxes at line 24-25-->


<script>
const textDescription = "Sales Data for Q1 2026"
const csvString = "id,product,revenue\n1,Widget A,1000\n2,Widget B,1500\n3,Widget C,2000";
const formData = new FormData();
// As JSON file 
const myVar = "Hello from JS!";

fetch("http://localhost:8000/printVar", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({ value: myVar })
})
.then(res => res.json())
.then(data => console.log("R API replied:", data))
.catch(err => console.error(err));
</script>

<script>
// As form data
formData.append("description", textDescription); // or textField
formData.append("csv_file", new Blob([csvString], { type: "text/csv" }), "q1_sales.csv");
fetch("https://localhost:8000", {
  method: "POST",
  body: formData
})
.then(response => response.json())
.then(data => console.log("Success:", data))
.catch(error => console.error("Error:", error));
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
  print(req)
  body <- req$postBody
  print(body)
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

####### BUTTON
## {"error":"405 - Method Not Allowed"} INTERNAL server error when using GET method on /plot endpoint. Use POST method instead. Regardless of 1+ script
#* @param myVar
#* @post /printVar
function(myVar){
  body <- jsonlite::fromJSON(myVar$postBody)
  print(paste("Received from JS:",body$value))
  list(status="ok",received=body$value)
}



########* @param textDescription
######## @get /description {"error":"500 - Internal server error"}
######## @post /description 405 method not allowed
#function(textDescription){
  #print(paste("Received description:", textDescription))
#}