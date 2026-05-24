/**
 * Users & Clinics Controller Script
 * Extreme Medical Web Administration
 */

let allClinics = [];
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
                    <td colspan="6" style="text-align: center; color: var(--text-muted); padding: 40px 0;">
                        <i class="fa-solid fa-folder-open" style="font-size: 24px; margin-bottom: 8px; display: block;"></i>
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
                longitude: user.longitude || null
            });
        });
        
        renderClinicsTable(allClinics);
    }, (error) => {
        console.error("Error streaming table data:", error);
        tableBody.innerHTML = `
            <tr>
                <td colspan="6" style="text-align: center; color: var(--danger-color); padding: 40px 0;">
                    <i class="fa-solid fa-triangle-exclamation" style="font-size: 24px; margin-bottom: 8px; display: block;"></i>
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
                <td colspan="6" style="text-align: center; color: var(--text-muted); padding: 30px 0;">
                    No matching clinics found.
                </td>
            </tr>
        `;
        return;
    }
    
    list.forEach(clinic => {
        const row = document.createElement('tr');
        const hasCoords = clinic.latitude !== null && clinic.longitude !== null;
        const coordsBadge = hasCoords 
            ? `<span class="status-badge success" title="${clinic.latitude}, ${clinic.longitude}"><i class="fa-solid fa-location-dot"></i> Mapped</span>`
            : `<span class="status-badge danger"><i class="fa-solid fa-circle-xmark"></i> Unmapped</span>`;
            
        row.innerHTML = `
            <td><strong>${escapeHtml(clinic.clinicName)}</strong></td>
            <td>Dr. ${escapeHtml(clinic.firstName)} ${escapeHtml(clinic.lastName)}</td>
            <td>${escapeHtml(clinic.email)}</td>
            <td>${escapeHtml(clinic.phoneNumber)}</td>
            <td>${coordsBadge} <span style="font-size: 11px; color: var(--text-secondary); margin-left: 8px;">${escapeHtml(clinic.address)}</span></td>
            <td style="text-align: center; white-space: nowrap;">
                <button class="action-btn primary" title="View details & map" onclick="openViewClinicModal('${clinic.uid}')">
                    <i class="fa-solid fa-map-location-dot"></i>
                </button>
                <button class="action-btn danger" title="Delete Clinic" onclick="confirmDeleteClinic('${clinic.uid}', '${escapeHtml(clinic.clinicName)}')">
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
        addOverlay.classList.add('active');
        // Instantly init map container
        setTimeout(initAddClinicMap, 200);
    });
    
    // Close / Cancel actions
    const closeHandler = () => {
        addOverlay.classList.remove('active');
    };
    closeAddBtn.addEventListener('click', closeHandler);
    cancelAddBtn.addEventListener('click', closeHandler);
    
    // Stepper Navigation Actions
    nextBtn.addEventListener('click', handleStep1Submit);
    submitBtn.addEventListener('click', handleStep2Submit);
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
    
    overlay.classList.add('active');
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
        overlay.classList.remove('active');
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
    
    overlay.classList.add('active');
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
            
            document.getElementById('addClinicModal').classList.remove('active');
            resetAddClinicForm();
        } else {
            throw new Error("Both databases failed: " + errorDetails);
        }
        
    } catch (error) {
        console.error("Database save failed:", error);
        showToast(error.message || "Failed to save database profiles.", "error");
    } finally {
        overlay.classList.remove('active');
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
    
    document.getElementById('viewClinicModal').classList.add('active');
    
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
        document.getElementById('viewClinicModal').classList.remove('active');
    };
    closeBtn.onclick = closeHandler;
    footerCloseBtn.onclick = closeHandler;
}

/**
 * Delete User / Clinic Profile
 */
function confirmDeleteClinic(uid, name) {
    if (confirm(`Are you sure you want to permanently delete clinic "${name}"? This removes records from both Firestore and Realtime Database.`)) {
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
