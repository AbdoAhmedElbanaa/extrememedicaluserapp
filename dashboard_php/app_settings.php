<?php
/**
 * Application Settings Manager (Terms, Privacy, About)
 */
require_once __DIR__ . '/config.php';
check_auth();

$page_title = 'App Settings';
$page_scripts = [
    'https://code.jquery.com/jquery-3.7.0.min.js',
    'assets/js/firebase-config.js'
];

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/sidebar.php';
?>

<div class="flex-1 flex flex-col min-w-0 bg-darkbg">
    <!-- Navbar / Header -->
    <header class="h-20 border-b border-bordercolor px-8 flex items-center justify-between bg-darkbg/80 backdrop-blur-md sticky top-0 z-[90]">
        <div class="flex flex-col">
            <h1 class="text-xl font-extrabold text-white">Application Settings</h1>
            <p class="text-xs text-textsecondary">Edit Terms of Service, Privacy Policy, and About details for Google Play Store and Mobile App</p>
        </div>
    </header>

    <!-- Page Content -->
    <main class="p-8 flex-1 overflow-y-auto">
        <!-- Settings Form Section -->
        <div class="max-w-4xl mx-auto">
            <form id="settingsForm" onsubmit="saveAppSettings(event)" class="space-y-8">
                
                <!-- About App Section -->
                <section class="bg-darksurface border border-bordercolor rounded-[24px] p-6 shadow-xl space-y-4">
                    <div class="flex items-center gap-3 border-b border-bordercolor pb-4">
                        <div class="w-10 h-10 bg-primary/10 rounded-xl flex items-center justify-center text-primary">
                            <i class="fa-solid fa-circle-info text-lg"></i>
                        </div>
                        <div>
                            <h2 class="text-sm font-bold text-white uppercase tracking-wider">About Application Information</h2>
                            <p class="text-[11px] text-textsecondary">App description, developer info, and current public version</p>
                        </div>
                    </div>
                    
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div>
                            <label class="block text-xs font-bold text-textsecondary uppercase tracking-wider mb-2">App Version</label>
                            <input type="text" id="aboutVersion" placeholder="e.g. v2.0.0" class="w-full bg-white/5 border border-bordercolor rounded-xl py-2.5 px-4 text-white text-xs outline-none focus:border-primary transition duration-200" required>
                        </div>
                        <div>
                            <label class="block text-xs font-bold text-textsecondary uppercase tracking-wider mb-2">Company / Developer Name</label>
                            <input type="text" id="aboutCompany" placeholder="e.g. Extreme Medical Co." class="w-full bg-white/5 border border-bordercolor rounded-xl py-2.5 px-4 text-white text-xs outline-none focus:border-primary transition duration-200" required>
                        </div>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div>
                            <label class="block text-xs font-bold text-textsecondary uppercase tracking-wider mb-2">Support Email Address</label>
                            <input type="email" id="aboutSupportEmail" placeholder="e.g. support@extrememedical.com" class="w-full bg-white/5 border border-bordercolor rounded-xl py-2.5 px-4 text-white text-xs outline-none focus:border-primary transition duration-200" required>
                        </div>
                        <div>
                            <label class="block text-xs font-bold text-textsecondary uppercase tracking-wider mb-2">Website URL</label>
                            <input type="url" id="aboutWebsite" placeholder="e.g. https://extrememedical.com" class="w-full bg-white/5 border border-bordercolor rounded-xl py-2.5 px-4 text-white text-xs outline-none focus:border-primary transition duration-200" required>
                        </div>
                    </div>

                    <div>
                        <label class="block text-xs font-bold text-textsecondary uppercase tracking-wider mb-2">Application Description</label>
                        <textarea id="aboutDescription" rows="4" placeholder="Briefly describe what this application does..." class="w-full bg-white/5 border border-bordercolor rounded-xl py-2.5 px-4 text-white text-xs outline-none focus:border-primary transition duration-200 resize-none" required></textarea>
                    </div>
                </section>

                <!-- Privacy Policy Section -->
                <section class="bg-darksurface border border-bordercolor rounded-[24px] p-6 shadow-xl space-y-4">
                    <div class="flex items-center gap-3 border-b border-bordercolor pb-4">
                        <div class="w-10 h-10 bg-secondary/10 rounded-xl flex items-center justify-center text-secondary">
                            <i class="fa-solid fa-user-shield text-lg"></i>
                        </div>
                        <div>
                            <h2 class="text-sm font-bold text-white uppercase tracking-wider">Privacy Policy</h2>
                            <p class="text-[11px] text-textsecondary">Privacy agreement text required for Google Play Console compatibility</p>
                        </div>
                    </div>
                    <div>
                        <label class="block text-xs font-bold text-textsecondary uppercase tracking-wider mb-2">Privacy Policy Content</label>
                        <textarea id="privacyPolicy" rows="8" placeholder="Enter privacy policy text here..." class="w-full bg-white/5 border border-bordercolor rounded-xl py-2.5 px-4 text-white text-xs outline-none focus:border-primary transition duration-200 font-mono" required></textarea>
                    </div>
                </section>

                <!-- Terms of Service Section -->
                <section class="bg-darksurface border border-bordercolor rounded-[24px] p-6 shadow-xl space-y-4">
                    <div class="flex items-center gap-3 border-b border-bordercolor pb-4">
                        <div class="w-10 h-10 bg-warning/10 rounded-xl flex items-center justify-center text-warning">
                            <i class="fa-solid fa-file-contract text-lg"></i>
                        </div>
                        <div>
                            <h2 class="text-sm font-bold text-white uppercase tracking-wider">Terms of Service</h2>
                            <p class="text-[11px] text-textsecondary">Terms and conditions governing the medical staff application use</p>
                        </div>
                    </div>
                    <div>
                        <label class="block text-xs font-bold text-textsecondary uppercase tracking-wider mb-2">Terms of Service Content</label>
                        <textarea id="termsOfService" rows="8" placeholder="Enter terms of service text here..." class="w-full bg-white/5 border border-bordercolor rounded-xl py-2.5 px-4 text-white text-xs outline-none focus:border-primary transition duration-200 font-mono" required></textarea>
                    </div>
                </section>

                <!-- Form Submit Action -->
                <div class="flex justify-end gap-4">
                    <button type="submit" class="bg-gradient-to-tr from-primary to-secondary text-white font-bold text-xs px-8 py-3.5 rounded-xl hover:-translate-y-0.5 hover:shadow-primaryglow transition duration-200 cursor-pointer border-none flex items-center gap-2">
                        <i class="fa-solid fa-cloud-arrow-up"></i>
                        <span>Save App Settings</span>
                    </button>
                </div>
            </form>
        </div>
    </main>
