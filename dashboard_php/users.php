<?php
/**
 * Clinics & Users Management System
 */
require_once __DIR__ . '/config.php';
check_auth();

$page_title = 'Clinics Management';

$page_styles = [
    'https://cdn.datatables.net/1.13.6/css/jquery.dataTables.min.css',
    'https://cdn.datatables.net/responsive/2.5.0/css/responsive.dataTables.min.css',
    'https://cdn.datatables.net/buttons/2.4.2/css/buttons.dataTables.min.css'
];

$page_scripts = [
    'https://code.jquery.com/jquery-3.7.0.min.js',
    'https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js',
    'https://cdn.datatables.net/responsive/2.5.0/js/dataTables.responsive.min.js',
    'https://cdn.datatables.net/buttons/2.4.2/js/dataTables.buttons.min.js',
    'https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js',
    'https://cdn.jsdelivr.net/npm/pdfmake-rtl/build/pdfmake.min.js',
    'https://cdn.datatables.net/buttons/2.4.2/js/buttons.html5.min.js',
    'https://cdn.datatables.net/buttons/2.4.2/js/buttons.print.min.js',
    'assets/js/users.js'
];

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/sidebar.php';
?>

<div class="flex-1 flex flex-col min-w-0 bg-darkbg">
    <!-- Navbar / Header -->
    <header class="h-20 border-b border-bordercolor px-8 flex items-center justify-between bg-darkbg/80 backdrop-blur-md sticky top-0 z-[90]">
        <div class="flex flex-col">
            <h1 class="text-xl font-extrabold text-white">Users & Clinics Management</h1>
            <p class="text-xs text-textsecondary">Manage login credentials and clinic configuration profiles</p>
        </div>
        <div class="flex items-center gap-4">
            <button class="bg-gradient-to-tr from-primary to-secondary text-white font-bold text-sm px-5 py-3 rounded-xl flex items-center gap-2 hover:-translate-y-0.5 hover:shadow-primaryglow transition duration-200 cursor-pointer" id="openLinkDeviceModalBtn">
                <i class="fa-solid fa-link"></i> Link Device
            </button>
            <button class="bg-gradient-to-tr from-primary to-secondary text-white font-bold text-sm px-5 py-3 rounded-xl flex items-center gap-2 hover:-translate-y-0.5 hover:shadow-primaryglow transition duration-200 cursor-pointer" id="openAddClinicModalBtn">
                <i class="fa-solid fa-plus"></i> Add New Clinic
            </button>
        </div>
    </header>

    <!-- Page Content -->
    <main class="p-8 flex-1 overflow-y-auto">
        <!-- Controls & Filter Bar -->
        <div class="bg-darksurface border border-bordercolor rounded-[24px] p-4 px-6 shadow-xl mb-6">
            <div class="flex flex-col md:flex-row gap-4 items-center justify-between w-full">
                <!-- Search Input -->
                <div class="relative flex-1 w-full md:w-auto">
                    <i class="fa-solid fa-magnifying-glass absolute left-3.5 top-1/2 -translate-y-1/2 text-textsecondary text-sm"></i>
                    <input type="text" id="clinicSearchInput" placeholder="Search by clinic, email, phone, or doctor name..." class="w-full bg-white/5 border border-bordercolor rounded-xl py-2.5 pl-10 pr-4 text-white text-xs outline-none focus:border-primary transition duration-200">
                </div>
                <!-- Export buttons container -->
                <div id="buttonsContainer" class="flex flex-wrap gap-2 justify-end w-full md:w-auto"></div>
            </div>
        </div>

        <!-- Clinics Table Section -->
        <section class="bg-darksurface border border-bordercolor rounded-[24px] p-6 shadow-xl">
            <div class="overflow-x-auto w-full">
                <table id="clinicsTable" class="w-full border-collapse text-left">
                    <thead>
                        <tr>
                            <th class="p-4 border-b border-bordercolor text-textsecondary text-[11px] font-bold uppercase tracking-wider text-center" style="width: 50px;">#</th>
                            <th class="p-4 border-b border-bordercolor text-textsecondary text-[11px] font-bold uppercase tracking-wider">Clinic Name</th>
                            <th class="p-4 border-b border-bordercolor text-textsecondary text-[11px] font-bold uppercase tracking-wider">Doctor Name</th>
                            <th class="p-4 border-b border-bordercolor text-textsecondary text-[11px] font-bold uppercase tracking-wider">Email Address</th>
                            <th class="p-4 border-b border-bordercolor text-textsecondary text-[11px] font-bold uppercase tracking-wider">Phone Number</th>
                            <th class="p-4 border-b border-bordercolor text-textsecondary text-[11px] font-bold uppercase tracking-wider">Location / Address</th>
                            <th class="p-4 border-b border-bordercolor text-textsecondary text-[11px] font-bold uppercase tracking-wider text-center" style="width: 120px;">Actions</th>
                        </tr>
                    </thead>
                    <tbody id="clinicsTableBody">
                        <tr>
                            <td colspan="7" class="p-4 border-b border-bordercolor text-xs text-white text-center text-textmuted py-12">
                                <i class="fa-solid fa-circle-notch fa-spin"></i> Fetching registered clinics...
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </section>
    </main>
