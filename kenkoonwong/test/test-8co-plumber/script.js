// Get the form element
const form = document.getElementById('contactForm');
 
// Add submit event listener
form.addEventListener('submit', async (event) => {
  // Prevent default form submission (page reload)
  event.preventDefault();
 
  // Rest of the logic (collect data, send to server) will go here
});

// Collect form data
const formData = new FormData(form);
 
// Optional: Log data to console to verify
for (const [key, value] of formData.entries()) {
  console.log(`${key}: ${value}`); // Output: name: John, email: john@example.com, etc.
}


///
///
///
// body: formData, // Data to send (FormData object)
    // Optional: Add headers (e.g., for CSRF protection)
    //headers: {
      // 'Content-Type': 'application/x-www-form-urlencoded', // Uncomment if using URL-encoded data
      // 'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
    //}
try {
  const response = await fetch('https://127.0.0.1:8000/submit', {
    method: 'POST',
    body: formData // same as with  new URLSearchParams(formData).toString(), // OR lines 24-29
  });
 
  const result = await response.json();
 
  // Check if server response is successful
  if (response.ok) {
    // Show success message
    document.getElementById('formMessage').textContent = 'Message sent successfully!';
    document.getElementById('formMessage').style.color = 'green';
    // Reset form (optional)
    form.reset();
  } else {
    // Server returned an error (e.g., 400 Bad Request)
    document.getElementById('formMessage').textContent = `Error: ${result.message}`;
    document.getElementById('formMessage').style.color = 'red';
  }
}

//try {
  // Send POST request to server
  //const response = await fetch('https://127.0.0.1:8000/submit', {
    //method: 'POST', // HTTP method (GET, POST, etc.)
    //body: new URLSearchParams(formData).toString(),
//headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
  //});
 
  // Parse response (server should return JSON)
  //const result = await response.json();
//} 

catch (error) {
  // Network error (e.g., server unreachable)
  document.getElementById('formMessage').textContent = 'Failed to send message. Please check your internet connection.';
  document.getElementById('formMessage').style.color = 'red';
}
//catch (error) {
  // Handle network errors (e.g., no internet)
  //console.error('Network error:', error);
//}