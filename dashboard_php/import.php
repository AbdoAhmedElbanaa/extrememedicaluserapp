<?php
/**
 * Excel Data Importer Page
 * Extreme Medical Web Administration
 */
require_once __DIR__ . '/config.php';
check_auth();

$page_title = 'Data Importer';
// We don't need dedicated scripts as we can include them inline for self-containment
$page_scripts = [];

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/sidebar.php';
?>

<div class="flex-1 flex flex-col min-w-0 bg-darkbg">
    <!-- Navbar / Header -->
    <header class="h-20 border-b border-bordercolor px-8 flex items-center justify-between bg-darkbg/80 backdrop-blur-md sticky top-0 z-[90]">
        <div class="flex flex-col">
            <h1 class="text-xl font-extrabold text-white">Chiller Data Importer</h1>
            <p class="text-xs text-textsecondary">Import clinic locations, doctor contact profiles, and linked hardware chiller devices</p>
        </div>
        <div class="flex items-center gap-4">
            <button class="bg-gradient-to-tr from-primary to-secondary text-white font-bold text-sm px-5 py-3 rounded-xl flex items-center gap-2 hover:-translate-y-0.5 hover:shadow-primaryglow transition duration-200 cursor-pointer disabled:opacity-50 disabled:pointer-events-none" id="startImportBtn" onclick="startImport()">
                <i class="fa-solid fa-cloud-arrow-up"></i> Start Import (106 Records)
            </button>
        </div>
    </header>

    <!-- Page Content -->
    <main class="p-8 flex-1 overflow-y-auto flex flex-col gap-6">
        <!-- Import Progress Stats Grid -->
        <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
            <div class="bg-darksurface border border-bordercolor rounded-[24px] p-5 flex items-center gap-4 shadow-xl">
                <div class="w-12 h-12 rounded-2xl bg-primary/10 flex items-center justify-center text-primary text-xl">
                    <i class="fa-solid fa-list-check"></i>
                </div>
                <div class="flex flex-col">
                    <span class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Total Clinics</span>
                    <span class="text-2xl font-black text-white mt-0.5" id="statTotal">0</span>
                </div>
            </div>
            <div class="bg-darksurface border border-bordercolor rounded-[24px] p-5 flex items-center gap-4 shadow-xl">
                <div class="w-12 h-12 rounded-2xl bg-success/10 flex items-center justify-center text-success text-xl">
                    <i class="fa-solid fa-circle-check"></i>
                </div>
                <div class="flex flex-col">
                    <span class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Success</span>
                    <span class="text-2xl font-black text-success mt-0.5" id="statSuccess">0</span>
                </div>
            </div>
            <div class="bg-darksurface border border-bordercolor rounded-[24px] p-5 flex items-center gap-4 shadow-xl">
                <div class="w-12 h-12 rounded-2xl bg-warning/10 flex items-center justify-center text-warning text-xl">
                    <i class="fa-solid fa-forward"></i>
                </div>
                <div class="flex flex-col">
                    <span class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Skipped (Exists)</span>
                    <span class="text-2xl font-black text-warning mt-0.5" id="statSkipped">0</span>
                </div>
            </div>
            <div class="bg-darksurface border border-bordercolor rounded-[24px] p-5 flex items-center gap-4 shadow-xl">
                <div class="w-12 h-12 rounded-2xl bg-danger/10 flex items-center justify-center text-danger text-xl">
                    <i class="fa-solid fa-circle-exclamation"></i>
                </div>
                <div class="flex flex-col">
                    <span class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Failed</span>
                    <span class="text-2xl font-black text-danger mt-0.5" id="statFailed">0</span>
                </div>
            </div>
        </div>

        <!-- Progress Bar Card -->
        <div class="bg-darksurface border border-bordercolor rounded-[24px] p-6 shadow-xl flex flex-col gap-4">
            <div class="flex justify-between items-center text-xs font-bold text-white">
                <span id="progressText">Ready to import data...</span>
                <span id="progressPercent">0%</span>
            </div>
            <div class="w-full h-3 bg-white/5 rounded-full overflow-hidden border border-bordercolor">
                <div class="h-full bg-gradient-to-r from-primary to-secondary w-0 transition-all duration-300 rounded-full" id="progressBar"></div>
            </div>
        </div>

        <!-- Details Grid: Left Log, Right Dataset Preview -->
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 flex-1 min-h-[350px]">
            <!-- Left: Execution Log (2 Cols) -->
            <div class="lg:col-span-2 bg-darksurface border border-bordercolor rounded-[24px] p-6 shadow-xl flex flex-col h-full">
                <div class="flex items-center justify-between mb-4">
                    <h3 class="text-sm font-extrabold text-white uppercase tracking-wider flex items-center gap-2">
                        <i class="fa-solid fa-terminal text-primary"></i> Execution Log
                    </h3>
                    <button class="bg-white/5 hover:bg-white/10 text-textsecondary hover:text-white text-xs px-3 py-1.5 rounded-lg border border-bordercolor transition duration-200" onclick="clearLog()">Clear Log</button>
                </div>
                <div class="flex-1 bg-black/40 rounded-2xl p-4 font-mono text-[10px] text-textsecondary overflow-y-auto max-h-[400px] border border-bordercolor flex flex-col gap-1.5" id="executionLog">
                    <span class="text-textmuted">[SYSTEM] Initialized. Waiting for start...</span>
                </div>
            </div>

            <!-- Right: Dataset Preview (1 Col) -->
            <div class="bg-darksurface border border-bordercolor rounded-[24px] p-6 shadow-xl flex flex-col h-full">
                <h3 class="text-sm font-extrabold text-white uppercase tracking-wider mb-4 flex items-center gap-2">
                    <i class="fa-solid fa-table-list text-secondary"></i> Dataset Preview
                </h3>
                <div class="flex-1 overflow-y-auto max-h-[400px] flex flex-col gap-3 pr-2" id="datasetPreview">
                    <div class="text-center text-textmuted py-12 text-xs">
                        <i class="fa-solid fa-spinner fa-spin text-lg mb-2 block"></i> Loading dataset preview...
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>

