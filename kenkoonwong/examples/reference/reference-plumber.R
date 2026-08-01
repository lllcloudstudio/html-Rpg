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



