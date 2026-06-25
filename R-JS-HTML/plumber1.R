# plumber1.R

library(plumber)

#* @apiTitle HTML to Plumber POST API
#* user_name to username
#* Process data submitted from the HTML form
#* @post /process-text
function(username) {
  # Return a response that the HTML form can display
  list(
    status = "Success",
    message = paste0("Hello, ", username, "! Your data was received by R.")
  )
}



