/**
 * Devices & System Configuration Controller
 * Extreme Medical Web Administration
 */

let allDevices = [];
let editingDeviceId = "";

document.addEventListener('DOMContentLoaded', () => {
    // 1. Establish database connection listeners
    initializeDevicesDataSync();

    // 2. Setup Dialog Actions & Upload triggers
    setupDialogActions();
});

/**
 * Synchronize all catalog devices real-time
 */
function initializeDevicesDataSync() {
    const catalogGrid = document.getElementById('devicesCatalogGrid');

    // Devices Catalog Listener
    rtdb.ref('devices').on('value', (snapshot) => {
        const data = snapshot.val();
        allDevices = [];
        
        if (data) {
            Object.keys(data).forEach(key => {
                const dev = data[key];
                // Versions can be stored as array of objects now
                let versionList = [];
                if (Array.isArray(dev.versions)) {
                    versionList = dev.versions;
                } else if (typeof dev.versions === 'string') {
                    // Fallback for old comma strings
                    versionList = dev.versions.split(',').map(v => ({
                        versionName: v.trim(),
                        swVer: '1.0.0',
                        uiVer: '1.0.0',
                        ntcVer: 'v1',
                        pcbVer: 'Rev.A',
                        ssr: 'Active'
                    })).filter(v => v.versionName);
                }
                
                allDevices.push({
                    id: key,
                    name: dev.name || 'Unnamed Device',
                    description: dev.description || 'No description provided.',
                    imageUrl: dev.imageUrl || '',
                    versions: versionList
                });
            });
        }
        
        renderDevicesCatalog(allDevices);
    }, (error) => {
        console.error("Error fetching devices catalog:", error);
        if (catalogGrid) {
            catalogGrid.innerHTML = `
                <div style="grid-column: 1 / -1; text-align: center; color: var(--danger-color); padding: 50px 0;">
                    <i class="fa-solid fa-triangle-exclamation" style="font-size: 24px; margin-bottom: 8px; display: block;"></i>
                    Failed to sync catalog: ${error.message}
                </div>
            `;
        }
    });
}

/**
 * Render devices catalog grid
 */
function renderDevicesCatalog(list) {
    const grid = document.getElementById('devicesCatalogGrid');
    if (!grid) return;
    grid.innerHTML = '';
    
    if (list.length === 0) {
        grid.innerHTML = `
            <div class="col-span-full text-center text-textmuted py-12">
                <i class="fa-solid fa-folder-open text-3xl mb-3 block"></i>
                Devices catalog is empty. Add a new model to get started.
            </div>
        `;
        return;
    }
    
    list.forEach(device => {
        const card = document.createElement('div');
        card.className = 'bg-darksurface border border-bordercolor rounded-[20px] overflow-hidden flex flex-col shadow-lg hover:translate-y-[-4px] hover:border-primary/30 hover:shadow-primaryglow/10 transition duration-300';
        
        const imgSrc = device.imageUrl ? device.imageUrl : 'https://placehold.co/400x300/1e293b/94a3b8?text=No+Photo';
        
        const versionsHtml = device.versions.map((v, index) => {
            const vName = typeof v === 'object' ? v.versionName : v;
            return `<button class="ver-badge-btn text-[10px] font-bold bg-secondary/10 text-secondary px-2 py-0.5 rounded border border-secondary/20 hover:bg-secondary/20 cursor-pointer transition duration-150" onclick="showCatalogVersionSpecs('${device.id}', ${index}, this)">${escapeHtml(vName)}</button>`;
        }).join(' ');
        
        card.innerHTML = `
            <div class="h-44 w-full bg-[#0f121e] flex items-center justify-center border-b border-bordercolor overflow-hidden">
                <img src="${imgSrc}" alt="${escapeHtml(device.name)}" class="w-full h-full object-cover hover:scale-105 transition duration-300" onerror="this.src='https://placehold.co/400x300/1e293b/94a3b8?text=Image+Error'">
            </div>
            <div class="p-5 flex flex-col gap-3 flex-1">
                <h4 class="text-sm font-bold text-white">${escapeHtml(device.name)}</h4>
                <p class="text-xs text-textsecondary leading-relaxed flex-1">${escapeHtml(device.description)}</p>
                <div class="text-[10px] font-bold text-white mt-2 uppercase tracking-wide">Models / Versions:</div>
                <div class="flex flex-wrap gap-1.5">
                    ${versionsHtml || '<span class="text-xs text-textmuted">None configured</span>'}
                </div>
                
                <!-- Dynamic Specifications Drawer -->
                <div class="mt-4 pt-3.5 border-t border-bordercolor hidden" id="specs-drawer-${device.id}"></div>
                
                <div class="pt-3.5 border-t border-bordercolor flex justify-between mt-1.5 items-center">
                    <button class="bg-primary/10 text-primary hover:bg-primary hover:text-white border-none cursor-pointer text-xs py-1.5 px-3 rounded-lg transition duration-250" title="Edit Device Model" onclick="openEditDeviceModal('${device.id}')">
                        <i class="fa-solid fa-pen-to-square mr-1"></i> Edit Model
                    </button>
                    <button class="bg-danger/10 text-danger hover:bg-danger hover:text-white border-none cursor-pointer text-xs py-1.5 px-3 rounded-lg transition duration-250" title="Delete Device Model" onclick="deleteDeviceModel('${device.id}', '${escapeHtml(device.name)}')">
                        <i class="fa-solid fa-trash-can mr-1"></i> Delete Model
                    </button>
                </div>
            </div>
        `;
        
        grid.appendChild(card);
    });
}