</div>

<script>
document.addEventListener('DOMContentLoaded', () => {
    loadAppSettings();
});

function loadAppSettings() {
    // We can disable form fields while loading
    const formFields = document.querySelectorAll('#settingsForm input, #settingsForm textarea, #settingsForm button');
    formFields.forEach(field => field.setAttribute('disabled', 'true'));

    const defaultPrivacy = `Privacy Policy for Extreme Medical Staff App

Effective Date: June 24, 2026

Extreme Medical Co. ("we," "our," or "us") operates the Extreme Medical Staff mobile application (the "App") and the administrative control dashboard (the "Dashboard"). This Privacy Policy describes how we collect, use, share, and protect personal and diagnostic information when you use our services.

By using the App, you consent to the data practices described in this policy.

1. Information We Collect
We collect information to provide diagnostic services to medical practitioners:
- Personal Identification: First name, last name, email address, phone number.
- Telemetry & Diagnostic Data: Hardware telemetry readings, sensor logs, device diagnostics, device state indicators.
- Device Metadata: Hardware serial numbers, version indicators, operating system, and system identifiers.
- Geolocation Data: Coordinates (latitude and longitude) of clinic sites to map equipment locations.

2. How We Use Your Information
We process your personal and telemetry information for the following purposes:
- Operation & Maintenance: To configure, track, and sync diagnostic devices.
- Technical Support: To respond to clinic inquiries, resolve help desk tickets, and debug telemetry.
- Push Notifications: To alert staff members of critical telemetry readings and system updates.
- Compliance & Safety: To enforce clinic identity checks and ensure clinical equipment safety.

3. Telemetry and Data Protection
We prioritize patient and staff confidentiality:
- Encryption: All telemetry readings and diagnostic metrics are encrypted in transit and at rest.
- Firestore & Realtime Database: All profile configurations are managed securely using Firebase infrastructure.
- Minimal Sharing: We do not sell or trade your telemetry or personal records. Information is only shared with authorized medical clinic personnel.

4. Data Retention and Deletion
We retain personal and telemetry data only as long as necessary for the clinic's diagnostic tracking. Staff members can request account deletion by contacting support at support@extrememedical.com.

5. Changes to This Privacy Policy
We may update this policy. We will notify you of any changes by posting the new policy on this page.

Contact Us
If you have any questions, please contact support@extrememedical.com.`;

    const defaultTerms = `Terms of Service for Extreme Medical Staff App

Effective Date: June 24, 2026

Please read these Terms of Service ("Terms") carefully before using the Extreme Medical Staff mobile application (the "App") or the web administration dashboard (the "Dashboard").

By accessing or using our services, you agree to be bound by these Terms.

1. Acceptance and Eligibility
By registering a staff account, you represent that you are a certified healthcare practitioner or authorized clinic representative eligible to monitor telemetry diagnostics.

2. Equipment and Telemetry Use
- You agree to use the App solely to monitor telemetry diagnostics of linked equipment.
- Unauthorized interception, reverse engineering, or modification of hardware signaling or data streams is strictly prohibited.
- Telemetry logs and alerts are diagnostic aids and must not replace professional clinical judgment.

3. Account Responsibility
- You are responsible for maintaining the confidentiality of your credentials (including Two-Factor Authentication codes).
- Falsification of identity, coordinates, address, or hardware serial numbers is grounds for immediate termination of access.

4. Intellectual Property
All application logic, dashboard elements, diagrams, layout designs, and translations are the property of Extreme Medical Co.

5. Limitation of Liability
To the maximum extent permitted by law, Extreme Medical Co. shall not be liable for any indirect, incidental, or consequential damages resulting from telemetry sync delays or diagnostic tracking issues.

6. Modifications and Termination
We reserve the right to suspend or terminate accounts that violate these Terms or present security risks to the clinical network.

Contact Us
For support, contact support@extrememedical.com.`;

    rtdb.ref('app_settings').once('value', (snapshot) => {
        const data = snapshot.val() || {};
        let needsWrite = false;

        if (!data.privacy_policy) {
            data.privacy_policy = defaultPrivacy;
            needsWrite = true;
        }
        if (!data.terms_of_service) {
            data.terms_of_service = defaultTerms;
            needsWrite = true;
        }
        
        const about = data.about_info || {};
        if (!about.description) {
            about.description = 'Extreme Medical Clinic Staff App provides real-time telemetry tracking, hardware integration, diagnostic analytics, and patient profiling to medical practitioners.';
            needsWrite = true;
        }
        if (!about.version) {
            about.version = 'v2.0.0';
            needsWrite = true;
        }
        if (!about.company) {
            about.company = 'Extreme Medical Co.';
            needsWrite = true;
        }
        if (!about.support_email) {
            about.support_email = 'support@extrememedical.com';
            needsWrite = true;
        }
        if (!about.website) {
            about.website = 'https://extrememedical.com';
            needsWrite = true;
        }

        data.about_info = about;

        if (needsWrite) {
            rtdb.ref('app_settings').set(data);
        }
        
        document.getElementById('privacyPolicy').value = data.privacy_policy;
        document.getElementById('termsOfService').value = data.terms_of_service;
        document.getElementById('aboutDescription').value = about.description;
        document.getElementById('aboutVersion').value = about.version;
        document.getElementById('aboutCompany').value = about.company;
        document.getElementById('aboutSupportEmail').value = about.support_email;
        document.getElementById('aboutWebsite').value = about.website;
        
        // Re-enable form fields
        formFields.forEach(field => field.removeAttribute('disabled'));
    }, (error) => {
        console.error("Error loading app settings:", error);
        showToast("Failed to load settings: " + error.message, "error");
    });
}

