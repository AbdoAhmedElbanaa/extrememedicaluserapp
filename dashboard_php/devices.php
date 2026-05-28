<?php
/**
 * Devices Catalog Management
 */
require_once __DIR__ . '/config.php';
check_auth();

$page_title = 'Devices Catalog';
$page_scripts = ['assets/js/devices.js'];

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/sidebar.php';
?>

<div class="flex-1 flex flex-col min-w-0 bg-darkbg">
    <!-- Navbar / Header -->
    <header class="h-20 border-b border-bordercolor px-8 flex items-center justify-between bg-darkbg/80 backdrop-blur-md sticky top-0 z-[90]">
        <div class="flex flex-col">
            <h1 class="text-xl font-extrabold text-white">System Devices Catalog</h1>
            <p class="text-xs text-textsecondary">Manage the global database of device models and their software versions</p>
        </div>
        <div class="flex items-center gap-4">
            <button class="bg-gradient-to-tr from-primary to-secondary text-white font-bold text-sm px-5 py-3 rounded-xl flex items-center gap-2 hover:-translate-y-0.5 hover:shadow-primaryglow transition duration-200 cursor-pointer" id="openAddDeviceModalBtn">
                <i class="fa-solid fa-plus"></i> Add Device Model
            </button>
        </div>
    </header>

    <!-- Page Content -->
    <main class="p-8 flex-1 overflow-y-auto">
        <!-- Devices Catalog Grid -->
        <section class="bg-transparent border-none shadow-none p-0">
            <div class="grid grid-cols-1 md:grid-cols-3 gap-6" id="devicesCatalogGrid">
                <!-- Loaded dynamically via JS -->
                <div style="grid-column: 1 / -1; text-align: center; color: var(--text-muted); padding: 50px 0;">
                    <i class="fa-solid fa-circle-notch fa-spin"></i> Loading devices catalog...
                </div>
            </div>
        </section>
    </main>
</div>

<!-- ========================================== -->
<!-- MODAL: ADD DEVICE MODEL TO CATALOG         -->
<!-- ========================================== -->
<div class="modal-overlay fixed inset-0 bg-darkbg/85 backdrop-blur-md flex items-center justify-center z-[1000] opacity-0 pointer-events-none transition-opacity duration-300" id="addDeviceModal">
    <div class="modal-content bg-darksec border border-bordercolor rounded-[28px] w-[90%] max-w-[700px] max-h-[90vh] flex flex-col overflow-hidden scale-90 transition-transform duration-300 shadow-2xl">
        <div class="p-6 border-b border-bordercolor flex items-center justify-between">
            <div class="flex items-center gap-4">
                <div class="w-11 h-11 bg-gradient-to-tr from-primary to-secondary rounded-xl flex items-center justify-center text-white text-lg">
                    <i class="fa-solid fa-laptop-medical"></i>
                </div>
                <div>
                    <h3 class="text-lg font-extrabold text-white leading-tight" id="modalDeviceTitle">Add Device Model</h3>
                    <p class="text-[11px] text-textsecondary" id="modalDeviceSubtitle">Create a new device type in the global catalog with versions & specifications</p>
                </div>
            </div>
            <button class="border-none bg-white/5 text-textsecondary w-9 h-9 rounded-full cursor-pointer flex items-center justify-center hover:bg-white/10 hover:text-white transition duration-200 text-lg" id="closeAddDeviceModalBtn">&times;</button>
        </div>

        <div class="p-6 overflow-y-auto flex-1 relative">
            <div class="absolute inset-0 bg-darkbg/70 flex flex-col items-center justify-center z-50 gap-4 opacity-0 pointer-events-none transition-opacity duration-200" id="addDeviceLoadingOverlay">
                <div class="w-12 h-12 border-4 border-primary/20 rounded-full border-t-primary animate-spin"></div>
                <p class="text-sm font-bold text-white">Saving device model...</p>
            </div>

            <!-- Form -->
            <form id="addDeviceForm" onsubmit="event.preventDefault();">
                <div class="flex flex-col gap-1.5 mb-4">
                    <label for="catalogName" class="text-[11px] font-bold text-textsecondary uppercase tracking-wider">Device Name</label>
                    <input type="text" id="catalogName" placeholder="e.g. Extreme Laser Max" class="bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-sm outline-none focus:border-primary transition duration-200" required>
                </div>
                <div class="flex flex-col gap-1.5 mb-4">
                    <label for="catalogDesc" class="text-[11px] font-bold text-textsecondary uppercase tracking-wider">Description</label>
                    <input type="text" id="catalogDesc" placeholder="e.g. Dual-diode therapeutic laser system" class="bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-sm outline-none focus:border-primary transition duration-200" required>
                </div>
                <div class="flex flex-col gap-1.5 mb-4">
                    <label class="text-[11px] font-bold text-textsecondary uppercase tracking-wider">Device Image</label>
                    <input type="file" id="catalogImageFile" accept="image/*" style="display: none;">
                    <input type="hidden" id="catalogImageUrl" value="">
                    <div class="w-full h-36 rounded-xl border-2 border-dashed border-bordercolor bg-black/20 flex items-center justify-center cursor-pointer overflow-hidden relative hover:border-primary hover:bg-primary/5 transition duration-200" id="imageUploadPreviewBox">
                        <div class="flex flex-col items-center text-textmuted gap-2 text-xs" id="imageUploadPlaceholder">
                            <i class="fa-solid fa-cloud-arrow-up text-2xl text-textsecondary"></i>
                            <span>Click to upload device photo (Max 5MB)</span>
                        </div>
                    </div>
                </div>
                
                <!-- Versions Specs Builder -->
                <div class="h-[1px] bg-bordercolor my-5"></div>
                <div class="flex items-center justify-between mb-3">
                    <span class="text-[11px] font-extrabold text-primary uppercase tracking-wider">Device Versions & Specifications</span>
                    <button type="button" class="bg-primary/10 text-primary hover:bg-primary hover:text-white px-3 py-1.5 rounded-lg text-xs font-bold transition duration-200" onclick="addVersionFormRow()">
                        <i class="fa-solid fa-plus mr-1"></i> Add Version
                    </button>
                </div>
                <div class="flex flex-col gap-4" id="catalogVersionsContainer">
                    <!-- Version rows generated dynamically via JS -->
                </div>
            </form>
        </div>

        <div class="p-6 border-t border-bordercolor bg-white/5 flex justify-end gap-4">
            <button class="bg-transparent border border-bordercolor text-textsecondary px-5 py-3 rounded-xl text-sm font-semibold hover:bg-white/5 hover:text-white transition duration-200 cursor-pointer" id="cancelAddDeviceBtn">Cancel</button>
            <button class="bg-gradient-to-tr from-primary to-secondary text-white font-bold text-sm px-5 py-3 rounded-xl flex items-center gap-2 hover:-translate-y-0.5 hover:shadow-primaryglow transition duration-200 cursor-pointer" id="submitAddDeviceBtn">
                <i class="fa-solid fa-check"></i> <span id="submitDeviceBtnText">Save Device Model</span>
            </button>
        </div>
    </div>
</div>

<?php
require_once __DIR__ . '/includes/footer.php';
?>
