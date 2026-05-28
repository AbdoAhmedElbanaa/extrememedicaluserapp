/**
 * Firebase Client Config & Initialization
 * Extreme Medical Web Administration
 */

const firebaseConfig = {
    apiKey: "AIzaSyBj0Ql_flqq_rf53ErUJI0nDuCUauufq94",
    authDomain: "extremecool-app.firebaseapp.com",
    projectId: "extremecool-app",
    databaseURL: "https://extremecool-app-default-rtdb.firebaseio.com",
    storageBucket: "extremecool-app.firebasestorage.app",
    messagingSenderId: "2089029110",
    appId: "1:2089029110:web:493ecf6036ffa749944bd7",
    measurementId: "G-ZNDYER78ZR"
};

// Initialize Firebase globally
const app = firebase.initializeApp(firebaseConfig);

// Services
const auth = firebase.auth();
const db = firebase.firestore();
const rtdb = firebase.database();

/**
 * Toast Notification Helper
 */
function showToast(message, type = 'success') {
    let alertEl = document.getElementById('customAlert');
    if (!alertEl) {
        alertEl = document.createElement('div');
        alertEl.id = 'customAlert';
        alertEl.className = 'fixed top-5 right-5 z-[2000] flex items-center gap-3 px-4 py-3 rounded-2xl border backdrop-blur-md shadow-xl translate-x-[120%] opacity-0 transition-all duration-300 pointer-events-none';
        alertEl.innerHTML = `
            <div class="w-5 h-5 rounded-full flex items-center justify-center text-xs" id="alertIcon"></div>
            <span class="text-xs font-semibold text-white" id="alertMessage"></span>
        `;
        document.body.appendChild(alertEl);
    }
    
    const messageEl = document.getElementById('alertMessage');
    const iconEl = document.getElementById('alertIcon');
    messageEl.textContent = message;
    
    // Set colors & icons based on type
    if (type === 'success') {
        alertEl.className = 'fixed top-5 right-5 z-[2000] flex items-center gap-3 px-4 py-3 rounded-2xl border border-success/20 bg-success/15 backdrop-blur-md shadow-xl translate-x-[120%] opacity-0 transition-all duration-300 pointer-events-none';
        iconEl.className = 'w-5 h-5 rounded-full flex items-center justify-center text-xs bg-success text-white';
        iconEl.innerHTML = '<i class="fa-solid fa-check"></i>';
    } else if (type === 'error' || type === 'danger') {
        alertEl.className = 'fixed top-5 right-5 z-[2000] flex items-center gap-3 px-4 py-3 rounded-2xl border border-danger/20 bg-danger/15 backdrop-blur-md shadow-xl translate-x-[120%] opacity-0 transition-all duration-300 pointer-events-none';
        iconEl.className = 'w-5 h-5 rounded-full flex items-center justify-center text-xs bg-danger text-white';
        iconEl.innerHTML = '<i class="fa-solid fa-exclamation"></i>';
    } else if (type === 'warning') {
        alertEl.className = 'fixed top-5 right-5 z-[2000] flex items-center gap-3 px-4 py-3 rounded-2xl border border-warning/20 bg-warning/15 backdrop-blur-md shadow-xl translate-x-[120%] opacity-0 transition-all duration-300 pointer-events-none';
        iconEl.className = 'w-5 h-5 rounded-full flex items-center justify-center text-xs bg-warning text-white';
        iconEl.innerHTML = '<i class="fa-solid fa-triangle-exclamation"></i>';
    } else {
        alertEl.className = 'fixed top-5 right-5 z-[2000] flex items-center gap-3 px-4 py-3 rounded-2xl border border-primary/20 bg-primary/15 backdrop-blur-md shadow-xl translate-x-[120%] opacity-0 transition-all duration-300 pointer-events-none';
        iconEl.className = 'w-5 h-5 rounded-full flex items-center justify-center text-xs bg-primary text-white';
        iconEl.innerHTML = '<i class="fa-solid fa-info"></i>';
    }
    
    // Slide in
    setTimeout(() => {
        alertEl.classList.remove('translate-x-[120%]', 'opacity-0', 'pointer-events-none');
        alertEl.classList.add('translate-x-0', 'opacity-100');
    }, 50);
    
    // Slide out
    setTimeout(() => {
        alertEl.classList.remove('translate-x-0', 'opacity-100');
        alertEl.classList.add('translate-x-[120%]', 'opacity-0', 'pointer-events-none');
    }, 4500);
}

