library(plumber)

#* @apiTitle Plumber Example API
#* @apiDescription Plumber example description.
#* @get /
#* @serializer html

function() {
  html_content <- '
<!DOCTYPE html>
<head>
</head>
<body>
  <h3>Enter comma-separated numeric values</h3>
  <textarea id="vals" rows="3" cols="40">1,2,3,4,5</textarea><br><br>
  <button onclick="getPlot()">Generate Plot</button>

  <h3>Plot:</h3>
  <img id="plotImg" style="border:1px solid #ccc; max-width:400px;">

<script>
function getPlot() {
  const txt = document.getElementById("vals").value.trim();
  if (!txt) {
    alert("Please enter some values.");
    return;
  }

  // URL-encode the query
  const url = "http://localhost:8000/plot_values?x=" + encodeURIComponent(txt);

  // Fetch the PNG and display it without reloading the page
  fetch(url)
    .then(res => {
      if (!res.ok) throw new Error("Server error");
      return res.blob();
    })
    .then(blob => {
      const imgUrl = URL.createObjectURL(blob);
      document.getElementById("plotImg").src = imgUrl;
    })
    .catch(err => alert(err));
}
</script>
</body>
</html>
'
  return(html_content)
}


#* Return a plot from comma-separated numeric values
#* @get /plot_values
### @param txt instead of @query x:[string]
#* @param txt
#* @serializer png

function(txt) {
  # Validate and parse
  #raw <- query$x
  print(txt)
  #if (is.null(raw)) {
    #stop("Provide x values, e.g. ?x=1,2,3")
  #}
  
  # raw becomes a character vector; if comma-separated, split each element
  #vals <- unlist(strsplit(raw, ","))
  #nums <- suppressWarnings(as.numeric(vals))
  
  if (any(is.na(txt))) {
    stop("All values must be numeric.")
  }
  
  # Produce a simple plot
  plot(
    txt,
    type = "b",
    main = "User-provided values",
    xlab = "Index",
    ylab = "Value"
  )
}