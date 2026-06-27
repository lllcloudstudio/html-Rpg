library(plumber)
library(tidyverse)
library(magrittr)
library(dplyr)
library(DBI)
library(RMySQL)

# file <- "migraine.csv"
# if (file.exists(file)) {
  # df <- read_csv(file)
# } else {
# df <- tibble(date=as.POSIXct(character()))
# }

#* @apiTitle MySQL to R

#* @apiDescription A simple API to db

#* Return HTML content to page, no new tab 
#* @get /
#* @serializer html

function() {
html_content = '<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>MySQL to R to HTML</title>
    <style>
        table, th, td { border: 1px solid black; border-collapse: collapse; padding: 8px; }
    </style>
</head>
<body>
    <h2>Enter SQL Query</h2>
    <textarea id="sqlQuery" rows="4" cols="50" placeholder="SELECT * FROM my_table LIMIT 10;"></textarea>
    <br>
    <button onclick="executeQuery()">Execute</button>

    <h3>Results</h3>
    <table id="resultTable">
        <thead id="tableHead"></thead>
        <tbody id="tableBody"></tbody>
    </table>

    <script>
        async function executeQuery() {
            const queryText = document.getElementById('sqlQuery').value;

            try {
                // POST to R Plumber API
                const response = await fetch('http://localhost:8000/query', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ query: queryText })
                });

                if (!response.ok) throw new Error('Query execution failed');

                const data = await response.json();
                renderTable(data);
            } catch (error) { # first } is from try
                console.error('Error:', error);
                alert('Error running query. Check console for details.');
            } # { to catch
        } # executeQuery function }

        function renderTable(data) {
            const tableHead = document.getElementById('tableHead');
            const tableBody = document.getElementById('tableBody');
            
            tableHead.innerHTML = '';
            tableBody.innerHTML = '';

            if (data.length === 0) return;

            // Generate Table Headers
            const headers = Object.keys(data[0]);
            let headerRow = '<tr>';
            headers.forEach(h => headerRow += `<th>${h}</th>`);
            headerRow += '</tr>';
            tableHead.innerHTML = headerRow;

            // Generate Table Rows
            data.forEach(row => {
                let tr = '<tr>';
                headers.forEach(h => tr += `<td>${row[h]}</td>`);
                tr += '</tr>';
                tableBody.innerHTML += tr;
            });
        }
    </script>
</body>
</html>
'
 return(html_content)
}

#* 
#* @get /data **************************
function(query) {
# Establish connection Opt 1 
# MySQL connection  
# Create a driver
drv <- MySQL() # not postgre or RMariadb
# Connection parameters
host <- "localhost"   # or "localhost"
port <- 3306          # default MySQL port
user <- "root"
password <- Sys.getenv("MYSQL_PASS") # password <- ""
dbname <- "sakila"
# Connection to a MySQL database
con <- tryCatch({
  dbConnect(
    drv,
    host = host,
    port = port,
    user = user,
    password = password,
    dbname = dbname
  )
}, error = function(e) {
  stop("Database connection failed: ", e$message)
})

query <- "SELECT * FROM actor" # example if actor
results <- NULL
tryCatch({
    results <- dbGetQuery(con, query)
    message("✅ Query executed successfully.")
}, error = function(e) {
    stop("❌ Query failed: ", e$message)
})
# Display results
print(results)
# Always disconnect after use
if (!is.null(con)) {
    dbDisconnect(con)
    message("🔌 Disconnected from database.")
}

#dbWriteTable(con, "my_table", dynamic_data, overwrite = TRUE) # to connect to binary file and view as not db "my_table"
#dbListTables(con)  # list table
#dbGetQuery(con, "SELECT * FROM my_table") # view (print) and or query db as my_table
# List tables
tables <- dbListTables(con) # 1 table, how multiple tables?
print(tables) # connects to local mysql database but recommends using rmariadb to query
#return(tables)




  # **********************Execute the SQL query and return the results
}
# sql_value ****************************