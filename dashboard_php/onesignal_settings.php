<?php
/**
 * OneSignal & Push Notifications Settings Management
 * Extreme Medical Web Administration
 */
require_once __DIR__ . '/config.php';
check_auth();

$page_title = 'OneSignal & Push Configuration';
$page_scripts = ['assets/js/onesignal_settings.js'];

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/sidebar.php';
?>

<div class="flex-1 flex flex-col min-w-0 bg-darkbg">
    <!-- Header -->
    <header class="h-20 border-b border-bordercolor px-8 flex items-center justify-between bg-darkbg/80 backdrop-blur-md sticky top-0 z-[90]">
        <div class="flex flex-col">
            <h1 class="text-xl font-extrabold text-white">OneSignal Push Settings</h1>
            <p class="text-xs text-textsecondary">Configure push notifications settings, delivery rules, and dispatch manual alerts</p>
        </div>
    </header>

    <!-- Page Content -->
    <main class="p-8 flex-1 overflow-y-auto">
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
            <!-- Left Side: Config Forms (2 Cols) -->
            <div class="lg:col-span-2 flex flex-col gap-8">
                <!-- Credentials Section -->
                <div class="bg-darksec border border-bordercolor rounded-[24px] p-8 shadow-lg">
                    <div class="flex items-center gap-3 mb-6">
                        <div class="w-10 h-10 rounded-xl bg-primary/10 flex items-center justify-center text-primary text-lg">
                            <i class="fa-solid fa-sliders"></i>
                        </div>
                        <div>
                            <h2 class="text-base font-extrabold text-white">OneSignal Core Keys</h2>
                            <p class="text-[11px] text-textsecondary">Specify API access credentials to initialize and dispatch notifications</p>
                        </div>
                    </div>

                    <form id="onesignalConfigForm" class="flex flex-col gap-5" onsubmit="event.preventDefault(); saveOneSignalConfig();">
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                            <div class="flex flex-col gap-1.5">
                                <label for="onesignalAppId" class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">OneSignal App ID</label>
                                <input type="text" id="onesignalAppId" class="bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-xs outline-none focus:border-primary transition" placeholder="e.g. xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" required>
                            </div>
                            <div class="flex flex-col gap-1.5">
                                <label for="onesignalApiKey" class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">REST API Key (Secret)</label>
                                <input type="password" id="onesignalApiKey" class="bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-xs outline-none focus:border-primary transition" placeholder="e.g. NGM0ZGEyNDgt..." required>
                            </div>
                        </div>

                        <div class="flex items-center justify-between p-4 bg-white/[0.02] border border-bordercolor rounded-xl mt-2">
                            <div class="flex flex-col gap-0.5">
                                <span class="text-xs font-bold text-white">Enable Push Globally</span>
                                <span class="text-[10px] text-textsecondary">Allow the system to dispatch automated background notifications</span>
                            </div>
                            <label class="relative inline-flex items-center cursor-pointer">
                                <input type="checkbox" id="onesignalEnabled" class="sr-only peer">
                                <div class="w-11 h-6 bg-white/10 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary"></div>
                            </label>
                        </div>

                        <!-- Routing Preferences -->
                        <div class="h-[1px] bg-bordercolor my-2"></div>
                        <h3 class="text-xs font-bold text-white uppercase tracking-wider">Automatic Routing Rules</h3>

                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div class="flex items-center justify-between p-3.5 bg-white/[0.01] border border-bordercolor/60 rounded-xl">
                                <div class="flex flex-col">
                                    <span class="text-xs font-bold text-white">New Tickets Alert</span>
                                    <span class="text-[9px] text-textmuted">Notify when a clinic submits a ticket</span>
                                </div>
                                <input type="checkbox" id="notifyOnNewTicket" class="w-4 h-4 text-primary bg-white/5 border-bordercolor rounded focus:ring-primary">
                            </div>

                            <div class="flex items-center justify-between p-3.5 bg-white/[0.01] border border-bordercolor/60 rounded-xl">
                                <div class="flex flex-col">
                                    <span class="text-xs font-bold text-white">Chat Replies Alert</span>
                                    <span class="text-[9px] text-textmuted">Notify users on admin support chat replies</span>
                                </div>
                                <input type="checkbox" id="notifyOnChatReply" class="w-4 h-4 text-primary bg-white/5 border-bordercolor rounded focus:ring-primary">
                            </div>

                            <div class="flex items-center justify-between p-3.5 bg-white/[0.01] border border-bordercolor/60 rounded-xl">
                                <div class="flex flex-col">
                                    <span class="text-xs font-bold text-white">Ticket Updates Alert</span>
                                    <span class="text-[9px] text-textmuted">Notify users on ticket status modifications</span>
                                </div>
                                <input type="checkbox" id="notifyOnTicketStatusChange" class="w-4 h-4 text-primary bg-white/5 border-bordercolor rounded focus:ring-primary">
                            </div>

                            <div class="flex flex-col gap-1.5 justify-center pl-1">
                                <label for="defaultNotificationSound" class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Default Sound Profile</label>
                                <select id="defaultNotificationSound" class="bg-darkbg border border-bordercolor rounded-xl px-4 py-2.5 text-white text-xs outline-none focus:border-primary transition">
                                    <option value="default">Default OS Sound</option>
                                    <option value="chime">Medical Premium Chime</option>
                                    <option value="alert">High Intensity Siren</option>
                                    <option value="silent">No Sound (Silent Mode)</option>
                                </select>
                            </div>
                        </div>

                        <div class="flex justify-end mt-4">
                            <button type="submit" class="bg-gradient-to-tr from-primary to-secondary text-white font-bold text-xs px-6 py-3.5 rounded-xl hover:-translate-y-0.5 hover:shadow-primaryglow transition duration-200 cursor-pointer">
                                <i class="fa-solid fa-cloud-arrow-up mr-1.5"></i> Update Push Settings
                            </button>
                        </div>
                    </form>
                </div>

                <!-- Test Notification Section -->
                <div class="bg-darksec border border-bordercolor rounded-[24px] p-8 shadow-lg">
                    <div class="flex items-center gap-3 mb-6">
                        <div class="w-10 h-10 rounded-xl bg-warning/10 flex items-center justify-center text-warning text-lg">
                            <i class="fa-solid fa-paper-plane"></i>
                        </div>
                        <div>
                            <h2 class="text-base font-extrabold text-white">Manual Push Dispatcher</h2>
                            <p class="text-[11px] text-textsecondary">Send interactive test push alerts instantly to specific users or broadcast globally</p>
                        </div>
                    </div>

                    <form id="testPushForm" class="flex flex-col gap-4" onsubmit="event.preventDefault(); sendTestPush();">
                        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                            <div class="flex flex-col gap-1.5">
                                <label for="pushTargetType" class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Target Audience</label>
                                <select id="pushTargetType" onchange="toggleTargetUidField()" class="bg-darkbg border border-bordercolor rounded-xl px-4 py-3 text-white text-xs outline-none focus:border-primary transition">
                                    <option value="all">Broadcast (All Subscribed Users)</option>
                                    <option value="user">Specific User UID Alias</option>
                                </select>
                            </div>
                            <div class="flex flex-col gap-1.5 md:col-span-2 hidden" id="targetUidWrapper">
                                <label for="pushTargetUid" class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">User Firebase UID</label>
                                <input type="text" id="pushTargetUid" class="bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-xs outline-none focus:border-primary transition" placeholder="Paste user authentication UID (e.g. jx73Hsd...)">
                            </div>
                        </div>

                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div class="flex flex-col gap-1.5">
                                <label for="pushTitle" class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Alert Heading / Title</label>
                                <input type="text" id="pushTitle" class="bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-xs outline-none focus:border-primary transition" placeholder="e.g. Critical Device System Error" required>
                            </div>
                            <div class="flex flex-col gap-1.5">
                                <label for="pushActionRoute" class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">App Deep Link Route (Action)</label>
                                <select id="pushActionRoute" class="bg-darkbg border border-bordercolor rounded-xl px-4 py-3 text-white text-xs outline-none focus:border-primary transition">
                                    <option value="">None (Just Open App Home)</option>
                                    <option value="/contactSupport">Contact Support / Live chat</option>
                                    <option value="/mySupportRequests">My Tickets Center</option>
                                    <option value="/devices">Connected Devices Status</option>
                                    <option value="/videoTutorials">Video Library</option>
                                </select>
                            </div>
                        </div>

                        <div class="flex flex-col gap-1.5">
                            <label for="pushBody" class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Alert Content / Message Body</label>
                            <textarea id="pushBody" rows="3" class="bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-xs outline-none focus:border-primary transition resize-none" placeholder="Write notification message content clearly..." required></textarea>
                        </div>

                        <div class="flex flex-col gap-1.5">
                            <label for="pushCustomData" class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Custom JSON Payload Data (Optional)</label>
                            <textarea id="pushCustomData" rows="2" class="bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-xs font-mono outline-none focus:border-primary transition resize-none" placeholder='e.g. {"errorCode": "E102", "ticketId": "-Nxs28Hds"}'></textarea>
                        </div>

                        <div class="flex justify-end gap-3 mt-2">
                            <button type="submit" id="sendPushBtn" class="bg-gradient-to-tr from-warning to-secondary text-white font-bold text-xs px-6 py-3.5 rounded-xl hover:-translate-y-0.5 hover:shadow-primaryglow transition duration-200 cursor-pointer flex items-center justify-center gap-2">
                                <i class="fa-solid fa-paper-plane"></i> Dispatch Notification
                            </button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Right Side: Status Cards (1 Col) -->
            <div class="flex flex-col gap-6">
                <!-- OneSignal API Connection Status -->
                <div class="bg-darksec border border-bordercolor rounded-[24px] p-6 shadow-xl">
                    <div class="flex items-center justify-between mb-4">
                        <h2 class="text-sm font-bold text-white flex items-center gap-2.5">
                            <i class="fa-solid fa-network-wired text-primary"></i>
                            OneSignal Status
                        </h2>
                        <span class="status-badge success" id="onesignalConnectionBadge">
                            <i class="fa-solid fa-circle"></i> Connected
                        </span>
                    </div>

                    <div class="flex flex-col gap-4 text-xs">
                        <div class="flex justify-between items-center">
                            <span class="text-textsecondary">Config State:</span>
                            <span class="font-bold text-white" id="configStateText">Loading...</span>
                        </div>
                        <div class="h-[1px] bg-bordercolor"></div>
                        <div class="flex justify-between items-center">
                            <span class="text-textsecondary">App Registered:</span>
                            <span class="font-bold text-white truncate max-w-[150px]" id="onesignalStateAppId">Not Configured</span>
                        </div>
                        <div class="h-[1px] bg-bordercolor"></div>
                        <div class="flex justify-between items-center">
                            <span class="text-textsecondary">Endpoint API:</span>
                            <span class="font-bold text-textsecondary">api.onesignal.com</span>
                        </div>
                    </div>
                </div>

                <!-- Setup Reference Guide -->
                <div class="bg-darksec border border-bordercolor rounded-[24px] p-6 shadow-xl">
                    <h3 class="text-sm font-extrabold text-white mb-3 flex items-center gap-2.5">
                        <i class="fa-solid fa-circle-info text-warning"></i>
                        Setup Instructions
                    </h3>
                    <div class="text-[11px] text-textsecondary leading-relaxed flex flex-col gap-3">
                        <p>
                            To configure Push Notifications successfully:
                        </p>
                        <ol class="list-decimal pl-4 flex flex-col gap-2">
                            <li>Create or open an app inside the <a href="https://onesignal.com/" target="_blank" class="text-primary hover:underline font-bold">OneSignal Console</a>.</li>
                            <li>Go to <strong>Settings -> Keys & IDs</strong> to copy the App ID and REST API Key.</li>
                            <li>Paste the credentials into the Core Keys form on the left.</li>
                            <li>In the Flutter app, ensure the configurations sync automatically from Firebase.</li>
                        </ol>
                        <p class="text-textmuted">
                            Note: Users register their device dynamically with their Firebase UID as an alias (external_id) when logging into the app.
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>

<?php
require_once __DIR__ . '/includes/footer.php';
?>
