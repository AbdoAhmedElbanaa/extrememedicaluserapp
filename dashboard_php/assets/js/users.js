/**
 * Users & Clinics Controller Script
 * Extreme Medical Web Administration
 */

let allClinics = [];
let allCatalogDevices = []; // Cache for global device models
let addMap = null;
let addMarker = null;
let viewMap = null;
let viewMarker = null;

// Stepper Wizard State
let activeStep = 1;
let createdUid = "";
let selectedLat = 30.0444;
let selectedLng = 31.2357;

document.addEventListener('DOMContentLoaded', () => {
    // 1. Hook user table stream
    initializeRealtimeTable();
    
    // 2. Setup Dialog Actions
    setupModalActions();
    
    // 3. Search Bar Listener
    document.getElementById('clinicSearchInput').addEventListener('input', filterClinicsTable);

    // 4. Hook device catalog stream
    initializeDevicesSync();
});

/**
 * Sync clinics table in real-time
 */
function initializeRealtimeTable() {
    const tableBody = document.getElementById('clinicsTableBody');
    const usersRef = rtdb.ref('users');
    
    usersRef.on('value', (snapshot) => {
        const data = snapshot.val();
        
        if (!data) {
            allClinics = [];
            tableBody.innerHTML = `
                <tr>
                    <td colspan="7" class="p-4 border-b border-bordercolor text-xs text-textmuted text-center py-10">
                        <i class="fa-solid fa-folder-open text-2xl mb-2 block"></i>
                        No registered clinics found.
                    </td>
                </tr>
            `;
            return;
        }
        
        allClinics = [];
        Object.keys(data).forEach(key => {
            const user = data[key];
            allClinics.push({
                uid: key,
                email: user.email || 'N/A',
                phoneNumber: user.phoneNumber || 'N/A',
                clinicName: user.clinicName || 'Unnamed Clinic',
                firstName: user.firstName || '',
                lastName: user.lastName || '',
                address: user.address || 'No address registered',
                latitude: user.latitude || null,
                longitude: user.longitude || null,
                device: user.device || null
            });
        });
        
        renderClinicsTable(allClinics);
    }, (error) => {
        console.error("Error streaming table data:", error);
        tableBody.innerHTML = `
            <tr>
                <td colspan="7" class="p-4 border-b border-bordercolor text-xs text-danger text-center py-10">
                    <i class="fa-solid fa-triangle-exclamation text-2xl mb-2 block"></i>
                    Failed to connect: ${error.message}
                </td>
            </tr>
        `;
    });
}

function renderClinicsTable(list) {
    const tableBody = document.getElementById('clinicsTableBody');
    tableBody.innerHTML = '';
    
    if (list.length === 0) {
        tableBody.innerHTML = `
            <tr>
                <td colspan="7" class="p-4 border-b border-bordercolor text-xs text-textmuted text-center py-10">
                    No matching clinics found.
                </td>
            </tr>
        `;
        return;
    }
    
    list.forEach((clinic, index) => {
        const row = document.createElement('tr');
        row.className = 'group hover:bg-white/5 transition duration-150';
        
        const hasCoords = clinic.latitude !== null && clinic.longitude !== null;
        const coordsBadge = hasCoords 
            ? `<span class="px-2 py-0.5 rounded-lg text-[10px] font-bold inline-flex items-center gap-1 bg-success/15 text-success" title="${clinic.latitude}, ${clinic.longitude}"><i class="fa-solid fa-location-dot"></i> Mapped</span>`
            : `<span class="px-2 py-0.5 rounded-lg text-[10px] font-bold inline-flex items-center gap-1 bg-danger/15 text-danger"><i class="fa-solid fa-circle-xmark"></i> Unmapped</span>`;
            
        const hasDevice = clinic.device !== null;
        const linkDeviceButton = hasDevice
            ? `<button class="bg-success/15 text-success hover:bg-success hover:text-white border-none cursor-pointer text-sm p-2 rounded-lg transition duration-200 mr-1" title="Edit Linked Device" onclick="openLinkDeviceModal('${clinic.uid}')">
                 <i class="fa-solid fa-laptop-medical"></i>
               </button>`
            : `<button class="bg-white/5 text-textsecondary hover:bg-primary hover:text-white border-none cursor-pointer text-sm p-2 rounded-lg transition duration-200 mr-1" title="Link Hardware Device" onclick="openLinkDeviceModal('${clinic.uid}')">
                 <i class="fa-solid fa-link"></i>
               </button>`;

        row.innerHTML = `
            <td class="p-4 border-b border-bordercolor text-xs text-white text-center"><span class="inline-flex items-center justify-center w-6 h-6 rounded-full bg-white/5 border border-bordercolor text-textsecondary text-[10px] font-bold transition duration-200 group-hover:bg-gradient-to-tr group-hover:from-primary group-hover:to-secondary group-hover:text-white group-hover:border-transparent group-hover:shadow-primaryglow">${index + 1}</span></td>
            <td class="p-4 border-b border-bordercolor text-xs text-white"><strong>${escapeHtml(clinic.clinicName)}</strong></td>
            <td class="p-4 border-b border-bordercolor text-xs text-white">Dr. ${escapeHtml(clinic.firstName)} ${escapeHtml(clinic.lastName)}</td>
            <td class="p-4 border-b border-bordercolor text-xs text-white">${escapeHtml(clinic.email)}</td>
            <td class="p-4 border-b border-bordercolor text-xs text-white">${escapeHtml(clinic.phoneNumber)}</td>
            <td class="p-4 border-b border-bordercolor text-xs text-white">${coordsBadge} <span class="text-[10px] text-textsecondary ml-2">${escapeHtml(clinic.address)}</span></td>
            <td class="p-4 border-b border-bordercolor text-xs text-white text-center whitespace-nowrap">
                ${linkDeviceButton}
                <button class="bg-primary/10 text-primary hover:bg-primary hover:text-white border-none cursor-pointer text-sm p-2 rounded-lg transition duration-200 mr-1" title="View details & map" onclick="openViewClinicModal('${clinic.uid}')">
                    <i class="fa-solid fa-map-location-dot"></i>
                </button>
                <button class="bg-danger/10 text-danger hover:bg-danger hover:text-white border-none cursor-pointer text-sm p-2 rounded-lg transition duration-200" title="Delete Clinic" onclick="confirmDeleteClinic('${clinic.uid}', '${escapeHtml(clinic.clinicName)}')">
                    <i class="fa-solid fa-trash-can"></i>
                </button>
            </td>
        `;
        tableBody.appendChild(row);
    });
}

