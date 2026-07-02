#* @apiTitle CSV Textarea Read
#* @parser text
#* @param csvText
#* @post /read_csv
function(req) { # csvText or csv-data as parameter not function(req,res){}
  # req$postBody contains the raw CSV string from the textarea
  csv_string <- req$postBody # set R variable 
  
  # Read the CSV string into an R data frame
  df <- read.csv(textConnection(csv_string))
  
  # Perform your calculations or data manipulations here
  # Example: return the summary or structure
  return(list(
    message = "CSV successfully received and processed!",
    row_count = nrow(df),
    column_names = names(df)
  ))
}