/**
 * Dialog actions & dynamic version rows
 */
function setupDialogActions() {
    const addOverlay = document.getElementById('addDeviceModal');
    const openAddBtn = document.getElementById('openAddDeviceModalBtn');
    const closeAddBtn = document.getElementById('closeAddDeviceModalBtn');
    const cancelAddBtn = document.getElementById('cancelAddDeviceBtn');
    const submitAddBtn = document.getElementById('submitAddDeviceBtn');
    
    // Add Device Model Show
    if (openAddBtn) {
        openAddBtn.addEventListener('click', () => {
            editingDeviceId = "";
            document.getElementById('modalDeviceTitle').textContent = "Add Device Model";
            document.getElementById('modalDeviceSubtitle').textContent = "Create a new device type in the global catalog with versions & specifications";
            document.getElementById('submitDeviceBtnText').textContent = "Save Device Model";
            resetAddDeviceForm();
            openModal('addDeviceModal');
        });
    }
    
    // Close Add modal
    const closeAddHandler = () => closeModal('addDeviceModal');
    if (closeAddBtn) closeAddBtn.addEventListener('click', closeAddHandler);
    if (cancelAddBtn) cancelAddBtn.addEventListener('click', closeAddHandler);
    
    // File input triggers
    const uploadBox = document.getElementById('imageUploadPreviewBox');
    const fileInput = document.getElementById('catalogImageFile');
    
    if (uploadBox && fileInput) {
        uploadBox.addEventListener('click', () => fileInput.click());
        fileInput.addEventListener('change', handleImageUpload);
    }
    
    // Submit handler
    if (submitAddBtn) {
        submitAddBtn.addEventListener('click', submitAddDeviceModel);
    }
}

/**
 * Add Version card row dynamically
 */
