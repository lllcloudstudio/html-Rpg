library(plumber)

#* @get /
#* @serializer html

function(){
  html_content <- '
<!DOCTYPE html>
<head>
</head>
<body>
<select id="myDropDown">
<option value="ny"> New York</option>
<option value="ct"> Connecticut</option>
</select>
<button id="dropDownSelect" onclick="getSelectedValue()">Get Selected Value</button>

<!-- empty container <div> or <p> -->
<p id="resultDisplay"> Waiting for result...</p>



<script>
    document.getElementById("dropDownSelect").addEventListener("click", function() {
    const dropdown = document.getElementById("myDropDown"); // or const
    const selectedValue = dropdown.value; // or const
    console.log("Selected Value:", selectedValue);
    // Encode query for URL
    const encodedQuery = encodeURIComponent(selectedValue);
    // Trigger file download
    window.location.href = `http://localhost:8000/downloaddropDown?selectedValue=${encodedQuery}`;
        });


        });
</script>
<script>
// to get the selected value from the dropdown and print it to html by <p> 
function getSelectedValue() {
  var dropdown = document.getElementById("myDropDown"); // or const
  var selectedValue = dropdown.value; // or const
  document.getElementById("resultDisplay").innerHTML = "Selected value to print to html: " + selectedValue;
  console.log("Selected Value:", selectedValue);
}
</script>
</body>
</html>'
return(html_content)
}

#* @get /downloaddropDown
#* @param selectedValue 
#* @serializer text
#contentType list(type="text/csv")
# {"error":"404 - Resource Not Found"}
function(selectedValue="") {
    print("Selected Value:", selectedValue) # not printed to console ERROR
    return(selectedValue)
}

#* Return "hello world"
#* @get /hW
#print("hello world X") # printed to console ERROR
function(notById) { # notById = NULL, ERROR Argument of class NULL cannot be used to set default value in OpenAPI Specifications. Not otherwise
  return("hello world")
  pr_set_debug(TRUE)
  #print("hello world Y") # not printed to console ERROR

}

######### @param Value Error set by var or const; see script line 23
#### localhost refused to connect: {"error":"500 - Internal server error"} 
#### <evalError in (function (selectedValue) {    print("Selected Value:", selectedValue)    return(selectedValue)})(): argument "selectedValue" is missing, with no default>




