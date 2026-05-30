/**
 * User Manual Management Controller
 * Extreme Medical Web Administration
 */

let allSteps = [];
let currentCategory = '';
let quillEditor = null;

document.addEventListener('DOMContentLoaded', () => {
    // 1. Initialize Quill Rich Text Editor
    initializeQuillEditor();

    // 2. Load data from Firebase Realtime Database
    initializeUserManualSync();
});

/**
 * Initialize Quill Rich Text Editor
 */
function initializeQuillEditor() {
    quillEditor = new Quill('#editor-container', {
        theme: 'snow',
        placeholder: 'Write step instructions, format text, and embed images here...',
        modules: {
            toolbar: [
                ['bold', 'italic', 'underline'],
                [{ 'list': 'ordered'}, { 'list': 'bullet' }],
                ['link', 'image'],
                ['clean']
            ]
        }
    });
}

/**
 * Establish database listener to sync steps from Firebase RTDB
 */
function initializeUserManualSync() {
    rtdb.ref('user_manual/steps').on('value', (snapshot) => {
        const data = snapshot.val();
        allSteps = [];
        if (data) {
            Object.keys(data).forEach(key => {
                allSteps.push({ id: key, ...data[key] });
            });
        }
        
        // Refresh views
        updateCategoriesGrid();
        updateCategoriesDatalist();
        
        if (currentCategory) {
            showStepsForCategory(currentCategory);
        }
    }, (error) => {
        console.error("Error fetching user manual steps:", error);
        document.getElementById('categoriesGridContainer').innerHTML = `<div class="col-span-full text-center text-danger py-6">Error: ${error.message}</div>`;
    });
}

/**
 * Update the Categories Grid landing page
 */
function updateCategoriesGrid() {
    const container = document.getElementById('categoriesGridContainer');
    if (!container) return;

    // Compile unique categories and their step counts
    const categoryCounts = {};
    allSteps.forEach(step => {
        const cat = step.category || 'Uncategorized';
        categoryCounts[cat] = (categoryCounts[cat] || 0) + 1;
    });

    const categoriesList = Object.keys(categoryCounts);

    if (categoriesList.length === 0) {
        container.innerHTML = `
            <div class="col-span-full text-center text-textmuted py-12">
                <i class="fa-solid fa-book-open text-3xl mb-3 block"></i>
                No categories configured yet. Click Add Manual Step to create one.
            </div>
        `;
        return;
    }

    container.innerHTML = '';
    categoriesList.forEach(category => {
        const count = categoryCounts[category];
        const card = document.createElement('div');
        card.className = 'bg-darksec border border-bordercolor rounded-[24px] p-6 hover:-translate-y-1 hover:border-primary/20 hover:shadow-primaryglow transition duration-300 cursor-pointer flex flex-col justify-between';
        card.onclick = () => showStepsForCategory(category);
        
        let iconHtml = '<i class="fa-solid fa-bookmark"></i>';
        let colorClass = 'text-primary bg-primary/10';
        
        const lowerCat = category.toLowerCase();
        if (lowerCat === 'installation') {
            iconHtml = '<i class="fa-solid fa-bolt"></i>';
            colorClass = 'text-warning bg-warning/10';
        } else if (lowerCat === 'setup') {
            iconHtml = '<i class="fa-solid fa-sliders"></i>';
            colorClass = 'text-success bg-success/10';
        } else if (lowerCat === 'maintenance') {
            iconHtml = '<i class="fa-solid fa-screwdriver-wrench"></i>';
            colorClass = 'text-danger bg-danger/10';
        } else if (lowerCat === 'safety') {
            iconHtml = '<i class="fa-solid fa-shield-halved"></i>';
            colorClass = 'text-info bg-info/10';
        }

        card.innerHTML = `
            <div>
                <div class="w-12 h-12 rounded-2xl ${colorClass} flex items-center justify-center text-xl mb-4">
                    ${iconHtml}
                </div>
                <h3 class="text-sm font-bold text-white mb-1">${escapeHtml(category)}</h3>
                <p class="text-[11px] text-textsecondary">${count} instructional step${count > 1 ? 's' : ''}</p>
            </div>
            <div class="mt-6 flex items-center justify-between text-xs font-semibold text-primary">
                <span>Manage steps</span>
                <i class="fa-solid fa-arrow-right"></i>
            </div>
        `;
        container.appendChild(card);
    });
}

