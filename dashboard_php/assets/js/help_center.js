/**
 * Help & Knowledge Center Controller
 * Extreme Medical Web Administration
 */

let allFaqs = [];
let allErrors = [];
let allDiagnoseOptions = [];

document.addEventListener('DOMContentLoaded', () => {
    // 1. Initialize Tabs
    setupTabSwitching();

    // 2. Establish database connection listeners
    initializeHelpCenterDataSync();
});

/**
 * Setup sub-tabs navigation
 */
function setupTabSwitching() {
    const tabs = document.querySelectorAll('#helpCenterTabs button');
    const panels = document.querySelectorAll('.tab-panel');

    tabs.forEach(tab => {
        tab.addEventListener('click', () => {
            // Remove active classes
            tabs.forEach(t => {
                t.classList.remove('text-primary', 'border-primary');
                t.classList.add('text-textsecondary', 'border-transparent');
            });
            panels.forEach(p => p.classList.add('hidden'));

            // Add active classes to selected
            tab.classList.remove('text-textsecondary', 'border-transparent');
            tab.classList.add('text-primary', 'border-primary');
            
            const activePanel = document.getElementById(`${tab.dataset.tab}TabPanel`);
            if (activePanel) {
                activePanel.classList.remove('hidden');
            }
        });
    });
}

/**
 * Synchronize help center data from Firebase RTDB
 */
function initializeHelpCenterDataSync() {
    // 1. FAQs Listener
    rtdb.ref('knowledge_center/faqs').on('value', (snapshot) => {
        const data = snapshot.val();
        allFaqs = [];
        if (data) {
            Object.keys(data).forEach(key => {
                allFaqs.push({ id: key, ...data[key] });
            });
        }
        renderFaqs(allFaqs);
    }, (error) => {
        console.error("Error fetching FAQs:", error);
        document.getElementById('faqsListContainer').innerHTML = `<div class="text-center text-danger py-6">Error: ${error.message}</div>`;
    });

    // 2. Error Codes Listener
    rtdb.ref('knowledge_center/errors').on('value', (snapshot) => {
        const data = snapshot.val();
        allErrors = [];
        if (data) {
            Object.keys(data).forEach(key => {
                allErrors.push({ id: key, ...data[key] });
            });
        }
        // Sort by code
        allErrors.sort((a, b) => (a.code || '').localeCompare(b.code || ''));
        renderErrors(allErrors);
    }, (error) => {
        console.error("Error fetching errors:", error);
        document.getElementById('errorsTableBody').innerHTML = `<tr><td colspan="5" class="text-center text-danger py-6">Error: ${error.message}</td></tr>`;
    });

    // 3. Diagnose Options Listener
    rtdb.ref('knowledge_center/diagnose').on('value', (snapshot) => {
        const data = snapshot.val();
        allDiagnoseOptions = [];
        if (data) {
            Object.keys(data).forEach(key => {
                allDiagnoseOptions.push({ id: key, ...data[key] });
            });
        }
        renderDiagnoseOptions(allDiagnoseOptions);
    }, (error) => {
        console.error("Error fetching diagnose options:", error);
        document.getElementById('diagnoseGridContainer').innerHTML = `<div class="text-center text-danger py-6">Error: ${error.message}</div>`;
    });
}

/**
 * Render FAQs list
 */
function renderFaqs(list) {
    const container = document.getElementById('faqsListContainer');
    if (!container) return;

    if (list.length === 0) {
        container.innerHTML = `
            <div class="text-center text-textmuted py-12">
                <i class="fa-solid fa-circle-question text-3xl mb-3 block"></i>
                No FAQs added yet. Click Add FAQ to create one.
            </div>
        `;
        return;
    }

    container.innerHTML = '';
    list.forEach(faq => {
        const card = document.createElement('div');
        card.className = 'bg-darksec border border-bordercolor rounded-2xl p-5 flex flex-col md:flex-row justify-between items-start md:items-center gap-4 hover:border-primary/20 transition';
        card.innerHTML = `
            <div class="flex-1">
                <h4 class="text-sm font-bold text-white mb-2"><i class="fa-solid fa-circle-question text-primary mr-2"></i>${escapeHtml(faq.question)}</h4>
                <p class="text-xs text-textsecondary leading-relaxed">${escapeHtml(faq.answer)}</p>
            </div>
            <div class="flex gap-2 self-end md:self-center">
                <button onclick="openEditFaqModal('${faq.id}')" class="bg-primary/10 text-primary hover:bg-primary hover:text-white px-3 py-1.5 rounded-lg text-xs font-bold transition cursor-pointer">Edit</button>
                <button onclick="deleteFaq('${faq.id}', '${escapeHtml(faq.question)}')" class="bg-danger/10 text-danger hover:bg-danger hover:text-white px-3 py-1.5 rounded-lg text-xs font-bold transition cursor-pointer">Delete</button>
            </div>
        `;
        container.appendChild(card);
    });
}