/**
 * Custom Premium Dialog Helpers (Alert / Confirm)
 */
function getOrCreateCustomDialogDOM() {
    let overlay = document.getElementById('customDialogOverlay');
    if (!overlay) {
        overlay = document.createElement('div');
        overlay.id = 'customDialogOverlay';
        overlay.className = 'fixed inset-0 bg-darkbg/80 backdrop-blur-md flex items-center justify-center z-[3000] opacity-0 pointer-events-none transition-all duration-300';
        overlay.innerHTML = `
            <div class="bg-darksec border border-bordercolor rounded-[28px] w-[90%] max-w-[420px] p-8 shadow-2xl flex flex-col items-center text-center transform scale-90 transition-transform duration-300" id="customDialogCard">
                <div class="w-14 h-14 rounded-2xl flex items-center justify-center text-2xl mb-4" id="customDialogIcon">
                    <i class="fa-solid fa-circle-info"></i>
                </div>
                <h3 class="text-lg font-extrabold text-white mb-2 leading-tight" id="customDialogTitle">Notification</h3>
                <p class="text-xs text-textsecondary leading-relaxed mb-6" id="customDialogMessage"></p>
                <div class="flex items-center justify-center gap-3.5 w-full" id="customDialogFooter">
                    <button class="flex-1 bg-transparent border border-bordercolor text-textsecondary px-4 py-3 rounded-xl text-xs font-bold hover:bg-white/5 hover:text-white transition duration-200 cursor-pointer" id="customDialogCancelBtn">Cancel</button>
                    <button class="flex-1 bg-gradient-to-tr from-primary to-secondary text-white font-bold text-xs px-4 py-3 rounded-xl hover:-translate-y-0.5 hover:shadow-primaryglow transition duration-200 cursor-pointer" id="customDialogConfirmBtn">OK</button>
                </div>
            </div>
        `;
        document.body.appendChild(overlay);
    }
    return overlay;
}

window.showCustomAlert = function(title, message, type = 'info') {
    return new Promise((resolve) => {
        const overlay = getOrCreateCustomDialogDOM();
        const card = document.getElementById('customDialogCard');
        const iconEl = document.getElementById('customDialogIcon');
        const titleEl = document.getElementById('customDialogTitle');
        const messageEl = document.getElementById('customDialogMessage');
        const cancelBtn = document.getElementById('customDialogCancelBtn');
        const confirmBtn = document.getElementById('customDialogConfirmBtn');
        
        let iconHtml = '<i class="fa-solid fa-circle-info"></i>';
        let typeClasses = 'bg-primary/15 text-primary';
        
        if (type === 'success') {
            iconHtml = '<i class="fa-solid fa-circle-check"></i>';
            typeClasses = 'bg-success/15 text-success';
        } else if (type === 'error' || type === 'danger') {
            iconHtml = '<i class="fa-solid fa-circle-exclamation"></i>';
            typeClasses = 'bg-danger/15 text-danger';
        } else if (type === 'warning') {
            iconHtml = '<i class="fa-solid fa-triangle-exclamation"></i>';
            typeClasses = 'bg-warning/15 text-warning';
        }
        
        iconEl.innerHTML = iconHtml;
        iconEl.className = `w-14 h-14 rounded-2xl flex items-center justify-center text-2xl mb-4 ${typeClasses}`;
        titleEl.textContent = title;
        messageEl.textContent = message;
        
        cancelBtn.style.display = 'none';
        confirmBtn.textContent = 'OK';
        confirmBtn.className = 'flex-1 bg-gradient-to-tr from-primary to-secondary text-white font-bold text-xs px-4 py-3 rounded-xl hover:-translate-y-0.5 hover:shadow-primaryglow transition duration-200 cursor-pointer';
        
        // Show
        overlay.classList.remove('opacity-0', 'pointer-events-none');
        card.classList.remove('scale-90');
        card.classList.add('scale-100');
        
        const handleConfirm = () => {
            overlay.classList.add('opacity-0', 'pointer-events-none');
            card.classList.remove('scale-100');
            card.classList.add('scale-90');
            confirmBtn.removeEventListener('click', handleConfirm);
            resolve();
        };
        
        confirmBtn.addEventListener('click', handleConfirm);
    });
};

