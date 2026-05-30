/**
 * Video Tutorials & Categories Management
 * Extreme Medical Web Administration
 */

let categoriesList = [];
let videosList = [];
let localUploadedFileUrl = '';

document.addEventListener('DOMContentLoaded', () => {
    // Sync Categories
    syncCategories();

    // Sync Videos
    syncVideos();
});

/**
 * Sync Video Categories from Firebase RTDB
 */
function syncCategories() {
    rtdb.ref('video_tutorials/categories').on('value', (snapshot) => {
        const data = snapshot.val();
        categoriesList = [];
        if (data) {
            Object.keys(data).forEach(key => {
                categoriesList.push(data[key]);
            });
        }

        // Sort by timestamp
        categoriesList.sort((a, b) => (a.timestamp || 0) - (b.timestamp || 0));

        renderCategoriesTable();
        populateCategoriesDropdown();
    }, (error) => {
        console.error("Failed to sync categories:", error);
    });
}

/**
 * Render Categories List
 */
function renderCategoriesTable() {
    const body = document.getElementById('categoriesTableBody');
    if (!body) return;

    if (categoriesList.length === 0) {
        body.innerHTML = `
            <tr>
                <td colspan="2" class="py-4 text-center text-textsecondary text-xs">
                    No categories defined.
                </td>
            </tr>
        `;
        return;
    }

    body.innerHTML = '';
    categoriesList.forEach(cat => {
        const tr = document.createElement('tr');
        tr.className = 'hover:bg-white/[0.01] transition';
        tr.innerHTML = `
            <td class="py-3 text-xs font-bold text-white">${escapeHtml(cat.name)}</td>
            <td class="py-3 text-right">
                <button onclick="deleteCategory('${cat.id}')" class="text-textmuted hover:text-danger p-1 transition cursor-pointer" title="Delete Category">
                    <i class="fa-solid fa-trash-can"></i>
                </button>
            </td>
        `;
        body.appendChild(tr);
    });
}

/**
 * Populate Modal dropdown with categories list
 */
function populateCategoriesDropdown() {
    const select = document.getElementById('videoCategory');
    if (!select) return;

    if (categoriesList.length === 0) {
        select.innerHTML = '<option value="">No categories defined yet</option>';
        return;
    }

    select.innerHTML = '';
    categoriesList.forEach(cat => {
        const opt = document.createElement('option');
        opt.value = cat.id;
        opt.textContent = cat.name;
        select.appendChild(opt);
    });
}

/**
 * Add a new Category
 */
async function addCategory() {
    const input = document.getElementById('newCategoryName');
    const name = input.value.trim();
    if (!name) return;

    // Check duplication
    const duplicate = categoriesList.find(c => c.name.toLowerCase() === name.toLowerCase());
    if (duplicate) {
        showToast("Category name already exists!", "warning");
        return;
    }

    try {
        const newRef = rtdb.ref('video_tutorials/categories').push();
        const id = newRef.key;
        
        await newRef.set({
            id,
            name,
            timestamp: Date.now()
        });
        
        showToast("Category created successfully! 🏷️");
        input.value = '';
    } catch (err) {
        showToast("Failed to create category: " + err.message, "error");
    }
}

/**
 * Delete Category (and warning about cascade video removal)
 */
async function deleteCategory(id) {
    const cat = categoriesList.find(c => c.id === id);
    if (!cat) return;

    // Check count of videos in this category
    const videosCount = videosList.filter(v => v.categoryId === id).length;
    let confirmMsg = `Are you sure you want to delete the "${cat.name}" category?`;
    if (videosCount > 0) {
        confirmMsg += ` Warning: ${videosCount} video tutorial(s) belong to this category and will be cascade deleted.`;
    }

    const confirmed = await showCustomConfirm("Delete Category?", confirmMsg, "danger");
    if (!confirmed) return;

    try {
        // 1. Remove Category
        await rtdb.ref(`video_tutorials/categories/${id}`).remove();

        // 2. Cascade delete videos
        const cascadeDeletes = {};
        videosList.forEach(v => {
            if (v.categoryId === id) {
                cascadeDeletes[`video_tutorials/videos/${v.id}`] = null;
            }
        });

        if (Object.keys(cascadeDeletes).length > 0) {
            await rtdb.ref().update(cascadeDeletes);
        }

        showToast("Category deleted successfully!");
    } catch (err) {
        showToast("Failed to delete category: " + err.message, "error");
    }
}

