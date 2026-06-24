/**
 * Feedbacks Controller Script
 * Extreme Medical Web Administration
 */

let allFeedbacks = [];
let arabicFontBase64 = null;

document.addEventListener('DOMContentLoaded', () => {
    // 1. Load Arabic Font for PDF export
    loadArabicFont();

    // 2. Hook feedbacks stream
    initializeRealtimeFeedbacks();

    // 3. Search input bind
    document.getElementById('feedbackSearchInput').addEventListener('input', filterFeedbacksTable);
});

/**
 * Fetch Amiri font dynamically from CDN, convert to Base64, and register to pdfMake
 */
async function loadArabicFont() {
    try {
        const fontUrl = 'https://cdn.jsdelivr.net/gh/google/fonts@main/ofl/amiri/Amiri-Regular.ttf';
        console.log("Loading Arabic Amiri font from CDN...");
        const response = await fetch(fontUrl);
        const arrayBuffer = await response.arrayBuffer();
        
        let binary = '';
        const bytes = new Uint8Array(arrayBuffer);
        const len = bytes.byteLength;
        for (let i = 0; i < len; i++) {
            binary += String.fromCharCode(bytes[i]);
        }
        arabicFontBase64 = window.btoa(binary);
        console.log("Arabic Amiri font loaded successfully!");
        
        if ($.fn.DataTable.isDataTable('#feedbacksTable') && allFeedbacks.length > 0) {
            renderFeedbacksTable(allFeedbacks);
        }
    } catch (err) {
        console.error("Failed to load Arabic font for PDF export:", err);
    }
}