function filterClinicsTable() {
    const query = document.getElementById('clinicSearchInput').value.toLowerCase().trim();
    if (!query) {
        renderClinicsTable(allClinics);
        return;
    }
    
    const filtered = allClinics.filter(c => {
        return c.clinicName.toLowerCase().includes(query) ||
               c.firstName.toLowerCase().includes(query) ||
               c.lastName.toLowerCase().includes(query) ||
               c.email.toLowerCase().includes(query) ||
               c.phoneNumber.toLowerCase().includes(query) ||
               c.address.toLowerCase().includes(query);
    });
    
    renderClinicsTable(filtered);
}

/**
 * Modal Actions Setup
 */
function setupModalActions() {
    const addOverlay = document.getElementById('addClinicModal');
    const openAddBtn = document.getElementById('openAddClinicModalBtn');
    const closeAddBtn = document.getElementById('closeAddClinicModalBtn');
    const cancelAddBtn = document.getElementById('cancelAddClinicBtn');
    
    const nextBtn = document.getElementById('nextAddClinicBtn');
    const submitBtn = document.getElementById('submitAddClinicBtn');
    
    // Open Dialog
    openAddBtn.addEventListener('click', () => {
        resetAddClinicForm();
        openModal('addClinicModal');
        // Instantly init map container
        setTimeout(initAddClinicMap, 200);
    });
    
    // Close / Cancel actions
    const closeHandler = () => {
        closeModal('addClinicModal');
    };
    closeAddBtn.addEventListener('click', closeHandler);
    cancelAddBtn.addEventListener('click', closeHandler);
    
    // Stepper Navigation Actions
    nextBtn.addEventListener('click', handleStep1Submit);
    submitBtn.addEventListener('click', handleStep2Submit);

    // Link Device Modal triggers
    const openLinkBtn = document.getElementById('openLinkDeviceModalBtn');
    const closeLinkBtn = document.getElementById('closeLinkDeviceModalBtn');
    const cancelLinkBtn = document.getElementById('cancelLinkDeviceBtn');
    const submitLinkBtn = document.getElementById('submitLinkDeviceBtn');
    
    if (openLinkBtn) {
        openLinkBtn.addEventListener('click', () => {
            openLinkDeviceModal();
        });
    }
    
    if (closeLinkBtn) {
        closeLinkBtn.addEventListener('click', () => closeModal('linkDeviceModal'));
    }
    if (cancelLinkBtn) {
        cancelLinkBtn.addEventListener('click', () => closeModal('linkDeviceModal'));
    }
    if (submitLinkBtn) {
        submitLinkBtn.addEventListener('click', submitLinkDeviceForm);
    }
    
    // Dropdown change listeners
    const clinicSelect = document.getElementById('linkClinicSelect');
    if (clinicSelect) {
        clinicSelect.addEventListener('change', (e) => {
            handleClinicSelectionChange(e.target.value);
        });
    }
    
    const modelSelect = document.getElementById('linkModelSelect');
    if (modelSelect) {
        modelSelect.addEventListener('change', (e) => {
            populateVersionDropdown(e.target.value);
        });
    }
    
    const versionSelect = document.getElementById('linkVersionSelect');
    if (versionSelect) {
        versionSelect.addEventListener('change', (e) => {
            const modelId = modelSelect.value;
            const model = allCatalogDevices.find(m => m.id === modelId);
            if (model) {
                const verObj = model.versions.find(v => v.versionName === e.target.value);
                updateSpecsPreview(verObj);
            } else {
                updateSpecsPreview(null);
            }
        });
    }
}

function withTimeout(promise, ms, errorMessage = "Operation timed out") {
    const timeout = new Promise((_, reject) =>
        setTimeout(() => reject(new Error(errorMessage)), ms)
    );
    return Promise.race([promise, timeout]);
}

