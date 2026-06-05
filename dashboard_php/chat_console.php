<?php
/**
 * Live Chat Multi-Session Workstation Console
 * Extreme Medical Admin Dashboard
 */
require_once __DIR__ . '/config.php';
check_auth();

$page_title = 'Live Support Chat';
$page_scripts = ['assets/js/chat_console.js'];

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/sidebar.php';
?>

<div class="flex-1 flex min-w-0 bg-darkbg overflow-hidden h-screen">
    <!-- COLUMN 1: Active Conversations List -->
    <aside class="w-[340px] border-r border-bordercolor flex flex-col bg-darksec/40 shrink-0">
        <!-- Search & Filter Header -->
        <div class="p-5 border-b border-bordercolor flex flex-col gap-3.5 bg-darksec/20">
            <div>
                <h2 class="text-sm font-extrabold text-white">Live Support Chats</h2>
                <p class="text-[10px] text-textsecondary">Manage active user chat sessions in real-time</p>
            </div>
            <div class="relative">
                <i class="fa-solid fa-magnifying-glass absolute left-3.5 top-1/2 -translate-y-1/2 text-textsecondary text-xs"></i>
                <input type="text" id="chatSearchInput" oninput="filterChats()" placeholder="Search clinic or ticket ID..." class="w-full bg-white/5 border border-bordercolor rounded-xl py-2 pl-9 pr-4 text-white text-xs outline-none focus:border-primary transition">
            </div>
        </div>

        <!-- Chats Scrollable area -->
        <div class="flex-1 overflow-y-auto divide-y divide-bordercolor/60" id="chatListContainer">
            <div class="p-12 text-center text-textmuted">
                <i class="fa-solid fa-circle-notch fa-spin text-xl mb-3 block"></i> Syncing chat rooms...
            </div>
        </div>
    </aside>

    <!-- COLUMN 2: Message Stream Window -->
    <section class="flex-1 flex flex-col min-w-0 bg-darkbg relative">
        <!-- Chat Welcome / Placeholder state -->
        <div id="chatConsolePlaceholder" class="absolute inset-0 flex flex-col items-center justify-center text-center p-8 bg-darkbg z-10 transition-opacity duration-300">
            <div class="w-16 h-16 rounded-3xl bg-primary/10 flex items-center justify-center text-primary text-3xl mb-5 shadow-primaryglow animate-pulse">
                <i class="fa-solid fa-comments"></i>
            </div>
            <h3 class="text-base font-extrabold text-white">Live Chat Console</h3>
            <p class="text-xs text-textsecondary mt-1 max-w-[320px] leading-relaxed">Select an active chat session from the list on the left to start communicating with the clinic in real-time.</p>
        </div>

        <!-- Active Chat Header -->
        <header class="h-20 border-b border-bordercolor px-6 flex items-center justify-between bg-darksec/20 backdrop-blur-md shrink-0">
            <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-xl bg-gradient-to-tr from-primary to-secondary flex items-center justify-center text-white text-base">
                    <i class="fa-solid fa-clinic-medical"></i>
                </div>
                <div class="flex flex-col">
                    <div class="flex items-center gap-2">
                        <h2 class="text-xs font-extrabold text-white" id="activeChatClinicName">Clinic Name</h2>
                        <span class="px-2 py-0.5 rounded text-[8px] font-bold bg-danger/15 text-danger" id="activeChatTicketId">UM-00000</span>
                    </div>
                    <span class="text-[10px] text-textsecondary" id="activeChatSubject">Device Calibration - High</span>
                </div>
            </div>

            <!-- Header Controls -->
            <div class="flex items-center gap-3">
                <!-- Status Picker -->
                <div class="flex items-center gap-1.5">
                    <label for="activeTicketStatus" class="text-[9px] font-bold text-textsecondary uppercase tracking-wider">Status:</label>
                    <select id="activeTicketStatus" onchange="updateActiveTicketStatus()" class="bg-white/5 border border-bordercolor rounded-lg px-2.5 py-1.5 text-white text-[10px] font-bold outline-none focus:border-primary transition">
                        <option value="IN REVIEW">IN REVIEW</option>
                        <option value="RESPONSE SENT">RESPONSE SENT</option>
                        <option value="AWAITING REPLY">AWAITING REPLY</option>
                        <option value="RESOLVED">RESOLVED</option>
                    </select>
                </div>
                <!-- Close Session button -->
                <button onclick="resolveActiveChat()" class="bg-success/15 hover:bg-success text-success hover:text-white px-3.5 py-1.5 rounded-xl text-xs font-bold transition flex items-center gap-1.5 cursor-pointer">
                    <i class="fa-solid fa-circle-check"></i> Close Chat
                </button>
            </div>
        </header>

        <!-- Message logs stream box -->
        <div class="flex-1 overflow-y-auto p-6 flex flex-col gap-4" id="chatMessagesBox">
            <!-- Messages render here -->
        </div>

        <!-- Chat Input area -->
        <footer class="p-4 border-t border-bordercolor bg-darksec/10 shrink-0">
            <!-- Quick Responses dropdown -->
            <div class="flex items-center gap-2 mb-3">
                <span class="text-[9px] font-bold text-textmuted uppercase tracking-wider">Quick Templates:</span>
                <button onclick="useQuickTemplate('Hello, our engineering team is currently investigating the issue.')" class="bg-white/5 hover:bg-white/10 text-white/70 px-2 py-1 rounded text-[9px] font-semibold transition cursor-pointer">Investigating</button>
                <button onclick="useQuickTemplate('Please verify your device internet connection and reboot the controller.')" class="bg-white/5 hover:bg-white/10 text-white/70 px-2 py-1 rounded text-[9px] font-semibold transition cursor-pointer">Verify Conn</button>
                <button onclick="useQuickTemplate('We have updated your device firmware. Please check if the issue is resolved.')" class="bg-white/5 hover:bg-white/10 text-white/70 px-2 py-1 rounded text-[9px] font-semibold transition cursor-pointer">Firmware Update</button>
                <button onclick="useQuickTemplate('Thank you for contacting support. The ticket has been resolved successfully.')" class="bg-white/5 hover:bg-white/10 text-white/70 px-2 py-1 rounded text-[9px] font-semibold transition cursor-pointer">Resolved</button>
            </div>

            <!-- Message Form -->
            <form id="chatInputForm" class="flex gap-3" onsubmit="event.preventDefault(); sendChatMessage();">
                <textarea id="chatMessageInput" placeholder="Type support message (Press Enter to Send)..." rows="1" class="flex-1 bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-xs outline-none focus:border-primary transition resize-none"></textarea>
                <button type="submit" class="bg-gradient-to-tr from-primary to-secondary text-white w-12 h-12 rounded-xl flex items-center justify-center shadow-primaryglow hover:-translate-y-0.5 transition duration-200 cursor-pointer">
                    <i class="fa-solid fa-paper-plane text-sm"></i>
                </button>
            </form>
        </footer>
    </section>

    <!-- COLUMN 3: Right-aligned Ticket Details Sidebar -->
    <aside class="w-[300px] border-l border-bordercolor flex flex-col bg-darksec/40 shrink-0 overflow-y-auto" id="ticketDetailSidebar">
        <!-- Section Header -->
        <div class="p-5 border-b border-bordercolor bg-darksec/20">
            <h3 class="text-xs font-extrabold text-white uppercase tracking-wider flex items-center gap-2">
                <i class="fa-solid fa-circle-info text-primary"></i> Case Overview
            </h3>
        </div>

        <div class="p-5 flex flex-col gap-6">
            <!-- Clinic & Device Card -->
            <div class="flex flex-col gap-3">
                <span class="text-[9px] font-bold text-textsecondary uppercase tracking-wider">Device & Clinic details</span>
                <div class="bg-white/[0.02] border border-bordercolor rounded-2xl p-4 flex flex-col gap-3 text-xs">
                    <div>
                        <span class="text-textmuted block text-[10px]">Clinic Name</span>
                        <span class="text-white font-bold mt-0.5 block" id="sideClinicName">Clinic Name</span>
                    </div>
                    <div>
                        <span class="text-textmuted block text-[10px]">Device Description</span>
                        <span class="text-white font-bold mt-0.5 block" id="sideDeviceDesc">SmartThermo Pro</span>
                    </div>
                    <div>
                        <span class="text-textmuted block text-[10px]">Serial Number</span>
                        <span class="text-white font-bold mt-0.5 block" id="sideDeviceSn">SN-2024-00123</span>
                    </div>
                </div>
            </div>

            <!-- Original Request Info -->
            <div class="flex flex-col gap-2.5">
                <span class="text-[9px] font-bold text-textsecondary uppercase tracking-wider">Original Request Details</span>
                <div class="flex justify-between items-center text-xs">
                    <span class="text-textmuted">Priority:</span>
                    <span class="px-2 py-0.5 rounded text-[10px] font-bold" id="sidePriority">High</span>
                </div>
                <div class="flex justify-between items-center text-xs">
                    <span class="text-textmuted">Error Code:</span>
                    <span class="font-bold text-warning" id="sideErrorCode">None</span>
                </div>
                <div class="flex justify-between items-center text-xs">
                    <span class="text-textmuted">Submitted:</span>
                    <span class="text-white font-semibold" id="sideSubmittedTime">June 4, 10:24 PM</span>
                </div>
                <div class="flex flex-col gap-1 mt-1">
                    <span class="text-textmuted text-xs">Clinic Case Description:</span>
                    <div class="bg-black/25 border border-bordercolor/60 rounded-xl p-3.5 text-xs text-textsecondary leading-relaxed whitespace-pre-wrap mt-0.5" id="sideDescription">
                        Loading...
                    </div>
                </div>
            </div>

            <!-- Attachments -->
            <div class="flex flex-col gap-3">
                <span class="text-[9px] font-bold text-textsecondary uppercase tracking-wider">Submitted Attachments</span>
                <div id="sideAttachmentsContainer" class="flex flex-wrap gap-2.5">
                    <span class="text-xs text-textmuted">No attachments.</span>
                </div>
            </div>
        </div>
    </aside>
</div>

<?php
require_once __DIR__ . '/includes/footer.php';
?>