</div>

<!-- ========================================== -->
<!-- MODAL: ADD NEW CLINIC (2-STEP STEPPER) -->
<!-- ========================================== -->
<div class="modal-overlay fixed inset-0 bg-darkbg/85 backdrop-blur-md flex items-center justify-center z-[1000] opacity-0 pointer-events-none transition-opacity duration-300" id="addClinicModal">
    <div class="modal-content bg-darksec border border-bordercolor rounded-[28px] w-[90%] max-w-[800px] max-h-[90vh] flex flex-col overflow-hidden scale-90 transition-transform duration-300 shadow-2xl">
        <div class="p-6 border-b border-bordercolor flex items-center justify-between">
            <div class="flex items-center gap-4">
                <div class="w-11 h-11 bg-gradient-to-tr from-primary to-secondary rounded-xl flex items-center justify-center text-white text-lg" id="wizardHeaderIcon">
                    <i class="fa-solid fa-key"></i>
                </div>
                <div>
                    <h3 class="text-lg font-extrabold text-white leading-tight" id="wizardHeaderTitle">Step 1: Account Credentials</h3>
                    <p class="text-[11px] text-textsecondary" id="wizardHeaderSubtitle">Configure admin credentials on Firebase Auth</p>
                </div>
            </div>
            <button class="border-none bg-white/5 text-textsecondary w-9 h-9 rounded-full cursor-pointer flex items-center justify-center hover:bg-white/10 hover:text-white transition duration-200 text-lg" id="closeAddClinicModalBtn">&times;</button>
        </div>

        <div class="p-6 overflow-y-auto flex-1 relative">
            <!-- Stepper Steps Indicator -->
            <div class="flex justify-center items-center gap-3 mb-6">
                <div class="step-node active" id="stepNode1">
                    <div>1</div>
                    <span>Auth Credentials</span>
                </div>
                <div class="w-14 h-[1px] bg-bordercolor"></div>
                <div class="step-node" id="stepNode2">
                    <div>2</div>
                    <span>Clinic Profile</span>
                </div>
            </div>

            <!-- Modal Loading Overlay -->
            <div class="absolute inset-0 bg-darkbg/70 flex flex-col items-center justify-center z-50 gap-4 opacity-0 pointer-events-none transition-opacity duration-200" id="modalLoadingOverlay">
                <div class="w-12 h-12 border-4 border-primary/20 rounded-full border-t-primary animate-spin"></div>
                <p class="text-sm font-bold text-white" id="modalLoadingText">Creating authentication account...</p>
            </div>

            <!-- STEP 1 VIEW: Credentials -->
            <div class="wizard-step-view" id="wizardStep1View">
                <div class="flex flex-col gap-1.5 mb-4">
                    <label for="regEmail" class="text-[11px] font-bold text-textsecondary uppercase tracking-wider">Email Address</label>
                    <input type="email" id="regEmail" placeholder="clinic@extrememedical.com" class="bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-sm outline-none focus:border-primary transition duration-200" required>
                </div>
                <div class="flex flex-col gap-1.5 mb-4">
                    <label for="regPassword" class="text-[11px] font-bold text-textsecondary uppercase tracking-wider">Password</label>
                    <input type="password" id="regPassword" placeholder="Minimum 6 characters" class="bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-sm outline-none focus:border-primary transition duration-200" required>
                </div>
            </div>

            <!-- STEP 2 VIEW: Profile Details -->
            <div class="wizard-step-view" id="wizardStep2View" style="display: none;">
                <div class="flex flex-col gap-1.5 mb-4">
                    <label for="regClinicName" class="text-[11px] font-bold text-textsecondary uppercase tracking-wider">Clinic Name</label>
                    <input type="text" id="regClinicName" placeholder="e.g. Bright Future Center" class="bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-sm outline-none focus:border-primary transition duration-200">
                </div>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                    <div class="flex flex-col gap-1.5">
                        <label for="regFirstName" class="text-[11px] font-bold text-textsecondary uppercase tracking-wider">Doctor First Name</label>
                        <input type="text" id="regFirstName" placeholder="Ahmed" class="bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-sm outline-none focus:border-primary transition duration-200">
                    </div>
                    <div class="flex flex-col gap-1.5">
                        <label for="regLastName" class="text-[11px] font-bold text-textsecondary uppercase tracking-wider">Doctor Last Name</label>
                        <input type="text" id="regLastName" placeholder="Ali" class="bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-sm outline-none focus:border-primary transition duration-200">
                    </div>
                </div>
                <div class="flex flex-col gap-1.5 mb-4">
                    <label for="regPhone" class="text-[11px] font-bold text-textsecondary uppercase tracking-wider">Phone Number</label>
                    <input type="text" id="regPhone" placeholder="e.g. +20 123 4567 890" class="bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-sm outline-none focus:border-primary transition duration-200">
                </div>
                <div class="flex flex-col gap-1.5 mb-4">
                    <label for="regAddress" class="text-[11px] font-bold text-textsecondary uppercase tracking-wider">Address / Street Location</label>
                    <input type="text" id="regAddress" placeholder="Click map or type street address" class="bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-sm outline-none focus:border-primary transition duration-200">
                </div>
                
                <!-- Leaflet Interactive Map Picker -->
                <div class="flex flex-col gap-1.5 mb-4">
                    <label class="text-[11px] font-bold text-textsecondary uppercase tracking-wider">Select Clinic Location on Map</label>
                    <div class="mt-2 rounded-2xl border border-bordercolor overflow-hidden relative shadow-inner">
                        <div class="h-[250px] w-full bg-[#111]" id="addClinicMap"></div>
                    </div>
                    <div class="text-[10px] text-textsecondary mt-1.5 flex items-center gap-1.5">
                        <i class="fa-solid fa-location-crosshairs"></i>
                        <span>Coordinates: <span id="mapSelectedCoords">30.0444, 31.2357 (Default Cairo)</span></span>
                    </div>
                </div>
            </div>
        </div>

        <div class="p-6 border-t border-bordercolor bg-white/5 flex justify-end gap-4">
            <button class="bg-transparent border border-bordercolor text-textsecondary px-5 py-3 rounded-xl text-sm font-semibold hover:bg-white/5 hover:text-white transition duration-200 cursor-pointer" id="cancelAddClinicBtn">Cancel</button>
            <button class="bg-gradient-to-tr from-primary to-secondary text-white font-bold text-sm px-5 py-3 rounded-xl flex items-center gap-2 hover:-translate-y-0.5 hover:shadow-primaryglow transition duration-200 cursor-pointer" id="nextAddClinicBtn">
                Next: Configure Profile <i class="fa-solid fa-arrow-right"></i>
            </button>
            <button class="bg-gradient-to-tr from-primary to-secondary text-white font-bold text-sm px-5 py-3 rounded-xl flex items-center gap-2 hover:-translate-y-0.5 hover:shadow-primaryglow transition duration-200 cursor-pointer" id="submitAddClinicBtn" style="display: none;">
                <i class="fa-solid fa-check"></i> Save Clinic Profile
            </button>
        </div>
    </div>