window.showCustomConfirm = function(title, message, type = 'warning') {
    return new Promise((resolve) => {
        const overlay = getOrCreateCustomDialogDOM();
        const card = document.getElementById('customDialogCard');
        const iconEl = document.getElementById('customDialogIcon');
        const titleEl = document.getElementById('customDialogTitle');
        const messageEl = document.getElementById('customDialogMessage');
        const cancelBtn = document.getElementById('customDialogCancelBtn');
        const confirmBtn = document.getElementById('customDialogConfirmBtn');
        
        let iconHtml = '<i class="fa-solid fa-circle-question"></i>';
        let typeClasses = 'bg-warning/15 text-warning';
        
        if (type === 'danger') {
            iconHtml = '<i class="fa-solid fa-trash-can"></i>';
            typeClasses = 'bg-danger/15 text-danger';
        }
        
        iconEl.innerHTML = iconHtml;
        iconEl.className = `w-14 h-14 rounded-2xl flex items-center justify-center text-2xl mb-4 ${typeClasses}`;
        titleEl.textContent = title;
        messageEl.textContent = message;
        
        cancelBtn.style.display = 'block';
        cancelBtn.textContent = 'Cancel';
        confirmBtn.textContent = 'Confirm';
        if (type === 'danger') {
            confirmBtn.className = 'flex-1 bg-gradient-to-tr from-danger to-secondary text-white font-bold text-xs px-4 py-3 rounded-xl hover:-translate-y-0.5 hover:shadow-dangerglow transition duration-200 cursor-pointer';
        } else {
            confirmBtn.className = 'flex-1 bg-gradient-to-tr from-primary to-secondary text-white font-bold text-xs px-4 py-3 rounded-xl hover:-translate-y-0.5 hover:shadow-primaryglow transition duration-200 cursor-pointer';
        }
        
        // Show
        overlay.classList.remove('opacity-0', 'pointer-events-none');
        card.classList.remove('scale-90');
        card.classList.add('scale-100');
        
        const cleanup = () => {
            overlay.classList.add('opacity-0', 'pointer-events-none');
            card.classList.remove('scale-100');
            card.classList.add('scale-90');
            confirmBtn.removeEventListener('click', handleConfirmClick);
            cancelBtn.removeEventListener('click', handleCancelClick);
        };
        
        const handleConfirmClick = () => {
            cleanup();
            resolve(true);
        };
        
        const handleCancelClick = () => {
            cleanup();
            resolve(false);
        };
        
        confirmBtn.addEventListener('click', handleConfirmClick);
        cancelBtn.addEventListener('click', handleCancelClick);
    });
};

// Hook window.alert and window.confirm globally
window.alert = function(message) {
    showCustomAlert("Notification", message, "info");
};

window.confirm = function(message) {
    console.warn("Synchronous confirm() is deprecated. Please use async showCustomConfirm instead.");
    showCustomAlert("Confirmation", message, "warning");
    return false;
};

/**
 * Global Tailwind Modal & Overlay Display Helpers
 */
window.openModal = function(modalId) {
    const modal = document.getElementById(modalId);
    if (!modal) return;
    modal.classList.remove('opacity-0', 'pointer-events-none');
    modal.classList.add('opacity-100', 'pointer-events-auto');
    const content = modal.querySelector('.modal-content');
    if (content) {
        content.classList.remove('scale-90');
        content.classList.add('scale-100');
    }
};

window.closeModal = function(modalId) {
    const modal = document.getElementById(modalId);
    if (!modal) return;
    modal.classList.add('opacity-0', 'pointer-events-none');
    modal.classList.remove('opacity-100', 'pointer-events-auto');
    const content = modal.querySelector('.modal-content');
    if (content) {
        content.classList.remove('scale-100');
        content.classList.add('scale-90');
    }
};

window.showOverlay = function(overlayId) {
    const overlay = document.getElementById(overlayId);
    if (!overlay) return;
    overlay.classList.remove('opacity-0', 'pointer-events-none');
    overlay.classList.add('opacity-100', 'pointer-events-auto');
};

window.hideOverlay = function(overlayId) {
    const overlay = document.getElementById(overlayId);
    if (!overlay) return;
    overlay.classList.add('opacity-0', 'pointer-events-none');
    overlay.classList.remove('opacity-100', 'pointer-events-auto');
};
