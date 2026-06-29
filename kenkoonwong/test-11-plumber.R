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
