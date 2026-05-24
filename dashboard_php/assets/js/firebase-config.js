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
        alertEl.className = 'custom-alert';
        alertEl.innerHTML = '<span class="alert-message" id="alertMessage"></span>';
        document.body.appendChild(alertEl);
    }
    
    const messageEl = document.getElementById('alertMessage');
    messageEl.textContent = message;
    
    // Reset and add style
    alertEl.className = `custom-alert ${type}`;
    
    // Slide in
    alertEl.classList.add('active');
    
    // Slide out
    setTimeout(() => {
        alertEl.classList.remove('active');
    }, 4500);
}