/**
 * Render Errors table
 */
function renderErrors(list) {
    const body = document.getElementById('errorsTableBody');
    if (!body) return;

    if (list.length === 0) {
        body.innerHTML = `
            <tr>
                <td colspan="5" class="py-12 text-center text-textmuted">
                    <i class="fa-solid fa-triangle-exclamation text-3xl mb-3 block"></i>
                    No error codes configured yet.
                </td>
            </tr>
        `;
        return;
    }

    body.innerHTML = '';
    list.forEach(err => {
        let sevClass = 'bg-success/15 text-success';
        if (err.severity === 'critical') sevClass = 'bg-danger/15 text-danger';
        else if (err.severity === 'medium') sevClass = 'bg-warning/15 text-warning';

        const row = document.createElement('tr');
        row.className = 'border-b border-bordercolor/50 hover:bg-white/[0.01] transition';
        row.innerHTML = `
            <td class="py-4 px-6 font-bold text-white">${escapeHtml(err.code)}</td>
            <td class="py-4 px-6 font-semibold text-white max-w-[200px] truncate" title="${escapeHtml(err.title)}">${escapeHtml(err.title)}</td>
            <td class="py-4 px-6">
                <span class="status-badge ${err.severity === 'critical' ? 'danger' : (err.severity === 'medium' ? 'warning' : 'success')}">
                    ${escapeHtml((err.severity || 'medium').toUpperCase())}
                </span>
            </td>
            <td class="py-4 px-6 text-textsecondary">
                <div class="flex gap-2">
                    <span class="bg-white/5 px-2 py-0.5 rounded text-[10px]">${(err.causes || []).length} Causes</span>
                    <span class="bg-white/5 px-2 py-0.5 rounded text-[10px]">${(err.steps || []).length} Steps</span>
                    ${err.tutorialTitle ? '<span class="bg-primary/10 text-primary px-2 py-0.5 rounded text-[10px]"><i class="fa-solid fa-circle-play mr-1"></i>Video</span>' : ''}
                </div>
            </td>
            <td class="py-4 px-6 text-right">
                <div class="flex gap-2 justify-end">
                    <button onclick="openEditErrorModal('${err.id}')" class="bg-primary/10 text-primary hover:bg-primary hover:text-white px-3 py-1.5 rounded-lg text-xs font-bold transition cursor-pointer">Edit</button>
                    <button onclick="deleteError('${err.id}', '${escapeHtml(err.code)}')" class="bg-danger/10 text-danger hover:bg-danger hover:text-white px-3 py-1.5 rounded-lg text-xs font-bold transition cursor-pointer">Delete</button>
                </div>
            </td>
        `;
        body.appendChild(row);
    });
}

/**
 * Render Diagnose Options grid
 */
