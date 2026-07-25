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
    <form id="myForm" action="https://127.0.0.1:8000/Rplot" method="post">
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
const form = document.getElementById("myForm");
form.addEventListener("submit", async (e) => {
    e.preventDefault();

    const textarea = form.elements["csv_data3"]; // e.g., "apple, orange, banana"
    const dropdown = form.elements["plot_id2"];

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

#* @apiTitle JSON Array Processor

#* Process the incoming JSON payload or as /submit
#* @post /Rplot
#* @serializer json
###########* @serializer png
function(csv_array, dropdown_option) {
  # csv_array automatically arrives as a native R character vector
  # dropdown_option arrives as a single character string
  vector_data=c(1,2,3,4,5)
  print(toupper(vector_data))
  print(csv_array) # no
  print(dropdown_option) # no
  # Example operations in R:
  item_count <- length(csv_array)
  upper_items <- toupper(csv_array)
  print(item_count) # [1] 5
  print(upper_items) # [1] "1" "2" "3" "4" "5"
  plot(csv_array)
  

  # Return a response list (automatically converted back to JSON)
  #list(
    #status = "success",
    #message = paste("Processed", item_count, "items for option", dropdown_option),
    #received_items = upper_items,
    #selected_option = dropdown_option
  #)
  
}
