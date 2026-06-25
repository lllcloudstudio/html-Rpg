# plumber.R
library(plumber)
library(magrittr)
library(dplyr)
#* Echo the processed text back to the client
#* @post /process-text


function(userInput) {
  # Perform your R operations here
  processed <- paste("R successfully processed your input:", toupper(userInput))
  print(processed)
  
  # Return as a list; plumber will automatically serialize to JSON
  list(result = processed)
}