function renderDiagnoseOptions(list) {
    const container = document.getElementById('diagnoseGridContainer');
    if (!container) return;

    if (list.length === 0) {
        container.innerHTML = `
            <div class="col-span-full text-center text-textmuted py-12">
                <i class="fa-solid fa-toolbox text-3xl mb-3 block"></i>
                No diagnostic categories added yet.
            </div>
        `;
        return;
    }

    container.innerHTML = '';
    list.forEach(opt => {
        const card = document.createElement('div');
        card.className = 'bg-darksec border border-bordercolor rounded-[20px] p-5 flex flex-col gap-4 hover:border-primary/20 transition';
        
        let iconHtml = '<i class="fa-solid fa-triangle-exclamation"></i>';
        if (opt.iconName === 'bolt') iconHtml = '<i class="fa-solid fa-bolt"></i>';
        else if (opt.iconName === 'wifi') iconHtml = '<i class="fa-solid fa-wifi"></i>';
        else if (opt.iconName === 'thermostat') iconHtml = '<i class="fa-solid fa-temperature-half"></i>';
        else if (opt.iconName === 'battery') iconHtml = '<i class="fa-solid fa-battery-three-quarters"></i>';
        else if (opt.iconName === 'sync') iconHtml = '<i class="fa-solid fa-rotate"></i>';

        card.innerHTML = `
            <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-xl flex items-center justify-center text-lg" style="background-color: ${opt.colorHex}25; color: ${opt.colorHex}">
                    ${iconHtml}
                </div>
                <div>
                    <h4 class="text-xs font-bold text-white leading-tight">${escapeHtml(opt.title)}</h4>
                    <span class="text-[9px] font-bold text-textsecondary px-1.5 py-0.5 rounded bg-white/5 border border-bordercolor/50 mt-1 inline-block" style="color: ${opt.colorHex}">${escapeHtml(opt.colorHex)}</span>
                </div>
            </div>
            <p class="text-xs text-textsecondary leading-relaxed flex-1">${escapeHtml(opt.description)}</p>
            <div class="text-[10px] font-bold text-textmuted">${(opt.steps || []).length} Troubleshooting Steps</div>
            
            <div class="pt-3 border-t border-bordercolor flex justify-end gap-2">
                <button onclick="openEditDiagnoseModal('${opt.id}')" class="bg-primary/10 text-primary hover:bg-primary hover:text-white px-3 py-1.5 rounded-lg text-xs font-bold transition cursor-pointer">Edit</button>
                <button onclick="deleteDiagnose('${opt.id}', '${escapeHtml(opt.title)}')" class="bg-danger/10 text-danger hover:bg-danger hover:text-white px-3 py-1.5 rounded-lg text-xs font-bold transition cursor-pointer">Delete</button>
            </div>
        `;
        container.appendChild(card);
    });
}

// ==========================================
// FAQ ADMIN OPERATIONS
// ==========================================
function openAddFaqModal() {
    document.getElementById('faqId').value = "";
    document.getElementById('faqModalTitle').textContent = "Add FAQ";
    document.getElementById('faqQuestion').value = "";
    document.getElementById('faqAnswer').value = "";
    openModal('faqModal');
}

function openEditFaqModal(id) {
    const faq = allFaqs.find(f => f.id === id);
    if (!faq) return;

    document.getElementById('faqId').value = id;
    document.getElementById('faqModalTitle').textContent = "Edit FAQ";
    document.getElementById('faqQuestion').value = faq.question;
    document.getElementById('faqAnswer').value = faq.answer;
    openModal('faqModal');
}

async function saveFaq() {
    const id = document.getElementById('faqId').value;
    const question = document.getElementById('faqQuestion').value.trim();
    const answer = document.getElementById('faqAnswer').value.trim();

    try {
        const ref = id ? rtdb.ref(`knowledge_center/faqs/${id}`) : rtdb.ref('knowledge_center/faqs').push();
        await ref.set({ question, answer });
        showToast("FAQ saved successfully! ✨");
        closeModal('faqModal');
    } catch (err) {
        showToast("Failed to save FAQ: " + err.message, "error");
    }
}

async function deleteFaq(id, title) {
    const confirmed = await showCustomConfirm("Delete FAQ", `Are you sure you want to delete "${title}"?`, 'danger');
    if (!confirmed) return;

    try {
        await rtdb.ref(`knowledge_center/faqs/${id}`).remove();
        showToast("FAQ deleted.");
    } catch (err) {
        showToast("Delete Failed: " + err.message, "error");
    }
}

// ==========================================
// ERROR CODES ADMIN OPERATIONS
// ==========================================
function addErrorCauseRow(value = "") {
    const container = document.getElementById('errorCausesContainer');
    const div = document.createElement('div');
    div.className = 'cause-row flex gap-2 items-center';
    div.innerHTML = `
        <input type="text" class="error-cause-input flex-1 bg-white/5 border border-bordercolor rounded-lg px-3 py-2 text-white text-xs outline-none focus:border-primary transition" placeholder="e.g. Loose or damaged ribbon cable" value="${escapeHtml(value)}" required>
        <button type="button" class="text-textsecondary hover:text-danger p-1 text-sm transition" onclick="this.closest('.cause-row').remove()"><i class="fa-solid fa-trash-can"></i></button>
    `;
    container.appendChild(div);
}