function addVersionFormRow(initialData = null) {
    const container = document.getElementById('catalogVersionsContainer');
    if (!container) return;
    
    const row = document.createElement('div');
    row.className = 'version-row bg-white/5 border border-bordercolor rounded-2xl p-4 relative flex flex-col gap-3';
    
    row.innerHTML = `
        <button type="button" class="absolute top-3 right-3 text-textsecondary hover:text-danger transition duration-150 text-sm" onclick="this.closest('.version-row').remove()">
            <i class="fa-solid fa-trash-can"></i>
        </button>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-3 pr-6">
            <div class="flex flex-col gap-1">
                <label class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Version Name</label>
                <input type="text" class="ver-name bg-white/5 border border-bordercolor rounded-lg px-3 py-2 text-white text-xs outline-none focus:border-primary transition duration-200" placeholder="e.g. v1.0 Pro" value="${initialData ? escapeHtml(initialData.versionName) : ''}" required>
            </div>
            <div class="flex flex-col gap-1">
                <label class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">SW Version</label>
                <input type="text" class="ver-sw bg-white/5 border border-bordercolor rounded-lg px-3 py-2 text-white text-xs outline-none focus:border-primary transition duration-200" placeholder="e.g. 1.4.2" value="${initialData ? escapeHtml(initialData.swVer) : ''}" required>
            </div>
        </div>
        <div class="grid grid-cols-2 md:grid-cols-4 gap-3">
            <div class="flex flex-col gap-1">
                <label class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">UI Version</label>
                <input type="text" class="ver-ui bg-white/5 border border-bordercolor rounded-lg px-3 py-2 text-white text-xs outline-none focus:border-primary transition duration-200" placeholder="e.g. 1.2.0" value="${initialData ? escapeHtml(initialData.uiVer) : ''}" required>
            </div>
            <div class="flex flex-col gap-1">
                <label class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">NTC Version</label>
                <input type="text" class="ver-ntc bg-white/5 border border-bordercolor rounded-lg px-3 py-2 text-white text-xs outline-none focus:border-primary transition duration-200" placeholder="e.g. v2" value="${initialData ? escapeHtml(initialData.ntcVer) : ''}" required>
            </div>
            <div class="flex flex-col gap-1">
                <label class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">PCB Version</label>
                <input type="text" class="ver-pcb bg-white/5 border border-bordercolor rounded-lg px-3 py-2 text-white text-xs outline-none focus:border-primary transition duration-200" placeholder="e.g. Rev.B" value="${initialData ? escapeHtml(initialData.pcbVer) : ''}" required>
            </div>
            <div class="flex flex-col gap-1">
                <label class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">SSR Version/Status</label>
                <input type="text" class="ver-ssr bg-white/5 border border-bordercolor rounded-lg px-3 py-2 text-white text-xs outline-none focus:border-primary transition duration-200" placeholder="e.g. Active" value="${initialData ? escapeHtml(initialData.ssr) : ''}" required>
            </div>
        </div>
    `;
    container.appendChild(row);
}
window.addVersionFormRow = addVersionFormRow;

/**
 * Reset Add Device Form
 */
function resetAddDeviceForm() {
    document.getElementById('catalogName').value = '';
    document.getElementById('catalogDesc').value = '';
    document.getElementById('catalogImageUrl').value = '';
    
    // Reset upload box preview
    const previewBox = document.getElementById('imageUploadPreviewBox');
    if (previewBox) {
        previewBox.style.backgroundImage = 'none';
        const placeholder = document.getElementById('imageUploadPlaceholder');
        if (placeholder) placeholder.style.display = 'flex';
    }
    
    // Clear and set one default version row
    const container = document.getElementById('catalogVersionsContainer');
    if (container) {
        container.innerHTML = '';
        addVersionFormRow();
    }
}

/**
 * Handle image file upload using AJAX upload.php
 */
async function handleImageUpload(e) {
    const file = e.target.files[0];
    if (!file) return;
    
    const uploadBox = document.getElementById('imageUploadPreviewBox');
    const hiddenUrlInput = document.getElementById('catalogImageUrl');
    const placeholder = document.getElementById('imageUploadPlaceholder');
    
    placeholder.innerHTML = `
        <i class="fa-solid fa-spinner fa-spin text-2xl text-primary"></i>
        <span>Uploading to server...</span>
    `;
    
    try {
        const formData = new FormData();
        formData.append('image', file);
        
        const response = await fetch('upload.php', {
            method: 'POST',
            body: formData
        });
        
        const resData = await response.json();
        if (resData.status === 'success') {
            hiddenUrlInput.value = resData.url;
            uploadBox.style.backgroundImage = `url('${resData.url}')`;
            uploadBox.style.backgroundSize = 'cover';
            uploadBox.style.backgroundPosition = 'center';
            placeholder.style.display = 'none';
            showToast("Device photo uploaded successfully!");
        } else {
            throw new Error(resData.message || "Upload failed.");
        }
    } catch (err) {
        console.error("Image upload failed:", err);
        placeholder.innerHTML = `
            <i class="fa-solid fa-circle-exclamation text-2xl text-danger"></i>
            <span>Upload failed: ${err.message}</span>
        `;
        showToast("Image Upload Error: " + err.message, "error");
    }
}

/**
 * Save new device model to RTDB Catalog
 */
