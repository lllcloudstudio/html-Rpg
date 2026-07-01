const express = require("express");
const multer = require("multer");
const mysql = require("mysql2");
const fs = require("fs");
const fastcsv = require("fast-csv");
const cors = require("cors");

const app = express();
app.use(cors()); // Enables cross-origin requests from your HTML file

// 1. Configure MySQL Connection Pool
const pool = mysql.createPool({
    host: "localhost",
    user: "root",          // Your MySQL username
    password: "189999",  // Your MySQL password
    database: "my_database" // Your database name
}).promise();

// 2. Configure Multer for local temporary file storage
const upload = multer({ dest: "uploads/" });

// 3. POST Endpoint to process the CSV upload
app.post("/upload", upload.single("csvFile"), (req, res) => {
    if (!req.file) {
        return res.status(400).json({ error: "No file uploaded." });
    }

    const filePath = req.file.path;
    let csvData = [];

    // Parse the uploaded file stream
    fs.createReadStream(filePath)
        .pipe(fastcsv.parse({ headers: true })) // "headers: true" maps the first row as keys
        .on("data", (row) => {
            // Push values in the order matching your SQL query columns
            // Example columns: name, email, age
            csvData.push([row.name, row.email, row.age]);
        })
        .on("end", async () => {
            try {
                // Perform a single bulk insert operation for optimal performance
                const sql = "INSERT INTO users (name, email, age) VALUES ?";
                await pool.query(sql, [csvData]);

                // Cleanup: Delete the temp file from the disk
                fs.unlinkSync(filePath);

                res.json({ message: `${csvData.length} records successfully imported!` });
            } catch (err) {
                // Cleanup temp file even if the SQL operation crashes
                if (fs.existsSync(filePath)) fs.unlinkSync(filePath);
                
                console.error(err);
                res.status(500).json({ error: "Database insertion failed: " + err.message });
            }
        })
        .on("error", (error) => {
            if (fs.existsSync(filePath)) fs.unlinkSync(filePath);
            res.status(500).json({ error: "Failed to parse CSV: " + error.message });
        });
});

// Run the Express Server
app.listen(3000, () => {
    console.log("Server running safely on http://localhost:3000");
});