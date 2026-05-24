<?php
/**
 * Administrator Authentication Portal
 */
require_once __DIR__ . '/config.php';

// Redirect to dashboard if already authenticated
if (isset($_SESSION['admin_logged_in']) && $_SESSION['admin_logged_in'] === true) {
    header('Location: index.php');
    exit;
}

// Session initialization endpoint (POST request)
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'set_session') {
    $_SESSION['admin_logged_in'] = true;
    $_SESSION['admin_email'] = filter_var($_POST['email'], FILTER_SANITIZE_EMAIL);
    header('Content-Type: application/json');
    echo json_encode(['status' => 'success']);
    exit;
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Extreme Medical Admin</title>
    
    <!-- Fonts & Icons -->
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;700;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- Theme CSS -->
    <link rel="stylesheet" href="assets/css/style.css">
    
    <!-- Firebase Compat SDKs -->
    <script src="https://www.gstatic.com/firebasejs/10.8.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/10.8.0/firebase-auth-compat.js"></script>
</head>
<body class="login-body">
    
    <!-- Glassmorphic Login Box -->
    <div class="login-card">
        <div class="login-logo">
            <div class="login-logo-icon">
                <i class="fa-solid fa-house-medical"></i>
            </div>
            <h1 class="login-title">EXTREME MEDICAL</h1>
            <p class="login-subtitle">System Administration Portal</p>
        </div>
        
        <form id="loginForm">
            <div class="form-group">
                <label for="email">Email Address</label>
                <input type="email" id="email" required placeholder="admin@extrememedical.com">
            </div>
            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" required placeholder="••••••••">
            </div>
            <button type="submit" class="btn-primary-gradient login-btn" id="loginBtn">
                <i class="fa-solid fa-right-to-bracket"></i> Sign In
            </button>
        </form>
    </div>

    <!-- Spinner Loading Overlay -->
    <div class="loading-overlay" id="loadingOverlay">
        <div class="spinner"></div>
        <p class="loading-text">Authenticating Admin...</p>
    </div>

    <!-- Firebase setup & custom auth script -->
    <script src="assets/js/firebase-config.js"></script>
    <script>
        document.getElementById('loginForm').addEventListener('submit', async (e) => {
            e.preventDefault();
            const email = document.getElementById('email').value.trim();
            const password = document.getElementById('password').value;
            const overlay = document.getElementById('loadingOverlay');
            
            overlay.classList.add('active');
            
            try {
                // 1. Authenticate user against Firebase
                const userCredential = await auth.signInWithEmailAndPassword(email, password);
                const user = userCredential.user;
                
                // 2. Transmit credentials to PHP session handler
                const response = await fetch('login.php', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: `action=set_session&email=${encodeURIComponent(user.email)}`
                });
                
                const resData = await response.json();
                if (resData.status === 'success') {
                    window.location.href = 'index.php';
                } else {
                    showToast('Failed to initialize session.', 'error');
                }
            } catch (error) {
                console.error("Auth error:", error);
                overlay.classList.remove('active');
                showToast(error.message || 'Login failed. Please verify credentials.', 'error');
            }
        });
    </script>
</body>
</html>