async function submitAddDeviceModel() {
    const name = document.getElementById('catalogName').value.trim();
    const desc = document.getElementById('catalogDesc').value.trim();
    const imageUrl = document.getElementById('catalogImageUrl').value;
    
    if (!name || !desc) {
        showToast("Please fill in the catalog model name and description.", "error");
        return;
    }
    
    const versionRows = document.querySelectorAll('#catalogVersionsContainer .version-row');
    if (versionRows.length === 0) {
        showToast("Please add at least one version configuration.", "error");
        return;
    }
    
    const versionsArr = [];
    let validationPassed = true;
    
    versionRows.forEach(row => {
        const vName = row.querySelector('.ver-name').value.trim();
        const sw = row.querySelector('.ver-sw').value.trim();
        const ui = row.querySelector('.ver-ui').value.trim();
        const ntc = row.querySelector('.ver-ntc').value.trim();
        const pcb = row.querySelector('.ver-pcb').value.trim();
        const ssr = row.querySelector('.ver-ssr').value.trim();
        
        if (!vName || !sw || !ui || !ntc || !pcb || !ssr) {
            validationPassed = false;
        }
        
        versionsArr.push({
            versionName: vName,
            swVer: sw,
            uiVer: ui,
            ntcVer: ntc,
            pcbVer: pcb,
            ssr: ssr
        });
    });
    
    if (!validationPassed) {
        showToast("Please fill in all specifications fields for every version added.", "error");
        return;
    }
    
    const overlay = document.getElementById('addDeviceLoadingOverlay');
    showOverlay('addDeviceLoadingOverlay');
    
    try {
        const ref = editingDeviceId ? rtdb.ref(`devices/${editingDeviceId}`) : rtdb.ref('devices').push();
        const payload = {
            name: name,
            description: desc,
            imageUrl: imageUrl,
            versions: versionsArr
        };
        
        await withTimeout(ref.set(payload), 5000, "Catalog save timed out.");
        
        if (editingDeviceId) {
            showToast(`Catalog model "${name}" updated successfully! ✨`);
        } else {
            showToast(`Catalog model "${name}" registered successfully! ✨`);
        }
        closeModal('addDeviceModal');
        resetAddDeviceForm();
    } catch (err) {
        console.error("Saving catalog item failed:", err);
        showToast("Error saving catalog item: " + err.message, "error");
    } finally {
        hideOverlay('addDeviceLoadingOverlay');
    }
}

/**
 * Prompt delete device catalog model confirmation
 */
async function deleteDeviceModel(deviceId, modelName) {
    const title = "Delete Catalog Device Model";
    const message = `Are you sure you want to delete the model "${modelName}" from the global catalog? Clinics currently linked to this model won't be unlinked, but new linkings won't be able to select this model.`;
    
    const confirmed = await showCustomConfirm(title, message, 'danger');
    if (!confirmed) return;
    
    try {
        await withTimeout(
            rtdb.ref(`devices/${deviceId}`).remove(),
            5000,
            "Delete catalog item timed out."
        );
        showToast(`Device model "${modelName}" deleted from catalog.`);
    } catch (err) {
        console.error("Deleting device model failed:", err);
        showToast("Deletion Failed: " + err.message, "error");
    }
}
window.deleteDeviceModel = deleteDeviceModel;

/**
 * Helper: Operations Timeout wrapping
 */
function withTimeout(promise, ms, errorMessage = "Operation timed out") {
    const timeout = new Promise((_, reject) =>
        setTimeout(() => reject(new Error(errorMessage)), ms)
    );
    return Promise.race([promise, timeout]);
}

/**
 * Helper: Escape HTML strings safely
 */
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

/**
 * Open modal to Edit device catalog model
 */
function openEditDeviceModal(deviceId) {
    const device = allDevices.find(d => d.id === deviceId);
    if (!device) return;
    
    editingDeviceId = deviceId;
    
    // Update headers and texts
    document.getElementById('modalDeviceTitle').textContent = "Edit Device Model";
    document.getElementById('modalDeviceSubtitle').textContent = "Update catalog model name, description, photo and versions specs";
    document.getElementById('submitDeviceBtnText').textContent = "Update Device Model";
    
    // Set fields
    document.getElementById('catalogName').value = device.name;
    document.getElementById('catalogDesc').value = device.description;
    document.getElementById('catalogImageUrl').value = device.imageUrl || '';
    
    // Set image preview box
    const previewBox = document.getElementById('imageUploadPreviewBox');
    const placeholder = document.getElementById('imageUploadPlaceholder');
    if (device.imageUrl) {
        previewBox.style.backgroundImage = `url('${device.imageUrl}')`;
        previewBox.style.backgroundSize = 'cover';
        previewBox.style.backgroundPosition = 'center';
        placeholder.style.display = 'none';
    } else {
        previewBox.style.backgroundImage = 'none';
        placeholder.style.display = 'flex';
        placeholder.innerHTML = `
            <i class="fa-solid fa-cloud-arrow-up text-2xl text-textsecondary"></i>
            <span>Click to upload device photo (Max 5MB)</span>
        `;
    }
    
    // Load version rows
    const container = document.getElementById('catalogVersionsContainer');
    container.innerHTML = '';
    if (device.versions && device.versions.length > 0) {
        device.versions.forEach(v => {
            addVersionFormRow(v);
        });
    } else {
        addVersionFormRow();
    }
    
    openModal('addDeviceModal');
}
window.openEditDeviceModal = openEditDeviceModal;