function saveAppSettings(e) {
    e.preventDefault();
    
    const submitBtn = document.querySelector('#settingsForm button[type="submit"]');
    const originalText = submitBtn.innerHTML;
    submitBtn.setAttribute('disabled', 'true');
    submitBtn.innerHTML = `<i class="fa-solid fa-spinner fa-spin mr-2"></i> Saving...`;

    rtdb.ref('app_settings').set({
        privacy_policy: document.getElementById('privacyPolicy').value.trim(),
        terms_of_service: document.getElementById('termsOfService').value.trim(),
        about_info: {
            description: document.getElementById('aboutDescription').value.trim(),
            version: document.getElementById('aboutVersion').value.trim(),
            company: document.getElementById('aboutCompany').value.trim(),
            support_email: document.getElementById('aboutSupportEmail').value.trim(),
            website: document.getElementById('aboutWebsite').value.trim()
        }
    }).then(() => {
        showToast('Settings saved successfully!');
    }).catch(err => {
        console.error("Failed to save app settings:", err);
        showToast('Failed to save settings: ' + err.message, 'error');
    }).finally(() => {
        submitBtn.removeAttribute('disabled');
        submitBtn.innerHTML = originalText;
    });
}
</script>

<?php
require_once __DIR__ . '/includes/footer.php';
?>