async function handleStep1Submit() {
    const email = document.getElementById('regEmail').value.trim();
    const password = document.getElementById('regPassword').value;
    const overlay = document.getElementById('modalLoadingOverlay');
    const loadingText = document.getElementById('modalLoadingText');
    
    if (!email || !password) {
        showToast("Please fill in both email and password.", "error");
        return;
    }
    if (password.length < 6) {
        showToast("Password must be at least 6 characters long.", "error");
        return;
    }
    
    showOverlay('modalLoadingOverlay');
    loadingText.textContent = "Checking if clinic exists...";
    
    try {
        // 1. Check if user already exists in database
        let existingClinic = null;
        
        try {
            // Try Firestore check first
            const querySnapshot = await withTimeout(db.collection('users').where('email', '==', email).get(), 3000);
            if (querySnapshot && !querySnapshot.empty) {
                existingClinic = querySnapshot.docs[0].data();
            }
        } catch (fsCheckErr) {
            console.warn("Firestore check failed/disabled, falling back to RTDB:", fsCheckErr);
            // Fallback: Check Realtime Database
            try {
                const rtdbSnapshot = await withTimeout(rtdb.ref('users').orderByChild('email').equalTo(email).once('value'), 3000);
                if (rtdbSnapshot.exists()) {
                    const rtdbData = rtdbSnapshot.val();
                    const key = Object.keys(rtdbData)[0];
                    existingClinic = rtdbData[key];
                    existingClinic.uid = existingClinic.uid || key;
                }
            } catch (rtdbCheckErr) {
                console.warn("Realtime Database check also failed:", rtdbCheckErr);
            }
        }
        
        if (existingClinic) {
            createdUid = existingClinic.uid;
            
            // Populate Step 2 with existing data to allow updating
            document.getElementById('regClinicName').value = existingClinic.clinicName || "";
            document.getElementById('regFirstName').value = existingClinic.firstName || "";
            document.getElementById('regLastName').value = existingClinic.lastName || "";
            document.getElementById('regPhone').value = existingClinic.phoneNumber || "";
            document.getElementById('regAddress').value = existingClinic.address || "";
            
            if (existingClinic.latitude && existingClinic.longitude) {
                selectedLat = Number(existingClinic.latitude);
                selectedLng = Number(existingClinic.longitude);
                document.getElementById('mapSelectedCoords').textContent = `${selectedLat.toFixed(5)}, ${selectedLng.toFixed(5)}`;
                if (addMarker) {
                    addMarker.setLatLng([selectedLat, selectedLng]);
                    addMap.setView([selectedLat, selectedLng], 13);
                }
            }
            
            activeStep = 2;
            transitionWizardUI();
            showToast("Clinic already exists in database. Loaded profile details to update.");
            return;
        }
        
        loadingText.textContent = "Configuring Auth credentials...";
        
        // 2. Create secondary Firebase App instance for clean Auth user creation
        let secondaryApp = null;
        try {
            secondaryApp = firebase.initializeApp(firebaseConfig, "UserCreationApp");
            const secondaryAuth = secondaryApp.auth();
            
            try {
                // Try creating a new account
                const credential = await secondaryAuth.createUserWithEmailAndPassword(email, password);
                createdUid = credential.user.uid;
                showToast("Credentials created successfully! Now configure the profile.");
            } catch (authError) {
                // If account exists in Auth but not Firestore, try to authenticate to retrieve UID
                if (authError.code === 'auth/email-already-in-use') {
                    console.log("Email exists in Auth. Authenticating to retrieve UID...");
                    loadingText.textContent = "Mapping existing credentials...";
                    const credential = await secondaryAuth.signInWithEmailAndPassword(email, password);
                    createdUid = credential.user.uid;
                    showToast("Credentials recognized! Loaded account UID to configure profile.");
                } else {
                    throw authError;
                }
            }
            
            await secondaryApp.delete();
            secondaryApp = null;
            
            activeStep = 2;
            transitionWizardUI();
            
        } catch (authError) {
            console.error("Auth transaction failed:", authError);
            if (secondaryApp) {
                await secondaryApp.delete();
            }
            
            if (authError.code === 'auth/wrong-password') {
                showToast("This email is already registered, and the password entered is incorrect.", "error");
            } else {
                showToast("Authentication Error: " + authError.message, "error");
            }
        }
        
    } catch (error) {
        console.error("Checking user failed:", error);
        showToast("Error checking user existence: " + error.message, "error");
    } finally {
        hideOverlay('modalLoadingOverlay');
    }
}

/**
 * Stepper Step 2: Complete profile & database save
 */
