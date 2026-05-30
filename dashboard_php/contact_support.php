<?php
/**
 * Contact Support & Ticketing Settings Admin Dashboard
 */
require_once __DIR__ . '/config.php';
check_auth();

$page_title = 'Contact Support Management';
$page_scripts = ['assets/js/contact_support.js'];

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/sidebar.php';
?>

<div class="flex-1 flex flex-col min-w-0 bg-darkbg">
    <!-- Header -->
    <header class="h-20 border-b border-bordercolor px-8 flex items-center justify-between bg-darkbg/80 backdrop-blur-md sticky top-0 z-[90]">
        <div class="flex flex-col">
            <h1 class="text-xl font-extrabold text-white">Contact Support</h1>
            <p class="text-xs text-textsecondary">Configure support availability and respond to clinic trouble tickets</p>
        </div>
    </header>

    <!-- Page Content -->
    <main class="p-8 flex-1 overflow-y-auto">
        <!-- Configuration & Analytics Grid -->
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
            <!-- Availability Settings Card -->
            <div class="bg-darksec border border-bordercolor rounded-[24px] p-6 lg:col-span-2">
                <div class="flex items-center gap-3 mb-6">
                    <div class="w-10 h-10 rounded-xl bg-primary/10 flex items-center justify-center text-primary text-lg">
                        <i class="fa-solid fa-gears"></i>
                    </div>
                    <div>
                        <h2 class="text-sm font-extrabold text-white">Support Status Config</h2>
                        <p class="text-[11px] text-textsecondary">Toggle support status and response text displayed in the app</p>
                    </div>
                </div>

                <form id="configForm" class="flex flex-col gap-4" onsubmit="event.preventDefault(); saveConfig();">
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                        <div class="flex flex-col gap-1.5">
                            <label for="configStatus" class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Availability Status</label>
                            <select id="configStatus" class="bg-darkbg border border-bordercolor rounded-xl px-4 py-3 text-white text-xs outline-none focus:border-primary transition">
                                <option value="online">Online (Show Active Green Badge)</option>
                                <option value="offline">Offline (Show Busy/Closed)</option>
                            </select>
                        </div>
                        <div class="flex flex-col gap-1.5 md:col-span-2">
                            <label for="configResponseTimeText" class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Response Delay Text (App Header)</label>
                            <input type="text" id="configResponseTimeText" class="bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-xs outline-none focus:border-primary transition" placeholder="e.g. We typically reply in 2–4 hours" required>
                        </div>
                    </div>

                    <div class="flex flex-col gap-1.5">
                        <label for="configResponseTime" class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Est. Response Time (Ticket Details)</label>
                        <input type="text" id="configResponseTime" class="bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-xs outline-none focus:border-primary transition" placeholder="e.g. 2-4 business hours" required>
                    </div>

                    <!-- Subjects Configuration Section -->
                    <div class="flex flex-col gap-1.5 mt-4">
                        <label class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Configure Ticket Subjects</label>
                        <div class="flex gap-2">
                            <input type="text" id="newSubjectInput" class="flex-1 bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-xs outline-none focus:border-primary transition" placeholder="Add new subject (e.g. Calibration Problem)">
                            <button type="button" onclick="addNewSubject()" class="bg-white/5 hover:bg-white/10 border border-bordercolor text-white px-4 py-2.5 rounded-xl text-xs font-bold transition flex items-center justify-center cursor-pointer">
                                <i class="fa-solid fa-plus mr-1"></i> Add
                            </button>
                        </div>
                        <div id="subjectsListContainer" class="flex flex-wrap gap-2 mt-2">
                            <!-- Syncing subjects tags -->
                        </div>
                    </div>

                    <div class="flex justify-end mt-2">
                        <button type="submit" class="bg-gradient-to-tr from-primary to-secondary text-white font-bold text-xs px-5 py-3 rounded-xl hover:-translate-y-0.5 hover:shadow-primaryglow transition duration-200 cursor-pointer">
                            Update Config Settings
                        </button>
                    </div>
                </form>
            </div>

            <!-- Stats Info Card -->
            <div class="bg-darksec border border-bordercolor rounded-[24px] p-6 flex flex-col justify-between">
                <div class="flex justify-between items-start">
                    <div>
                        <span class="text-xs font-bold text-textsecondary">Active Tickets Status</span>
                        <h3 class="text-3xl font-black text-white mt-1" id="activeTicketsCount">0</h3>
                    </div>
                    <div class="w-12 h-12 rounded-2xl bg-danger/10 text-danger flex items-center justify-center text-xl">
                        <i class="fa-solid fa-headset"></i>
                    </div>
                </div>
                <div class="h-[1px] bg-bordercolor my-4"></div>
                <div class="flex flex-col gap-2">
                    <div class="flex justify-between text-xs">
                        <span class="text-textsecondary">Total Submitted:</span>
                        <span class="font-bold text-white" id="totalTicketsCount">0</span>
                    </div>
                    <div class="flex justify-between text-xs">
                        <span class="text-textsecondary">Resolved:</span>
                        <span class="font-bold text-success" id="resolvedTicketsCount">0</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Tickets Section -->
        <section class="bg-darksec border border-bordercolor rounded-[28px] overflow-hidden">
            <div class="p-6 border-b border-bordercolor flex justify-between items-center bg-white/[0.01]">
                <div>
                    <h2 class="text-base font-extrabold text-white">Submitted Support Tickets</h2>
                    <p class="text-xs text-textsecondary">Review and track incoming issues submitted by clinic devices</p>
                </div>
            </div>

            <div class="overflow-x-auto">
                <table class="w-full text-left border-collapse">
                    <thead>
                        <tr class="border-b border-bordercolor bg-white/[0.02]">
                            <th class="p-5 text-[10px] font-bold text-textsecondary uppercase tracking-wider">Ticket ID</th>
                            <th class="p-5 text-[10px] font-bold text-textsecondary uppercase tracking-wider">Clinic & Device</th>
                            <th class="p-5 text-[10px] font-bold text-textsecondary uppercase tracking-wider">Subject & details</th>
                            <th class="p-5 text-[10px] font-bold text-textsecondary uppercase tracking-wider">Priority</th>
                            <th class="p-5 text-[10px] font-bold text-textsecondary uppercase tracking-wider">Status</th>
                            <th class="p-5 text-[10px] font-bold text-textsecondary uppercase tracking-wider text-right">Actions</th>
                        </tr>
                    </thead>
                    <tbody id="ticketsTableBody" class="divide-y divide-bordercolor">
                        <tr>
                            <td colspan="6" class="p-12 text-center text-textmuted">
                                <i class="fa-solid fa-circle-notch fa-spin text-xl mb-3 block"></i> Loading support tickets...
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </section>
    </main>
