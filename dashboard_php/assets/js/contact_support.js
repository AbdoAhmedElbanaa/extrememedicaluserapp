/**
 * Contact Support & Ticketing Settings Controller
 * Extreme Medical Web Administration
 */

let allTickets = [];
let selectedTicketId = '';
let configuredSubjects = [];

document.addEventListener('DOMContentLoaded', () => {
    // 1. Sync Contact Support configurations
    syncSupportConfig();

    // 2. Sync incoming support tickets
    syncSupportTickets();

    // Add keypress listener to subjects input field
    const subjectInput = document.getElementById('newSubjectInput');
    if (subjectInput) {
        subjectInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') {
                e.preventDefault();
                addNewSubject();
            }
        });
    }
});

/**
 * Sync support availability settings config from Firebase RTDB
 */
function syncSupportConfig() {
    rtdb.ref('contact_support/config').on('value', (snapshot) => {
        const config = snapshot.val();
        if (config) {
            document.getElementById('configStatus').value = config.status || 'online';
            document.getElementById('configResponseTimeText').value = config.responseTimeText || 'We typically reply in 2–4 hours';
            document.getElementById('configResponseTime').value = config.responseTime || '2-4 business hours';
            // Sync subjects
            configuredSubjects = config.subjects || [
                'Device Not Working',
                'Calibration Needed',
                'Data Sync Error',
                'Billing & Payments',
                'Software/Update Issue',
                'Other Query'
            ];
        } else {
            configuredSubjects = [
                'Device Not Working',
                'Calibration Needed',
                'Data Sync Error',
                'Billing & Payments',
                'Software/Update Issue',
                'Other Query'
            ];
        }
        renderSubjectsTags();
    }, (error) => {
        console.error("Failed to read support config:", error);
    });
}

/**
 * Render configured subjects as tags in the container
 */
function renderSubjectsTags() {
    const container = document.getElementById('subjectsListContainer');
    if (!container) return;
    
    container.innerHTML = '';
    configuredSubjects.forEach((subject, index) => {
        const tag = document.createElement('div');
        tag.className = 'flex items-center gap-2 bg-white/5 border border-bordercolor/80 text-white text-xs px-3 py-1.5 rounded-xl';
        tag.innerHTML = `
            <span>${escapeHtml(subject)}</span>
            <button type="button" onclick="removeSubject(${index})" class="text-textsecondary hover:text-danger font-bold text-sm leading-none focus:outline-none transition">&times;</button>
        `;
        container.appendChild(tag);
    });
}

/**
 * Add a new subject to the local list and re-render tags
 */
function addNewSubject() {
    const input = document.getElementById('newSubjectInput');
    if (!input) return;
    const value = input.value.trim();
    if (!value) return;
    
    if (configuredSubjects.includes(value)) {
        showToast("Subject already exists!", "error");
        return;
    }
    
    configuredSubjects.push(value);
    input.value = '';
    renderSubjectsTags();
}

/**
 * Remove a subject from the list and re-render tags
 */
function removeSubject(index) {
    if (index >= 0 && index < configuredSubjects.length) {
        configuredSubjects.splice(index, 1);
        renderSubjectsTags();
    }
}

/**
 * Save configuration changes to Firebase RTDB
 */
async function saveConfig() {
    const status = document.getElementById('configStatus').value;
    const responseTimeText = document.getElementById('configResponseTimeText').value.trim();
    const responseTime = document.getElementById('configResponseTime').value.trim();

    try {
        await rtdb.ref('contact_support/config').update({
            status,
            responseTimeText,
            responseTime,
            subjects: configuredSubjects
        });
        showToast("Support configuration updated successfully! 🛠️");
    } catch (err) {
        showToast("Failed to update config: " + err.message, "error");
    }
}

/**
 * Establish live listener for incoming tickets
 */
function syncSupportTickets() {
    rtdb.ref('contact_support/tickets').on('value', (snapshot) => {
        const data = snapshot.val();
        allTickets = [];
        if (data) {
            Object.keys(data).forEach(key => {
                allTickets.push({ id: key, ...data[key] });
            });
        }

        // Sort by timestamp descending (newest first)
        allTickets.sort((a, b) => (b.timestamp || 0) - (a.timestamp || 0));

        updateStats();
        renderTicketsTable();

        if (selectedTicketId) {
            openInspectTicketModal(selectedTicketId);
        }
    }, (error) => {
        console.error("Failed to fetch tickets:", error);
        document.getElementById('ticketsTableBody').innerHTML = `
            <tr>
                <td colspan="6" class="p-12 text-center text-danger">
                    Error loading tickets: ${error.message}
                </td>
            </tr>
        `;
    });
}