</div>

<!-- ========================================== -->
<!-- MODAL: CLINIC PROFILE DETAILS & MAP VIEW -->
<!-- ========================================== -->
<div class="modal-overlay fixed inset-0 bg-darkbg/85 backdrop-blur-md flex items-center justify-center z-[1000] opacity-0 pointer-events-none transition-opacity duration-300" id="viewClinicModal">
    <div class="modal-content bg-darksec border border-bordercolor rounded-[28px] w-[90%] max-w-[850px] max-h-[90vh] flex flex-col overflow-hidden scale-90 transition-transform duration-300 shadow-2xl">
        <div class="p-6 border-b border-bordercolor flex items-center justify-between">
            <div class="flex items-center gap-4">
                <div class="w-11 h-11 bg-gradient-to-tr from-primary to-secondary rounded-xl flex items-center justify-center text-white text-lg">
                    <i class="fa-solid fa-medical-services"></i>
                </div>
                <div>
                    <h3 class="text-lg font-extrabold text-white leading-tight" id="viewClinicTitle">Bright Future Center</h3>
                    <p class="text-[11px] text-textsecondary" id="viewClinicSubtitle">UID: ...</p>
                </div>
            </div>
            <button class="border-none bg-white/5 text-textsecondary w-9 h-9 rounded-full cursor-pointer flex items-center justify-center hover:bg-white/10 hover:text-white transition duration-200 text-lg" id="closeViewClinicModalBtn">&times;</button>
        </div>

        <div class="p-6 overflow-y-auto flex-1">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                <!-- Left: Profile cards -->
                <div class="bg-white/5 border border-bordercolor rounded-2xl p-5 flex flex-col gap-4">
                    <div class="flex gap-3.5 items-start">
                        <i class="fa-solid fa-user-doctor text-primary text-lg mt-0.5"></i>
                        <div class="flex flex-col">
                            <span class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Owner Doctor</span>
                            <span class="text-xs text-white font-semibold mt-0.5" id="viewDoctorName">Dr. Ahmed Ali</span>
                        </div>
                    </div>
                    <div class="flex gap-3.5 items-start">
                        <i class="fa-solid fa-envelope text-primary text-lg mt-0.5"></i>
                        <div class="flex flex-col">
                            <span class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Email Address</span>
                            <span class="text-xs text-white font-semibold mt-0.5" id="viewClinicEmail">clinic@example.com</span>
                        </div>
                    </div>
                    <div class="flex gap-3.5 items-start">
                        <i class="fa-solid fa-mobile-screen text-primary text-lg mt-0.5"></i>
                        <div class="flex flex-col">
                            <span class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Phone Number</span>
                            <span class="text-xs text-white font-semibold mt-0.5" id="viewClinicPhone">+2012345678</span>
                        </div>
                    </div>
                    <div class="flex gap-3.5 items-start">
                        <i class="fa-solid fa-map-location text-primary text-lg mt-0.5"></i>
                        <div class="flex flex-col">
                            <span class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Clinic Address</span>
                            <span class="text-xs text-white font-semibold mt-0.5" id="viewClinicAddress">123 Street, Cairo</span>
                        </div>
                    </div>
                </div>

                <!-- Right: Map display -->
                <div>
                    <span class="text-[10px] font-bold text-textsecondary uppercase tracking-wider mb-2 block">Map Position</span>
                    <div class="mt-2 rounded-2xl border border-bordercolor overflow-hidden relative shadow-inner">
                        <div class="h-[230px] w-full bg-[#111]" id="viewClinicMap"></div>
                    </div>
                </div>
            </div>

            <!-- Linked Hardware Device Section -->
            <div class="border-t border-bordercolor pt-5 mt-5">
                <span class="text-[10px] font-bold text-textsecondary uppercase tracking-wider mb-3 block">Linked Hardware Device</span>
                <div id="viewClinicDeviceContainer">
                    <!-- Populated dynamically via Javascript -->
                </div>
            </div>
        </div>

        <div class="p-6 border-t border-bordercolor bg-white/5 flex justify-end gap-4">
            <button class="bg-gradient-to-tr from-primary to-secondary text-white font-bold text-sm px-5 py-3 rounded-xl flex items-center gap-2 hover:-translate-y-0.5 hover:shadow-primaryglow transition duration-200 cursor-pointer" id="closeViewClinicBtn">Close Details</button>
        </div>
    </div>
