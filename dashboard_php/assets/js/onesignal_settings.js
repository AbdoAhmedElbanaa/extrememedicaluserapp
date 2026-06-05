/**
 * OneSignal & Push Settings Page Controller
 * Extreme Medical Web Administration
 */

let onesignalConfig = {};

document.addEventListener('DOMContentLoaded', () => {
    // Sync settings from Firebase
    syncOneSignalSettings();
});

/**
 * Listen and sync settings dynamically from Firebase RTDB
 */
function syncOneSignalSettings() {
    rtdb.ref('contact_support/config/onesignal').on('value', (snapshot) => {
        const data = snapshot.val();
        onesignalConfig = data || {};
        
        if (data) {
            document.getElementById('onesignalAppId').value = data.appId || '';
            document.getElementById('onesignalApiKey').value = data.apiKey || '';
            document.getElementById('onesignalEnabled').checked = data.enabled !== false; // defaults to true
            document.getElementById('notifyOnNewTicket').checked = data.notifyOnNewTicket === true;
            document.getElementById('notifyOnChatReply').checked = data.notifyOnChatReply === true;
            document.getElementById('notifyOnTicketStatusChange').checked = data.notifyOnTicketStatusChange === true;
            document.getElementById('defaultNotificationSound').value = data.defaultSound || 'default';
            
            // Connection Status UI
            document.getElementById('configStateText').innerHTML = '<span class="text-success font-semibold">Active & Synced</span>';
            document.getElementById('onesignalStateAppId').textContent = data.appId || 'Not Configured';
            document.getElementById('onesignalConnectionBadge').className = 'status-badge success';
            document.getElementById('onesignalConnectionBadge').innerHTML = '<i class="fa-solid fa-circle"></i> Configured';
        } else {
            document.getElementById('configStateText').innerHTML = '<span class="text-warning font-semibold">No Credentials</span>';
            document.getElementById('onesignalStateAppId').textContent = 'Not Configured';
            document.getElementById('onesignalConnectionBadge').className = 'status-badge warning';
            document.getElementById('onesignalConnectionBadge').innerHTML = '<i class="fa-solid fa-circle"></i> Unconfigured';
        }
    }, (error) => {
        console.error("Failed to fetch OneSignal settings:", error);
        showToast("Error reading configuration: " + error.message, "error");
    });
}

/**
 * Save configuration to Firebase Realtime Database
 */
async function saveOneSignalConfig() {
    const appId = document.getElementById('onesignalAppId').value.trim();
    const apiKey = document.getElementById('onesignalApiKey').value.trim();
    const enabled = document.getElementById('onesignalEnabled').checked;
    const notifyOnNewTicket = document.getElementById('notifyOnNewTicket').checked;
    const notifyOnChatReply = document.getElementById('notifyOnChatReply').checked;
    const notifyOnTicketStatusChange = document.getElementById('notifyOnTicketStatusChange').checked;
    const defaultSound = document.getElementById('defaultNotificationSound').value;

    try {
        await rtdb.ref('contact_support/config/onesignal').update({
            appId,
            apiKey,
            enabled,
            notifyOnNewTicket,
            notifyOnChatReply,
            notifyOnTicketStatusChange,
            defaultSound
        });
        showToast("OneSignal push configuration saved successfully! 🚀");
    } catch (err) {
        showToast("Failed to save settings: " + err.message, "error");
    }
}

/**
 * Toggle Target UID field visibility
 */
function toggleTargetUidField() {
    const targetType = document.getElementById('pushTargetType').value;
    const wrapper = document.getElementById('targetUidWrapper');
    if (targetType === 'user') {
        wrapper.classList.remove('hidden');
    } else {
        wrapper.classList.add('hidden');
    }
}

/**
 * Dispatch manual test push via OneSignal REST API
 */
async function sendTestPush() {
    const appId = onesignalConfig.appId;
    const apiKey = onesignalConfig.apiKey;
    const isPushEnabled = onesignalConfig.enabled !== false;

    if (!appId || !apiKey) {
        showToast("Please save OneSignal API credentials first!", "error");
        return;
    }

    if (!isPushEnabled) {
        const confirmSend = await showCustomConfirm(
            "Push Notifications Disabled",
            "Warning: Push notifications are marked as disabled globally in settings. Do you want to send this test message anyway?",
            "warning"
        );
        if (!confirmSend) return;
    }

    const targetType = document.getElementById('pushTargetType').value;
    const targetUid = document.getElementById('pushTargetUid').value.trim();
    const title = document.getElementById('pushTitle').value.trim();
    const body = document.getElementById('pushBody').value.trim();
    const actionRoute = document.getElementById('pushActionRoute').value;
    const customDataStr = document.getElementById('pushCustomData').value.trim();

    if (targetType === 'user' && !targetUid) {
        showToast("Please specify the target Firebase User UID!", "error");
        return;
    }

    let parsedCustomData = {};
    if (customDataStr) {
        try {
            parsedCustomData = JSON.parse(customDataStr);
        } catch (e) {
            showToast("Invalid JSON syntax in custom payload data field!", "error");
            return;
        }
    }

    // Embed actionRoute in custom data for the Flutter app deep link handling
    if (actionRoute) {
        parsedCustomData.route = actionRoute;
    }

    // Disable button and show loader
    const sendBtn = document.getElementById('sendPushBtn');
    const originalText = sendBtn.innerHTML;
    sendBtn.disabled = true;
    sendBtn.innerHTML = '<i class="fa-solid fa-spinner fa-spin mr-1"></i> Dispatching...';

    try {
        const headers = {
            'Content-Type': 'application/json; charset=utf-8',
            'Authorization': `Basic ${apiKey}`
        };

        const payload = {
            app_id: appId,
            headings: { en: title },
            contents: { en: body },
            data: parsedCustomData
        };

        if (targetType === 'user') {
            payload.include_aliases = {
                external_id: [targetUid]
            };
            payload.target_channel = "push";
        } else {
            payload.included_segments = ["Subscribed Users"];
        }

        // Apply sound profile
        if (onesignalConfig.defaultSound && onesignalConfig.defaultSound !== 'default') {
            // Can configure specific sound file names here if uploaded to assets
            if (onesignalConfig.defaultSound === 'silent') {
                payload.ios_sound = 'nil';
                payload.android_sound = 'nil';
            }
        }

        const response = await fetch('https://onesignal.com/api/v1/notifications', {
            method: 'POST',
            headers: headers,
            body: JSON.stringify(payload)
        });

        const resData = await response.json();
        
        if (response.ok) {
            if (resData.errors) {
                let errMessage = Array.isArray(resData.errors) ? resData.errors.join(", ") : JSON.stringify(resData.errors);
                showToast("OneSignal returned warnings: " + errMessage, "warning");
            } else {
                showToast(`Test push alert dispatched! Recipients: ${resData.recipients || 0}`);
            }
        } else {
            showToast(`API Error: ${resData.errors ? resData.errors[0] : response.statusText}`, "error");
        }
    } catch (err) {
        console.error("Test push error:", err);
        showToast("Network request to OneSignal failed: " + err.message, "error");
    } finally {
        sendBtn.disabled = false;
        sendBtn.innerHTML = originalText;
    }
}
