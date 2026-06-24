<?php
/**
 * Sidebar Component (Tailwind CSS Version)
 */
$current_page = basename($_SERVER['PHP_SELF']);
?>
<style>
/* Custom scrollbar for sidebar navigation */
.custom-scrollbar::-webkit-scrollbar {
    width: 4px;
}
.custom-scrollbar::-webkit-scrollbar-track {
    background: transparent;
}
.custom-scrollbar::-webkit-scrollbar-thumb {
    background: rgba(255, 255, 255, 0.1);
    border-radius: 4px;
}
.custom-scrollbar::-webkit-scrollbar-thumb:hover {
    background: rgba(255, 255, 255, 0.25);
}
</style>
<aside class="w-[290px] bg-darksec border-r border-bordercolor flex flex-col p-6 sticky top-0 h-screen z-[100] shrink-0">
    <!-- Sidebar Branding Section -->
    <div class="pb-6">
        <div class="flex items-center gap-4 mb-3">
            <div class="w-11 h-11 bg-gradient-to-tr from-primary to-secondary rounded-xl flex items-center justify-center text-white text-xl shadow-primaryglow">
                <i class="fa-solid fa-house-medical"></i>
            </div>
            <div class="flex flex-col">
                <span class="text-lg font-black tracking-wider text-white">EXTREME</span>
                <div class="flex items-center gap-1.5">
                    <span class="text-[11px] font-bold text-primary">MEDICAL</span>
                    <span class="text-[9px] font-extrabold bg-primary/15 text-primary px-1.5 py-0.5 rounded">v2.0</span>
                </div>
            </div>
        </div>
        <p class="text-[11px] text-textmuted leading-relaxed">Advanced Healthcare Administration System</p>
    </div>

    <div class="h-[1px] bg-bordercolor mb-6"></div>

    <!-- Navigation Menu Items -->
    <nav class="flex flex-col gap-2 flex-1 overflow-y-auto pr-1 custom-scrollbar">
        <a href="index.php" class="flex items-center gap-4 px-4 py-3.5 rounded-2xl text-sm font-medium transition duration-300 relative <?php echo ($current_page == 'index.php' || $current_page == '') ? 'text-white bg-gradient-to-tr from-primary to-secondary shadow-primaryglow' : 'text-textsecondary hover:text-white hover:bg-white/5'; ?>">
            <i class="fa-solid fa-chart-pie text-lg"></i>
            <span>Dashboard</span>
            <?php if ($current_page == 'index.php' || $current_page == ''): ?>
                <span class="w-1.5 h-1.5 bg-white rounded-full absolute right-4"></span>
            <?php endif; ?>
        </a>
        <a href="users.php" class="flex items-center gap-4 px-4 py-3.5 rounded-2xl text-sm font-medium transition duration-300 relative <?php echo $current_page == 'users.php' ? 'text-white bg-gradient-to-tr from-primary to-secondary shadow-primaryglow' : 'text-textsecondary hover:text-white hover:bg-white/5'; ?>">
            <i class="fa-solid fa-users text-lg"></i>
            <span>Users / Clinics</span>
            <?php if ($current_page == 'users.php'): ?>
                <span class="w-1.5 h-1.5 bg-white rounded-full absolute right-4"></span>
            <?php endif; ?>
        </a>
        <a href="feedbacks.php" class="flex items-center gap-4 px-4 py-3.5 rounded-2xl text-sm font-medium transition duration-300 relative <?php echo $current_page == 'feedbacks.php' ? 'text-white bg-gradient-to-tr from-primary to-secondary shadow-primaryglow' : 'text-textsecondary hover:text-white hover:bg-white/5'; ?>">
            <i class="fa-solid fa-star text-lg"></i>
            <span>Feedbacks</span>
            <?php if ($current_page == 'feedbacks.php'): ?>
                <span class="w-1.5 h-1.5 bg-white rounded-full absolute right-4"></span>
            <?php endif; ?>
        </a>
        <a href="devices.php" class="flex items-center gap-4 px-4 py-3.5 rounded-2xl text-sm font-medium transition duration-300 relative <?php echo $current_page == 'devices.php' ? 'text-white bg-gradient-to-tr from-primary to-secondary shadow-primaryglow' : 'text-textsecondary hover:text-white hover:bg-white/5'; ?>">
            <i class="fa-solid fa-microchip text-lg"></i>
            <span>Devices</span>
            <?php if ($current_page == 'devices.php'): ?>
                <span class="w-1.5 h-1.5 bg-white rounded-full absolute right-4"></span>
            <?php endif; ?>
        </a>
        <a href="help_center.php" class="flex items-center gap-4 px-4 py-3.5 rounded-2xl text-sm font-medium transition duration-300 relative <?php echo $current_page == 'help_center.php' ? 'text-white bg-gradient-to-tr from-primary to-secondary shadow-primaryglow' : 'text-textsecondary hover:text-white hover:bg-white/5'; ?>">
            <i class="fa-solid fa-circle-info text-lg"></i>
            <span>Help Center</span>
            <?php if ($current_page == 'help_center.php'): ?>
                <span class="w-1.5 h-1.5 bg-white rounded-full absolute right-4"></span>
            <?php endif; ?>
        </a>
        <a href="user_manual.php" class="flex items-center gap-4 px-4 py-3.5 rounded-2xl text-sm font-medium transition duration-300 relative <?php echo $current_page == 'user_manual.php' ? 'text-white bg-gradient-to-tr from-primary to-secondary shadow-primaryglow' : 'text-textsecondary hover:text-white hover:bg-white/5'; ?>">
            <i class="fa-solid fa-book-open text-lg"></i>
            <span>User Manual</span>
            <?php if ($current_page == 'user_manual.php'): ?>
                <span class="w-1.5 h-1.5 bg-white rounded-full absolute right-4"></span>
            <?php endif; ?>
        </a>
        <a href="video_tutorials.php" class="flex items-center gap-4 px-4 py-3.5 rounded-2xl text-sm font-medium transition duration-300 relative <?php echo $current_page == 'video_tutorials.php' ? 'text-white bg-gradient-to-tr from-primary to-secondary shadow-primaryglow' : 'text-textsecondary hover:text-white hover:bg-white/5'; ?>">
            <i class="fa-solid fa-circle-play text-lg"></i>
            <span>Video Tutorials</span>
            <?php if ($current_page == 'video_tutorials.php'): ?>
                <span class="w-1.5 h-1.5 bg-white rounded-full absolute right-4"></span>
            <?php endif; ?>
        </a>
        <a href="contact_support.php" class="flex items-center gap-4 px-4 py-3.5 rounded-2xl text-sm font-medium transition duration-300 relative <?php echo $current_page == 'contact_support.php' ? 'text-white bg-gradient-to-tr from-primary to-secondary shadow-primaryglow' : 'text-textsecondary hover:text-white hover:bg-white/5'; ?>">
            <i class="fa-solid fa-headset text-lg"></i>
            <span>Contact Support</span>
            <?php if ($current_page == 'contact_support.php'): ?>
                <span class="w-1.5 h-1.5 bg-white rounded-full absolute right-4"></span>
            <?php endif; ?>
        </a>
        <a href="chat_console.php" class="flex items-center gap-4 px-4 py-3.5 rounded-2xl text-sm font-medium transition duration-300 relative <?php echo $current_page == 'chat_console.php' ? 'text-white bg-gradient-to-tr from-primary to-secondary shadow-primaryglow' : 'text-textsecondary hover:text-white hover:bg-white/5'; ?>">
            <i class="fa-solid fa-comments text-lg"></i>
            <span>Live Chat</span>
            <?php if ($current_page == 'chat_console.php'): ?>
                <span class="w-1.5 h-1.5 bg-white rounded-full absolute right-4"></span>
            <?php endif; ?>
        </a>
        <a href="notifications.php" class="flex items-center gap-4 px-4 py-3.5 rounded-2xl text-sm font-medium transition duration-300 relative <?php echo $current_page == 'notifications.php' ? 'text-white bg-gradient-to-tr from-primary to-secondary shadow-primaryglow' : 'text-textsecondary hover:text-white hover:bg-white/5'; ?>">
            <i class="fa-solid fa-bell text-lg"></i>
            <span>Notifications</span>
            <span class="bg-danger text-white text-[10px] font-bold px-2 py-0.5 rounded-full absolute right-4 hidden animate-pulse" id="sidebarNotificationBadge">0</span>
            <?php if ($current_page == 'notifications.php'): ?>
                <span class="w-1.5 h-1.5 bg-white rounded-full absolute right-4"></span>
            <?php endif; ?>
        </a>
        <a href="onesignal_settings.php" class="flex items-center gap-4 px-4 py-3.5 rounded-2xl text-sm font-medium transition duration-300 relative <?php echo $current_page == 'onesignal_settings.php' ? 'text-white bg-gradient-to-tr from-primary to-secondary shadow-primaryglow' : 'text-textsecondary hover:text-white hover:bg-white/5'; ?>">
            <i class="fa-solid fa-tower-broadcast text-lg"></i>
            <span>OneSignal Settings</span>
            <?php if ($current_page == 'onesignal_settings.php'): ?>
                <span class="w-1.5 h-1.5 bg-white rounded-full absolute right-4"></span>
            <?php endif; ?>
        </a>
        <a href="app_settings.php" class="flex items-center gap-4 px-4 py-3.5 rounded-2xl text-sm font-medium transition duration-300 relative <?php echo $current_page == 'app_settings.php' ? 'text-white bg-gradient-to-tr from-primary to-secondary shadow-primaryglow' : 'text-textsecondary hover:text-white hover:bg-white/5'; ?>">
            <i class="fa-solid fa-gears text-lg"></i>
            <span>App Settings</span>
            <?php if ($current_page == 'app_settings.php'): ?>
                <span class="w-1.5 h-1.5 bg-white rounded-full absolute right-4"></span>
            <?php endif; ?>
        </a>
        <a href="import.php" class="flex items-center gap-4 px-4 py-3.5 rounded-2xl text-sm font-medium transition duration-300 relative <?php echo $current_page == 'import.php' ? 'text-white bg-gradient-to-tr from-primary to-secondary shadow-primaryglow' : 'text-textsecondary hover:text-white hover:bg-white/5'; ?>">
            <i class="fa-solid fa-file-import text-lg"></i>
            <span>Import Data</span>
            <?php if ($current_page == 'import.php'): ?>
                <span class="w-1.5 h-1.5 bg-white rounded-full absolute right-4"></span>
            <?php endif; ?>
        </a>
    </nav>

    <!-- Sidebar Profile Footer -->
    <div class="pt-4 border-t border-bordercolor">
        <div class="flex items-center bg-white/5 border border-bordercolor rounded-2xl p-3 gap-3">
            <div class="w-[38px] h-[38px] rounded-full bg-gradient-to-tr from-primary to-secondary flex items-center justify-center text-white text-base border-2 border-white/20">
                <i class="fa-solid fa-user"></i>
            </div>
            <div class="flex-1 min-w-0">
                <p class="text-xs font-bold text-white leading-tight">Super Admin</p>
                <p class="text-[10px] text-textsecondary overflow-hidden text-ellipsis whitespace-nowrap" id="sidebarAdminEmail"><?php echo isset($_SESSION['admin_email']) ? htmlspecialchars($_SESSION['admin_email']) : 'admin@extrememedical.com'; ?></p>
            </div>
            <div class="flex items-center">
                <a href="logout.php" title="Logout" class="text-textmuted text-lg p-1 hover:text-danger transition duration-200">
                    <i class="fa-solid fa-right-from-bracket"></i>
                </a>
            </div>
        </div>
    </div>
</aside>