</div>

<!-- ========================================== -->
<!-- MODAL: LINK DEVICE TO CLINIC               -->
<!-- ========================================== -->
<div class="modal-overlay fixed inset-0 bg-darkbg/85 backdrop-blur-md flex items-center justify-center z-[1000] opacity-0 pointer-events-none transition-opacity duration-300" id="linkDeviceModal">
    <div class="modal-content bg-darksec border border-bordercolor rounded-[28px] w-[90%] max-w-[650px] max-h-[90vh] flex flex-col overflow-hidden scale-90 transition-transform duration-300 shadow-2xl">
        <div class="p-6 border-b border-bordercolor flex items-center justify-between">
            <div class="flex items-center gap-4">
                <div class="w-11 h-11 bg-gradient-to-tr from-primary to-secondary rounded-xl flex items-center justify-center text-white text-lg">
                    <i class="fa-solid fa-link"></i>
                </div>
                <div>
                    <h3 class="text-lg font-extrabold text-white leading-tight">Link Hardware Device</h3>
                    <p class="text-[11px] text-textsecondary">Associate a catalog device model and version with a clinic</p>
                </div>
            </div>
            <button class="border-none bg-white/5 text-textsecondary w-9 h-9 rounded-full cursor-pointer flex items-center justify-center hover:bg-white/10 hover:text-white transition duration-200 text-lg" id="closeLinkDeviceModalBtn">&times;</button>
        </div>

        <div class="p-6 overflow-y-auto flex-1 relative">
            <div class="absolute inset-0 bg-darkbg/70 flex flex-col items-center justify-center z-50 gap-4 opacity-0 pointer-events-none transition-opacity duration-200" id="linkDeviceLoadingOverlay">
                <div class="w-12 h-12 border-4 border-primary/20 rounded-full border-t-primary animate-spin"></div>
                <p class="text-sm font-bold text-white">Saving device link...</p>
            </div>

            <!-- Form -->
            <form id="linkDeviceForm" onsubmit="event.preventDefault();">
                <!-- Clinic Selection -->
                <div class="flex flex-col gap-1.5 mb-4">
                    <label for="linkClinicSelect" class="text-[11px] font-bold text-textsecondary uppercase tracking-wider">Select Clinic</label>
                    <div class="relative w-full">
                        <select id="linkClinicSelect" class="w-full bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-sm outline-none focus:border-primary transition duration-200 appearance-none cursor-pointer" required>
                            <option value="" class="bg-darksec text-white">Choose a clinic...</option>
                        </select>
                        <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center px-4 text-textsecondary">
                            <i class="fa-solid fa-chevron-down text-xs"></i>
                        </div>
                    </div>
                </div>

                <!-- Grid for Device Model & Version -->
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                    <div class="flex flex-col gap-1.5">
                        <label for="linkModelSelect" class="text-[11px] font-bold text-textsecondary uppercase tracking-wider">Device Model</label>
                        <div class="relative w-full">
                            <select id="linkModelSelect" class="w-full bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-sm outline-none focus:border-primary transition duration-200 appearance-none cursor-pointer" required>
                                <option value="" class="bg-darksec text-white">Select model...</option>
                            </select>
                            <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center px-4 text-textsecondary">
                                <i class="fa-solid fa-chevron-down text-xs"></i>
                            </div>
                        </div>
                    </div>
                    <div class="flex flex-col gap-1.5">
                        <label for="linkVersionSelect" class="text-[11px] font-bold text-textsecondary uppercase tracking-wider">Device Version</label>
                        <div class="relative w-full">
                            <select id="linkVersionSelect" class="w-full bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-sm outline-none focus:border-primary transition duration-200 appearance-none cursor-pointer" required disabled>
                                <option value="" class="bg-darksec text-white">Select version...</option>
                            </select>
                            <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center px-4 text-textsecondary">
                                <i class="fa-solid fa-chevron-down text-xs"></i>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Dynamic Specifications Preview Card (Read-only) -->
                <div class="hidden mb-4" id="linkSpecsPreviewContainer">
                    <span class="text-[11px] font-bold text-textsecondary uppercase tracking-wider mb-2 block">Version Specifications (Read-Only)</span>
                    <div class="grid grid-cols-2 sm:grid-cols-5 gap-3.5 bg-black/20 border border-bordercolor rounded-xl p-3 text-center sm:text-left">
                        <div class="flex flex-col">
                            <span class="text-[9px] font-bold text-textsecondary uppercase tracking-wider">SW Ver</span>
                            <span class="text-xs font-semibold text-white mt-0.5" id="previewSwVer">N/A</span>
                        </div>
                        <div class="flex flex-col">
                            <span class="text-[9px] font-bold text-textsecondary uppercase tracking-wider">UI Ver</span>
                            <span class="text-xs font-semibold text-white mt-0.5" id="previewUiVer">N/A</span>
                        </div>
                        <div class="flex flex-col">
                            <span class="text-[9px] font-bold text-textsecondary uppercase tracking-wider">NTC Ver</span>
                            <span class="text-xs font-semibold text-white mt-0.5" id="previewNtcVer">N/A</span>
                        </div>
                        <div class="flex flex-col">
                            <span class="text-[9px] font-bold text-textsecondary uppercase tracking-wider">PCB Ver</span>
                            <span class="text-xs font-semibold text-white mt-0.5" id="previewPcbVer">N/A</span>
                        </div>
                        <div class="flex flex-col">
                            <span class="text-[9px] font-bold text-textsecondary uppercase tracking-wider">SSR</span>
                            <span class="text-xs font-semibold text-white mt-0.5" id="previewSsr">N/A</span>
                        </div>
                    </div>
                </div>

                <!-- Installation Info Inputs -->
                <div class="flex flex-col gap-1.5 mb-4">
                    <label for="linkSerialNo" class="text-[11px] font-bold text-textsecondary uppercase tracking-wider">Serial Number (Serial No)</label>
                    <input type="text" id="linkSerialNo" placeholder="e.g. EX-98472-A" class="bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-sm outline-none focus:border-primary transition duration-200" required>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div class="flex flex-col gap-1.5">
                        <label for="linkInstallingDate" class="text-[11px] font-bold text-textsecondary uppercase tracking-wider">Installing Date</label>
                        <input type="date" id="linkInstallingDate" class="bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-sm outline-none focus:border-primary transition duration-200" required>
                    </div>
                    <div class="flex flex-col gap-1.5">
                        <label for="linkEndWarranty" class="text-[11px] font-bold text-textsecondary uppercase tracking-wider">End Warranty</label>
                        <input type="date" id="linkEndWarranty" class="bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-sm outline-none focus:border-primary transition duration-200" required>
                    </div>
                </div>
            </form>
        </div>

        <div class="p-6 border-t border-bordercolor bg-white/5 flex justify-end gap-4">
            <button class="bg-transparent border border-bordercolor text-textsecondary px-5 py-3 rounded-xl text-sm font-semibold hover:bg-white/5 hover:text-white transition duration-200 cursor-pointer" id="cancelLinkDeviceBtn">Cancel</button>
            <button class="bg-gradient-to-tr from-primary to-secondary text-white font-bold text-sm px-5 py-3 rounded-xl flex items-center gap-2 hover:-translate-y-0.5 hover:shadow-primaryglow transition duration-200 cursor-pointer" id="submitLinkDeviceBtn">
                <i class="fa-solid fa-link"></i> Save Device Link
            </button>
        </div>
    </div>
</div>

<?php
require_once __DIR__ . '/includes/footer.php';
?>