/**
 * Sync Video Guides List from Firebase RTDB
 */
function syncVideos() {
    rtdb.ref('video_tutorials/videos').on('value', (snapshot) => {
        const data = snapshot.val();
        videosList = [];
        if (data) {
            Object.keys(data).forEach(key => {
                videosList.push(data[key]);
            });
        }

        // Sort newest first
        videosList.sort((a, b) => (b.timestamp || 0) - (a.timestamp || 0));

        renderVideosTable();
    }, (error) => {
        console.error("Failed to sync videos:", error);
    });
}

/**
 * Render Videos Library table
 */
function renderVideosTable() {
    const body = document.getElementById('videosTableBody');
    if (!body) return;

    if (videosList.length === 0) {
        body.innerHTML = `
            <tr>
                <td colspan="5" class="py-12 text-center text-textmuted text-xs">
                    <i class="fa-solid fa-folder-open text-2xl mb-2 block"></i> No video guides found in database.
                </td>
            </tr>
        `;
        return;
    }

    body.innerHTML = '';
    videosList.forEach(vid => {
        const tr = document.createElement('tr');
        tr.className = 'hover:bg-white/[0.01] transition duration-200';

        // Find category name
        const cat = categoriesList.find(c => c.id === vid.categoryId);
        const catName = cat ? cat.name : 'Unknown';

        // Tag styling based on category
        let catBadge = 'bg-primary/10 text-primary border border-primary/20';
        if (catName.toLowerCase().includes('error') || catName.toLowerCase().includes('fix')) {
            catBadge = 'bg-danger/10 text-danger border border-danger/20';
        } else if (catName.toLowerCase().includes('maintenance')) {
            catBadge = 'bg-success/10 text-success border border-success/20';
        }

        // Source preview
        const isLocal = vid.url.startsWith('uploads/');
        const sourceHtml = isLocal
            ? `<span class="text-[10px] text-success font-semibold flex items-center gap-1"><i class="fa-solid fa-server"></i> Local Upload</span>`
            : `<span class="text-[10px] text-textsecondary flex items-center gap-1"><i class="fa-solid fa-link"></i> External URL</span>`;

        // Featured tag
        const featuredHtml = vid.isFeatured
            ? `<span class="status-badge success"><i class="fa-solid fa-star"></i> Featured</span>`
            : `<span class="text-[10px] text-textmuted">Standard</span>`;

        tr.innerHTML = `
            <td class="p-4">
                <div class="flex flex-col">
                    <span class="text-xs font-bold text-white">${escapeHtml(vid.title)}</span>
                    <span class="text-[10px] text-textmuted max-w-[280px] truncate">${escapeHtml(vid.description)}</span>
                </div>
            </td>
            <td class="p-4">
                <span class="px-2 py-0.5 rounded-lg text-[9px] font-bold ${catBadge}">${escapeHtml(catName)}</span>
            </td>
            <td class="p-4 text-xs font-semibold text-white">${vid.duration}</td>
            <td class="p-4">
                <div class="flex flex-col gap-1.5">
                    ${featuredHtml}
                    ${sourceHtml}
                </div>
            </td>
            <td class="p-4 text-right">
                <div class="flex items-center justify-end gap-2">
                    <button onclick="openEditVideoModal('${vid.id}')" class="bg-primary/10 text-primary hover:bg-primary hover:text-white px-2 py-1 rounded transition text-xs font-semibold cursor-pointer">
                        <i class="fa-solid fa-pen-to-square"></i>
                    </button>
                    <button onclick="deleteVideo('${vid.id}')" class="bg-danger/10 text-danger hover:bg-danger hover:text-white px-2 py-1 rounded transition text-xs font-semibold cursor-pointer">
                        <i class="fa-solid fa-trash-can"></i>
                    </button>
                </div>
            </td>
        `;
        body.appendChild(tr);
    });
}

