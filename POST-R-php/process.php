php<?php
// Connect to your MySQL database
$conn = new mysqli('localhost', 'username', 'password', 'database_name');

// Capture the POST data
$input_data = $_POST['user_input'];

// Insert into the database
$sql = "INSERT INTO my_table (column_name) VALUES ('$input_data')";
$conn->query($sql);

$conn->close();
?>