<?php
/**
 * Public Privacy Policy Page for Google Play Store Compliance
 */
require_once __DIR__ . '/config.php';
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Privacy Policy - <?php echo SITE_NAME; ?></title>
    
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
                    <i class="fa-solid fa-user-shield"></i>
                </div>
                <div class="flex flex-col">
                    <span class="text-sm font-black tracking-wider text-white">EXTREME MEDICAL</span>
                    <span class="text-[9px] font-bold text-primary uppercase tracking-widest">Privacy Portal</span>
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
                <h1 class="text-3xl font-black text-white tracking-tight mb-2">Privacy Policy</h1>
                <p class="text-xs text-textsecondary mb-8">Last Updated: <?php echo date('F d, Y'); ?></p>
                
                <div class="h-[1px] bg-bordercolor mb-8"></div>
                
                <!-- Dynamic Content Loader -->
                <div id="policyContent" class="text-xs text-textsecondary leading-relaxed space-y-6 whitespace-pre-wrap">
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
                <a href="terms_of_service.php" class="hover:text-white transition">Terms of Service</a>
                <a href="mailto:support@extrememedical.com" id="footerEmailLink" class="hover:text-white transition">Support</a>
            </div>
        </div>
    </footer>

    <script>
    document.addEventListener('DOMContentLoaded', () => {
        rtdb.ref('app_settings').once('value', (snapshot) => {
            const data = snapshot.val() || {};
            const contentEl = document.getElementById('policyContent');
            
            if (data.privacy_policy) {
                contentEl.innerHTML = escapeHtml(data.privacy_policy);
            } else {
                contentEl.innerHTML = `
<p class="mb-4">Extreme Medical Co. ("we," "our," or "us") operates the Extreme Medical Staff mobile application (the "App") and the administrative control dashboard (the "Dashboard"). This Privacy Policy describes how we collect, use, share, and protect personal and diagnostic information when you use our services.</p>

<h2 class="text-white text-sm font-bold mt-6 mb-2">1. Information We Collect</h2>
<p class="mb-4">We collect information directly from your telemetry device, profile configuration, and support requests to provide and improve the service. This includes:</p>
<ul class="list-disc pl-6 mb-4 space-y-1">
    <li><strong>Personal Identification:</strong> First name, last name, email address, phone number.</li>
    <li><strong>Telemetry & Diagnostic Data:</strong> Hardware telemetry readings, sensor logs, device diagnostics, device state indicators.</li>
    <li><strong>Device Metadata:</strong> Hardware serial numbers, version indicators, operating system, and system identifiers.</li>
    <li><strong>Geolocation Data:</strong> Coordinates (latitude and longitude) of clinic sites to map equipment locations.</li>
</ul>

<h2 class="text-white text-sm font-bold mt-6 mb-2">2. How We Use Your Information</h2>
<p class="mb-4">We process your personal and telemetry information for the following purposes:</p>
<ul class="list-disc pl-6 mb-4 space-y-1">
    <li><strong>Operation & Maintenance:</strong> To configure, track, and sync diagnostic devices.</li>
    <li><strong>Technical Support:</strong> To respond to clinic inquiries, resolve help desk tickets, and debug telemetry.</li>
    <li><strong>Push Notifications:</strong> To alert staff members of critical telemetry readings and system updates.</li>
    <li><strong>Compliance & Safety:</strong> To enforce clinic identity checks and ensure clinical equipment safety.</li>
</ul>

<h2 class="text-white text-sm font-bold mt-6 mb-2">3. Telemetry and Data Protection</h2>
<p class="mb-4">We prioritize patient and staff confidentiality:</p>
<ul class="list-disc pl-6 mb-4 space-y-1">
    <li><strong>Encryption:</strong> All telemetry readings and diagnostic metrics are encrypted in transit and at rest.</li>
    <li><strong>Firebase RTDB:</strong> All profile configurations are managed securely using Firebase infrastructure.</li>
    <li><strong>Minimal Sharing:</strong> We do not sell or trade your telemetry or personal records. Information is only shared with authorized medical clinic personnel.</li>
</ul>

<h2 class="text-white text-sm font-bold mt-6 mb-2">4. Data Retention and Deletion</h2>
<p class="mb-4">We retain personal and telemetry data only as long as necessary for the clinic's diagnostic tracking. Staff members can request account deletion by contacting support at support@extrememedical.com.</p>

<h2 class="text-white text-sm font-bold mt-6 mb-2">5. Changes to This Privacy Policy</h2>
<p class="mb-4">We may update this policy. We will notify you of any changes by posting the new policy on this page.</p>
                `;
            }

            const about = data.about_info || {};
            if (about.support_email) {
                document.getElementById('footerEmailLink').setAttribute('href', 'mailto:' + about.support_email);
            }
        }, (error) => {
            console.error("Firebase fetch error:", error);
            document.getElementById('policyContent').innerHTML = `<p class="text-danger">Failed to fetch dynamic policy: ${error.message}</p>`;
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
