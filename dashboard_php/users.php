<?php
/**
 * Clinics & Users Management System
 */
require_once __DIR__ . '/config.php';
check_auth();

$page_title = 'Clinics Management';
$page_scripts = ['assets/js/users.js'];

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/sidebar.php';
?>

<div class="main-panel">
    <!-- Navbar / Header -->
    <header class="main-header">
        <div class="header-title-section">
            <h1 class="header-title">Users & Clinics Management</h1>
            <p class="header-subtitle">Manage login credentials and clinic configuration profiles</p>
        </div>
        <div class="header-actions">
            <button class="btn-primary-gradient" id="openAddClinicModalBtn">
                <i class="fa-solid fa-plus"></i> Add New Clinic
            </button>
        </div>
    </header>

    <!-- Page Content -->
    <main class="page-content">
        <!-- Controls & Filter Bar -->
        <div class="dashboard-card" style="margin-bottom: 24px; padding: 16px 24px;">
            <div style="display: flex; gap: 16px; align-items: center; width: 100%;">
                <div class="search-bar" style="flex: 1; width: auto;">
                    <i class="fa-solid fa-magnifying-glass"></i>
                    <input type="text" id="clinicSearchInput" placeholder="Search by clinic, email, phone, or doctor name...">
                </div>
            </div>
        </div>

        <!-- Clinics Table Section -->
        <section class="dashboard-card">
            <div class="table-responsive">
                <table class="custom-table">
                    <thead>
                        <tr>
                            <th>Clinic Name</th>
                            <th>Doctor Name</th>
                            <th>Email Address</th>
                            <th>Phone Number</th>
                            <th>Location / Address</th>
                            <th style="width: 120px; text-align: center;">Actions</th>
                        </tr>
                    </thead>
                    <tbody id="clinicsTableBody">
                        <tr>
                            <td colspan="6" style="text-align: center; color: var(--text-muted); padding: 50px 0;">
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
<div class="modal-overlay" id="addClinicModal">
    <div class="modal-content">
        <div class="modal-header">
            <div class="modal-header-info">
                <div class="modal-header-icon" id="wizardHeaderIcon">
                    <i class="fa-solid fa-key"></i>
                </div>
                <div>
                    <h3 class="modal-header-title" id="wizardHeaderTitle">Step 1: Account Credentials</h3>
                    <p class="modal-header-subtitle" id="wizardHeaderSubtitle">Configure admin credentials on Firebase Auth</p>
                </div>
            </div>
            <button class="modal-close-btn" id="closeAddClinicModalBtn">&times;</button>
        </div>

        <div class="modal-body" style="position: relative;">
            <!-- Stepper Steps Indicator -->
            <div class="stepper-wizard">
                <div class="step-node active" id="stepNode1">
                    <div class="step-node-number">1</div>
                    <span>Auth Credentials</span>
                </div>
                <div class="step-divider"></div>
                <div class="step-node" id="stepNode2">
                    <div class="step-node-number">2</div>
                    <span>Clinic Profile</span>
                </div>
            </div>

            <!-- Modal Loading Overlay -->
            <div class="loading-overlay" id="modalLoadingOverlay">
                <div class="spinner"></div>
                <p class="loading-text" id="modalLoadingText">Creating authentication account...</p>
            </div>

            <!-- STEP 1 VIEW: Credentials -->
            <div class="wizard-step-view" id="wizardStep1View">
                <div class="form-group">
                    <label for="regEmail">Email Address</label>
                    <input type="email" id="regEmail" placeholder="clinic@extrememedical.com" required>
                </div>
                <div class="form-group">
                    <label for="regPassword">Password</label>
                    <input type="password" id="regPassword" placeholder="Minimum 6 characters" required>
                </div>
            </div>

            <!-- STEP 2 VIEW: Profile Details -->
            <div class="wizard-step-view" id="wizardStep2View" style="display: none;">
                <div class="form-group">
                    <label for="regClinicName">Clinic Name</label>
                    <input type="text" id="regClinicName" placeholder="e.g. Bright Future Center">
                </div>
                <div class="form-grid-2">
                    <div class="form-group">
                        <label for="regFirstName">Doctor First Name</label>
                        <input type="text" id="regFirstName" placeholder="Ahmed">
                    </div>
                    <div class="form-group">
                        <label for="regLastName">Doctor Last Name</label>
                        <input type="text" id="regLastName" placeholder="Ali">
                    </div>
                </div>
                <div class="form-group">
                    <label for="regPhone">Phone Number</label>
                    <input type="text" id="regPhone" placeholder="e.g. +20 123 4567 890">
                </div>
                <div class="form-group">
                    <label for="regAddress">Address / Street Location</label>
                    <input type="text" id="regAddress" placeholder="Click map or type street address">
                </div>
                
                <!-- Leaflet Interactive Map Picker -->
                <div class="form-group">
                    <label>Select Clinic Location on Map</label>
                    <div class="map-picker-container">
                        <div class="map-picker" id="addClinicMap"></div>
                    </div>
                    <div class="map-coords-indicator">
                        <i class="fa-solid fa-location-crosshairs"></i>
                        <span>Coordinates: <span id="mapSelectedCoords">30.0444, 31.2357 (Default Cairo)</span></span>
                    </div>
                </div>
            </div>
        </div>

        <div class="modal-footer">
            <button class="btn-secondary" id="cancelAddClinicBtn">Cancel</button>
            <button class="btn-primary-gradient" id="nextAddClinicBtn">
                Next: Configure Profile <i class="fa-solid fa-arrow-right"></i>
            </button>
            <button class="btn-primary-gradient" id="submitAddClinicBtn" style="display: none;">
                <i class="fa-solid fa-check"></i> Save Clinic Profile
            </button>
        </div>
    </div>
