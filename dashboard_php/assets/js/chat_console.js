/**
 * Support Chat Console Controller
 * Extreme Medical Web Administration
 */

let chatTickets = [];
let selectedTicketId = '';
let activeMessagesRef = null;
let existingChatTicketIds = new Set();
let activeMessagesInitialLoad = true;

function _notifyNewChatRequest(ticket) {
    if (!ticket || !ticket.isChat) return;
    const clinicName = ticket.clinicName || 'Clinic user';
    showToast(`New live chat request from ${clinicName}`, 'warning');
    playNotificationChime();
}

function _notifyIncomingMessage(message) {
    if (!message || message.senderId === 'admin') return;
    const senderName = message.senderName || 'Support user';
    showToast(`New message from ${senderName}: ${message.message}`, 'info');
    playNotificationChime();
}

document.addEventListener('DOMContentLoaded', () => {
    // Check for ticketId in URL parameters
    const urlParams = new URLSearchParams(window.location.search);
    const queryTicketId = urlParams.get('ticketId');
    if (queryTicketId) {
        selectedTicketId = queryTicketId;
    }

    // Sync incoming support chat tickets
    syncChatTickets();

    // Enable Enter-to-send for chat input textarea
    const inputArea = document.getElementById('chatMessageInput');
    if (inputArea) {
        inputArea.addEventListener('keypress', (e) => {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                sendChatMessage();
            }
        });
    }
});

/**
 * Sync tickets that have chat requested from Firebase RTDB
 */
function syncChatTickets() {
    let firstLoad = true;
    rtdb.ref('contact_support/tickets').on('value', (snapshot) => {
        const data = snapshot.val();
        chatTickets = [];
        const newChatTicketIds = new Set();
        if (data) {
            Object.keys(data).forEach(key => {
                const ticket = data[key];
                // Only include chat tickets
                if (ticket.isChat) {
                    if (!existingChatTicketIds.has(key) && !firstLoad) {
                        _notifyNewChatRequest(ticket);
                    }
                    newChatTicketIds.add(key);
                    chatTickets.push({ id: key, ...ticket });
                }
            });
        }

        existingChatTicketIds = newChatTicketIds;

        // Sort by timestamp descending (newest first)
        chatTickets.sort((a, b) => (b.timestamp || 0) - (a.timestamp || 0));

        renderChatsList();

        // Refresh currently active chat if selected
        if (selectedTicketId) {
            const activeTicket = chatTickets.find(t => t.id === selectedTicketId);
            if (activeTicket) {
                updateSidebarInfo(activeTicket);
                document.getElementById('activeTicketStatus').value = activeTicket.status || 'IN REVIEW';
                
                // If resolved, lock inputs
                toggleChatInputLock(activeTicket.status === 'RESOLVED' || activeTicket.status === 'CLOSED');

                if (firstLoad) {
                    selectChatSession(selectedTicketId);
                }
            }
        }

        firstLoad = false;
    }, (error) => {
        console.error("Failed to sync chat rooms:", error);
        document.getElementById('chatListContainer').innerHTML = `
            <div class="p-12 text-center text-danger">
                Error loading: ${error.message}
            </div>
        `;
    });
}

/**
 * Render chats sidebar list
 */
