<?php
/**
 * Sidebar Component
 */
$current_page = basename($_SERVER['PHP_SELF']);
?>
<aside class="app-sidebar">
    <!-- Sidebar Branding Section -->
    <div class="sidebar-header">
        <div class="logo-wrapper">
            <div class="logo-icon">
                <i class="fa-solid fa-house-medical"></i>
            </div>
            <div class="logo-text">
                <span class="logo-title">EXTREME</span>
                <div class="logo-subtitle-row">
                    <span class="logo-subtitle">MEDICAL</span>
                    <span class="logo-version">v2.0</span>
                </div>
            </div>
        </div>
        <p class="sidebar-desc">Advanced Healthcare Administration System</p>
    </div>

    <div class="sidebar-divider"></div>

    <!-- Navigation Menu Items -->
    <nav class="sidebar-nav">
        <a href="index.php" class="nav-item <?php echo ($current_page == 'index.php' || $current_page == '') ? 'active' : ''; ?>">
            <i class="fa-solid fa-chart-pie nav-icon"></i>
            <span class="nav-label">Dashboard</span>
            <?php if ($current_page == 'index.php' || $current_page == ''): ?>
                <span class="nav-indicator"></span>
            <?php endif; ?>
        </a>
        <a href="users.php" class="nav-item <?php echo $current_page == 'users.php' ? 'active' : ''; ?>">
            <i class="fa-solid fa-users nav-icon"></i>
            <span class="nav-label">Users / Clinics</span>
            <?php if ($current_page == 'users.php'): ?>
                <span class="nav-indicator"></span>
            <?php endif; ?>
        </a>
    </nav>

    <!-- Sidebar Profile Footer -->
    <div class="sidebar-footer">
        <div class="profile-card">
            <div class="profile-avatar">
                <i class="fa-solid fa-user"></i>
            </div>
            <div class="profile-info">
                <p class="profile-role">Super Admin</p>
                <p class="profile-email" id="sidebarAdminEmail"><?php echo isset($_SESSION['admin_email']) ? htmlspecialchars($_SESSION['admin_email']) : 'admin@extrememedical.com'; ?></p>
            </div>
            <div class="profile-actions">
                <a href="logout.php" title="Logout" class="logout-btn">
                    <i class="fa-solid fa-right-from-bracket"></i>
                </a>
            </div>
        </div>
    </div>
</aside>