</div>

<!-- ========================================== -->
<!-- MODAL: CLINIC PROFILE DETAILS & MAP VIEW -->
<!-- ========================================== -->
<div class="modal-overlay" id="viewClinicModal">
    <div class="modal-content" style="max-width: 700px;">
        <div class="modal-header">
            <div class="modal-header-info">
                <div class="modal-header-icon" style="background: var(--primary-gradient);">
                    <i class="fa-solid fa-medical-services"></i>
                </div>
                <div>
                    <h3 class="modal-header-title" id="viewClinicTitle">Bright Future Center</h3>
                    <p class="modal-header-subtitle" id="viewClinicSubtitle">UID: ...</p>
                </div>
            </div>
            <button class="modal-close-btn" id="closeViewClinicModalBtn">&times;</button>
        </div>

        <div class="modal-body">
            <div class="detail-grid">
                <!-- Left: Profile cards -->
                <div class="detail-card-panel">
                    <div class="detail-item">
                        <i class="fa-solid fa-user-doctor detail-item-icon"></i>
                        <div class="detail-item-content">
                            <span class="detail-item-label">Owner Doctor</span>
                            <span class="detail-item-value" id="viewDoctorName">Dr. Ahmed Ali</span>
                        </div>
                    </div>
                    <div class="detail-item">
                        <i class="fa-solid fa-envelope detail-item-icon"></i>
                        <div class="detail-item-content">
                            <span class="detail-item-label">Email Address</span>
                            <span class="detail-item-value" id="viewClinicEmail">clinic@example.com</span>
                        </div>
                    </div>
                    <div class="detail-item">
                        <i class="fa-solid fa-mobile-screen detail-item-icon"></i>
                        <div class="detail-item-content">
                            <span class="detail-item-label">Phone Number</span>
                            <span class="detail-item-value" id="viewClinicPhone">+2012345678</span>
                        </div>
                    </div>
                    <div class="detail-item">
                        <i class="fa-solid fa-map-location detail-item-icon"></i>
                        <div class="detail-item-content">
                            <span class="detail-item-label">Clinic Address</span>
                            <span class="detail-item-value" id="viewClinicAddress">123 Street, Cairo</span>
                        </div>
                    </div>
                </div>

                <!-- Right: Map display -->
                <div>
                    <span class="detail-item-label" style="display: block; margin-bottom: 8px;">Map Position</span>
                    <div class="map-picker-container">
                        <div class="map-picker" id="viewClinicMap" style="height: 230px;"></div>
                    </div>
                </div>
            </div>
        </div>

        <div class="modal-footer">
            <button class="btn-primary-gradient" id="closeViewClinicBtn">Close Details</button>
        </div>
    </div>
</div>

<?php
require_once __DIR__ . '/includes/footer.php';
?>