/**
 * Open Modal to Add Video
 */
function openAddVideoModal() {
    if (categoriesList.length === 0) {
        showToast("Please add at least one category before adding videos!", "warning");
        return;
    }

    document.getElementById('videoForm').reset();
    document.getElementById('editVideoId').value = '';
    document.getElementById('modalTitle').textContent = 'Add Video Tutorial';
    document.getElementById('submitVideoBtn').textContent = 'Save Video';
    document.getElementById('selectedFileName').textContent = 'No file selected.';
    localUploadedFileUrl = '';

    // Default to Link
    document.getElementById('videoSourceType').value = 'link';
    toggleSourceType();

    // Reset Progress Bar
    document.getElementById('uploadProgressContainer').classList.add('hidden');
    document.getElementById('formAlert').classList.add('hidden');

    openModal('videoModal');
}

/**
 * Open Modal to Edit Video
 */
function openEditVideoModal(id) {
    const vid = videosList.find(v => v.id === id);
    if (!vid) return;

    document.getElementById('videoForm').reset();
    document.getElementById('editVideoId').value = vid.id;
    document.getElementById('modalTitle').textContent = 'Edit Video Tutorial';
    document.getElementById('submitVideoBtn').textContent = 'Update Video';
    document.getElementById('formAlert').classList.add('hidden');
    
    // Fill fields
    document.getElementById('videoTitle').value = vid.title;
    document.getElementById('videoDescription').value = vid.description;
    document.getElementById('videoCategory').value = vid.categoryId;
    document.getElementById('videoDeviceName').value = vid.deviceName;
    document.getElementById('videoDuration').value = vid.duration;
    document.getElementById('videoViews').value = vid.views || 0;
    document.getElementById('videoIsFeatured').checked = vid.isFeatured || false;

    // Detect Source Type
    const isLocal = vid.url.startsWith('uploads/');
    if (isLocal) {
        document.getElementById('videoSourceType').value = 'upload';
        document.getElementById('selectedFileName').textContent = 'Existing file is set.';
        localUploadedFileUrl = vid.url;
    } else {
        document.getElementById('videoSourceType').value = 'link';
        document.getElementById('videoUrl').value = vid.url;
        localUploadedFileUrl = '';
    }

    toggleSourceType();
    openModal('videoModal');
}

/**
 * Toggle Visibility of Link input / Upload buttons based on Select box
 */
function toggleSourceType() {
    const type = document.getElementById('videoSourceType').value;
    const linkCon = document.getElementById('sourceLinkContainer');
    const uploadCon = document.getElementById('sourceUploadContainer');

    if (type === 'link') {
        linkCon.classList.remove('hidden');
        uploadCon.classList.add('hidden');
    } else {
        linkCon.classList.add('hidden');
        uploadCon.classList.remove('hidden');
    }
}

/**
 * Update Selected File Label on File Picked
 */
function handleFileSelected() {
    const fileInput = document.getElementById('videoFile');
    const label = document.getElementById('selectedFileName');
    
    if (fileInput.files.length > 0) {
        label.textContent = fileInput.files[0].name + ' (' + (fileInput.files[0].size / 1024 / 1024).toFixed(2) + ' MB)';
        localUploadedFileUrl = ''; // Clear because new file chosen
    } else {
        label.textContent = 'No file selected.';
    }
}

/**
 * Delete Video Guide from Firebase
 */
async function deleteVideo(id) {
    const confirmed = await showCustomConfirm(
        "Delete Video?",
        "Are you sure you want to delete this video guide? The action cannot be undone.",
        "danger"
    );
    if (!confirmed) return;

    try {
        await rtdb.ref(`video_tutorials/videos/${id}`).remove();
        showToast("Video guide removed successfully!");
    } catch (err) {
        showToast("Failed to delete video: " + err.message, "error");
    }
}

/**
 * Form Submit: Upload Video (if local type chosen) and save details to RTDB
 */
