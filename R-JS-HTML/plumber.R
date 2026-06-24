# plumber.R

#* Echo the processed text back to the client
#* @post /process-text
library(plumber)
function(userInput) {
  # Perform your R operations here
  processed <- paste("R successfully processed your input:", toupper(userInput))
  print(processed)
  
  # Return as a list; plumber will automatically serialize to JSON
  list(result = processed)
}
print(class(list(result=processed)))
library(plumber)
library(dplyr)

r <- plumb("plumber.R")
r$run(port = 8000)