function initializeRealtimeFeedbacks() {
    const tableBody = document.getElementById('feedbacksTableBody');
    const feedbacksRef = rtdb.ref('feedbacks');
    
    feedbacksRef.on('value', (snapshot) => {
        const data = snapshot.val();
        
        if (!data) {
            allFeedbacks = [];
            tableBody.innerHTML = `
                <tr>
                    <td colspan="7" class="p-4 border-b border-bordercolor text-xs text-textmuted text-center py-10">
                        <i class="fa-solid fa-star text-2xl mb-2 block text-textsecondary"></i>
                        No feedbacks submitted yet.
                    </td>
                </tr>
            `;
            return;
        }
        
        allFeedbacks = [];
        Object.keys(data).forEach(key => {
            const fb = data[key];
            allFeedbacks.push({
                id: key,
                userId: fb.userId || 'N/A',
                userName: fb.userName || 'Unknown Staff',
                userEmail: fb.userEmail || 'N/A',
                rating: fb.rating || 5,
                comment: fb.comment || '',
                timestamp: fb.timestamp || null
            });
        });
        
        // Sort by timestamp descending
        allFeedbacks.sort((a, b) => (b.timestamp || 0) - (a.timestamp || 0));
        
        renderFeedbacksTable(allFeedbacks);
    }, (error) => {
        console.error("Error streaming feedbacks:", error);
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

function renderFeedbacksTable(list) {
    let currentSearch = '';
    let currentPage = 0;
    let hasDataTable = $.fn.DataTable.isDataTable('#feedbacksTable');
    if (hasDataTable) {
        const api = $('#feedbacksTable').DataTable();
        currentSearch = api.search();
        currentPage = api.page();
        api.destroy();
    }

    const tableBody = document.getElementById('feedbacksTableBody');
    tableBody.innerHTML = '';
    
    if (list.length === 0) {
        tableBody.innerHTML = `
            <tr>
                <td colspan="7" class="p-4 border-b border-bordercolor text-xs text-textmuted text-center py-10">
                    No matching feedbacks found.
                </td>
            </tr>
        `;
        return;
    }
    
    list.forEach((fb, index) => {
        const row = document.createElement('tr');
        row.className = 'group hover:bg-white/5 transition duration-150';
        
        // Render rating stars
        let starsHtml = '';
        for (let i = 1; i <= 5; i++) {
            if (fb.rating >= i) {
                starsHtml += '<i class="fa-solid fa-star text-warning text-xs mr-0.5"></i>';
            } else {
                starsHtml += '<i class="fa-regular fa-star text-white/20 text-xs mr-0.5"></i>';
            }
        }

        // Render date
        let dateStr = 'N/A';
        if (fb.timestamp) {
            const date = new Date(fb.timestamp);
            dateStr = date.toLocaleDateString() + ' ' + date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
        }

        row.innerHTML = `
            <td class="p-4 border-b border-bordercolor text-xs text-white text-center"><span class="inline-flex items-center justify-center w-6 h-6 rounded-full bg-white/5 border border-bordercolor text-textsecondary text-[10px] font-bold transition duration-200 group-hover:bg-gradient-to-tr group-hover:from-primary group-hover:to-secondary group-hover:text-white group-hover:border-transparent group-hover:shadow-primaryglow">${index + 1}</span></td>
            <td class="p-4 border-b border-bordercolor text-xs text-white"><strong>${escapeHtml(fb.userName)}</strong></td>
            <td class="p-4 border-b border-bordercolor text-xs text-white">${escapeHtml(fb.userEmail)}</td>
            <td class="p-4 border-b border-bordercolor text-xs text-center whitespace-nowrap" data-rating="${fb.rating}">${starsHtml}</td>
            <td class="p-4 border-b border-bordercolor text-xs text-white max-w-xs overflow-hidden text-ellipsis">${escapeHtml(fb.comment)}</td>
            <td class="p-4 border-b border-bordercolor text-xs text-white">${dateStr}</td>
            <td class="p-4 border-b border-bordercolor text-xs text-white text-center whitespace-nowrap">
                <button class="bg-danger/10 text-danger hover:bg-danger hover:text-white border-none cursor-pointer text-sm p-2 rounded-lg transition duration-200" title="Delete Feedback" onclick="confirmDeleteFeedback('${fb.id}', '${escapeHtml(fb.userName)}')">
                    <i class="fa-solid fa-trash-can"></i>
                </button>
            </td>
        `;
        tableBody.appendChild(row);
    });

    if (arabicFontBase64) {
        pdfMake.vfs = pdfMake.vfs || {};
        pdfMake.vfs['Amiri-Regular.ttf'] = arabicFontBase64;
        pdfMake.fonts = {
            Amiri: {
                normal: 'Amiri-Regular.ttf',
                bold: 'Amiri-Regular.ttf',
                italics: 'Amiri-Regular.ttf',
                bolditalics: 'Amiri-Regular.ttf'
            }
        };
    }

    const exportFormat = {
        body: function (data, row, column, node) {
            if (column === 3) {
                return node.getAttribute('data-rating') + ' / 5 Stars';
            }
            if (column === 1) {
                return node.textContent || node.innerText || data;
            }
            return data;
        }
    };

    const dtInstance = $('#feedbacksTable').DataTable({
        responsive: true,
        searching: true,
        info: true,
        paging: true,
        pageLength: 10,
        order: [],
        dom: 'Brtip',
        buttons: [
            {
                extend: 'copyHtml5',
                text: '<i class="fa-solid fa-copy"></i> Copy',
                titleAttr: 'Copy to Clipboard',
                className: 'bg-gradient-to-tr from-primary/80 to-secondary/80 text-white font-bold text-xs px-4 py-2.5 rounded-xl hover:-translate-y-0.5 hover:shadow-primaryglow transition duration-200 cursor-pointer flex items-center gap-1.5 border-none',
                exportOptions: {
                    columns: [1, 2, 3, 4, 5],
                    format: exportFormat
                }
            },
            {
                extend: 'excelHtml5',
                text: '<i class="fa-solid fa-file-excel"></i> Excel',
                titleAttr: 'Export to Excel (.xlsx)',
                className: 'bg-gradient-to-tr from-green-600/80 to-emerald-600/80 text-white font-bold text-xs px-4 py-2.5 rounded-xl hover:-translate-y-0.5 hover:shadow-primaryglow transition duration-200 cursor-pointer flex items-center gap-1.5 border-none',
                filename: 'feedbacks_report_' + new Date().toISOString().slice(0, 10),
                exportOptions: {
                    columns: [1, 2, 3, 4, 5],
                    format: exportFormat
                }
            },
            {
                extend: 'pdfHtml5',
                text: '<i class="fa-solid fa-file-pdf"></i> PDF',
                titleAttr: 'Export to PDF (.pdf)',
                className: 'bg-gradient-to-tr from-red-600/80 to-pink-600/80 text-white font-bold text-xs px-4 py-2.5 rounded-xl hover:-translate-y-0.5 hover:shadow-primaryglow transition duration-200 cursor-pointer flex items-center gap-1.5 border-none',
                filename: 'feedbacks_report_' + new Date().toISOString().slice(0, 10),
                exportOptions: {
                    columns: [1, 2, 3, 4, 5],
                    format: exportFormat
                },
                customize: function(doc) {
                    if (arabicFontBase64) {
                        doc.defaultStyle.font = 'Amiri';
                        if (doc.content && doc.content.length > 1) {
                            const tableBody = doc.content[1].table.body;
                            tableBody.forEach(row => {
                                row.forEach(cell => {
                                    cell.alignment = 'right';
                                });
                            });
                        }
                    }
                }
            },
            {
                extend: 'print',
                text: '<i class="fa-solid fa-print"></i> Print',
                titleAttr: 'Print Table',
                className: 'bg-gradient-to-tr from-blue-600/80 to-cyan-600/80 text-white font-bold text-xs px-4 py-2.5 rounded-xl hover:-translate-y-0.5 hover:shadow-primaryglow transition duration-200 cursor-pointer flex items-center gap-1.5 border-none',
                exportOptions: {
                    columns: [1, 2, 3, 4, 5],
                    format: exportFormat
                }
            }
        ]
    });

    document.getElementById('buttonsContainer').innerHTML = '';
    dtInstance.buttons().container().appendTo('#buttonsContainer');

    if (hasDataTable) {
        if (currentSearch) {
            dtInstance.search(currentSearch).draw(false);
        }
        if (currentPage) {
            dtInstance.page(currentPage).draw(false);
        }
    }
}

function filterFeedbacksTable() {
    const query = document.getElementById('feedbackSearchInput').value.trim();
    if ($.fn.DataTable.isDataTable('#feedbacksTable')) {
        $('#feedbacksTable').DataTable().search(query).draw();
    }
}

async function confirmDeleteFeedback(id, name) {
    const title = "Delete Feedback Record";
    const message = `Are you sure you want to permanently delete the feedback submitted by "${name}"?`;
    const confirmed = await showCustomConfirm(title, message, 'danger');
    if (confirmed) {
        deleteFeedback(id);
    }
}

async function deleteFeedback(id) {
    try {
        await rtdb.ref(`feedbacks/${id}`).remove();
        showToast("Feedback deleted successfully.");
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