async function saveVideo() {
    const title = document.getElementById('videoTitle').value.trim();
    const description = document.getElementById('videoDescription').value.trim();
    const categoryId = document.getElementById('videoCategory').value;
    const deviceName = document.getElementById('videoDeviceName').value.trim();
    const duration = document.getElementById('videoDuration').value.trim();
    const views = parseInt(document.getElementById('videoViews').value, 10) || 0;
    const isFeatured = document.getElementById('videoIsFeatured').checked;
    const sourceType = document.getElementById('videoSourceType').value;
    const editId = document.getElementById('editVideoId').value;
    
    const alertBox = document.getElementById('formAlert');
    alertBox.classList.add('hidden');

    if (!title || !description || !categoryId || !deviceName || !duration) {
        alertBox.textContent = "Please fill in all required fields.";
        alertBox.classList.remove('hidden');
        return;
    }

    let videoUrl = '';

    if (sourceType === 'link') {
        videoUrl = document.getElementById('videoUrl').value.trim();
        if (!videoUrl) {
            alertBox.textContent = "Please enter an external Video URL Link.";
            alertBox.classList.remove('hidden');
            return;
        }
    } else {
        // Upload type
        const fileInput = document.getElementById('videoFile');
        const hasExisting = editId && localUploadedFileUrl;
        
        if (fileInput.files.length === 0 && !hasExisting) {
            alertBox.textContent = "Please choose a video file to upload.";
            alertBox.classList.remove('hidden');
            return;
        }

        if (fileInput.files.length > 0) {
            // Need to run AJAX upload
            try {
                videoUrl = await uploadLocalVideo(fileInput.files[0]);
            } catch (err) {
                alertBox.textContent = "Upload Failed: " + err;
                alertBox.classList.remove('hidden');
                return;
            }
        } else {
            // Re-use existing local URL
            videoUrl = localUploadedFileUrl;
        }
    }

    try {
        const id = editId ? editId : rtdb.ref('video_tutorials/videos').push().key;
        const timestamp = editId 
            ? (videosList.find(v => v.id === editId)?.timestamp || Date.now()) 
            : Date.now();

        await rtdb.ref(`video_tutorials/videos/${id}`).set({
            id,
            title,
            description,
            url: videoUrl,
            duration,
            categoryId,
            views,
            deviceName,
            isFeatured,
            timestamp
        });

        showToast(editId ? "Video tutorial updated successfully! 🎬" : "New video tutorial added! 🎬");
        closeModal('videoModal');
    } catch (err) {
        alertBox.textContent = "Database Error: " + err.message;
        alertBox.classList.remove('hidden');
    }
}

/**
 * AJAX uploader helper with progress callback
 */
function uploadLocalVideo(file) {
    return new Promise((resolve, reject) => {
        const formData = new FormData();
        formData.append('video', file);

        const xhr = new XMLHttpRequest();
        xhr.open('POST', 'upload_video.php', true);

        const progressCon = document.getElementById('uploadProgressContainer');
        const progressBar = document.getElementById('uploadProgressBar');
        const progressText = document.getElementById('uploadProgressText');

        progressCon.classList.remove('hidden');
        progressBar.style.width = '0%';
        progressText.textContent = 'Uploading file: 0%';

        xhr.upload.onprogress = (e) => {
            if (e.lengthComputable) {
                const percent = Math.round((e.loaded / e.total) * 100);
                progressBar.style.width = percent + '%';
                progressText.textContent = `Uploading file: ${percent}%`;
            }
        };

        xhr.onload = () => {
            if (xhr.status === 200) {
                try {
                    const res = JSON.parse(xhr.responseText);
                    if (res.status === 'success') {
                        progressBar.style.width = '100%';
                        progressText.textContent = 'Upload complete! Finalizing...';
                        setTimeout(() => {
                            progressCon.classList.add('hidden');
                        }, 500);
                        resolve(res.url);
                    } else {
                        reject(res.message);
                    }
                } catch (err) {
                    reject("Malformed server response.");
                }
            } else {
                reject(`HTTP Error: ${xhr.status}`);
            }
        };

        xhr.onerror = () => reject("Network error occurred.");
        xhr.send(formData);
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
