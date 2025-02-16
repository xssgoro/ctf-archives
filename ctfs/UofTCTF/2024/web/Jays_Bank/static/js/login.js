document.addEventListener('DOMContentLoaded', function() {
    const loginForm = document.getElementById('loginForm');
    const messageBox = document.getElementById('messageBox');

    loginForm.addEventListener('submit', function(e) {
        e.preventDefault();
        const data = {
            username: loginForm.username.value,
            password: loginForm.password.value
        };

        fetch('/login', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        }).then(response => response.json())
        .then(json => {
            showMessage(json.message, json.success ? 'success' : 'error');
            if (json.success) {
                window.location.href = '/dashboard'; 
            }
        }).catch(error => {
            showMessage('An error occurred. Please try again.', 'error');
        });
    });

    function showMessage(message, type) {
        messageBox.textContent = message;
        messageBox.className = `message-box ${type}`;
        messageBox.style.display = 'block'; 
    }
});
