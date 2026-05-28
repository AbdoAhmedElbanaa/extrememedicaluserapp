/**
 * Dashboard Client Controller
 * Extreme Medical Web Administration
 */

let registrationsChart = null;

document.addEventListener('DOMContentLoaded', () => {
    // 1. Establish database connection listener
    initializeRealtimeDashboard();
});

function initializeRealtimeDashboard() {
    const totalEl = document.getElementById('statTotalClinics');
    const mappedEl = document.getElementById('statMappedClinics');
    const authEl = document.getElementById('statActiveAccounts');
    const tableBody = document.getElementById('recentClinicsTableBody');
    const syncDesc = document.getElementById('syncStatusDesc');
    const connectionDesc = document.getElementById('activeConnectionDesc');
    
    // Connect to Realtime Database "users" node
    const usersRef = rtdb.ref('users');
    
    connectionDesc.textContent = "Connecting to WebSocket...";
    
    usersRef.on('value', (snapshot) => {
        const data = snapshot.val();
        
        connectionDesc.textContent = "Active WebSocket Connection";
        syncDesc.textContent = "Listening for live database changes...";
        
        if (!data) {
            totalEl.textContent = "0";
            mappedEl.textContent = "0";
            authEl.textContent = "0";
            tableBody.innerHTML = `
                <tr>
                    <td colspan="6" class="p-4 border-b border-bordercolor text-xs text-textmuted text-center py-10">
                        <i class="fa-solid fa-folder-open text-2xl mb-2 block"></i>
                        No registered clinics found.
                    </td>
                </tr>
            `;
            updateDashboardCharts([]);
            return;
        }
        
        // Convert map of users to an array
        const usersList = [];
        Object.keys(data).forEach(key => {
            const user = data[key];
            usersList.push({
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
        
        // 2. Aggregate statistics
        const totalClinics = usersList.length;
        const mappedClinics = usersList.filter(u => u.latitude !== null && u.longitude !== null).length;
        
        // Update stats
        totalEl.textContent = totalClinics;
        mappedEl.textContent = mappedClinics;
        authEl.textContent = totalClinics; // each clinic has a Firebase Auth account
        
        // 3. Populate Recent Clinic List (limit to 5)
        // Since Firebase RTDB keys are UIDs (not chronological), we show the first 5 or reverse list
        const recentUsers = usersList.slice(-5).reverse();
        
        tableBody.innerHTML = '';
        recentUsers.forEach((user, index) => {
            const hasLocation = user.latitude !== null && user.longitude !== null;
            const badgeClass = hasLocation 
                ? 'bg-success/15 text-success'
                : 'bg-danger/15 text-danger';
            const badgeIcon = hasLocation
                ? '<i class="fa-solid fa-location-dot text-[8px]"></i>'
                : '<i class="fa-solid fa-location-pin-slash text-[8px]"></i>';
            const statusBadgeHtml = `<span class="px-2.5 py-1 rounded-lg text-[10px] font-bold inline-flex items-center gap-1.5 ${badgeClass}">${badgeIcon} ${hasLocation ? 'Configured' : 'Unmapped'}</span>`;
                
            const row = document.createElement('tr');
            row.className = 'group hover:bg-white/5 transition duration-150';
            row.innerHTML = `
                <td class="p-4 border-b border-bordercolor text-xs text-white text-center"><span class="inline-flex items-center justify-center w-6 h-6 rounded-full bg-white/5 border border-bordercolor text-textsecondary text-[10px] font-bold transition duration-200 group-hover:bg-gradient-to-tr group-hover:from-primary group-hover:to-secondary group-hover:text-white group-hover:border-transparent group-hover:shadow-primaryglow">${index + 1}</span></td>
                <td class="p-4 border-b border-bordercolor text-xs text-white"><strong>${escapeHtml(user.clinicName)}</strong></td>
                <td class="p-4 border-b border-bordercolor text-xs text-white">Dr. ${escapeHtml(user.firstName)} ${escapeHtml(user.lastName)}</td>
                <td class="p-4 border-b border-bordercolor text-xs text-white">${escapeHtml(user.phoneNumber)}</td>
                <td class="p-4 border-b border-bordercolor text-xs text-white">${escapeHtml(user.email)}</td>
                <td class="p-4 border-b border-bordercolor text-xs text-white">${statusBadgeHtml}</td>
            `;
            tableBody.appendChild(row);
        });
        
        // 4. Update registrations chart
        updateDashboardCharts(usersList);
        
    }, (error) => {
        console.error("Firebase Database read error:", error);
        syncDesc.textContent = "Sync failed. Reconnecting...";
        connectionDesc.textContent = "Authentication / Rule Error";
        document.getElementById('dbStatusBadge').className = "status-badge danger";
        document.getElementById('dbStatusBadge').innerHTML = '<i class="fa-solid fa-circle"></i> Error';
        showToast("Failed to stream real-time data: " + error.message, "error");
    });
}

function updateDashboardCharts(users) {
    const ctx = document.getElementById('registrationsChart').getContext('2d');
    
    // Group clinics by cities parsed from their address
    const cityGroups = {
        'Cairo': 0,
        'Giza': 0,
        'Alexandria': 0,
        'Mansoura': 0,
        'Other Cities': 0
    };
    
    users.forEach(user => {
        const addr = (user.address || '').toLowerCase();
        if (addr.includes('cairo') || addr.includes('القاهرة')) {
            cityGroups['Cairo']++;
        } else if (addr.includes('giza') || addr.includes('الجيزة')) {
            cityGroups['Giza']++;
        } else if (addr.includes('alexandria') || addr.includes('الاسكندرية') || addr.includes('الإسكندرية')) {
            cityGroups['Alexandria']++;
        } else if (addr.includes('mansoura') || addr.includes('المنصورة')) {
            cityGroups['Mansoura']++;
        } else {
            cityGroups['Other Cities']++;
        }
    });
    
    const labels = Object.keys(cityGroups);
    const data = Object.values(cityGroups);
    
    if (registrationsChart) {
        registrationsChart.destroy();
    }
    
    registrationsChart = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [{
                label: 'Clinics Registered',
                data: data,
                backgroundColor: [
                    'rgba(99, 102, 241, 0.65)',
                    'rgba(168, 85, 247, 0.65)',
                    'rgba(16, 185, 129, 0.65)',
                    'rgba(245, 158, 11, 0.65)',
                    'rgba(100, 116, 139, 0.65)'
                ],
                borderColor: [
                    '#6366f1',
                    '#a855f7',
                    '#10b981',
                    '#f59e0b',
                    '#64748b'
                ],
                borderWidth: 1.5,
                borderRadius: 8
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: false
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    grid: {
                        color: 'rgba(255, 255, 255, 0.05)'
                    },
                    ticks: {
                        color: '#94a3b8',
                        precision: 0
                    }
                },
                x: {
                    grid: {
                        display: false
                    },
                    ticks: {
                        color: '#94a3b8'
                    }
                }
            }
        }
    });
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