/**
 * Show version specs expandable drawer in device catalog card
 */
function showCatalogVersionSpecs(deviceId, versionIndex, btn) {
    const specsDrawer = document.getElementById(`specs-drawer-${deviceId}`);
    if (!specsDrawer) return;
    
    const device = allDevices.find(d => d.id === deviceId);
    if (!device || !device.versions || !device.versions[versionIndex]) return;
    
    const v = device.versions[versionIndex];
    
    // Toggle check
    const isCurrent = btn.classList.contains('active-ver-badge');
    
    // Clear styles for all version buttons in this card
    const card = btn.closest('.flex-col');
    card.querySelectorAll('.ver-badge-btn').forEach(b => {
        b.classList.remove('active-ver-badge', 'bg-secondary', 'text-white');
        b.classList.add('bg-secondary/10', 'text-secondary');
    });
    
    if (isCurrent && !specsDrawer.classList.contains('hidden')) {
        specsDrawer.classList.add('hidden');
        specsDrawer.innerHTML = '';
        return;
    }
    
    // Set active style
    btn.classList.remove('bg-secondary/10', 'text-secondary');
    btn.classList.add('active-ver-badge', 'bg-secondary', 'text-white');
    
    // Render specs contents
    specsDrawer.innerHTML = `
        <div class="bg-black/35 rounded-xl border border-bordercolor p-3 flex flex-col gap-2.5">
            <div class="flex items-center justify-between">
                <span class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Version Name</span>
                <span class="text-xs font-bold text-white">${escapeHtml(v.versionName)}</span>
            </div>
            <div class="grid grid-cols-2 gap-2 text-left mt-1">
                <div class="flex flex-col bg-white/5 border border-bordercolor rounded-lg p-2">
                    <span class="text-[9px] font-bold text-textsecondary uppercase tracking-wider">SW Ver</span>
                    <span class="text-xs font-semibold text-white mt-0.5">${escapeHtml(v.swVer || 'N/A')}</span>
                </div>
                <div class="flex flex-col bg-white/5 border border-bordercolor rounded-lg p-2">
                    <span class="text-[9px] font-bold text-textsecondary uppercase tracking-wider">UI Ver</span>
                    <span class="text-xs font-semibold text-white mt-0.5">${escapeHtml(v.uiVer || 'N/A')}</span>
                </div>
                <div class="flex flex-col bg-white/5 border border-bordercolor rounded-lg p-2">
                    <span class="text-[9px] font-bold text-textsecondary uppercase tracking-wider">NTC Ver</span>
                    <span class="text-xs font-semibold text-white mt-0.5">${escapeHtml(v.ntcVer || 'N/A')}</span>
                </div>
                <div class="flex flex-col bg-white/5 border border-bordercolor rounded-lg p-2">
                    <span class="text-[9px] font-bold text-textsecondary uppercase tracking-wider">PCB Ver</span>
                    <span class="text-xs font-semibold text-white mt-0.5">${escapeHtml(v.pcbVer || 'N/A')}</span>
                </div>
            </div>
            <div class="flex items-center justify-between border-t border-bordercolor/50 pt-2 mt-1">
                <span class="text-[9px] font-bold text-textsecondary uppercase tracking-wider">SSR Version/Status</span>
                <span class="px-2 py-0.5 rounded text-[10px] font-bold bg-primary/10 text-primary border border-primary/20">${escapeHtml(v.ssr || 'N/A')}</span>
            </div>
        </div>
    `;
    
    specsDrawer.classList.remove('hidden');
}
window.showCatalogVersionSpecs = showCatalogVersionSpecs;
