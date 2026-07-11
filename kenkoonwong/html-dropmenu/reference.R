library(plumber)

#* @get /
#* @serializer html

function(){
  html_content <- '
<!DOCTYPE html>
<head>
</head>
<body>
<!-- empty container <div> or <p> -->
<p id="resultDisplay"> Waiting for result...</p>
</body>
</html>'
return(html_content)
}


#* Return "hello world"
#* @get /hello
function() {
  "hello world"
}