<?php
/**
 * Staff Feedbacks Management System
 */
require_once __DIR__ . '/config.php';
check_auth();

$page_title = 'Staff Feedbacks';
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
    'assets/js/feedbacks.js'
];

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/sidebar.php';
?>

<div class="flex-1 flex flex-col min-w-0 bg-darkbg">
    <!-- Navbar / Header -->
    <header class="h-20 border-b border-bordercolor px-8 flex items-center justify-between bg-darkbg/80 backdrop-blur-md sticky top-0 z-[90]">
        <div class="flex flex-col">
            <h1 class="text-xl font-extrabold text-white">Staff Feedbacks</h1>
            <p class="text-xs text-textsecondary">View user reviews, star ratings, and application feedback</p>
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
                    <input type="text" id="feedbackSearchInput" placeholder="Search by name, email, or comment..." class="w-full bg-white/5 border border-bordercolor rounded-xl py-2.5 pl-10 pr-4 text-white text-xs outline-none focus:border-primary transition duration-200">
                </div>
                <!-- Export buttons container -->
                <div id="buttonsContainer" class="flex flex-wrap gap-2 justify-end w-full md:w-auto"></div>
            </div>
        </div>

        <!-- Feedbacks Table Section -->
        <section class="bg-darksurface border border-bordercolor rounded-[24px] p-6 shadow-xl">
            <div class="overflow-x-auto w-full">
                <table id="feedbacksTable" class="w-full border-collapse text-left">
                    <thead>
                        <tr>
                            <th class="p-4 border-b border-bordercolor text-textsecondary text-[11px] font-bold uppercase tracking-wider text-center" style="width: 50px;">#</th>
                            <th class="p-4 border-b border-bordercolor text-textsecondary text-[11px] font-bold uppercase tracking-wider">User Name</th>
                            <th class="p-4 border-b border-bordercolor text-textsecondary text-[11px] font-bold uppercase tracking-wider">Email Address</th>
                            <th class="p-4 border-b border-bordercolor text-textsecondary text-[11px] font-bold uppercase tracking-wider text-center" style="width: 120px;">Rating</th>
                            <th class="p-4 border-b border-bordercolor text-textsecondary text-[11px] font-bold uppercase tracking-wider">Feedback Comment</th>
                            <th class="p-4 border-b border-bordercolor text-textsecondary text-[11px] font-bold uppercase tracking-wider">Date Submitted</th>
                            <th class="p-4 border-b border-bordercolor text-textsecondary text-[11px] font-bold uppercase tracking-wider text-center" style="width: 80px;">Actions</th>
                        </tr>
                    </thead>
                    <tbody id="feedbacksTableBody">
                        <tr>
                            <td colspan="7" class="p-4 border-b border-bordercolor text-xs text-white text-center text-textmuted py-12">
                                <i class="fa-solid fa-circle-notch fa-spin"></i> Fetching feedbacks...
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