async function handleStep2Submit() {
    const clinicName = document.getElementById('regClinicName').value.trim();
    const firstName = document.getElementById('regFirstName').value.trim();
    const lastName = document.getElementById('regLastName').value.trim();
    const phone = document.getElementById('regPhone').value.trim();
    const address = document.getElementById('regAddress').value.trim();
    const email = document.getElementById('regEmail').value.trim();
    
    const overlay = document.getElementById('modalLoadingOverlay');
    const loadingText = document.getElementById('modalLoadingText');
    
    if (!clinicName || !firstName || !lastName || !phone || !address) {
        showToast("Please fill in all clinic profile fields.", "error");
        return;
    }
    
    showOverlay('modalLoadingOverlay');
    loadingText.textContent = "Saving to databases...";
    
    try {
        const payload = {
            uid: createdUid,
            email: email,
            phoneNumber: phone,
            clinicName: clinicName,
            firstName: firstName,
            lastName: lastName,
            address: address,
            latitude: selectedLat,
            longitude: selectedLng
        };
        
        let firestoreSuccess = false;
        let rtdbSuccess = false;
        let errorDetails = "";
        
        // 1. Try to save to Firestore
        try {
            await withTimeout(
                db.collection('users').doc(createdUid).set(payload), 
                6000, 
                "Firestore write timed out."
            );
            firestoreSuccess = true;
            console.log("Saved to Firestore successfully.");
        } catch (fsError) {
            console.warn("Firestore write failed/disabled:", fsError);
            errorDetails += `Firestore: ${fsError.message || fsError}. `;
        }
        
        // 2. Save to Realtime Database
        try {
            await withTimeout(
                rtdb.ref(`users/${createdUid}`).set(payload), 
                6000, 
                "Realtime Database write timed out."
            );
            rtdbSuccess = true;
            console.log("Saved to Realtime Database successfully.");
        } catch (rtdbError) {
            console.warn("Realtime Database sync failed:", rtdbError);
            errorDetails += `Realtime Database: ${rtdbError.message || rtdbError}. `;
        }
        
        // 3. Evaluate results
        if (firestoreSuccess || rtdbSuccess) {
            if (firestoreSuccess && rtdbSuccess) {
                showToast("Clinic registered successfully! ✨");
            } else if (firestoreSuccess) {
                showToast("Saved to Firestore. (RTDB sync failed/disabled)", "warning");
            } else {
                showToast("Saved to Realtime Database. (Firestore sync disabled)", "warning");
            }
            
            closeModal('addClinicModal');
            resetAddClinicForm();
        } else {
            throw new Error("Both databases failed: " + errorDetails);
        }
        
    } catch (error) {
        console.error("Database save failed:", error);
        showToast(error.message || "Failed to save database profiles.", "error");
    } finally {
        hideOverlay('modalLoadingOverlay');
    }
}

/**
 * Stepper wizard layout transitions
 */
function transitionWizardUI() {
    const step1View = document.getElementById('wizardStep1View');
    const step2View = document.getElementById('wizardStep2View');
    const stepNode1 = document.getElementById('stepNode1');
    const stepNode2 = document.getElementById('stepNode2');
    const nextBtn = document.getElementById('nextAddClinicBtn');
    const submitBtn = document.getElementById('submitAddClinicBtn');
    
    const modalHeaderTitle = document.getElementById('wizardHeaderTitle');
    const modalHeaderSubtitle = document.getElementById('wizardHeaderSubtitle');
    const modalHeaderIcon = document.getElementById('wizardHeaderIcon');
    
    if (activeStep === 1) {
        step1View.style.display = 'block';
        step2View.style.display = 'none';
        stepNode1.className = "step-node active";
        stepNode2.className = "step-node";
        nextBtn.style.display = 'inline-flex';
        submitBtn.style.display = 'none';
        
        modalHeaderTitle.textContent = "Step 1: Account Credentials";
        modalHeaderSubtitle.textContent = "Configure admin credentials on Firebase Auth";
        modalHeaderIcon.innerHTML = '<i class="fa-solid fa-key"></i>';
    } else {
        step1View.style.display = 'none';
        step2View.style.display = 'block';
        stepNode1.className = "step-node completed";
        stepNode2.className = "step-node active";
        nextBtn.style.display = 'none';
        submitBtn.style.display = 'inline-flex';
        
        modalHeaderTitle.textContent = "Step 2: Clinic Profile Info";
        modalHeaderSubtitle.textContent = "Configure profile details, phone & location";
        modalHeaderIcon.innerHTML = '<i class="fa-solid fa-hospital"></i>';
        
        // Leaflet maps requires a refresh to render properly when transitioning from a hidden state
        if (addMap) {
            setTimeout(() => {
                addMap.invalidateSize();
            }, 100);
        }
    }
}

function resetAddClinicForm() {
    document.getElementById('regEmail').value = "";
    document.getElementById('regPassword').value = "";
    document.getElementById('regClinicName').value = "";
    document.getElementById('regFirstName').value = "";
    document.getElementById('regLastName').value = "";
    document.getElementById('regPhone').value = "";
    document.getElementById('regAddress').value = "";
    document.getElementById('mapSelectedCoords').textContent = "30.0444, 31.2357 (Default Cairo)";
    
    activeStep = 1;
    createdUid = "";
    selectedLat = 30.0444;
    selectedLng = 31.2357;
    
    transitionWizardUI();
}

/**
 * Interactive Leaflet Map for Step 2 location picker
 */
