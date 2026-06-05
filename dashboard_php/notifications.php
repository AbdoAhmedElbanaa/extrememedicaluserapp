<?php
/**
 * System Notifications Logs Center
 * Extreme Medical Admin Dashboard
 */
require_once __DIR__ . '/config.php';
check_auth();

$page_title = 'System Notifications';
$page_scripts = ['assets/js/notifications.js'];

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/sidebar.php';
?>

<div class="flex-1 flex flex-col min-w-0 bg-darkbg">
    <!-- Navbar / Header -->
    <header class="h-20 border-b border-bordercolor px-8 flex items-center justify-between bg-darkbg/80 backdrop-blur-md sticky top-0 z-[90]">
        <div class="flex flex-col">
            <h1 class="text-xl font-extrabold text-white">Notification History</h1>
            <p class="text-xs text-textsecondary">Monitor system alerts, incoming support tickets, and clinic activities</p>
        </div>
        <div class="flex items-center gap-3">
            <!-- Bulk Actions -->
            <button onclick="markAllNotificationsAsRead()" class="bg-white/5 hover:bg-white/10 border border-bordercolor text-white px-4 py-2.5 rounded-xl text-xs font-bold transition flex items-center justify-center cursor-pointer">
                <i class="fa-solid fa-envelope-open mr-1.5"></i> Mark All Read
            </button>
            <button onclick="clearNotificationLogs()" class="bg-danger/10 hover:bg-danger text-danger hover:text-white border border-danger/20 hover:border-danger px-4 py-2.5 rounded-xl text-xs font-bold transition flex items-center justify-center cursor-pointer">
                <i class="fa-solid fa-trash-can mr-1.5"></i> Clear All
            </button>
        </div>
    </header>

    <!-- Page Content -->
    <main class="p-8 flex-1 overflow-y-auto">
        <!-- Notifications Table Card -->
        <section class="bg-darksec border border-bordercolor rounded-[24px] overflow-hidden">
            <div class="p-6 border-b border-bordercolor flex justify-between items-center bg-white/[0.01]">
                <div>
                    <h2 class="text-sm font-extrabold text-white">Event Log Feed</h2>
                    <p class="text-xs text-textsecondary">Showing all received events and push notification alerts</p>
                </div>
            </div>

            <!-- List Area -->
            <div class="overflow-x-auto w-full">
                <table class="w-full border-collapse text-left">
                    <thead>
                        <tr class="border-b border-bordercolor bg-white/[0.02]">
                            <th class="p-5 text-[10px] font-bold text-textsecondary uppercase tracking-wider text-center" style="width: 60px;">Status</th>
                            <th class="p-5 text-[10px] font-bold text-textsecondary uppercase tracking-wider" style="width: 180px;">Type / Alert</th>
                            <th class="p-5 text-[10px] font-bold text-textsecondary uppercase tracking-wider">Description details</th>
                            <th class="p-5 text-[10px] font-bold text-textsecondary uppercase tracking-wider" style="width: 160px;">Clinic User</th>
                            <th class="p-5 text-[10px] font-bold text-textsecondary uppercase tracking-wider" style="width: 150px;">Received At</th>
                            <th class="p-5 text-[10px] font-bold text-textsecondary uppercase tracking-wider text-right" style="width: 130px;">Action</th>
                        </tr>
                    </thead>
                    <tbody id="notificationsTableBody" class="divide-y divide-bordercolor">
                        <tr>
                            <td colspan="6" class="p-12 text-center text-textmuted py-16">
                                <i class="fa-solid fa-circle-notch fa-spin text-xl mb-3 block"></i> Loading notification feed logs...
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