<!-- Firebase Config & Helper functions -->
<script src="/assets/js/firebase-config.js"></script>

<script>
let clinicsData = [];
let chillerModelId = "";

// The 7 unique versions present in the spreadsheet
const CHILLER_VERSIONS = [
    { versionName: "Chiller SW25 UI11", swVer: "25", uiVer: "11", ntcVer: "100k", pcbVer: "1.1", ssr: "yes" },
    { versionName: "Chiller SW26 UI15 P1.1", swVer: "26", uiVer: "15", ntcVer: "100k", pcbVer: "1.1", ssr: "yes" },
    { versionName: "Chiller SW26 UI15 P2.1", swVer: "26", uiVer: "15", ntcVer: "100k", pcbVer: "2.1", ssr: "yes" },
    { versionName: "Chiller SW25 UI10 EG", swVer: "25", uiVer: "10", ntcVer: "100k eg", pcbVer: "1.1", ssr: "yes" },
    { versionName: "Chiller SW26 UI15 SSR-NO", swVer: "26", uiVer: "15", ntcVer: "100k", pcbVer: "2.1", ssr: "NO" },
    { versionName: "Chiller SW25 UI10", swVer: "25", uiVer: "10", ntcVer: "100k", pcbVer: "1.1", ssr: "yes" },
    { versionName: "Chiller SW25 UI10 Old", swVer: "25", uiVer: "10", ntcVer: "10k old", pcbVer: "1.1", ssr: "yes" }
];

document.addEventListener('DOMContentLoaded', () => {
    loadDatasetPreview();
});

async function loadDatasetPreview() {
    const previewContainer = document.getElementById('datasetPreview');
    try {
        const response = await fetch('resolved_clinics.json');
        clinicsData = await response.json();
        
        document.getElementById('statTotal').textContent = clinicsData.length;
        
        previewContainer.innerHTML = '';
        clinicsData.slice(0, 10).forEach(c => {
            const card = document.createElement('div');
            card.className = 'bg-white/5 border border-bordercolor rounded-xl p-3.5 flex flex-col gap-1.5';
            card.innerHTML = `
                <div class="flex items-center justify-between">
                    <span class="text-xs font-bold text-white">${escapeHtml(c.clinicName)}</span>
                    <span class="text-[10px] font-bold bg-primary/10 text-primary px-1.5 py-0.5 rounded border border-primary/20">SN: ${escapeHtml(c.serialNo)}</span>
                </div>
                <div class="text-[10px] text-textsecondary flex flex-col gap-0.5">
                    <span>Doctor: Dr. ${escapeHtml(c.firstName)} ${escapeHtml(c.lastName)}</span>
                    <span>Email: ${escapeHtml(c.email)}</span>
                    <span>Specs: SW ${c.swVer} / UI ${c.uiVer} / NTC ${c.ntcVer} / PCB ${c.pcbVer} / SSR ${c.ssr}</span>
                </div>
            `;
            previewContainer.appendChild(card);
        });
        
        if (clinicsData.length > 10) {
            const more = document.createElement('div');
            more.className = 'text-center text-[10px] text-textmuted py-2 font-bold uppercase tracking-wider';
            more.textContent = `+ ${clinicsData.length - 10} more clinics`;
            previewContainer.appendChild(more);
        }
        
        logMessage("Preview loaded successfully. Ready to import.");
    } catch (err) {
        console.error(err);
        previewContainer.innerHTML = `
            <div class="text-center text-danger py-12 text-xs">
                <i class="fa-solid fa-triangle-exclamation text-lg mb-2 block"></i>
                Failed to load resolved_clinics.json
            </div>
        `;
        logMessage(`[ERROR] Failed to load dataset: ${err.message}`, 'error');
    }
}

