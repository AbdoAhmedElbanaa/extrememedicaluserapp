/**
 * System Notifications Center Logic
 * Extreme Medical Web Administration
 */

let allNotifications = [];

// Register global sync hook so firebase-config.js updates our local screen
window.onNotificationsSync = function(notifications) {
    allNotifications = notifications;
    // Sort chronologically (newest first)
    allNotifications.sort((a, b) => b.timestamp - a.timestamp);
    renderNotificationsTable();
};

/**
 * Render system notifications inside table
 */
function renderNotificationsTable() {
    const body = document.getElementById('notificationsTableBody');
    if (!body) return;

    if (allNotifications.length === 0) {
        body.innerHTML = `
            <tr>
                <td colspan="6" class="p-12 text-center text-textmuted">
                    <i class="fa-solid fa-bell-slash text-3xl mb-3 block"></i> No system notifications received yet.
                </td>
            </tr>
        `;
        return;
    }

    body.innerHTML = '';
    allNotifications.forEach(notif => {
        const tr = document.createElement('tr');
        tr.className = `hover:bg-white/[0.01] transition duration-200 ${notif.isRead ? 'opacity-60' : ''}`;

        // Date Format
        const dateStr = notif.timestamp ? new Date(notif.timestamp).toLocaleString('en-US', {
            month: 'short',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        }) : 'Unknown';

        // Unread status indicator dot
        const statusDot = notif.isRead 
            ? '<div class="w-2 h-2 rounded-full bg-white/10 mx-auto"></div>'
            : '<div class="w-2 h-2 rounded-full bg-success mx-auto shadow-success/40 animate-pulse"></div>';

        // Badges depending on types
        let typeBadge = 'bg-white/5 text-textsecondary border border-bordercolor';
        let typeLabel = 'Alert';
        if (notif.type === 'new_chat') {
            typeBadge = 'bg-primary/10 text-primary border border-primary/20';
            typeLabel = 'Chat Support';
        } else if (notif.type === 'new_ticket') {
            typeBadge = 'bg-secondary/10 text-secondary border border-secondary/20';
            typeLabel = 'New Ticket';
        }

        // Action links
        const targetPage = notif.type === 'new_chat' ? 'chat_console.php' : 'contact_support.php';
        const actionUrl = `${targetPage}?ticketId=${notif.ticketId}`;

        tr.innerHTML = `
            <td class="p-4 text-center">${statusDot}</td>
            <td class="p-4">
                <span class="text-[10px] font-bold px-2 py-0.5 rounded-lg ${typeBadge}">${typeLabel}</span>
            </td>
            <td class="p-4">
                <div class="flex flex-col gap-0.5">
                    <span class="text-xs font-bold text-white">${escapeHtml(notif.title)}</span>
                    <span class="text-[10px] text-textsecondary leading-relaxed">${escapeHtml(notif.body)}</span>
                </div>
            </td>
            <td class="p-4 text-xs text-white font-medium">${escapeHtml(notif.clinicName || 'Clinic')}</td>
            <td class="p-4 text-[10px] text-textsecondary font-bold">${dateStr}</td>
            <td class="p-4 text-right">
                <button onclick="handleNotificationClick('${notif.id}', '${actionUrl}')" class="bg-primary/10 text-primary hover:bg-primary hover:text-white px-3.5 py-1.5 rounded-xl text-xs font-bold transition cursor-pointer">
                    View Action
                </button>
            </td>
        `;
        body.appendChild(tr);
    });
}

/**
 * Handle notification card tap: marks as read in RTDB first then redirects
 */
async function handleNotificationClick(notifId, url) {
    try {
        await rtdb.ref(`contact_support/notifications/${notifId}`).update({
            isRead: true
        });
        window.location.href = url;
    } catch (err) {
        console.error("Failed to mark read:", err);
        window.location.href = url; // Fallback redirect anyway
    }
}

/**
 * Mark all notifications as read in Firebase database
 */
async function markAllNotificationsAsRead() {
    const unread = allNotifications.filter(n => !n.isRead);
    if (unread.length === 0) {
        showToast("All notifications are already read!");
        return;
    }

    try {
        const updates = {};
        unread.forEach(n => {
            updates[`contact_support/notifications/${n.id}/isRead`] = true;
        });

        await rtdb.ref().update(updates);
        showToast("All notifications marked as read. 📩");
    } catch (err) {
        showToast("Bulk update failed: " + err.message, "error");
    }
}

/**
 * Prune all notifications logs
 */
async function clearNotificationLogs() {
    if (allNotifications.length === 0) {
        showToast("Logs are already empty!");
        return;
    }

    const confirmClear = await showCustomConfirm(
        "Clear Notification History?",
        "Are you sure you want to permanently delete all notification history logs from the database? This cannot be undone.",
        "danger"
    );
    if (!confirmClear) return;

    try {
        await rtdb.ref('contact_support/notifications').set(null);
        showToast("Notification log history cleared successfully.");
    } catch (err) {
        showToast("Clear logs failed: " + err.message, "error");
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