function renderChatsList() {
    const container = document.getElementById('chatListContainer');
    if (!container) return;

    if (chatTickets.length === 0) {
        container.innerHTML = `
            <div class="p-12 text-center text-textmuted">
                <i class="fa-solid fa-comments-slash text-2xl mb-3 block"></i> No chat tickets requested.
            </div>
        `;
        return;
    }

    const searchQuery = document.getElementById('chatSearchInput').value.toLowerCase().trim();

    container.innerHTML = '';
    chatTickets.forEach(ticket => {
        // Search filter
        const clinicName = (ticket.clinicName || 'Clinic').toLowerCase();
        const tid = (ticket.id || '').toLowerCase();
        const subj = (ticket.subject || '').toLowerCase();
        if (searchQuery && !clinicName.includes(searchQuery) && !tid.includes(searchQuery) && !subj.includes(searchQuery)) {
            return;
        }

        const isSelected = ticket.id === selectedTicketId;
        const isClosed = ticket.status === 'RESOLVED' || ticket.status === 'CLOSED';

        const card = document.createElement('div');
        card.className = `p-4 flex flex-col gap-2 cursor-pointer border-b border-bordercolor/40 transition hover:bg-white/[0.02] ${isSelected ? 'bg-white/[0.04] border-l-4 border-l-primary' : ''}`;
        card.onclick = () => selectChatSession(ticket.id);

        // Date String
        const timeStr = ticket.timestamp ? new Date(ticket.timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : '';

        // Priority Badge Color
        let prioClass = 'bg-white/5 text-textsecondary';
        if (ticket.priority === 'Critical') prioClass = 'bg-danger/10 text-danger border border-danger/20';
        else if (ticket.priority === 'High') prioClass = 'bg-warning/10 text-warning border border-warning/20';
        else if (ticket.priority === 'Medium') prioClass = 'bg-primary/10 text-primary border border-primary/20';

        // Status pill
        let statusBadge = 'bg-warning/15 text-warning';
        if (isClosed) statusBadge = 'bg-success/15 text-success';
        else if (ticket.status === 'RESPONSE SENT') statusBadge = 'bg-primary/15 text-primary';
        else if (ticket.status === 'AWAITING REPLY') statusBadge = 'bg-secondary/15 text-secondary';

        card.innerHTML = `
            <div class="flex justify-between items-start">
                <span class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">${ticket.id}</span>
                <span class="text-[9px] text-textmuted">${timeStr}</span>
            </div>
            <div class="flex flex-col">
                <span class="text-xs font-bold ${isSelected ? 'text-primary' : 'text-white'} truncate max-w-[220px]">${escapeHtml(ticket.clinicName || 'Clinic')}</span>
                <span class="text-[10px] text-textsecondary mt-0.5 truncate max-w-[240px]">${escapeHtml(ticket.subject)}</span>
            </div>
            <div class="flex gap-2 items-center mt-1">
                <span class="text-[8px] font-bold px-1.5 py-0.5 rounded ${prioClass}">${ticket.priority}</span>
                <span class="text-[8px] font-black px-1.5 py-0.5 rounded ${statusBadge}">${ticket.status}</span>
            </div>
        `;
        container.appendChild(card);
    });
}

/**
 * Filter list based on search bar
 */
function filterChats() {
    renderChatsList();
}

/**
 * Swap active conversation session
 */
function selectChatSession(ticketId) {
    if (selectedTicketId === ticketId) return;

    selectedTicketId = ticketId;
    const ticket = chatTickets.find(t => t.id === ticketId);
    if (!ticket) return;

    // Remove old DB listener
    if (activeMessagesRef) {
        activeMessagesRef.off();
    }

    // Hide placeholder
    const placeholder = document.getElementById('chatConsolePlaceholder');
    if (placeholder) {
        placeholder.style.opacity = '0';
        setTimeout(() => placeholder.classList.add('hidden'), 300);
    }

    // Update active chat headers
    document.getElementById('activeChatClinicName').textContent = ticket.clinicName || 'Clinic';
    document.getElementById('activeChatTicketId').textContent = ticket.id;
    document.getElementById('activeChatSubject').textContent = ticket.subject + ' - ' + ticket.priority;
    document.getElementById('activeTicketStatus').value = ticket.status || 'IN REVIEW';

    // Lock/Unlock input based on status
    toggleChatInputLock(ticket.status === 'RESOLVED' || ticket.status === 'CLOSED');

    // Update Sidebar details
    updateSidebarInfo(ticket);

    // Sync Messages of the selected ticket in real time
    const chatMsgBox = document.getElementById('chatMessagesBox');
    chatMsgBox.innerHTML = `
        <div class="flex-1 flex flex-col items-center justify-center text-textmuted text-center py-20">
            <i class="fa-solid fa-circle-notch fa-spin text-xl mb-3 block"></i> Loading messages...
        </div>
    `;

    activeMessagesRef = rtdb.ref(`contact_support/chats/${ticketId}/messages`);
    activeMessagesInitialLoad = true;

    activeMessagesRef.on('child_added', (snapshot) => {
        if (activeMessagesInitialLoad) return;
        const msg = snapshot.val();
        _notifyIncomingMessage(msg);
    });

    activeMessagesRef.on('value', (snapshot) => {
        const msgs = [];
        const raw = snapshot.val();
        if (raw) {
            Object.keys(raw).forEach(k => {
                msgs.push(raw[k]);
            });
        }
        msgs.sort((a, b) => a.timestamp - b.timestamp);
        renderMessages(msgs);
        if (activeMessagesInitialLoad) {
            activeMessagesInitialLoad = false;
        }
    });

    // Mark active card selected in DOM list
    renderChatsList();
}

/**
 * Toggle lock/disable on chat inputs if resolved
 */
function toggleChatInputLock(isLocked) {
    const textInput = document.getElementById('chatMessageInput');
    const submitBtn = document.querySelector('#chatInputForm button');
    
    if (isLocked) {
        textInput.disabled = true;
        textInput.placeholder = "This chat is locked because the ticket has been resolved.";
        submitBtn.disabled = true;
        submitBtn.classList.add('opacity-40', 'cursor-not-allowed');
    } else {
        textInput.disabled = false;
        textInput.placeholder = "Type support message (Press Enter to Send)...";
        submitBtn.disabled = false;
        submitBtn.classList.remove('opacity-40', 'cursor-not-allowed');
    }
}

/**
 * Render message logs in the dialog box
 */
function renderMessages(messages) {
    const box = document.getElementById('chatMessagesBox');
    if (!box) return;

    if (messages.length === 0) {
        box.innerHTML = `
            <div class="flex-1 flex flex-col items-center justify-center text-textmuted text-center py-20">
                <i class="fa-solid fa-shield-halved text-2xl mb-3 text-primary/30"></i>
                <span class="text-xs font-semibold">End-to-End Encrypted Session</span>
                <p class="text-[10px] text-textsecondary mt-1">Send a message to open support communication logs.</p>
            </div>
        `;
        return;
    }

    box.innerHTML = '';
    messages.forEach(msg => {
        const isSystem = msg.isSystem === true;
        const isAdmin = msg.senderId === 'admin';
        
        const row = document.createElement('div');
        row.className = isSystem 
            ? 'flex justify-center my-2' 
            : `flex ${isAdmin ? 'justify-end' : 'justify-start'} w-full`;

        const timeStr = msg.timestamp ? new Date(msg.timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : '';

        if (isSystem) {
            row.innerHTML = `
                <div class="bg-white/5 border border-bordercolor/60 text-textsecondary text-[10px] font-bold px-3 py-1 rounded-xl">
                    ${escapeHtml(msg.message)}
                </div>
            `;
        } else {
            const isImage = msg.type === 'image';
            const isVideo = msg.type === 'video';
            const isAudio = msg.type === 'audio';

            let bgClass = '';
            let paddingClass = 'p-3';
            
            if (isImage || isVideo) {
                bgClass = 'bg-transparent';
                paddingClass = 'p-0';
            } else {
                bgClass = isAdmin 
                    ? 'bg-gradient-to-tr from-primary to-indigoPrimaryDark text-white rounded-tr-none shadow-md' 
                    : 'bg-darksec border border-bordercolor/80 text-white rounded-tl-none';
            }
            
            let contentHtml = '';
            if (isImage) {
                contentHtml = `
                    <div class="mt-1">
                        <img src="${msg.mediaUrl}" class="max-w-[280px] rounded-2xl cursor-pointer hover:opacity-90 transition border border-white/5 shadow-md" onclick="window.open(this.src, '_blank')">
                    </div>
                `;
            } else if (isVideo) {
                contentHtml = `
                    <div class="mt-1">
                        <video src="${msg.mediaUrl}" class="max-w-[280px] rounded-2xl border border-white/5 shadow-md" controls></video>
                    </div>
                `;
            } else if (isAudio) {
                contentHtml = `
                    <div class="mt-1">
                        <audio src="${msg.mediaUrl}" class="w-[260px] block" controls style="filter: invert(0.85);"></audio>
                    </div>
                `;
            } else {
                contentHtml = escapeHtml(msg.message);
            }
            
            row.innerHTML = `
                <div class="flex flex-col gap-1 max-w-[70%]">
                    <div class="${paddingClass} rounded-2xl text-xs leading-relaxed ${bgClass}">
                        ${contentHtml}
                    </div>
                    <div class="flex gap-1.5 items-center justify-between text-[8px] text-textmuted px-1">
                        <span>${escapeHtml(isAdmin ? 'Admin' : msg.senderName)}</span>
                        <span>${timeStr}</span>
                    </div>
                </div>
            `;
        }
        box.appendChild(row);
    });

    // Auto-scroll to bottom
    box.scrollTop = box.scrollHeight;
    updateCaseOverviewStats(messages);
}

/**
 * Quick templates helper click injection
 */
function useQuickTemplate(text) {
    const input = document.getElementById('chatMessageInput');
    if (input) {
        input.value = text;
        input.focus();
    }
}

function focusChatInput() {
    const input = document.getElementById('chatMessageInput');
    if (input) {
        input.focus();
        input.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }
}

function setTicketStatus(status) {
    const statusInput = document.getElementById('activeTicketStatus');
    if (statusInput) {
        statusInput.value = status;
    }
    updateActiveTicketStatus();
}

function notifyAppOfTicketUpdate(ticket, title, message) {
    if (!ticket || !ticket.userId) return;
    sendOneSignalPushNotification(ticket.userId, title, message, ticket.id);
}

function updateCaseOverviewStats(messages = []) {
    const totalMessages = messages.length;
    const adminMessages = messages.filter(msg => !msg.isSystem && msg.senderId === 'admin').length;
    const clinicMessages = messages.filter(msg => !msg.isSystem && msg.senderId !== 'admin').length;
    const lastTimestamp = messages.length ? messages[messages.length - 1].timestamp : null;
    const lastUpdate = lastTimestamp ? new Date(lastTimestamp).toLocaleString([], { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' }) : 'No activity yet';

    const totalEl = document.getElementById('overviewTotalMessages');
    const adminEl = document.getElementById('overviewAdminReplies');
    const clinicEl = document.getElementById('overviewUserReplies');
    const lastUpdateEl = document.getElementById('overviewLastUpdate');

    if (totalEl) totalEl.textContent = totalMessages;
    if (adminEl) adminEl.textContent = adminMessages;
    if (clinicEl) clinicEl.textContent = clinicMessages;
    if (lastUpdateEl) lastUpdateEl.textContent = lastUpdate;
}

/**
 * Send support reply message
 */
async function sendChatMessage() {
    if (!selectedTicketId) return;

    const input = document.getElementById('chatMessageInput');
    const text = input.value.trim();
    if (!text) return;

    // Check if resolved
    const ticket = chatTickets.find(t => t.id === selectedTicketId);
    if (ticket && (ticket.status === 'RESOLVED' || ticket.status === 'CLOSED')) {
        showToast("Cannot reply. Ticket resolved.", "error");
        return;
    }

    try {
        const msgId = 'MSG-' + Date.now();
        const updates = {};
        
        updates[`contact_support/chats/${selectedTicketId}/messages/${msgId}`] = {
            id: msgId,
            senderId: 'admin',
            senderName: 'Super Admin',
            message: text,
            timestamp: Date.now(),
            isSystem: false
        };

        // Also update ticket status to RESPONSE SENT automatically when admin replies
        if (ticket && ticket.status === 'IN REVIEW') {
            updates[`contact_support/tickets/${selectedTicketId}/status`] = 'RESPONSE SENT';
            
            // Add system log
            const sysId = 'SYS-' + (Date.now() + 1);
            updates[`contact_support/chats/${selectedTicketId}/messages/${sysId}`] = {
                id: sysId,
                senderId: 'system',
                senderName: 'System',
                message: 'Ticket status updated to RESPONSE SENT',
                timestamp: Date.now() + 1,
                isSystem: true
            };
        }

        await rtdb.ref().update(updates);
        input.value = '';
        input.focus();

        // Dispatch OneSignal push alert
        notifyAppOfTicketUpdate(ticket, `Response to Case ${ticket.id}`, text);

    } catch (err) {
        showToast("Failed to send: " + err.message, "error");
    }
}

/**
 * Update Status of the support ticket
 */
async function updateActiveTicketStatus() {
    if (!selectedTicketId) return;

    const newStatus = document.getElementById('activeTicketStatus').value;
    const ticket = chatTickets.find(t => t.id === selectedTicketId);
    if (!ticket || ticket.status === newStatus) return;

    try {
        const updates = {
            status: newStatus
        };
        if (newStatus === 'RESOLVED') {
            updates.resolvedAt = Date.now();
        }

        // Apply status update
        await rtdb.ref(`contact_support/tickets/${selectedTicketId}`).update(updates);

        // Append system log
        const sysId = 'SYS-' + Date.now();
        await rtdb.ref(`contact_support/chats/${selectedTicketId}/messages/${sysId}`).set({
            id: sysId,
            senderId: 'system',
            senderName: 'System',
            message: `Ticket status changed to ${newStatus} by admin`,
            timestamp: Date.now(),
            isSystem: true
        });

        showToast(`Ticket status updated to ${newStatus} successfully.`);
        notifyAppOfTicketUpdate(ticket, `Ticket ${ticket.id} Updated`, `Status changed to: ${newStatus}`);
    } catch (err) {
        showToast("Failed to update status: " + err.message, "error");
    }
}

/**
 * Close/Resolve active chat session
 */
async function resolveActiveChat() {
    if (!selectedTicketId) return;

    const confirmClose = await showCustomConfirm(
        "Close Ticket?",
        "Are you sure you want to resolve and close this support chat session? This will lock inputs for both parties.",
        "warning"
    );
    if (!confirmClose) return;

    try {
        const ticket = chatTickets.find(t => t.id === selectedTicketId);
        
        await rtdb.ref(`contact_support/tickets/${selectedTicketId}`).update({
            status: 'RESOLVED',
            resolvedAt: Date.now()
        });

        // Add system message
        const sysId = 'SYS-' + Date.now();
        await rtdb.ref(`contact_support/chats/${selectedTicketId}/messages/${sysId}`).set({
            id: sysId,
            senderId: 'system',
            senderName: 'System',
            message: 'Support ticket resolved and chat session closed by Administrator.',
            timestamp: Date.now(),
            isSystem: true
        });

        showToast("Ticket resolved and locked. 🛠️");
        notifyAppOfTicketUpdate(ticket, "Ticket Resolved", `Your support ticket ${ticket.id} has been marked as RESOLVED.`);
    } catch (err) {
        showToast("Failed to close chat: " + err.message, "error");
    }
}

/**
 * Dispatch Push notification to OneSignal target user
 */
async function sendOneSignalPushNotification(userId, title, message, ticketId = null) {
    try {
        const snapshot = await rtdb.ref('contact_support/config/onesignal').once('value');
        const keys = snapshot.val();
        if (!keys || !keys.appId || !keys.apiKey) {
            console.warn("OneSignal keys not configured in Firebase RTDB configuration.");
            return;
        }

        await fetch('https://onesignal.com/api/v1/notifications', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Basic ${keys.apiKey}`
            },
            body: JSON.stringify({
                app_id: keys.appId,
                headings: { en: title },
                contents: { en: message },
                include_external_user_ids: [userId],
                data: {
                    route: 'chat_support',
                    ticketId: ticketId,
                },
                ios_badgeType: 'Increase',
                ios_badgeCount: 1
            })
        });
        console.log("OneSignal push alert sent to UID:", userId);
    } catch (e) {
        console.error("Failed to send OneSignal push alert:", e);
    }
}

/**
 * Update info sidebar
 */
function updateSidebarInfo(ticket) {
    document.getElementById('sideClinicName').textContent = ticket.clinicName || 'Clinic';
    document.getElementById('sideDeviceDesc').textContent = ticket.deviceName || 'SmartThermo Pro';
    document.getElementById('sideDeviceSn').textContent = ticket.serialNo || 'SN-N/A';
    document.getElementById('sidePriority').textContent = ticket.priority || 'Medium';
    document.getElementById('sideErrorCode').textContent = ticket.errorCode || 'None';
    
    // Priority badge styling
    const sidePrio = document.getElementById('sidePriority');
    sidePrio.className = 'px-2 py-0.5 rounded text-[10px] font-bold';
    if (ticket.priority === 'Critical') sidePrio.classList.add('bg-danger/15', 'text-danger');
    else if (ticket.priority === 'High') sidePrio.classList.add('bg-warning/15', 'text-warning');
    else if (ticket.priority === 'Medium') sidePrio.classList.add('bg-primary/15', 'text-primary');
    else sidePrio.classList.add('bg-white/5', 'text-textsecondary');

    // Date
    const dateStr = ticket.timestamp ? new Date(ticket.timestamp).toLocaleString('en-US', {
        month: 'short', day: 'numeric', year: 'numeric',
        hour: '2-digit', minute: '2-digit'
    }) : 'Unknown';
    document.getElementById('sideSubmittedTime').textContent = dateStr;

    // Description
    document.getElementById('sideDescription').textContent = ticket.description || 'No description provided.';

    // Render attachments preview
    const container = document.getElementById('sideAttachmentsContainer');
    container.innerHTML = '';
    if (ticket.attachments && Array.isArray(ticket.attachments) && ticket.attachments.length > 0) {
        ticket.attachments.forEach((url, i) => {
            let isImage = false;
            let isVideo = false;
            let isPdf = false;
            
            if (url.startsWith('data:image/')) {
                isImage = true;
            } else if (url.startsWith('data:video/')) {
                isVideo = true;
            } else {
                const path = url.split('?')[0].split('#')[0].toLowerCase();
                if (path.match(/\.(jpeg|jpg|gif|png|webp|svg)$/i)) {
                    isImage = true;
                } else if (path.match(/\.(mp4|mov|avi|mkv|webm|3gp)$/i)) {
                    isVideo = true;
                } else if (path.match(/\.pdf$/i)) {
                    isPdf = true;
                }
            }

            const card = document.createElement('a');
            card.href = url;
            card.target = '_blank';
            card.className = 'w-16 h-16 rounded-xl overflow-hidden border border-bordercolor flex items-center justify-center bg-white/5 hover:border-primary transition relative group';
            
            if (isImage) {
                card.innerHTML = `<img src="${url}" class="w-full h-full object-cover"><div class="absolute inset-0 bg-black/40 flex items-center justify-center opacity-0 group-hover:opacity-100 transition"><i class="fa-solid fa-eye text-white text-xs"></i></div>`;
            } else if (isVideo) {
                card.innerHTML = `<video src="${url}" class="w-full h-full object-cover" muted></video><div class="absolute inset-0 bg-black/50 flex flex-col items-center justify-center transition group-hover:bg-black/30 text-white"><i class="fa-solid fa-play text-xs mb-0.5"></i></div>`;
            } else {
                const icon = isPdf ? 'fa-file-pdf text-danger' : 'fa-file-arrow-down text-textsecondary';
                card.innerHTML = `<i class="fa-solid ${icon} text-lg"></i>`;
            }
            container.appendChild(card);
        });
    } else {
        container.innerHTML = '<span class="text-xs text-textmuted">No attachments submitted.</span>';
    }
}

function escapeHtml(text) {
    if (!text) return '';
    return text
        .toString()
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}
