library(plumber)
library(RMySQL)
library(DBI)

#* Enable CORS so your frontend can talk to the API
#* @filter cors
function(res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  forward()
}

#* Get list of tables
#* @get /tables
#* @serializer text
function(db_name = "reference") { # default since no form to specify ok-- now input to just reference
  # Connect to the database specified in the GET query
  drv=MySQL()
  con <- dbConnect(
    drv,
    host     = "127.0.0.1",
    port     = 3306,
    username = "root",
    password = "189999",
    dbname   = "reference"
  )
  tables <- dbListTables(con)
  dbDisconnect(con)
  
  if (length(tables) == 0) {
    return("No tables found in this database.")
  }
  
  # Return tables as a clean comma-separated string
  paste(tables, collapse = ", ")
}

#* @apiTitle Dynamic R Vector Plotter API
#* Plot a single vector of numbers with a custom title
#* @param values A comma-separated string of numbers (e.g., “10,20,30”)
#* @param title A single text string for the main plot header
#* @param plot A single text string for the plot type (e.g., "scatter", "line")
#* @serializer png
#* @get /vector-plot
function(values = "1,2,3,4,5", title = "Default Plot Title", plot = "scatter") { # add plot not plotType 
  print(values)
  # 1. Split the comma-separated URL string into an R character vector
  char_vector <- unlist(strsplit(values, split = ","))
  
  # 2. Convert to numeric and strip out any spaces automatically
  numeric_vector <- as.numeric(char_vector)
  
  # 3. Clean out any missing or failed parsing values (e.g., letters)
  numeric_vector <- na.omit(numeric_vector)
  #############################################################
  # 4. Generate the plot inside the active graphics device
  if (length(numeric_vector) > 0 && plot == "scatter") { # add amperstand 
    # Customizing the base R plot style
    plot(
      numeric_vector, 
      type = "b",          # Both points and lines
      col = "#1a73e8",     # Clean blue color
      lwd = 3,             # Line width
      pch = 19,            # Solid circle points
      cex = 1.5,           # Point size
      main = title, 
      ylab = "Values", 
      xlab = "Index"
    )
    grid() # Add a subtle background grid
  } 
  #else {
    # Fallback error plot if user inputs invalid data
    #plot(1, 1, type = "n", xaxt = "n", yaxt = "n", xlab = "", ylab = "", 
         #main = "Error: No valid numeric data provided")
  #}



else if (plot == "line") {
    plot(x_vals, vals, main = "Line Chart", xlab = "Index", ylab = "Value", # main = title,
         col = "red", type = "l", lwd = 3.3,lty=2,cex=2.3,#  col red line
         xlim = c(0.5, length(vals) + 0.5))
    grid()
         ######################
  } else if (plot == "hist") {
    from=min(vals)
    to=max(vals)
    by=max(vals)/length(vals) # length.out=sum(vals)/length(vals)
    brks=seq(from,to,by)
    hist(vals,breaks=brks, main = "Histogram", xlab = "Value", col = "lightblue", # main = title, col bg 
         border = "black")
    abline(v=c(mean(vals),median(vals)),lty=c(2,3),lwd=2)
    legend("topright",legend=c("mean","median"),lty=c(2,3),lwd=2)
    grid()
  } else if (plot == "density"){
    dens <- density(vals)

  # Plot density curve
  plot(dens,
     main = "Density Plot (Base R)", # main = title,
     xlab = "Value",
     ylab = "Density",
     col = "blue", # col line
     lwd = 3)
    grid()
  # Add a rug plot to show actual data points
  rug(vals, col = "darkgray")

  }
    else if (plot == "stripchart"){
      stripchart(vals) # method = "stack",pch=19,col="lightblue",add=TRUE like rug()
      grid()
    }
    else if (plot == "boxplot"){
      boxplot(vals) # horizontal=TRUE,notch=TRUE,las=2,col="lightblue",border="grey20"
      grid()
    }
}
