function initAddClinicMap() {
    if (addMap !== null) return; // already initialized
    
    const defaultCoords = [30.0444, 31.2357]; // Cairo
    
    addMap = L.map('addClinicMap').setView(defaultCoords, 13);
    
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; OpenStreetMap contributors'
    }).addTo(addMap);
    
    // Custom Violet Marker matching theme
    const violetIcon = L.icon({
        iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-violet.png',
        shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png',
        iconSize: [25, 41],
        iconAnchor: [12, 41],
        popupAnchor: [1, -34],
        shadowSize: [41, 41]
    });
    
    addMarker = L.marker(defaultCoords, { icon: violetIcon, draggable: true }).addTo(addMap);
    
    // Map tap / click event
    addMap.on('click', (e) => {
        const lat = e.latlng.lat;
        const lng = e.latlng.lng;
        updateSelectedLocation(lat, lng);
    });
    
    // Marker dragging event
    addMarker.on('dragend', (e) => {
        const position = addMarker.getLatLng();
        updateSelectedLocation(position.lat, position.lng);
    });
}

function updateSelectedLocation(lat, lng) {
    selectedLat = lat;
    selectedLng = lng;
    
    addMarker.setLatLng([lat, lng]);
    document.getElementById('mapSelectedCoords').textContent = `${lat.toFixed(5)}, ${lng.toFixed(5)}`;
    
    // Reverse Geocode location using OpenStreetMap Nominatim
    const addressInput = document.getElementById('regAddress');
    fetch(`https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lng}&zoom=18&addressdetails=1`)
        .then(response => response.json())
        .then(data => {
            if (data && data.display_name) {
                addressInput.value = data.display_name;
            }
        })
        .catch(err => {
            console.error("Nominatim reverse geocode failed:", err);
        });
}

/**
 * Details Dialog & Map View
 */
function openViewClinicModal(uid) {
    const clinic = allClinics.find(c => c.uid === uid);
    if (!clinic) return;
    
    document.getElementById('viewClinicTitle').textContent = clinic.clinicName;
    document.getElementById('viewClinicSubtitle').textContent = `UID: ${clinic.uid}`;
    document.getElementById('viewDoctorName').textContent = `Dr. ${clinic.firstName} ${clinic.lastName}`;
    document.getElementById('viewClinicEmail').textContent = clinic.email;
    document.getElementById('viewClinicPhone').textContent = clinic.phoneNumber;
    document.getElementById('viewClinicAddress').textContent = clinic.address;
    
    // Draw Linked Device Details
    const deviceContainer = document.getElementById('viewClinicDeviceContainer');
    if (deviceContainer) {
        if (clinic.device) {
            const dev = clinic.device;
            deviceContainer.innerHTML = `
                <div class="bg-white/5 border border-bordercolor rounded-2xl p-5 flex flex-col md:flex-row gap-5 items-center relative overflow-hidden pt-8 md:pt-5">
                    <!-- Unlink Button -->
                    <div class="absolute top-3 right-3">
                        <button class="bg-danger/10 text-danger hover:bg-danger hover:text-white border-none cursor-pointer text-[10px] font-bold py-1 px-2.5 rounded-lg transition duration-200" title="Unlink Device" onclick="confirmUnlinkDevice('${clinic.uid}', '${escapeHtml(clinic.clinicName)}')">
                            <i class="fa-solid fa-link-slash mr-1"></i> Unlink
                        </button>
                    </div>
                    <!-- Left: Device Image -->
                    <div class="w-24 h-24 rounded-xl bg-black/20 border border-bordercolor overflow-hidden flex items-center justify-center shrink-0">
                        ${dev.imageUrl 
                            ? `<img src="${escapeHtml(dev.imageUrl)}" class="w-full h-full object-cover" alt="Device Image" />`
                            : `<i class="fa-solid fa-laptop-medical text-3xl text-textsecondary"></i>`
                        }
                    </div>
                    <!-- Middle: Specs -->
                    <div class="flex-1 min-w-0">
                        <div class="flex flex-wrap items-center gap-2 mb-1.5 justify-center md:justify-start">
                            <h4 class="text-sm font-extrabold text-white">${escapeHtml(dev.deviceName || 'System Device')}</h4>
                            <span class="px-2 py-0.5 rounded-md text-[10px] font-bold bg-primary/10 text-primary border border-primary/20">${escapeHtml(dev.deviceVersion || 'v1.0')}</span>
                        </div>
                        <p class="text-xs text-textsecondary mb-3 flex items-center gap-1.5 justify-center md:justify-start">
                            <i class="fa-solid fa-barcode text-primary"></i>
                            <span>Serial No: <strong class="text-white select-all">${escapeHtml(dev.serialNo || 'N/A')}</strong></span>
                        </p>
                        <div class="grid grid-cols-2 sm:grid-cols-5 gap-3.5 bg-black/20 border border-bordercolor rounded-xl p-3 text-center sm:text-left">
                            <div class="flex flex-col">
                                <span class="text-[9px] font-bold text-textsecondary uppercase tracking-wider">SW Ver</span>
                                <span class="text-xs font-semibold text-white mt-0.5">${escapeHtml(dev.swVer || 'N/A')}</span>
                            </div>
                            <div class="flex flex-col">
                                <span class="text-[9px] font-bold text-textsecondary uppercase tracking-wider">UI Ver</span>
                                <span class="text-xs font-semibold text-white mt-0.5">${escapeHtml(dev.uiVer || 'N/A')}</span>
                            </div>
                            <div class="flex flex-col">
                                <span class="text-[9px] font-bold text-textsecondary uppercase tracking-wider">NTC Ver</span>
                                <span class="text-xs font-semibold text-white mt-0.5">${escapeHtml(dev.ntcVer || 'N/A')}</span>
                            </div>
                            <div class="flex flex-col">
                                <span class="text-[9px] font-bold text-textsecondary uppercase tracking-wider">PCB Ver</span>
                                <span class="text-xs font-semibold text-white mt-0.5">${escapeHtml(dev.pcbVer || 'N/A')}</span>
                            </div>
                            <div class="flex flex-col">
                                <span class="text-[9px] font-bold text-textsecondary uppercase tracking-wider">SSR</span>
                                <span class="text-xs font-semibold text-white mt-0.5">${escapeHtml(dev.ssr || 'N/A')}</span>
                            </div>
                        </div>
                    </div>
                    <!-- Right: Dates -->
                    <div class="flex flex-col items-stretch justify-center gap-2 bg-white/5 border border-bordercolor rounded-xl p-3.5 min-w-[160px] text-center md:text-right w-full md:w-auto shrink-0">
                        <div class="flex flex-col">
                            <span class="text-[9px] font-bold text-textsecondary uppercase tracking-wider">Installation</span>
                            <span class="text-xs font-semibold text-white mt-0.5">${escapeHtml(dev.installingDate || 'N/A')}</span>
                        </div>
                        <div class="h-[1px] bg-bordercolor my-1 hidden md:block"></div>
                        <div class="flex flex-col">
                            <span class="text-[9px] font-bold text-textsecondary uppercase tracking-wider">Warranty Expiry</span>
                            <span class="text-xs font-semibold text-white mt-0.5">${escapeHtml(dev.endWarranty || 'N/A')}</span>
                        </div>
                    </div>
                </div>
            `;
        } else {
            deviceContainer.innerHTML = `
                <div class="bg-white/5 border border-bordercolor rounded-2xl p-6 flex flex-col items-center justify-center text-center text-textsecondary">
                    <i class="fa-solid fa-microchip text-3xl mb-2 text-textsecondary/60"></i>
                    <span class="text-xs">No hardware device is currently linked to this clinic.</span>
                </div>
            `;
        }
    }
    
    openModal('viewClinicModal');
    
    const lat = clinic.latitude || 30.0444;
    const lng = clinic.longitude || 31.2357;
    
    // Initialize or re-draw Map
    setTimeout(() => {
        if (viewMap === null) {
            viewMap = L.map('viewClinicMap').setView([lat, lng], 14);
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '&copy; OpenStreetMap contributors'
            }).addTo(viewMap);
            
            const violetIcon = L.icon({
                iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-violet.png',
                shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png',
                iconSize: [25, 41],
                iconAnchor: [12, 41],
                popupAnchor: [1, -34],
                shadowSize: [41, 41]
            });
            
            viewMarker = L.marker([lat, lng], { icon: violetIcon }).addTo(viewMap);
        } else {
            viewMap.setView([lat, lng], 14);
            viewMarker.setLatLng([lat, lng]);
            viewMap.invalidateSize();
        }
    }, 200);
    
    // Close Details Handlers
    const closeBtn = document.getElementById('closeViewClinicModalBtn');
    const footerCloseBtn = document.getElementById('closeViewClinicBtn');
    
    const closeHandler = () => {
        closeModal('viewClinicModal');
    };
    closeBtn.onclick = closeHandler;
    footerCloseBtn.onclick = closeHandler;
}