/**
 * Populates datalist autocomplete options for category inputs
 */
function updateCategoriesDatalist() {
    const list = document.getElementById('existingCategoriesList');
    if (!list) return;

    const uniqueCats = [...new Set(allSteps.map(s => s.category).filter(Boolean))];
    list.innerHTML = '';
    uniqueCats.forEach(c => {
        const option = document.createElement('option');
        option.value = c;
        list.appendChild(option);
    });
}

/**
 * Display the step list for a specific category
 */
function showStepsForCategory(category) {
    currentCategory = category;
    document.getElementById('currentCategoryTitle').textContent = `${category} Steps`;
    
    // Toggle views
    document.getElementById('categoriesSection').classList.add('hidden');
    document.getElementById('stepsSection').classList.remove('hidden');
    document.getElementById('backToCategoriesContainer').classList.remove('hidden');

    const container = document.getElementById('stepsListContainer');
    if (!container) return;

    // Filter and sort steps in this category
    const categorySteps = allSteps
        .filter(s => s.category === category)
        .sort((a, b) => (a.stepNumber || 0) - (b.stepNumber || 0));

    if (categorySteps.length === 0) {
        container.innerHTML = `
            <div class="text-center text-textmuted py-12 bg-darksec border border-bordercolor rounded-[24px]">
                <i class="fa-solid fa-circle-question text-3xl mb-3 block"></i>
                No steps found for this category. Click Add Step to create one.
            </div>
        `;
        return;
    }

    container.innerHTML = '';
    categorySteps.forEach(step => {
        const card = document.createElement('div');
        card.className = 'bg-darksec border border-bordercolor rounded-[24px] p-6 flex flex-col gap-4 hover:border-primary/20 transition';
        
        let noteBoxHtml = '';
        if (step.noteText && step.noteType && step.noteType !== 'none') {
            const isWarning = step.noteType === 'warning';
            const badgeClass = isWarning ? 'bg-warning/15 text-warning border-warning/30' : 'bg-primary/15 text-primary border-primary/30';
            noteBoxHtml = `
                <div class="border rounded-2xl p-4 text-xs ${badgeClass} flex items-start gap-3">
                    <i class="fa-solid ${isWarning ? 'fa-triangle-exclamation' : 'fa-circle-info'} text-base mt-0.5"></i>
                    <div>
                        <span class="font-extrabold uppercase tracking-wider text-[9px] block mb-1">${isWarning ? 'Warning' : 'Information'}</span>
                        <p class="leading-relaxed font-medium">${escapeHtml(step.noteText)}</p>
                    </div>
                </div>
            `;
        }

        card.innerHTML = `
            <div class="flex justify-between items-start">
                <div class="flex items-center gap-3">
                    <div class="w-8 h-8 rounded-lg bg-gradient-to-tr from-primary to-secondary text-white text-xs font-extrabold flex items-center justify-center shadow-primaryglow">
                        ${step.stepNumber}
                    </div>
                    <h4 class="text-sm font-bold text-white">${escapeHtml(step.title)}</h4>
                </div>
                <div class="flex gap-2">
                    <button onclick="openEditStepModal('${step.id}')" class="bg-primary/10 text-primary hover:bg-primary hover:text-white px-3 py-1.5 rounded-lg text-xs font-bold transition cursor-pointer">Edit</button>
                    <button onclick="deleteStep('${step.id}', '${escapeHtml(step.title)}')" class="bg-danger/10 text-danger hover:bg-danger hover:text-white px-3 py-1.5 rounded-lg text-xs font-bold transition cursor-pointer">Delete</button>
                </div>
            </div>
            
            <div class="text-xs text-textsecondary leading-relaxed bg-black/10 border border-bordercolor/50 rounded-2xl p-4 ql-editor ql-snow">
                ${step.description}
            </div>
            
            ${noteBoxHtml}
        `;
        container.appendChild(card);
    });
}

