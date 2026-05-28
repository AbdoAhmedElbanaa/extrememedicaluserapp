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
    
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        darkbg: '#0a0d16',
                        darksec: '#111523',
                        darksurface: 'rgba(20, 26, 45, 0.65)',
                        darkcard: 'rgba(28, 36, 62, 0.45)',
                        bordercolor: 'rgba(255, 255, 255, 0.08)',
                        primary: '#6366f1',
                        secondary: '#a855f7',
                        success: '#10b981',
                        danger: '#ef4444',
                        warning: '#f59e0b',
                        textprimary: '#f8fafc',
                        textsecondary: '#94a3b8',
                        textmuted: '#64748b',
                    },
                    fontFamily: {
                        sans: ['Outfit', 'sans-serif'],
                    },
                    boxShadow: {
                        primaryglow: '0 4px 15px rgba(99, 102, 241, 0.25)',
                    }
                }
            }
        }
    </script>
    
    <!-- Firebase Compat SDKs -->
    <script src="https://www.gstatic.com/firebasejs/10.8.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/10.8.0/firebase-auth-compat.js"></script>
</head>
<body class="bg-gradient-to-br from-[#1b2138] to-[#0a0d16] min-h-screen flex items-center justify-center font-sans text-textprimary px-4">
    
    <!-- Glassmorphic Login Box -->
    <div class="bg-darkcard border border-bordercolor backdrop-blur-xl w-full max-w-[440px] rounded-[28px] p-10 shadow-2xl flex flex-col">
        <div class="flex flex-col items-center gap-3 mb-8">
            <div class="w-[60px] h-[60px] bg-gradient-to-tr from-primary to-secondary rounded-2xl flex items-center justify-center text-white shadow-primaryglow text-3xl">
                <i class="fa-solid fa-house-medical"></i>
            </div>
            <h1 class="text-2xl font-black text-white tracking-wide">EXTREME MEDICAL</h1>
            <p class="text-xs text-textsecondary text-center -mt-1.5">System Administration Portal</p>
        </div>
        
        <form id="loginForm">
            <div class="flex flex-col gap-1.5 mb-5">
                <label for="email" class="text-[11px] font-bold text-textsecondary uppercase tracking-wider">Email Address</label>
                <input type="email" id="email" required placeholder="admin@extrememedical.com" class="bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-sm outline-none focus:border-primary transition duration-200">
            </div>
            <div class="flex flex-col gap-1.5 mb-5">
                <label for="password" class="text-[11px] font-bold text-textsecondary uppercase tracking-wider">Password</label>
                <input type="password" id="password" required placeholder="••••••••" class="bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-sm outline-none focus:border-primary transition duration-200">
            </div>
            <button type="submit" class="w-full bg-gradient-to-tr from-primary to-secondary text-white font-bold text-sm py-3.5 rounded-xl flex items-center justify-center gap-2 hover:-translate-y-0.5 hover:shadow-primaryglow transition duration-200 cursor-pointer mt-4" id="loginBtn">
                <i class="fa-solid fa-right-to-bracket"></i> Sign In
            </button>
        </form>
    </div>

    <!-- Spinner Loading Overlay -->
    <div class="fixed inset-0 bg-darkbg/85 flex flex-col items-center justify-center z-[3000] gap-4 opacity-0 pointer-events-none transition-opacity duration-300" id="loadingOverlay">
        <div class="w-12 h-12 border-4 border-primary/20 rounded-full border-t-primary animate-spin"></div>
        <p class="text-sm font-bold text-white">Authenticating Admin...</p>
    </div>

    <!-- Firebase setup & custom auth script -->
    <script src="assets/js/firebase-config.js"></script>
    <script>
        document.getElementById('loginForm').addEventListener('submit', async (e) => {
            e.preventDefault();
            const email = document.getElementById('email').value.trim();
            const password = document.getElementById('password').value;
            const overlay = document.getElementById('loadingOverlay');
            
            overlay.classList.remove('pointer-events-none');
            overlay.classList.add('opacity-100');
            
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
                overlay.classList.add('pointer-events-none');
                overlay.classList.remove('opacity-100');
                showToast(error.message || 'Login failed. Please verify credentials.', 'error');
            }
        });
    </script>
</body>
</html>
