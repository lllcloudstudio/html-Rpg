library(DBI)
library(odbc)
library(plumber)
library(mime)
install.packages(c(“plumber”, “DBI”, “odbc”, “mime”))

#10-11
# Connect to your database
drv=MySQL()
con <- dbConnect(
      drv,
      dbname   = "sakila",
      host     = "localhost",
      port     = 8000,
      user     = "root",
      password = "189999"
    )


#* Upload a CSV file and save it to the SQL database
#* @post /upload
#* @serializer json
function(req) {
  # Parse multipart form data
  form <- mime::parse_multipart(req)

  # Check if a file was provided
  if (is.null(form$file)) {
    res$status <- 400
    return(list(error = “No file uploaded. Make sure the form field is named ‘file’.”))
  }

  # Read the uploaded file (assuming it’s a CSV)
  # form$file$datapath contains the temporary location of the file
  uploaded_data <- read.csv(form$file$datapath)

  # Upload the data to the SQL database
  tryCatch({
    dbWriteTable(con, name = “target_table_name”, value = uploaded_data, append = TRUE, row.names = FALSE)
    list(success = TRUE, message = “File successfully uploaded and data inserted into SQL.”)
  }, error = function(e) {
    res$status <- 500
    list(error = paste(“Database insertion failed:”, e$message))
  })
}


curl -X POST “http://localhost:8000/upload” -F “file=@/path/to/your/file.csv”



#######################################################################################
#############################################################################################
####################################################################################
#* Process the HTML Form Upload
#* @post /upload
#### add 6/30/2026 1:43
#* @param query
#* @serializer html


################################################################
function(req, res) {
  # Parse the incoming multipart form data
  multipart <- mime::parse_multipart(req)
  
  # Validation: Check if a file was actually uploaded
  if (is.null(multipart$file)) {
    res$status <- 400
    return("<h3>Error: No file selected.</h3><a href=‘/‘>Go Back</a>")
  }
  
  # Extract temporary file path and actual file name
  tmp_file_path <- multipart$file$datapath
  original_name <- multipart$file$name

    con <- dbConnect(
      drv, # re-assign? 
      dbname   = extract_db_name(query), #sakila
      host     = "localhost",
      port     = 3306,
      user     = "root",
      password = "189999"
    )

    con <- dbConnect(
      drv, # re-assign? 
      dbname   = extract_db_name(query), #sakila
      host     = "localhost",
      port     = 3306,
      user     = "root",
      password = "189999"
    )





  # Read data and write to database safely
  tryCatch({
    # Read the temporary CSV file
    uploaded_data <- readr::read_csv(tmp_file_path)
    
    # Append data frame into the database table

    dbWriteTable(
      conn = con, 
      name = "uploaded_records", #########################
      value = uploaded_data, 
      append = TRUE, 
      row.names = FALSE
    )
    
    # Return a success message in HTML format
    return(paste0(
      "<h3>Success!</h3>",
      "<p>Successfully inserted <strong>", nrow(uploaded_data), "</strong> rows ",
      "from <em>", original_name, "</em> into the database.</p>",
      "<a href=‘/‘>Upload another file</a>"
    ))

  }, error = function(e) {
    # Fail-safe error
res$status <- 500 
return(paste0("<h3>Database Error</h3><p>", e$message, "</p><a href='/>Go Back</a>")) }) }

# write_delim(data,'titanic.csv',delim=',')
