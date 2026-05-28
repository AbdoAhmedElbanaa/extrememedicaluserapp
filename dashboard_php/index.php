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

<div class="flex-1 flex flex-col min-w-0 bg-darkbg">
    <!-- Navbar / Header -->
    <header class="h-20 border-b border-bordercolor px-8 flex items-center justify-between bg-darkbg/80 backdrop-blur-md sticky top-0 z-[90]">
        <div class="flex flex-col">
            <h1 class="text-xl font-extrabold text-white">Dashboard Overview</h1>
            <p class="text-xs text-textsecondary">Real-time healthcare node statistics</p>
        </div>
        <div class="flex items-center gap-4">
            <div class="relative w-80">
                <i class="fa-solid fa-magnifying-glass absolute left-3.5 top-1/2 -translate-y-1/2 text-textsecondary text-sm"></i>
                <input type="text" placeholder="Search parameters..." class="w-full bg-white/5 border border-bordercolor rounded-xl py-2.5 pl-10 pr-4 text-white text-xs outline-none focus:border-primary transition duration-200">
            </div>
        </div>
    </header>

    <!-- Page Content -->
    <main class="p-8 flex-1 overflow-y-auto">
        <!-- Metrics Counter Grid -->
        <section class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
            <!-- Card 1 -->
            <div class="bg-darksurface border border-bordercolor rounded-[24px] p-6 flex items-center gap-5 shadow-lg relative overflow-hidden before:absolute before:top-0 before:left-0 before:w-1 before:h-full before:bg-gradient-to-b before:from-primary before:to-secondary">
                <div class="w-14 h-14 rounded-2xl flex items-center justify-center text-2xl bg-primary/15 text-primary">
                    <i class="fa-solid fa-hospital"></i>
                </div>
                <div class="flex flex-col">
                    <span class="text-[11px] font-bold text-textsecondary uppercase tracking-wider">Total Clinics</span>
                    <span class="text-3xl font-extrabold text-white my-1" id="statTotalClinics">0</span>
                    <span class="text-[10px] text-textmuted">Registered medical centers</span>
                </div>
            </div>
            <!-- Card 2 -->
            <div class="bg-darksurface border border-bordercolor rounded-[24px] p-6 flex items-center gap-5 shadow-lg relative overflow-hidden before:absolute before:top-0 before:left-0 before:w-1 before:h-full before:bg-success">
                <div class="w-14 h-14 rounded-2xl flex items-center justify-center text-2xl bg-success/15 text-success">
                    <i class="fa-solid fa-map-location-dot"></i>
                </div>
                <div class="flex flex-col">
                    <span class="text-[11px] font-bold text-textsecondary uppercase tracking-wider">Mapped Clinics</span>
                    <span class="text-3xl font-extrabold text-white my-1" id="statMappedClinics">0</span>
                    <span class="text-[10px] text-textmuted">Clinics with coordinates set</span>
                </div>
            </div>
            <!-- Card 3 -->
            <div class="bg-darksurface border border-bordercolor rounded-[24px] p-6 flex items-center gap-5 shadow-lg relative overflow-hidden before:absolute before:top-0 before:left-0 before:w-1 before:h-full before:bg-warning">
                <div class="w-14 h-14 rounded-2xl flex items-center justify-center text-2xl bg-warning/15 text-warning">
                    <i class="fa-solid fa-user-shield"></i>
                </div>
                <div class="flex flex-col">
                    <span class="text-[11px] font-bold text-textsecondary uppercase tracking-wider">Active Accounts</span>
                    <span class="text-3xl font-extrabold text-white my-1" id="statActiveAccounts">0</span>
                    <span class="text-[10px] text-textmuted">Authenticated users in Auth</span>
                </div>
            </div>
        </section>

        <!-- Charts and Lists Grid -->
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
            <!-- Left Card: Chart -->
            <div class="bg-darksurface border border-bordercolor rounded-[24px] p-6 shadow-xl backdrop-blur-md lg:col-span-2">
                <div class="flex items-center justify-between mb-5">
                    <h2 class="text-sm font-bold text-white flex items-center gap-2.5">
                        <i class="fa-solid fa-chart-line text-primary"></i>
                        Clinic Registrations Timeline
                    </h2>
                </div>
                <div class="h-[320px] relative">
                    <canvas id="registrationsChart"></canvas>
                </div>
            </div>

            <!-- Right Card: Service Status / Live Feed -->
            <div class="bg-darksurface border border-bordercolor rounded-[24px] p-6 shadow-xl backdrop-blur-md lg:col-span-1">
                <div class="flex items-center justify-between mb-5">
                    <h2 class="text-sm font-bold text-white flex items-center gap-2.5">
                        <i class="fa-solid fa-network-wired text-primary"></i>
                        Live Database Status
                    </h2>
                    <span class="status-badge success" id="dbStatusBadge">
                        <i class="fa-solid fa-circle"></i> Connected
                    </span>
                </div>
                <div class="flex flex-col gap-4">
                    <div class="flex gap-3.5 items-start">
                        <i class="fa-solid fa-database text-primary text-lg mt-0.5"></i>
                        <div class="flex flex-col">
                            <span class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Database Type</span>
                            <span class="text-xs text-white font-semibold mt-0.5">Firestore + RTDB</span>
                        </div>
                    </div>
                    <div class="h-[1px] bg-bordercolor my-1"></div>
                    <div class="flex gap-3.5 items-start">
                        <i class="fa-solid fa-wifi text-success text-lg mt-0.5"></i>
                        <div class="flex flex-col">
                            <span class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">RTDB Syncing</span>
                            <span class="text-xs text-white font-semibold mt-0.5" id="syncStatusDesc">Listening for edits...</span>
                        </div>
                    </div>
                    <div class="h-[1px] bg-bordercolor my-1"></div>
                    <div class="flex gap-3.5 items-start">
                        <i class="fa-solid fa-circle-info text-warning text-lg mt-0.5"></i>
                        <div class="flex flex-col">
                            <span class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Active Connection</span>
                            <span class="text-xs text-white font-semibold mt-0.5" id="activeConnectionDesc">Establishing...</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Recent Registrations Section -->
        <section class="bg-darksurface border border-bordercolor rounded-[24px] p-6 shadow-xl backdrop-blur-md">
            <div class="flex items-center justify-between mb-5">
                <h2 class="text-sm font-bold text-white flex items-center gap-2.5">
                    <i class="fa-solid fa-clock-rotate-left text-primary"></i>
                    Recently Added Clinics
                </h2>
                <a href="users.php" class="bg-transparent border border-bordercolor text-textsecondary hover:text-white hover:bg-white/5 px-3.5 py-1.5 rounded-xl text-[11px] font-bold transition duration-200">Manage All</a>
            </div>
            <div class="overflow-x-auto w-full">
                <table class="w-full border-collapse text-left">
                    <thead>
                        <tr>
                            <th class="p-4 border-b border-bordercolor text-textsecondary text-[11px] font-bold uppercase tracking-wider text-center" style="width: 50px;">#</th>
                            <th class="p-4 border-b border-bordercolor text-textsecondary text-[11px] font-bold uppercase tracking-wider">Clinic Name</th>
                            <th class="p-4 border-b border-bordercolor text-textsecondary text-[11px] font-bold uppercase tracking-wider">Doctor / Contact</th>
                            <th class="p-4 border-b border-bordercolor text-textsecondary text-[11px] font-bold uppercase tracking-wider">Phone</th>
                            <th class="p-4 border-b border-bordercolor text-textsecondary text-[11px] font-bold uppercase tracking-wider">Email</th>
                            <th class="p-4 border-b border-bordercolor text-textsecondary text-[11px] font-bold uppercase tracking-wider">Location Status</th>
                        </tr>
                    </thead>
                    <tbody id="recentClinicsTableBody">
                        <tr>
                            <td colspan="6" class="p-4 border-b border-bordercolor text-xs text-white text-center text-textmuted py-10">
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
