<?php
/**
 * Administrator Dashboard Overview
 */
require_once __DIR__ . '/config.php';
check_auth();

$page_title = 'Dashboard';
$page_scripts = ['assets/js/dashboard.js'];

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/sidebar.php';
?>

<div class="main-panel">
    <!-- Navbar / Header -->
    <header class="main-header">
        <div class="header-title-section">
            <h1 class="header-title">Dashboard Overview</h1>
            <p class="header-subtitle">Real-time healthcare node statistics</p>
        </div>
        <div class="header-actions">
            <div class="search-bar">
                <i class="fa-solid fa-magnifying-glass"></i>
                <input type="text" placeholder="Search parameters...">
            </div>
        </div>
    </header>

    <!-- Page Content -->
    <main class="page-content">
        <!-- Metrics Counter Grid -->
        <section class="metrics-grid">
            <!-- Card 1 -->
            <div class="metric-card">
                <div class="metric-icon-box" style="background: rgba(99, 102, 241, 0.15); color: var(--primary-color);">
                    <i class="fa-solid fa-hospital"></i>
                </div>
                <div class="metric-info">
                    <span class="metric-label">Total Clinics</span>
                    <span class="metric-value" id="statTotalClinics">0</span>
                    <span class="metric-desc">Registered medical centers</span>
                </div>
            </div>
            <!-- Card 2 -->
            <div class="metric-card success">
                <div class="metric-icon-box" style="background: rgba(16, 185, 129, 0.15); color: var(--success-color);">
                    <i class="fa-solid fa-map-location-dot"></i>
                </div>
                <div class="metric-info">
                    <span class="metric-label">Mapped Clinics</span>
                    <span class="metric-value" id="statMappedClinics">0</span>
                    <span class="metric-desc">Clinics with coordinates set</span>
                </div>
            </div>
            <!-- Card 3 -->
            <div class="metric-card warning">
                <div class="metric-icon-box" style="background: rgba(245, 158, 11, 0.15); color: var(--warning-color);">
                    <i class="fa-solid fa-user-shield"></i>
                </div>
                <div class="metric-info">
                    <span class="metric-label">Active Accounts</span>
                    <span class="metric-value" id="statActiveAccounts">0</span>
                    <span class="metric-desc">Authenticated users in Auth</span>
                </div>
            </div>
        </section>

        <!-- Charts and Lists Grid -->
        <div class="dashboard-grid">
            <!-- Left Card: Chart -->
            <div class="dashboard-card">
                <div class="card-header">
                    <h2 class="card-title">
                        <i class="fa-solid fa-chart-line"></i>
                        Clinic Registrations Timeline
                    </h2>
                </div>
                <div style="height: 320px; position: relative;">
                    <canvas id="registrationsChart"></canvas>
                </div>
            </div>

            <!-- Right Card: Service Status / Live Feed -->
            <div class="dashboard-card">
                <div class="card-header">
                    <h2 class="card-title">
                        <i class="fa-solid fa-network-wired"></i>
                        Live Database Status
                    </h2>
                    <span class="status-badge success" id="dbStatusBadge">
                        <i class="fa-solid fa-circle"></i> Connected
                    </span>
                </div>
                <div class="detail-card-panel" style="margin-top: 10px; background: transparent; border: none; padding: 0;">
                    <div class="detail-item">
                        <i class="fa-solid fa-database detail-item-icon"></i>
                        <div class="detail-item-content">
                            <span class="detail-item-label">Database Type</span>
                            <span class="detail-item-value">Firestore + RTDB</span>
                        </div>
                    </div>
                    <div class="sidebar-divider" style="margin: 12px 0;"></div>
                    <div class="detail-item">
                        <i class="fa-solid fa-wifi detail-item-icon" style="color: var(--success-color);"></i>
                        <div class="detail-item-content">
                            <span class="detail-item-label">RTDB Syncing</span>
                            <span class="detail-item-value" id="syncStatusDesc">Listening for edits...</span>
                        </div>
                    </div>
                    <div class="sidebar-divider" style="margin: 12px 0;"></div>
                    <div class="detail-item">
                        <i class="fa-solid fa-circle-info detail-item-icon" style="color: var(--warning-color);"></i>
                        <div class="detail-item-content">
                            <span class="detail-item-label">Active Connection</span>
                            <span class="detail-item-value" id="activeConnectionDesc">Establishing...</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Recent Registrations Section -->
        <section class="dashboard-card">
            <div class="card-header">
                <h2 class="card-title">
                    <i class="fa-solid fa-clock-rotate-left"></i>
                    Recently Added Clinics
                </h2>
                <a href="users.php" class="btn-secondary" style="padding: 6px 14px; font-size: 12px;">Manage All</a>
            </div>
            <div class="table-responsive">
                <table class="custom-table">
                    <thead>
                        <tr>
                            <th>Clinic Name</th>
                            <th>Doctor / Contact</th>
                            <th>Phone</th>
                            <th>Email</th>
                            <th>Location Status</th>
                        </tr>
                    </thead>
                    <tbody id="recentClinicsTableBody">
                        <tr>
                            <td colspan="5" style="text-align: center; color: var(--text-muted); padding: 40px 0;">
                                <i class="fa-solid fa-circle-notch fa-spin"></i> Loading clinic feed...
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </section>
    </main>
</div>

<?php
require_once __DIR__ . '/includes/footer.php';
?>
