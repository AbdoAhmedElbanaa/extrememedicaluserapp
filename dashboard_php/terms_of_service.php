<?php
/**
 * Public Terms of Service Page for Google Play Store Compliance
 */
require_once __DIR__ . '/config.php';
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Terms of Service - <?php echo SITE_NAME; ?></title>
    
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <!-- FontAwesome -->
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
                        bordercolor: 'rgba(255, 255, 255, 0.08)',
                        primary: '#6366f1',
                        secondary: '#a855f7',
                        textprimary: '#f8fafc',
                        textsecondary: '#94a3b8',
                    },
                    fontFamily: {
                        sans: ['Outfit', 'sans-serif'],
                    }
                }
            }
        }
    </script>
    
    <!-- Firebase SDK (Compat Mode) -->
    <script src="https://www.gstatic.com/firebasejs/10.8.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/10.8.0/firebase-database-compat.js"></script>
    <script src="assets/js/firebase-config.js"></script>
</head>
<body class="bg-darkbg text-textprimary font-sans min-h-screen flex flex-col justify-between">

    <!-- Navbar / Header -->
    <header class="border-b border-bordercolor bg-darksec/60 backdrop-blur-md sticky top-0 z-50">
        <div class="max-w-4xl mx-auto px-6 h-20 flex items-center justify-between">
            <div class="flex items-center gap-3">
                <div class="w-9 h-9 bg-gradient-to-tr from-primary to-secondary rounded-lg flex items-center justify-center text-white text-base shadow-primaryglow">
                    <i class="fa-solid fa-file-contract"></i>
                </div>
                <div class="flex flex-col">
                    <span class="text-sm font-black tracking-wider text-white">EXTREME MEDICAL</span>
                    <span class="text-[9px] font-bold text-primary uppercase tracking-widest">Terms Portal</span>
                </div>
            </div>
            <a href="login.php" class="text-xs text-textsecondary hover:text-white transition duration-200">
                <i class="fa-solid fa-right-to-bracket mr-1.5"></i>Admin Console
            </a>
        </div>
    </header>

    <!-- Main Content -->
    <main class="flex-1 max-w-4xl w-full mx-auto px-6 py-12">
        <div class="bg-darksec/40 border border-bordercolor rounded-[32px] p-8 md:p-12 shadow-2xl relative overflow-hidden">
            <!-- Background Glow -->
            <div class="absolute -top-40 -right-40 w-96 h-96 bg-primary/10 rounded-full blur-3xl"></div>
            
            <div class="relative">
                <h1 class="text-3xl font-black text-white tracking-tight mb-2">Terms of Service</h1>
                <p class="text-xs text-textsecondary mb-8">Last Updated: <?php echo date('F d, Y'); ?></p>
                
                <div class="h-[1px] bg-bordercolor mb-8"></div>
                
                <!-- Dynamic Content Loader -->
                <div id="termsContent" class="text-xs text-textsecondary leading-relaxed space-y-6 whitespace-pre-wrap">
                    <div class="flex items-center justify-center py-20">
                        <i class="fa-solid fa-circle-notch fa-spin text-primary text-2xl mr-3"></i>
                        <span>Loading official agreement from secure server...</span>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <!-- Footer -->
    <footer class="border-t border-bordercolor bg-darksec/40 py-6 text-center text-xs text-textsecondary">
        <div class="max-w-4xl mx-auto px-6 flex flex-col md:flex-row justify-between items-center gap-4">
            <p>&copy; <?php echo date('Y'); ?> <span class="font-semibold text-white"><?php echo SITE_NAME; ?></span>. All rights reserved.</p>
            <div class="flex gap-4">
                <a href="privacy_policy.php" class="hover:text-white transition">Privacy Policy</a>
                <a href="mailto:support@extrememedical.com" id="footerEmailLink" class="hover:text-white transition">Support</a>
            </div>
        </div>
    </footer>

    <script>
    document.addEventListener('DOMContentLoaded', () => {
        rtdb.ref('app_settings').once('value', (snapshot) => {
            const data = snapshot.val() || {};
            const contentEl = document.getElementById('termsContent');
            
            if (data.terms_of_service) {
                contentEl.innerHTML = escapeHtml(data.terms_of_service);
            } else {
                contentEl.innerHTML = `
<p class="mb-4">Please read these Terms of Service ("Terms") carefully before using the Extreme Medical Staff mobile application (the "App") or the web administration dashboard (the "Dashboard"). By accessing or using our services, you agree to be bound by these Terms.</p>

<h2 class="text-white text-sm font-bold mt-6 mb-2">1. Acceptance and Eligibility</h2>
<p class="mb-4">By registering a staff account, you represent that you are a certified healthcare practitioner or authorized clinic representative eligible to monitor telemetry diagnostics.</p>

<h2 class="text-white text-sm font-bold mt-6 mb-2">2. Equipment and Telemetry Use</h2>
<ul class="list-disc pl-6 mb-4 space-y-1">
    <li>You agree to use the App solely to monitor telemetry diagnostics of linked equipment.</li>
    <li>Unauthorized interception, reverse engineering, or modification of hardware signaling or data streams is strictly prohibited.</li>
    <li>Telemetry logs and alerts are diagnostic aids and must not replace professional clinical judgment.</li>
</ul>

<h2 class="text-white text-sm font-bold mt-6 mb-2">3. Account Responsibility</h2>
<ul class="list-disc pl-6 mb-4 space-y-1">
    <li>You are responsible for maintaining the confidentiality of your credentials (including Two-Factor Authentication codes).</li>
    <li>Falsification of identity, coordinates, address, or hardware serial numbers is grounds for immediate termination of access.</li>
</ul>

<h2 class="text-white text-sm font-bold mt-6 mb-2">4. Intellectual Property</h2>
<p class="mb-4">All application logic, dashboard elements, diagrams, layout designs, and translations are the property of Extreme Medical Co.</p>

<h2 class="text-white text-sm font-bold mt-6 mb-2">5. Limitation of Liability</h2>
<p class="mb-4">To the maximum extent permitted by law, Extreme Medical Co. shall not be liable for any indirect, incidental, or consequential damages resulting from telemetry sync delays or diagnostic tracking issues.</p>

<h2 class="text-white text-sm font-bold mt-6 mb-2">6. Modifications and Termination</h2>
<p class="mb-4">We reserve the right to suspend or terminate accounts that violate these Terms or present security risks to the clinical network.</p>
                `;
            }

            const about = data.about_info || {};
            if (about.support_email) {
                document.getElementById('footerEmailLink').setAttribute('href', 'mailto:' + about.support_email);
            }
        }, (error) => {
            console.error("Firebase fetch error:", error);
            document.getElementById('termsContent').innerHTML = `<p class="text-danger">Failed to fetch dynamic terms: ${error.message}</p>`;
        });
    });

    function escapeHtml(text) {
        if (!text) return '';
        return text
            .toString()
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#039;");
    }
    </script>
</body>
</html>