/**
 * Recalculate stats cards
 */
function updateStats() {
    const total = allTickets.length;
    const resolved = allTickets.filter(t => t.status === 'RESOLVED').length;
    const active = total - resolved;

    document.getElementById('totalTicketsCount').textContent = total;
    document.getElementById('resolvedTicketsCount').textContent = resolved;
    document.getElementById('activeTicketsCount').textContent = active;
}

/**
 * Render tickets list inside the table
 */
function renderTicketsTable() {
    const body = document.getElementById('ticketsTableBody');
    if (!body) return;

    if (allTickets.length === 0) {
        body.innerHTML = `
            <tr>
                <td colspan="6" class="p-12 text-center text-textmuted">
                    <i class="fa-solid fa-folder-open text-3xl mb-3 block"></i> No support tickets submitted yet.
                </td>
            </tr>
        `;
        return;
    }

    body.innerHTML = '';
    allTickets.forEach(ticket => {
        const tr = document.createElement('tr');
        tr.className = 'hover:bg-white/[0.01] transition duration-200';

        // Format Date
        const dateStr = ticket.timestamp ? new Date(ticket.timestamp).toLocaleString('en-US', {
            month: 'short',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        }) : 'Unknown';

        // Priority styling
        let prioBadge = 'bg-white/5 text-textsecondary';
        if (ticket.priority === 'Critical') prioBadge = 'bg-danger/15 text-danger border border-danger/30';
        else if (ticket.priority === 'High') prioBadge = 'bg-warning/15 text-warning border border-warning/30';
        else if (ticket.priority === 'Medium') prioBadge = 'bg-primary/15 text-primary border border-primary/30';
        
        // Status badge
        let statusBadgeClass = 'bg-warning/15 text-warning border border-warning/30';
        let statusIcon = 'fa-circle-notch fa-spin';
        
        if (ticket.status === 'RESOLVED' || ticket.status === 'CLOSED') {
            statusBadgeClass = 'bg-success/15 text-success border border-success/30';
            statusIcon = 'fa-check';
        } else if (ticket.status === 'RESPONSE SENT') {
            statusBadgeClass = 'bg-primary/15 text-primary border border-primary/30';
            statusIcon = 'fa-paper-plane';
        } else if (ticket.status === 'AWAITING REPLY') {
            statusBadgeClass = 'bg-secondary/15 text-secondary border border-secondary/30';
            statusIcon = 'fa-hourglass-half';
        }

        tr.innerHTML = `
            <td class="p-5 font-bold text-white text-xs">${ticket.id}</td>
            <td class="p-5">
                <div class="flex flex-col">
                    <span class="text-xs font-bold text-white">${escapeHtml(ticket.clinicName || 'Clinic')}</span>
                    <span class="text-[10px] text-textsecondary">${escapeHtml(ticket.serialNo || 'No Device')}</span>
                </div>
            </td>
            <td class="p-5">
                <div class="flex flex-col">
                    <span class="text-xs font-bold text-white">${escapeHtml(ticket.subject)}</span>
                    <span class="text-[10px] text-textsecondary truncate max-w-[200px]">${escapeHtml(ticket.description)}</span>
                </div>
            </td>
            <td class="p-5">
                <span class="text-[10px] font-bold px-2 py-0.5 rounded ${prioBadge}">${ticket.priority}</span>
            </td>
            <td class="p-5">
                <span class="px-2.5 py-1 rounded-lg text-[10px] font-bold inline-flex items-center gap-1.5 ${statusBadgeClass}">
                    <i class="fa-solid ${statusIcon}"></i> ${ticket.status}
                </span>
            </td>
            <td class="p-5 text-right">
                <button onclick="openInspectTicketModal('${ticket.id}')" class="bg-primary/10 text-primary hover:bg-primary hover:text-white px-3 py-1.5 rounded-lg text-xs font-bold transition cursor-pointer">
                    Inspect
                </button>
            </td>
        `;
        body.appendChild(tr);
    });
}

/**
 * Open Modal to review and resolve ticket
 */