function addErrorStepRow(value = "") {
    const container = document.getElementById('errorStepsContainer');
    const div = document.createElement('div');
    div.className = 'step-row flex gap-2 items-center';
    div.innerHTML = `
        <input type="text" class="error-step-input flex-1 bg-white/5 border border-bordercolor rounded-lg px-3 py-2 text-white text-xs outline-none focus:border-primary transition" placeholder="e.g. Power off the device completely." value="${escapeHtml(value)}" required>
        <button type="button" class="text-textsecondary hover:text-danger p-1 text-sm transition" onclick="this.closest('.step-row').remove()"><i class="fa-solid fa-trash-can"></i></button>
    `;
    container.appendChild(div);
}

function openAddErrorModal() {
    document.getElementById('errorId').value = "";
    document.getElementById('errorModalTitle').textContent = "Add Error Code";
    document.getElementById('errorCode').value = "";
    document.getElementById('errorCode').readOnly = false;
    document.getElementById('errorTitle').value = "";
    document.getElementById('errorSeverity').value = "medium";
    document.getElementById('errorTutorialTitle').value = "";
    document.getElementById('errorTutorialDuration').value = "";
    document.getElementById('errorDesc').value = "";
    
    document.getElementById('errorCausesContainer').innerHTML = "";
    document.getElementById('errorStepsContainer').innerHTML = "";
    addErrorCauseRow();
    addErrorStepRow();

    openModal('errorModal');
}

function openEditErrorModal(id) {
    const err = allErrors.find(e => e.id === id);
    if (!err) return;

    document.getElementById('errorId').value = id;
    document.getElementById('errorModalTitle').textContent = "Edit Error Code";
    document.getElementById('errorCode').value = err.code;
    document.getElementById('errorCode').readOnly = true;
    document.getElementById('errorTitle').value = err.title;
    document.getElementById('errorSeverity').value = err.severity || 'medium';
    document.getElementById('errorTutorialTitle').value = err.tutorialTitle || '';
    document.getElementById('errorTutorialDuration').value = err.tutorialDuration || '';
    document.getElementById('errorDesc').value = err.description;
    
    const causesContainer = document.getElementById('errorCausesContainer');
    const stepsContainer = document.getElementById('errorStepsContainer');
    causesContainer.innerHTML = "";
    stepsContainer.innerHTML = "";

    if (err.causes && err.causes.length > 0) {
        err.causes.forEach(c => addErrorCauseRow(c));
    } else {
        addErrorCauseRow();
    }

    if (err.steps && err.steps.length > 0) {
        err.steps.forEach(s => addErrorStepRow(s));
    } else {
        addErrorStepRow();
    }

    openModal('errorModal');
}

async function saveError() {
    const id = document.getElementById('errorId').value;
    const code = document.getElementById('errorCode').value.trim().toUpperCase();
    const title = document.getElementById('errorTitle').value.trim();
    const severity = document.getElementById('errorSeverity').value;
    const tutorialTitle = document.getElementById('errorTutorialTitle').value.trim();
    const tutorialDuration = document.getElementById('errorTutorialDuration').value.trim();
    const description = document.getElementById('errorDesc').value.trim();

    const causeInputs = document.querySelectorAll('.error-cause-input');
    const causes = [];
    causeInputs.forEach(input => {
        const val = input.value.trim();
        if (val) causes.push(val);
    });

    const stepInputs = document.querySelectorAll('.error-step-input');
    const steps = [];
    stepInputs.forEach(input => {
        const val = input.value.trim();
        if (val) steps.push(val);
    });

    if (causes.length === 0 || steps.length === 0) {
        showToast("Please add at least one cause and one fix step.", "error");
        return;
    }

    try {
        // Use Code as RTDB child key for consistency
        const targetId = id || code;
        const ref = rtdb.ref(`knowledge_center/errors/${targetId}`);
        const payload = {
            code,
            title,
            severity,
            description,
            causes,
            steps
        };
        if (tutorialTitle) payload.tutorialTitle = tutorialTitle;
        if (tutorialDuration) payload.tutorialDuration = tutorialDuration;

        await ref.set(payload);
        showToast("Error Code saved successfully! ✨");
        closeModal('errorModal');
    } catch (err) {
        showToast("Failed to save error code: " + err.message, "error");
    }
}

