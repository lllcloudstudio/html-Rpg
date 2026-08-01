# plumber1.R

library(plumber)

#* @apiTitle HTML to Plumber POST API
#* user_name to username
#* Process data submitted from the HTML form
#* @post /process-text
function(username) { # by textarea {"error":"404 - Resource Not Found"} by Live server output
  # Return a response that the HTML form can display
  list(
    status = "Success",
    message = paste0("Hello, ", username, "! Your data was received by R.")
  )
}



