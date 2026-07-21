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
    <form id="myForm" action="/Rplot" method="post">
        <!-- Input for the CSV text -->
        <label for="plot_id2">Desired MySQL Table Name:</label><br>
        <input type="text" id="plot_id2" name="plot_id2" required placeholder="e.g., customer_logs"><br><br>
        
        <label for="csv_data3">Paste Vector Data (Do not Include Headers):</label><br>
        <textarea id="csv_data3" name="csv_data3" rows="10" cols="50" required placeholder="23,45,67,89,01,34,16"></textarea>
        <br><br>


        <input type="submit" value="Create Rplot">
    </form>


<br><br>
<script>
const form = document.getElementById("myForm");
form.addEventListener("submit", async (e) => {
    e.preventDefault();

    const textarea = form.elements["csv_data3"]; // e.g., "apple, orange, banana"
    const dropdown = form.elements["plot_id2"];

    // 1. Split by commas, trim spaces, and filter empty strings
    const jsonArray = textarea.value
        .split(",")
        .map(item => item.trim())
        .filter(item => item !== '');

    // 2. Build the payload
    const payload = {
        csv_array: jsonArray,        // Becomes an R character vector
        dropdown_option: dropdown.value // Becomes an R string
    };

    // 3. Send the POST request
    try {
        const response = await fetch("http://127.0.0.1:8000", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify(payload)
        });

        const result = await response.json();
        console.log("Server response:", result);
    } catch (error) {
        console.error("Fetch Failed:", error);
    }
});
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
function(csv_array, dropdown_option) {
  # csv_array automatically arrives as a native R character vector
  # dropdown_option arrives as a single character string
  
  # Example operations in R:
  item_count <- length(csv_array)
  upper_items <- toupper(csv_array)
  print(item_count)
  print(upper_items)
  # Return a response list (automatically converted back to JSON)
  list(
    status = "success",
    message = paste("Processed", item_count, "items for option", dropdown_option),
    received_items = upper_items,
    selected_option = dropdown_option
  )
  
}