async function deleteError(id, code) {
    const confirmed = await showCustomConfirm("Delete Error Code", `Are you sure you want to delete "${code}"?`, 'danger');
    if (!confirmed) return;

    try {
        await rtdb.ref(`knowledge_center/errors/${id}`).remove();
        showToast("Error Code deleted.");
    } catch (err) {
        showToast("Delete Failed: " + err.message, "error");
    }
}

// ==========================================
// DIAGNOSE OPTIONS ADMIN OPERATIONS
// ==========================================
function addDiagnoseStepRow(value = "") {
    const container = document.getElementById('diagnoseStepsContainer');
    const div = document.createElement('div');
    div.className = 'diagnose-step-row flex gap-2 items-center';
    div.innerHTML = `
        <input type="text" class="diagnose-step-input flex-1 bg-white/5 border border-bordercolor rounded-lg px-3 py-2 text-white text-xs outline-none focus:border-primary transition" placeholder="e.g. Check Wi-Fi configuration..." value="${escapeHtml(value)}" required>
        <button type="button" class="text-textsecondary hover:text-danger p-1 text-sm transition" onclick="this.closest('.diagnose-step-row').remove()"><i class="fa-solid fa-trash-can"></i></button>
    `;
    container.appendChild(div);
}

function openAddDiagnoseModal() {
    document.getElementById('diagnoseId').value = "";
    document.getElementById('diagnoseModalTitle').textContent = "Add Diagnose Option";
    document.getElementById('diagnoseTitle').value = "";
    document.getElementById('diagnoseIcon').value = "bolt";
    document.getElementById('diagnoseColor').value = "#6366f1";
    document.getElementById('diagnoseDesc').value = "";
    
    document.getElementById('diagnoseStepsContainer').innerHTML = "";
    addDiagnoseStepRow();

    openModal('diagnoseModal');
}

function openEditDiagnoseModal(id) {
    const opt = allDiagnoseOptions.find(o => o.id === id);
    if (!opt) return;

    document.getElementById('diagnoseId').value = id;
    document.getElementById('diagnoseModalTitle').textContent = "Edit Diagnose Option";
    document.getElementById('diagnoseTitle').value = opt.title;
    document.getElementById('diagnoseIcon').value = opt.iconName || 'bolt';
    document.getElementById('diagnoseColor').value = opt.colorHex || '#6366f1';
    document.getElementById('diagnoseDesc').value = opt.description;

    const container = document.getElementById('diagnoseStepsContainer');
    container.innerHTML = "";
    if (opt.steps && opt.steps.length > 0) {
        opt.steps.forEach(s => addDiagnoseStepRow(s));
    } else {
        addDiagnoseStepRow();
    }

    openModal('diagnoseModal');
}

async function saveDiagnose() {
    const id = document.getElementById('diagnoseId').value;
    const title = document.getElementById('diagnoseTitle').value.trim();
    const iconName = document.getElementById('diagnoseIcon').value;
    const colorHex = document.getElementById('diagnoseColor').value.trim();
    const description = document.getElementById('diagnoseDesc').value.trim();

    const stepInputs = document.querySelectorAll('.diagnose-step-input');
    const steps = [];
    stepInputs.forEach(input => {
        const val = input.value.trim();
        if (val) steps.push(val);
    });

    if (steps.length === 0) {
        showToast("Please add at least one troubleshooting step.", "error");
        return;
    }

    try {
        const ref = id ? rtdb.ref(`knowledge_center/diagnose/${id}`) : rtdb.ref('knowledge_center/diagnose').push();
        await ref.set({
            title,
            iconName,
            colorHex,
            description,
            steps
        });
        showToast("Diagnose Option saved successfully! ✨");
        closeModal('diagnoseModal');
    } catch (err) {
        showToast("Failed to save: " + err.message, "error");
    }
}

async function deleteDiagnose(id, title) {
    const confirmed = await showCustomConfirm("Delete Diagnose Option", `Are you sure you want to delete "${title}"?`, 'danger');
    if (!confirmed) return;

    try {
        await rtdb.ref(`knowledge_center/diagnose/${id}`).remove();
        showToast("Diagnose Option deleted.");
    } catch (err) {
        showToast("Delete Failed: " + err.message, "error");
    }
}

// ==========================================
// UTILITY HELPERS
// ==========================================
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
