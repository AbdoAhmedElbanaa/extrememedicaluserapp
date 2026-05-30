<?php
/**
 * Video Tutorials Management Admin Dashboard
 */
require_once __DIR__ . '/config.php';
check_auth();

$page_title = 'Video Tutorials Management';
$page_scripts = ['assets/js/video_tutorials.js'];

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/sidebar.php';
?>

<div class="flex-1 flex flex-col min-w-0 bg-darkbg">
    <!-- Header -->
    <header class="h-20 border-b border-bordercolor px-8 flex items-center justify-between bg-darkbg/80 backdrop-blur-md sticky top-0 z-[90]">
        <div class="flex flex-col">
            <h1 class="text-xl font-extrabold text-white">Video Tutorials</h1>
            <p class="text-xs text-textsecondary">Manage tutorials, categories, local/remote videos, and carousel promotions for the app</p>
        </div>
        <button onclick="openAddVideoModal()" class="bg-gradient-to-tr from-primary to-secondary text-white font-bold text-xs px-5 py-3 rounded-xl hover:-translate-y-0.5 hover:shadow-primaryglow transition duration-200 cursor-pointer flex items-center gap-2">
            <i class="fa-solid fa-plus"></i> Add New Video
        </button>
    </header>

    <!-- Page Content -->
    <main class="p-8 flex-1 overflow-y-auto">
        <div class="grid grid-cols-1 xl:grid-cols-3 gap-6 mb-8">
            <!-- Categories Configuration Card (Col Span 1) -->
            <div class="bg-darksec border border-bordercolor rounded-[24px] p-6 flex flex-col h-[520px]">
                <div class="flex items-center gap-3 mb-6">
                    <div class="w-10 h-10 rounded-xl bg-secondary/10 flex items-center justify-center text-secondary text-lg">
                        <i class="fa-solid fa-tags"></i>
                    </div>
                    <div>
                        <h2 class="text-sm font-extrabold text-white">Manage Categories</h2>
                        <p class="text-[11px] text-textsecondary">Organize video tutorials into classifications</p>
                    </div>
                </div>

                <!-- Add Category Form -->
                <form id="categoryForm" class="flex gap-2 mb-4" onsubmit="event.preventDefault(); addCategory();">
                    <input type="text" id="newCategoryName" class="flex-1 bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-xs outline-none focus:border-primary transition" placeholder="New category name (e.g. Error Fixes)" required>
                    <button type="submit" class="bg-white/5 hover:bg-white/10 border border-bordercolor text-white px-4 py-2.5 rounded-xl text-xs font-bold transition flex items-center justify-center cursor-pointer">
                        <i class="fa-solid fa-plus"></i>
                    </button>
                </form>

                <!-- Categories list container -->
                <div class="flex-1 overflow-y-auto pr-1">
                    <table class="w-full text-left border-collapse">
                        <thead>
                            <tr class="border-b border-bordercolor">
                                <th class="pb-2 text-[9px] font-bold text-textsecondary uppercase tracking-wider">Name</th>
                                <th class="pb-2 text-[9px] font-bold text-textsecondary uppercase tracking-wider text-right">Action</th>
                            </tr>
                        </thead>
                        <tbody id="categoriesTableBody" class="divide-y divide-bordercolor">
                            <tr>
                                <td colspan="2" class="py-4 text-center text-textmuted text-xs">
                                    <i class="fa-solid fa-circle-notch fa-spin mr-1"></i> Loading categories...
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Videos Management Grid (Col Span 2) -->
            <div class="bg-darksec border border-bordercolor rounded-[24px] p-6 xl:col-span-2 flex flex-col h-[520px]">
                <div class="flex items-center gap-3 mb-6">
                    <div class="w-10 h-10 rounded-xl bg-primary/10 flex items-center justify-center text-primary text-lg">
                        <i class="fa-solid fa-play"></i>
                    </div>
                    <div>
                        <h2 class="text-sm font-extrabold text-white">Video Tutorials Library</h2>
                        <p class="text-[11px] text-textsecondary">Catalog of step-by-step video manuals</p>
                    </div>
                </div>

                <!-- Videos list container -->
                <div class="flex-1 overflow-y-auto pr-1">
                    <table class="w-full text-left border-collapse">
                        <thead>
                            <tr class="border-b border-bordercolor">
                                <th class="pb-3 text-[10px] font-bold text-textsecondary uppercase tracking-wider">Video details</th>
                                <th class="pb-3 text-[10px] font-bold text-textsecondary uppercase tracking-wider">Category</th>
                                <th class="pb-3 text-[10px] font-bold text-textsecondary uppercase tracking-wider">Duration</th>
                                <th class="pb-3 text-[10px] font-bold text-textsecondary uppercase tracking-wider">Status</th>
                                <th class="pb-3 text-[10px] font-bold text-textsecondary uppercase tracking-wider text-right">Actions</th>
                            </tr>
                        </thead>
                        <tbody id="videosTableBody" class="divide-y divide-bordercolor">
                            <tr>
                                <td colspan="5" class="py-12 text-center text-textmuted text-xs">
                                    <i class="fa-solid fa-circle-notch fa-spin text-lg mb-3 block"></i> Loading tutorials...
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </main>
</div>