function logMessage(text, type = 'system') {
    const logContainer = document.getElementById('executionLog');
    const span = document.createElement('span');
    
    let colorClass = 'text-textsecondary';
    if (type === 'success') colorClass = 'text-success';
    if (type === 'warning') colorClass = 'text-warning';
    if (type === 'error') colorClass = 'text-danger font-bold';
    
    const timeStr = new Date().toLocaleTimeString();
    span.className = `${colorClass}`;
    span.innerHTML = `[${timeStr}] [${type.toUpperCase()}] ${text}`;
    logContainer.appendChild(span);
    logContainer.scrollTop = logContainer.scrollHeight;
}

function clearLog() {
    document.getElementById('executionLog').innerHTML = '';
}

function escapeHtml(text) {
    if (!text) return '';
    return text.toString().replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
}

function withTimeout(promise, ms, errorMessage = "Operation timed out") {
    const timeout = new Promise((_, reject) =>
        setTimeout(() => reject(new Error(errorMessage)), ms)
    );
    return Promise.race([promise, timeout]);
}

/**
 * Main import controller
 */
async function startImport() {
    if (clinicsData.length === 0) {
        showToast("No dataset loaded to import.", "error");
        return;
    }
    
    const startBtn = document.getElementById('startImportBtn');
    startBtn.disabled = true;
    
    logMessage("Starting import process...", "system");
    
    // 1. Verify/Create "Chiller" catalog device model
    try {
        logMessage("Verifying Chiller device catalog model exists...", "system");
        
        const devicesSnapshot = await withTimeout(rtdb.ref('devices').once('value'), 5000);
        const devices = devicesSnapshot.val();
        let existingChillerKey = "";
        
        if (devices) {
            Object.keys(devices).forEach(k => {
                if (devices[k].name === "Chiller") {
                    existingChillerKey = k;
                }
            });
        }
        
        if (existingChillerKey) {
            chillerModelId = existingChillerKey;
            logMessage(`Chiller device catalog model exists with ID: ${chillerModelId}`, "success");
        } else {
            logMessage("Chiller model not found. Registering in global catalog...", "system");
            const newRef = rtdb.ref('devices').push();
            const chillerPayload = {
                name: "Chiller",
                description: "Industrial Cooling and Chiller System",
                imageUrl: "",
                versions: CHILLER_VERSIONS
            };
            await withTimeout(newRef.set(chillerPayload), 5000);
            chillerModelId = newRef.key;
            logMessage(`Chiller catalog model registered successfully with ID: ${chillerModelId}`, "success");
        }
    } catch (err) {
        logMessage(`[FATAL] Catalog verification failed: ${err.message}`, "error");
        showToast("Import cancelled. Catalog setup failed.", "error");
        startBtn.disabled = false;
        return;
    }
    
    // 2. Loop and import each clinic
    let successCount = 0;
    let skippedCount = 0;
    let failedCount = 0;
    
    const total = clinicsData.length;
    const progressBar = document.getElementById('progressBar');
    const progressPercent = document.getElementById('progressPercent');
    const progressText = document.getElementById('progressText');
    
    const secondaryApp = firebase.initializeApp(firebaseConfig, "ImportAuthApp");
    const secondaryAuth = secondaryApp.auth();
    
    for (let i = 0; i < total; i++) {
        const c = clinicsData[i];
        logMessage(`Processing clinic [${i+1}/${total}]: ${c.clinicName} (SN: ${c.serialNo})...`, "system");
        
        try {
            // Check if clinic already exists by searching email in Firestore or RTDB
            let alreadyExists = false;
            try {
                const querySnapshot = await withTimeout(db.collection('users').where('email', '==', c.email).get(), 3000);
                if (querySnapshot && !querySnapshot.empty) {
                    alreadyExists = true;
                }
            } catch (fsErr) {
                // Fallback to RTDB check
                const rtdbSnapshot = await withTimeout(rtdb.ref('users').orderByChild('email').equalTo(c.email).once('value'), 3000);
                if (rtdbSnapshot.exists()) {
                    alreadyExists = true;
                }
            }
            
            if (alreadyExists) {
                skippedCount++;
                document.getElementById('statSkipped').textContent = skippedCount;
                logMessage(`Clinic ${c.email} already exists. Skipping.`, "warning");
                updateProgress(i + 1, total, progressBar, progressPercent, progressText, `Skipped: ${c.clinicName}`);
                continue;
            }
            
            // Create Firebase Auth credentials
            let uid = "";
            try {
                const credential = await withTimeout(
                    secondaryAuth.createUserWithEmailAndPassword(c.email, c.password),
                    6000,
                    "Auth account creation timed out."
                );
                uid = credential.user.uid;
            } catch (authError) {
                // If Auth email exists, try to resolve its UID by sign-in
                if (authError.code === 'auth/email-already-in-use') {
                    const credential = await withTimeout(
                        secondaryAuth.signInWithEmailAndPassword(c.email, c.password),
                        6000,
                        "Auth sign-in check timed out."
                    );
                    uid = credential.user.uid;
                } else {
                    throw authError;
                }
            }
            
            // Match specs version to naming version name
            let versionName = "Chiller SW25 UI10";
            const matchedVer = CHILLER_VERSIONS.find(v => 
                v.swVer === c.swVer && v.uiVer === c.uiVer && 
                v.ntcVer === c.ntcVer && v.pcbVer === c.pcbVer && v.ssr === c.ssr
            );
            if (matchedVer) {
                versionName = matchedVer.versionName;
            }
            
            // Payloads
            const profilePayload = {
                uid: uid,
                email: c.email,
                phoneNumber: c.phoneNumber,
                clinicName: c.clinicName,
                firstName: c.firstName,
                lastName: c.lastName,
                address: c.address,
                latitude: c.latitude,
                longitude: c.longitude
            };
            
            const devicePayload = {
                deviceId: chillerModelId,
                deviceName: "Chiller",
                deviceVersion: versionName,
                imageUrl: "",
                swVer: c.swVer,
                uiVer: c.uiVer,
                ntcVer: c.ntcVer,
                pcbVer: c.pcbVer,
                ssr: c.ssr,
                serialNo: c.serialNo,
                installingDate: c.installingDate,
                endWarranty: c.endWarranty
            };
            
            profilePayload.device = devicePayload;
            
            // Save to Firestore and RTDB
            let firestoreSuccess = false;
            let rtdbSuccess = false;
            
            try {
                await withTimeout(db.collection('users').doc(uid).set(profilePayload), 5000);
                firestoreSuccess = true;
            } catch (fsErr) {
                console.warn("Firestore save failed in import:", fsErr);
            }
            
            try {
                await withTimeout(rtdb.ref(`users/${uid}`).set(profilePayload), 5000);
                rtdbSuccess = true;
            } catch (rtdbErr) {
                console.warn("RTDB save failed in import:", rtdbErr);
            }
            
            if (firestoreSuccess || rtdbSuccess) {
                successCount++;
                document.getElementById('statSuccess').textContent = successCount;
                logMessage(`Clinic "${c.clinicName}" imported successfully. [UID: ${uid}]`, "success");
            } else {
                throw new Error("Failed to write to both databases.");
            }
            
        } catch (clinicErr) {
            failedCount++;
            document.getElementById('statFailed').textContent = failedCount;
            logMessage(`[ERROR] Failed importing clinic ${c.clinicName}: ${clinicErr.message}`, "error");
        }
        
        updateProgress(i + 1, total, progressBar, progressPercent, progressText, `Processing: ${c.clinicName}`);
        
        // Minor cooldown between iterations
        await new Promise(resolve => setTimeout(resolve, 150));
    }
    
    // Cleanup Auth instance
    await secondaryApp.delete();
    
    logMessage(`Import process completed. Success: ${successCount} | Skipped: ${skippedCount} | Failed: ${failedCount}`, "success");
    showToast("Import process completed!");
    startBtn.disabled = false;
}

function updateProgress(curr, total, bar, percentText, logText, currentOperation) {
    const percent = Math.round((curr / total) * 100);
    bar.style.width = `${percent}%`;
    percentText.textContent = `${percent}%`;
    logText.textContent = `Completed ${curr}/${total} | ${currentOperation}`;
}
</script>

<?php
require_once __DIR__ . '/includes/footer.php';
?>