function openInspectTicketModal(id) {
    const ticket = allTickets.find(t => t.id === id);
    if (!ticket) return;

    selectedTicketId = id;
    
    document.getElementById('modalTicketId').textContent = ticket.id;
    document.getElementById('modalClinicName').textContent = ticket.clinicName || 'N/A';
    document.getElementById('modalDeviceSn').textContent = (ticket.deviceName || 'N/A') + ' (' + (ticket.serialNo || 'N/A') + ')';
    document.getElementById('modalSubject').textContent = ticket.subject;
    document.getElementById('modalErrorCode').textContent = ticket.errorCode || 'None';
    document.getElementById('modalDescription').textContent = ticket.description;

    // Attachments Rendering
    const attachmentsContainer = document.getElementById('modalAttachmentsContainer');
    attachmentsContainer.innerHTML = '';
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
            card.className = 'w-20 h-20 rounded-xl overflow-hidden border border-bordercolor flex items-center justify-center bg-white/5 hover:border-primary transition relative group';
            
            if (isImage) {
                card.innerHTML = `<img src="${url}" class="w-full h-full object-cover"><div class="absolute inset-0 bg-black/40 flex items-center justify-center opacity-0 group-hover:opacity-100 transition"><i class="fa-solid fa-eye text-white text-xs"></i></div>`;
            } else if (isVideo) {
                card.innerHTML = `<video src="${url}" class="w-full h-full object-cover" muted></video><div class="absolute inset-0 bg-black/50 flex flex-col items-center justify-center transition group-hover:bg-black/30 text-white"><i class="fa-solid fa-play text-xs mb-0.5"></i><span class="text-[8px] text-white/80">Play</span></div>`;
            } else {
                const icon = isPdf ? 'fa-file-pdf text-danger' : 'fa-file-arrow-down text-textsecondary';
                card.innerHTML = `<i class="fa-solid ${icon} text-xl"></i><span class="absolute bottom-1 text-[8px] text-textmuted truncate max-w-[90%] px-1">File ${i+1}</span>`;
            }
            attachmentsContainer.appendChild(card);
        });
    } else {
        attachmentsContainer.innerHTML = '<span class="text-xs text-textmuted">No attachments submitted.</span>';
    }

    // Input Note Section & Resolution Button Handling
    document.getElementById('modalTicketStatus').value = ticket.status || 'IN REVIEW';
    
    const noteArea = document.getElementById('ticketResponse');
    noteArea.value = ticket.resolutionText || '';
    noteArea.disabled = false;

    openModal('ticketModal');
}

/**
 * Handle Ticket Updates (Status & Resolution text)
 */
async function saveTicketUpdates() {
    if (!selectedTicketId) return;

    const newStatus = document.getElementById('modalTicketStatus').value;
    const resolutionText = document.getElementById('ticketResponse').value.trim();

    if ((newStatus === 'RESOLVED' || newStatus === 'RESPONSE SENT') && !resolutionText) {
        showToast("Please provide a note/response before setting status to " + newStatus + ".", "error");
        return;
    }

    try {
        const updates = {
            status: newStatus,
            resolutionText: resolutionText || null
        };

        // If status changes to RESOLVED, set resolvedAt timestamp
        if (newStatus === 'RESOLVED') {
            updates.resolvedAt = Date.now();
        }

        await rtdb.ref(`contact_support/tickets/${selectedTicketId}`).update(updates);
        showToast("Ticket updated successfully! 🛠️");
        closeModal('ticketModal');
        selectedTicketId = '';
    } catch (err) {
        showToast("Failed to update ticket: " + err.message, "error");
    }
}

/**
 * Modal Overlay helper bindings
 */
function openModal(id) {
    const modal = document.getElementById(id);
    if (!modal) return;
    modal.classList.remove('pointer-events-none');
    modal.classList.add('opacity-100');
    modal.querySelector('.modal-content').classList.remove('scale-90');
    modal.querySelector('.modal-content').classList.add('scale-100');
}

function closeModal(id) {
    const modal = document.getElementById(id);
    if (!modal) return;
    modal.classList.add('pointer-events-none');
    modal.classList.remove('opacity-100');
    modal.querySelector('.modal-content').classList.add('scale-90');
    modal.querySelector('.modal-content').classList.remove('scale-100');
    if (id === 'ticketModal') {
        selectedTicketId = '';
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