<!-- ========================================== -->
<!-- MODAL: ADD / EDIT VIDEO GUIDE             -->
<!-- ========================================== -->
<div class="modal-overlay fixed inset-0 bg-darkbg/85 backdrop-blur-md flex items-center justify-center z-[1000] opacity-0 pointer-events-none transition-opacity duration-300" id="videoModal">
    <div class="modal-content bg-darksec border border-bordercolor rounded-[28px] w-[95%] max-w-[600px] max-h-[90vh] flex flex-col overflow-hidden scale-90 transition-transform duration-300 shadow-2xl">
        <div class="p-6 border-b border-bordercolor flex items-center justify-between">
            <h3 class="text-base font-extrabold text-white leading-tight" id="modalTitle">Add Video Tutorial</h3>
            <button onclick="closeModal('videoModal')" class="border-none bg-white/5 text-textsecondary w-9 h-9 rounded-full cursor-pointer flex items-center justify-center hover:bg-white/10 hover:text-white transition duration-200 text-lg">&times;</button>
        </div>
        
        <form id="videoForm" class="overflow-y-auto flex-1 p-6 flex flex-col gap-4" onsubmit="event.preventDefault(); saveVideo();">
            <input type="hidden" id="editVideoId" value="">

            <!-- Title -->
            <div class="flex flex-col gap-1.5">
                <label for="videoTitle" class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Tutorial Title</label>
                <input type="text" id="videoTitle" class="bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-xs outline-none focus:border-primary transition" placeholder="e.g. Complete Setup Guide for SmartThermo Pro" required>
            </div>

            <!-- Description -->
            <div class="flex flex-col gap-1.5">
                <label for="videoDescription" class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Details / Description</label>
                <textarea id="videoDescription" rows="3" class="bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-xs outline-none focus:border-primary transition" placeholder="Provide step-by-step textual details for the guide..." required></textarea>
            </div>

            <div class="grid grid-cols-2 gap-4">
                <!-- Category Dropdown -->
                <div class="flex flex-col gap-1.5">
                    <label for="videoCategory" class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Category</label>
                    <select id="videoCategory" class="bg-darkbg border border-bordercolor rounded-xl px-4 py-3 text-white text-xs outline-none focus:border-primary transition" required>
                        <!-- Populated dynamically -->
                    </select>
                </div>
                <!-- Device / Model Name -->
                <div class="flex flex-col gap-1.5">
                    <label for="videoDeviceName" class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Target Device / Model</label>
                    <input type="text" id="videoDeviceName" class="bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-xs outline-none focus:border-primary transition" placeholder="e.g. SmartThermo Pro" required>
                </div>
            </div>

            <div class="grid grid-cols-2 gap-4">
                <!-- Duration -->
                <div class="flex flex-col gap-1.5">
                    <label for="videoDuration" class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Duration (MM:SS)</label>
                    <input type="text" id="videoDuration" class="bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-xs outline-none focus:border-primary transition" placeholder="e.g. 8:24" required>
                </div>
                <!-- Views -->
                <div class="flex flex-col gap-1.5">
                    <label for="videoViews" class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Starting Views</label>
                    <input type="number" id="videoViews" class="bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-xs outline-none focus:border-primary transition" value="0" required>
                </div>
            </div>

            <!-- Video Source Selection -->
            <div class="flex flex-col gap-1.5">
                <label for="videoSourceType" class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Video Source Type</label>
                <select id="videoSourceType" onchange="toggleSourceType()" class="bg-darkbg border border-bordercolor rounded-xl px-4 py-3 text-white text-xs outline-none focus:border-primary transition">
                    <option value="link">Paste External Link / URL</option>
                    <option value="upload">Upload Video File Locally (Max 100MB)</option>
                </select>
            </div>

            <!-- Paste Link input -->
            <div class="flex flex-col gap-1.5" id="sourceLinkContainer">
                <label for="videoUrl" class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Video URL Link</label>
                <input type="url" id="videoUrl" class="bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-xs outline-none focus:border-primary transition" placeholder="e.g. https://www.w3schools.com/html/mov_bbb.mp4">
            </div>

            <!-- Local file upload input -->
            <div class="flex flex-col gap-1.5 hidden" id="sourceUploadContainer">
                <label for="videoFile" class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Upload Video File</label>
                <div class="flex items-center gap-3">
                    <input type="file" id="videoFile" accept="video/*" class="hidden" onchange="handleFileSelected()">
                    <button type="button" onclick="document.getElementById('videoFile').click()" class="bg-white/5 border border-bordercolor hover:bg-white/10 text-white text-xs px-4 py-3 rounded-xl transition font-semibold cursor-pointer">
                        Choose Video File
                    </button>
                    <span class="text-xs text-textsecondary" id="selectedFileName">No file selected.</span>
                </div>
                <!-- Uploading state bar -->
                <div id="uploadProgressContainer" class="hidden mt-2">
                    <div class="w-full bg-white/5 rounded-full h-1.5 border border-bordercolor">
                        <div id="uploadProgressBar" class="bg-gradient-to-r from-primary to-secondary h-1 rounded-full transition-all duration-300" style="width: 0%"></div>
                    </div>
                    <span class="text-[10px] text-primary font-bold mt-1 block" id="uploadProgressText">Uploading file: 0%</span>
                </div>
            </div>

            <!-- Featured Checkbox -->
            <div class="flex items-center gap-3 mt-2">
                <input type="checkbox" id="videoIsFeatured" class="w-4 h-4 rounded border-bordercolor text-primary focus:ring-primary bg-darkbg cursor-pointer">
                <label for="videoIsFeatured" class="text-xs font-bold text-white cursor-pointer select-none">Feature this tutorial in the slider (App Carousel Banner)</label>
            </div>

            <!-- Error/Warning details box -->
            <div id="formAlert" class="hidden border border-danger/20 bg-danger/10 text-danger text-xs p-4 rounded-2xl"></div>
        </form>

        <div class="p-6 border-t border-bordercolor flex justify-end gap-3 bg-white/[0.01]">
            <button type="button" onclick="closeModal('videoModal')" class="bg-transparent border border-bordercolor text-textsecondary px-4 py-2.5 rounded-xl text-xs font-semibold hover:bg-white/5 transition">Cancel</button>
            <button type="button" id="submitVideoBtn" onclick="saveVideo()" class="bg-gradient-to-tr from-primary to-secondary text-white font-bold text-xs px-5 py-2.5 rounded-xl hover:-translate-y-0.5 hover:shadow-primaryglow transition duration-200 cursor-pointer">
                Save Video
            </button>
        </div>
    </div>
</div>

<?php
require_once __DIR__ . '/includes/footer.php';
?>