</div>

<!-- ========================================== -->
<!-- MODAL: VIEW TICKET & DISPATCH RESPONSE    -->
<!-- ========================================== -->
<div class="modal-overlay fixed inset-0 bg-darkbg/85 backdrop-blur-md flex items-center justify-center z-[1000] opacity-0 pointer-events-none transition-opacity duration-300" id="ticketModal">
    <div class="modal-content bg-darksec border border-bordercolor rounded-[28px] w-[95%] max-w-[650px] max-h-[90vh] flex flex-col overflow-hidden scale-90 transition-transform duration-300 shadow-2xl">
        <div class="p-6 border-b border-bordercolor flex items-center justify-between">
            <div class="flex items-center gap-3">
                <span class="bg-primary/10 text-primary text-[10px] font-bold px-2 py-1 rounded" id="modalTicketId">UM-00000</span>
                <h3 class="text-base font-extrabold text-white leading-tight">Ticket Investigation</h3>
            </div>
            <button onclick="closeModal('ticketModal')" class="border-none bg-white/5 text-textsecondary w-9 h-9 rounded-full cursor-pointer flex items-center justify-center hover:bg-white/10 hover:text-white transition duration-200 text-lg">&times;</button>
        </div>
        <div class="p-6 overflow-y-auto flex-1 flex flex-col gap-5">
            <!-- Ticket Info Panel -->
            <div class="grid grid-cols-2 gap-4 bg-white/[0.02] border border-bordercolor rounded-2xl p-4">
                <div>
                    <span class="text-[9px] font-bold text-textsecondary uppercase tracking-wider">Clinic User</span>
                    <p class="text-xs font-bold text-white mt-1" id="modalClinicName">Clinic Name</p>
                </div>
                <div>
                    <span class="text-[9px] font-bold text-textsecondary uppercase tracking-wider">Device SN</span>
                    <p class="text-xs font-bold text-white mt-1" id="modalDeviceSn">SN-2024-0000</p>
                </div>
                <div>
                    <span class="text-[9px] font-bold text-textsecondary uppercase tracking-wider">Subject</span>
                    <p class="text-xs font-bold text-white mt-1" id="modalSubject">Subject</p>
                </div>
                <div>
                    <span class="text-[9px] font-bold text-textsecondary uppercase tracking-wider">Error Code</span>
                    <p class="text-xs font-bold text-white mt-1 text-warning" id="modalErrorCode">None</p>
                </div>
            </div>

            <!-- Description -->
            <div class="flex flex-col gap-1.5">
                <span class="text-[9px] font-bold text-textsecondary uppercase tracking-wider">Clinic Description</span>
                <div class="bg-black/10 border border-bordercolor/80 rounded-2xl p-4 text-xs text-textsecondary leading-relaxed whitespace-pre-wrap" id="modalDescription">
                    No description provided.
                </div>
            </div>

            <!-- Attachments -->
            <div class="flex flex-col gap-1.5">
                <span class="text-[9px] font-bold text-textsecondary uppercase tracking-wider">Ticket Attachments</span>
                <div id="modalAttachmentsContainer" class="flex flex-wrap gap-3">
                    <span class="text-xs text-textmuted">No attachments.</span>
                </div>
            </div>

            <!-- Response Admin Input -->
            <div class="flex flex-col gap-1.5" id="responseContainer">
                <label for="ticketResponse" class="text-[9px] font-bold text-textsecondary uppercase tracking-wider">Investigation Resolution Note</label>
                <textarea id="ticketResponse" rows="3" class="bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-xs outline-none focus:border-primary transition" placeholder="Write response details or debugging logs to help the clinic..."></textarea>
            </div>
        </div>
        <div class="p-6 border-t border-bordercolor flex justify-end gap-3 bg-white/[0.01]">
            <button type="button" onclick="closeModal('ticketModal')" class="bg-transparent border border-bordercolor text-textsecondary px-4 py-2.5 rounded-xl text-xs font-semibold hover:bg-white/5 transition">Close</button>
            <button type="button" id="resolveTicketBtn" onclick="resolveTicket()" class="bg-gradient-to-tr from-success to-primary text-white font-bold text-xs px-5 py-2.5 rounded-xl hover:-translate-y-0.5 hover:shadow-primaryglow transition duration-200 cursor-pointer">
                Resolve Support Ticket
            </button>
        </div>
    </div>
</div>

<?php
require_once __DIR__ . '/includes/footer.php';
?>
