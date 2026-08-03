library(plumber)

#* @apiTitle Plumber Example API
#* @apiDescription Plumber example description.
#* @get /
#* @serializer html

function() {
html_content='
<!DOCTYPE html>
<html lang=“en”>
<head>
  <meta charset=“UTF-8”>
  <meta name=“viewport” content=“width=device-width, initial-scale=1.0”>
  <style>

  </style>
</head>
<body>

    <h2>Vector data Plot </h2>
    <!--<form id="myForm" action="https://127.0.0.1:8000/Rplot" method="post">-->
    <form id="myForm">
        <!-- Input for the CSV text -->
        <label for="plot_id2">Desired MySQL Table Name:</label><br>
        <input type="text" id="plot_id2" name="plot_id2" required placeholder="e.g., customer_logs"><br><br>
        
        <label for="csv_data3">Paste Vector Data (Do not Include Headers):</label><br>
        <textarea id="csv_data3" name="csv_data3" rows="10" cols="50" required placeholder="23,45,67,89,01,34,16"></textarea>
        <br><br>


        <input type="submit" value="Create Rplot">
    </form>


<img id="plot" style="border:1px solid #444; max-width:500px;">

<br><br>

<script>

</script>

<script>
const form = document.getElementById("myForm");
form.addEventListener("submit", async (e) => {
    e.preventDefault();

    const textarea = form.elements["csv_data3"]; // e.g., "apple, orange, banana" //document.getElementById("csv_data3"); 
    const dropdown = form.elements["plot_id2"];//document.getElementById("plot_id2");

    // 1. Split by commas, trim spaces, and filter empty strings
    const jsonArray = textarea.value // text
        .split(",")
        .map(item => item.trim())
        .filter(item => item !== "");

    // 2. Build the payload
    const payload = { // or JSON data jsonData
        csv_array: jsonArray,        // Becomes an R character vector
        dropdown_option: dropdown.value // Becomes an R string
    };

    // 3. Send the POST request
    try {
        const response = await fetch("https://127.0.0.1:8000/Rplot", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify(payload) // or jsonString
        });

    if (!response.ok) {
      alert("Error: " + await response.text()); // by post to Rplot as JSON stringify
      return; // ok const response check data type i.e. text or stringify 
    }
    const result = await response.json(); // result: good to log not appl.
    console.log("Server response:", result);

    const blob = await response.blob(); // out of if and try 
    const url = URL.createObjectURL(blob);
    document.getElementById("plot").src = url;    


    } catch (error) { ///////////////
        console.error("Fetch Failed:", error);
    }
})

</script>



</body>
</html>
'

return(html_content)
}




#* Create a plot from CSV numeric values
#* @post /Rplot
#* @serializer png
function(req) {
  # Extract the raw POST body
  body <- req$postBody
  print(body)
  print(length(body))
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