/**
 * Delete User / Clinic Profile
 */
async function confirmDeleteClinic(uid, name) {
    const title = "Delete Clinic Profile";
    const message = `Are you sure you want to permanently delete clinic "${name}"? This removes records from both Firestore and Realtime Database.`;
    const confirmed = await showCustomConfirm(title, message, 'danger');
    if (confirmed) {
        deleteClinic(uid);
    }
}

async function deleteClinic(uid) {
    try {
        // 1. Delete from Firestore
        await db.collection('users').doc(uid).delete();
        
        // 2. Delete from Realtime Database
        await rtdb.ref(`users/${uid}`).remove();
        
        showToast("Clinic deleted successfully.");
    } catch (error) {
        console.error("Deletion failed:", error);
        showToast("Deletion Error: " + error.message, "error");
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

/**
 * Synchronize and cache devices catalog globally
 */
function initializeDevicesSync() {
    rtdb.ref('devices').on('value', (snapshot) => {
        const data = snapshot.val();
        allCatalogDevices = [];
        if (data) {
            Object.keys(data).forEach(key => {
                const dev = data[key];
                let versionList = [];
                if (Array.isArray(dev.versions)) {
                    versionList = dev.versions;
                } else if (typeof dev.versions === 'string') {
                    versionList = dev.versions.split(',').map(v => ({
                        versionName: v.trim(),
                        swVer: '1.0.0',
                        uiVer: '1.0.0',
                        ntcVer: 'v1',
                        pcbVer: 'Rev.A',
                        ssr: 'Active'
                    })).filter(v => v.versionName);
                }
                allCatalogDevices.push({
                    id: key,
                    name: dev.name || 'Unnamed Device',
                    description: dev.description || '',
                    imageUrl: dev.imageUrl || '',
                    versions: versionList
                });
            });
        }
    }, (error) => {
        console.error("Error synchronizing device catalog:", error);
    });
}

/**
 * Open Modal and prepopulate dropdowns and fields
 */
function openLinkDeviceModal(targetUid = "") {
    // 1. Populate Clinic dropdown
    const clinicSelect = document.getElementById('linkClinicSelect');
    clinicSelect.innerHTML = '<option value="" class="bg-darksec text-white">Choose a clinic...</option>';
    allClinics.forEach(c => {
        const opt = document.createElement('option');
        opt.value = c.uid;
        opt.className = 'bg-darksec text-white';
        opt.textContent = `${c.clinicName} (Dr. ${c.firstName} ${c.lastName})`;
        clinicSelect.appendChild(opt);
    });
    
    // 2. Populate Model dropdown
    const modelSelect = document.getElementById('linkModelSelect');
    modelSelect.innerHTML = '<option value="" class="bg-darksec text-white">Select model...</option>';
    allCatalogDevices.forEach(m => {
        const opt = document.createElement('option');
        opt.value = m.id;
        opt.className = 'bg-darksec text-white';
        opt.textContent = m.name;
        modelSelect.appendChild(opt);
    });
    
    // 3. Clear/Reset other fields
    document.getElementById('linkVersionSelect').innerHTML = '<option value="" class="bg-darksec text-white">Select version...</option>';
    document.getElementById('linkVersionSelect').disabled = true;
    document.getElementById('linkSpecsPreviewContainer').classList.add('hidden');
    document.getElementById('linkSerialNo').value = '';
    document.getElementById('linkInstallingDate').value = '';
    document.getElementById('linkEndWarranty').value = '';
    
    // 4. Handle pre-selection if targetUid is passed
    if (targetUid) {
        clinicSelect.value = targetUid;
        handleClinicSelectionChange(targetUid);
    }
    
    openModal('linkDeviceModal');
}
window.openLinkDeviceModal = openLinkDeviceModal;

/**
 * Handle clinic selection change inside Link Device Modal
 */
function handleClinicSelectionChange(clinicUid) {
    const modelSelect = document.getElementById('linkModelSelect');
    const versionSelect = document.getElementById('linkVersionSelect');
    const previewContainer = document.getElementById('linkSpecsPreviewContainer');
    const serialNoInput = document.getElementById('linkSerialNo');
    const installDateInput = document.getElementById('linkInstallingDate');
    const warrantyEndInput = document.getElementById('linkEndWarranty');
    
    // Reset fields first
    modelSelect.value = '';
    versionSelect.innerHTML = '<option value="">Select version...</option>';
    versionSelect.disabled = true;
    previewContainer.classList.add('hidden');
    serialNoInput.value = '';
    installDateInput.value = '';
    warrantyEndInput.value = '';
    
    if (!clinicUid) return;
    
    const clinic = allClinics.find(c => c.uid === clinicUid);
    if (clinic && clinic.device) {
        const dev = clinic.device;
        
        // Find model in catalog
        const model = allCatalogDevices.find(m => m.id === dev.deviceId || m.name === dev.deviceName);
        if (model) {
            modelSelect.value = model.id;
            
            // Populate versions
            populateVersionDropdown(model.id);
            
            // Pre-select version
            const verObj = model.versions.find(v => v.versionName === dev.deviceVersion);
            if (verObj) {
                versionSelect.value = verObj.versionName;
                updateSpecsPreview(verObj);
            }
        }
        
        serialNoInput.value = dev.serialNo || '';
        installDateInput.value = dev.installingDate || '';
        warrantyEndInput.value = dev.endWarranty || '';
    }
}

/**
 * Populate version dropdown based on selected model
 */
function populateVersionDropdown(modelId) {
    const versionSelect = document.getElementById('linkVersionSelect');
    versionSelect.innerHTML = '<option value="">Select version...</option>';
    versionSelect.disabled = true;
    
    const previewContainer = document.getElementById('linkSpecsPreviewContainer');
    previewContainer.classList.add('hidden');
    
    if (!modelId) return;
    
    const model = allCatalogDevices.find(m => m.id === modelId);
    if (!model || !model.versions || model.versions.length === 0) {
        return;
    }
    
    model.versions.forEach(v => {
        const option = document.createElement('option');
        option.value = v.versionName;
        option.className = 'bg-darksec text-white';
        option.textContent = v.versionName;
        versionSelect.appendChild(option);
    });
    versionSelect.disabled = false;
}

/**
 * Render read-only specifications card preview
 */
function updateSpecsPreview(v) {
    const previewContainer = document.getElementById('linkSpecsPreviewContainer');
    if (!v) {
        previewContainer.classList.add('hidden');
        return;
    }
    
    document.getElementById('previewSwVer').textContent = v.swVer || 'N/A';
    document.getElementById('previewUiVer').textContent = v.uiVer || 'N/A';
    document.getElementById('previewNtcVer').textContent = v.ntcVer || 'N/A';
    document.getElementById('previewPcbVer').textContent = v.pcbVer || 'N/A';
    document.getElementById('previewSsr').textContent = v.ssr || 'N/A';
    
    previewContainer.classList.remove('hidden');
}

/**
 * Submit and save device linking configuration payload to Firestore & RTDB
 */
async function submitLinkDeviceForm() {
    const clinicUid = document.getElementById('linkClinicSelect').value;
    const modelId = document.getElementById('linkModelSelect').value;
    const versionName = document.getElementById('linkVersionSelect').value;
    
    const serialNo = document.getElementById('linkSerialNo').value.trim();
    const installingDate = document.getElementById('linkInstallingDate').value;
    const endWarranty = document.getElementById('linkEndWarranty').value;
    
    if (!clinicUid || !modelId || !versionName || !serialNo || !installingDate || !endWarranty) {
        showToast("Please fill in all the required fields.", "error");
        return;
    }
    
    const modelObj = allCatalogDevices.find(m => m.id === modelId);
    if (!modelObj) {
        showToast("Selected device model not found.", "error");
        return;
    }
    
    const versionObj = modelObj.versions.find(v => v.versionName === versionName);
    if (!versionObj) {
        showToast("Selected version specs not found.", "error");
        return;
    }
    
    showOverlay('linkDeviceLoadingOverlay');
    
    try {
        const devicePayload = {
            deviceId: modelId,
            deviceName: modelObj.name,
            deviceVersion: versionName,
            imageUrl: modelObj.imageUrl || '',
            swVer: versionObj.swVer || 'N/A',
            uiVer: versionObj.uiVer || 'N/A',
            ntcVer: versionObj.ntcVer || 'N/A',
            pcbVer: versionObj.pcbVer || 'N/A',
            ssr: versionObj.ssr || 'N/A',
            serialNo: serialNo,
            installingDate: installingDate,
            endWarranty: endWarranty
        };
        
        let firestoreSuccess = false;
        let rtdbSuccess = false;
        let errorDetails = "";
        
        // 1. Save to Firestore under users/{uid}/device
        try {
            await withTimeout(
                db.collection('users').doc(clinicUid).update({
                    device: devicePayload
                }),
                5000,
                "Firestore link write timed out."
            );
            firestoreSuccess = true;
        } catch (fsErr) {
            console.warn("Firestore device link write failed:", fsErr);
            errorDetails += `Firestore: ${fsErr.message || fsErr}. `;
        }
        
        // 2. Save to Realtime Database under users/{uid}/device
        try {
            await withTimeout(
                rtdb.ref(`users/${clinicUid}/device`).set(devicePayload),
                5000,
                "Realtime Database link write timed out."
            );
            rtdbSuccess = true;
        } catch (rtdbErr) {
            console.warn("RTDB device link write failed:", rtdbErr);
            errorDetails += `RTDB: ${rtdbErr.message || rtdbErr}. `;
        }
        
        if (firestoreSuccess || rtdbSuccess) {
            if (firestoreSuccess && rtdbSuccess) {
                showToast("Device linked successfully! ✨");
            } else {
                showToast("Device linked (Partial database sync).", "warning");
            }
            closeModal('linkDeviceModal');
        } else {
            throw new Error("Both databases failed: " + errorDetails);
        }
    } catch (err) {
        console.error("Linking device failed:", err);
        showToast("Linking Failed: " + err.message, "error");
    } finally {
        hideOverlay('linkDeviceLoadingOverlay');
    }
}
window.submitLinkDeviceForm = submitLinkDeviceForm;

/**
 * Remove linked device object from clinic profile
 */
async function confirmUnlinkDevice(uid, clinicName) {
    const title = "Unlink Hardware Device";
    const message = `Are you sure you want to remove the linked hardware device from clinic "${clinicName}"?`;
    const confirmed = await showCustomConfirm(title, message, 'danger');
    if (!confirmed) return;
    
    try {
        let firestoreSuccess = false;
        let rtdbSuccess = false;
        let errorDetails = "";
        
        // 1. Remove from Firestore
        try {
            await withTimeout(
                db.collection('users').doc(uid).update({
                    device: firebase.firestore.FieldValue.delete()
                }),
                5000,
                "Firestore unlink write timed out."
            );
            firestoreSuccess = true;
        } catch (fsErr) {
            console.warn("Firestore device unlink failed:", fsErr);
            errorDetails += `Firestore: ${fsErr.message || fsErr}. `;
        }
        
        // 2. Remove from Realtime Database
        try {
            await withTimeout(
                rtdb.ref(`users/${uid}/device`).remove(),
                5000,
                "Realtime Database unlink write timed out."
            );
            rtdbSuccess = true;
        } catch (rtdbErr) {
            console.warn("RTDB device unlink failed:", rtdbErr);
            errorDetails += `RTDB: ${rtdbErr.message || rtdbErr}. `;
        }
        
        if (firestoreSuccess || rtdbSuccess) {
            showToast("Device unlinked successfully.");
            closeModal('viewClinicModal');
        } else {
            throw new Error("Both databases failed: " + errorDetails);
        }
    } catch (err) {
        console.error("Unlinking device failed:", err);
        showToast("Unlink Failed: " + err.message, "error");
    }
}
window.confirmUnlinkDevice = confirmUnlinkDevice;