/**
 * Return to the Categories Grid view
 */
function showCategoriesGrid() {
    currentCategory = '';
    document.getElementById('categoriesSection').classList.remove('hidden');
    document.getElementById('stepsSection').classList.add('hidden');
    document.getElementById('backToCategoriesContainer').classList.add('hidden');
}

/**
 * Add / Edit manual step modals
 */
function openAddStepModal(defaultCategory = '') {
    document.getElementById('stepId').value = "";
    document.getElementById('stepModalTitle').textContent = "Add Manual Step";
    document.getElementById('stepCategory').value = defaultCategory || currentCategory || "";
    document.getElementById('stepNumber').value = getNextStepNumber(defaultCategory || currentCategory);
    document.getElementById('stepTitle').value = "";
    quillEditor.root.innerHTML = "";
    document.getElementById('stepNoteType').value = "none";
    document.getElementById('stepNoteText').value = "";
    openModal('stepModal');
}

function openEditStepModal(id) {
    const step = allSteps.find(s => s.id === id);
    if (!step) return;

    document.getElementById('stepId').value = id;
    document.getElementById('stepModalTitle').textContent = "Edit Manual Step";
    document.getElementById('stepCategory').value = step.category || "";
    document.getElementById('stepNumber').value = step.stepNumber || "";
    document.getElementById('stepTitle').value = step.title || "";
    quillEditor.root.innerHTML = step.description || "";
    document.getElementById('stepNoteType').value = step.noteType || "none";
    document.getElementById('stepNoteText').value = step.noteText || "";
    openModal('stepModal');
}

function getNextStepNumber(category) {
    if (!category) return 1;
    const catSteps = allSteps.filter(s => s.category === category);
    if (catSteps.length === 0) return 1;
    const numbers = catSteps.map(s => s.stepNumber || 0);
    return Math.max(...numbers) + 1;
}

/**
 * Save manual step to Firebase Realtime Database
 */
async function saveStep() {
    const id = document.getElementById('stepId').value;
    const category = document.getElementById('stepCategory').value.trim();
    const stepNumber = parseInt(document.getElementById('stepNumber').value);
    const title = document.getElementById('stepTitle').value.trim();
    const description = quillEditor.root.innerHTML;
    const noteType = document.getElementById('stepNoteType').value;
    const noteText = document.getElementById('stepNoteText').value.trim();

    if (quillEditor.getText().trim() === "") {
        showToast("Please fill in the description HTML content.", "error");
        return;
    }

    try {
        const ref = id ? rtdb.ref(`user_manual/steps/${id}`) : rtdb.ref('user_manual/steps').push();
        const payload = {
            category,
            stepNumber,
            title,
            description,
            noteType
        };
        if (noteText) payload.noteText = noteText;
        if (!id) payload.id = ref.key; // Store key inside payload if creating new

        await ref.update(payload);
        showToast("Manual step saved successfully! ✨");
        closeModal('stepModal');
        
        // Auto navigate or stay on category
        if (!id) {
            showStepsForCategory(category);
        }
    } catch (err) {
        showToast("Failed to save manual step: " + err.message, "error");
    }
}

/**
 * Delete manual step
 */
async function deleteStep(id, title) {
    const confirmed = await showCustomConfirm("Delete Step", `Are you sure you want to delete "${title}"?`, 'danger');
    if (!confirmed) return;

    try {
        await rtdb.ref(`user_manual/steps/${id}`).remove();
        showToast("Manual step deleted.");
    } catch (err) {
        showToast("Delete Failed: " + err.message, "error");
    }
}

/**
 * Utility HTML Escaper
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