#* @get /download
#* @param query The SQL query to run
#* @serializer contentType list(type="text/csv")
function(query = "") {
#########################################
# Function to extract database name after 'USE ' until first semicolon
extract_db_name <- function(query) {
  # Validate input
  if (!is.character(query) || length(query) != 1) {
    stop("Input must be a single character string containing the SQL query.")
  }
  # Use regex: (?i) for case-insensitive, lookbehind for 'USE ', stop at first semicolon
  match <- regexpr("(?i)(?<=USE\\s)[^;]+", query, perl = TRUE)
  if (match == -1) {
    return(NA)  # No match found
  }
  
  # Extract and trim whitespace
  db_name <- trimws(regmatches(query, match))
  
  return(db_name)
}

# Function to extract everything after the first semicolon in a SQL query
extract_after_first_semicolon <- function(query) {
  # Validate input
  if (!is.character(query) || length(query) != 1) {
    stop("Input must be a single character string.")
  }
  
  # Find the position of the first semicolon
  semicolon_pos <- regexpr(";", query, fixed = TRUE)
  
  # If no semicolon found, return an empty string
  if (semicolon_pos == -1) {
    return("")
  }
  
  # Extract substring after the first semicolon
  result <- substr(query, semicolon_pos + 1, nchar(query))
  
  # Trim leading/trailing whitespace
  result <- trimws(result)
  
  return(result)
}
#########################################


#readRenviron("/Users/aflac/Documents/GitHub/.env")


#########################################
  # Connect to MySQL
  drv=MySQL()
  #con <- NULL # Initialize connection ?
  tryCatch({
    con <- dbConnect(
      drv,
      dbname   = extract_db_name(query), #sakila
      host     = "localhost",
      port     = 3306, #3306 db connection
      user     = "root",
      password = "189999"
    )

#con=dbConnect(
  #drv,
  #host=Sys.getenv("DB_HOST"),
  #port=Sys.getenv("DB_PORT"),
  #user=Sys.getenv("DB_USER"),
  #password=Sys.getenv("DB_PASSWORD"),
  #dbname=Sys.getenv("DB_NAME")
#)
    
    # Run query
    df <- dbGetQuery(con, extract_after_first_semicolon(query)) # query

    ## review class and type non-functional
    #html_table=knitr::kable(df,"html",data.attr = 'id="myTable"')
    #html_table
    # return(as.character(html_table)) # as.character() returns download as .csv not .html (fix) and id not at the top of the table
    #return(html_table)

    # Convert to CSV in memory
    tmp <- tempfile(fileext = ".csv")
    write.csv(df, tmp, row.names = FALSE)
    
    # Return CSV as raw bytes
    readBin(tmp, "raw", n = file.info(tmp)$size)
    
  }, error = function(e) { # !!!!
    msg <- paste("Error:", e$message)
    return(charToRaw(msg))
  }, finally = {
    if (!is.null(con)) dbDisconnect(con)
  })
}

# instead /html at line 148, #* @get /downloadtablequery 
#* @get /downloadtablequery 
#* @param tableQuery The SQL query to run
#* @serializer contentType list(type="text/html")

function(tableQuery = "") {
#########################################
# Function to extract database name after 'USE ' until first semicolon
extract_db_name <- function(tableQuery) {
  # Validate input
  if (!is.character(tableQuery) || length(tableQuery) != 1) {
    stop("Input must be a single character string containing the SQL query.")
  }
  
  # Use regex: (?i) for case-insensitive, lookbehind for 'USE ', stop at first semicolon
  match <- regexpr("(?i)(?<=USE\\s)[^;]+", tableQuery, perl = TRUE)
  
  if (match == -1) {
    return(NA)  # No match found
  }
  
  # Extract and trim whitespace
  db_name <- trimws(regmatches(tableQuery, match))
  
  return(db_name)
}

# Function to extract everything after the first semicolon in a SQL query
extract_after_first_semicolon <- function(tableQuery) {
  # Validate input
  if (!is.character(tableQuery) || length(tableQuery) != 1) {
    stop("Input must be a single character string.")
  }
  
  # Find the position of the first semicolon
  semicolon_pos <- regexpr(";", tableQuery, fixed = TRUE)
  
  # If no semicolon found, return an empty string
  if (semicolon_pos == -1) {
    return("")
  }
  
  # Extract substring after the first semicolon
  result <- substr(tableQuery, semicolon_pos + 1, nchar(tableQuery))
  
  # Trim leading/trailing whitespace
  result <- trimws(result)
  
  return(result)
}

  # Connect to MySQL
  drv=MySQL()
  #con <- NULL # Initialize connection ?
  tryCatch({
    con <- dbConnect(
      drv,
      dbname   = extract_db_name(tableQuery), #sakila
      host     = "localhost",
      port     = 3306, #3306 connection sql
      user     = "root",
      password = "189999"
    )
    
    # Run query
    df <- dbGetQuery(con, extract_after_first_semicolon(tableQuery)) # query

    ## review class and type non-functional
    #html_table=knitr::kable(df,format="html", attr="id='id_1'")# table.attr = "class='table'")
    html_table=kable(df, format="html", table.attr="id='id_1'")
    #print(html_table) to R console
    #return(as.character(html_table)) # as.character() returns download as .csv not .html (fix) and id not at the top of the table
    return(html_table) # similar to ^^

    # Convert to CSV in memory
    tmp <- tempfile(fileext = ".csv")
    write.csv(df, tmp, row.names = FALSE)
    
    # Return CSV as raw bytes
    readBin(tmp, "raw", n = file.info(tmp)$size)
    
  }, error = function(e) { # !!!!
    msg <- paste("Error:", e$message)
    return(charToRaw(msg))
  }, finally = {
    if (!is.null(con)) dbDisconnect(con)
  })
}





















