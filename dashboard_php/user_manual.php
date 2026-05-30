<?php
/**
 * User Manual Management Dashboard
 */
require_once __DIR__ . '/config.php';
check_auth();

$page_title = 'User Manual Management';
$page_scripts = ['assets/js/user_manual.js'];

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/sidebar.php';
?>

<!-- Include Quill.js stylesheet and script from CDN -->
<link href="https://cdn.quilljs.com/1.3.6/quill.snow.css" rel="stylesheet">
<script src="https://cdn.quilljs.com/1.3.6/quill.js"></script>

<div class="flex-1 flex flex-col min-w-0 bg-darkbg">
    <!-- Header -->
    <header class="h-20 border-b border-bordercolor px-8 flex items-center justify-between bg-darkbg/80 backdrop-blur-md sticky top-0 z-[90]">
        <div class="flex flex-col">
            <h1 class="text-xl font-extrabold text-white">User Manual Management</h1>
            <p class="text-xs text-textsecondary">Configure steps, documentation, and dynamic categories for the app's User Manual</p>
        </div>
        <!-- Breadcrumb / Back Button to Categories -->
        <div id="backToCategoriesContainer" class="hidden">
            <button onclick="showCategoriesGrid()" class="bg-white/5 border border-bordercolor text-textsecondary hover:text-white px-4 py-2.5 rounded-xl text-xs font-bold transition flex items-center gap-2 cursor-pointer">
                <i class="fa-solid fa-arrow-left"></i> Back to Categories
            </button>
        </div>
    </header>

    <!-- Page Content -->
    <main class="p-8 flex-1 overflow-y-auto">
        <!-- ========================================== -->
        <!-- VIEW: CATEGORIES GRID LANDING              -->
        <!-- ========================================== -->
        <section id="categoriesSection" class="view-section">
            <div class="flex justify-between items-center mb-6">
                <div>
                    <h2 class="text-base font-extrabold text-white">Documentation Categories</h2>
                    <p class="text-xs text-textsecondary">Select a category card to manage its step-by-step instructions</p>
                </div>
                <button onclick="openAddStepModal()" class="bg-gradient-to-tr from-primary to-secondary text-white font-bold text-xs px-4 py-2.5 rounded-xl flex items-center gap-1.5 hover:-translate-y-0.5 hover:shadow-primaryglow transition duration-200 cursor-pointer">
                    <i class="fa-solid fa-plus"></i> Add Manual Step
                </button>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-4 gap-6" id="categoriesGridContainer">
                <div class="col-span-full text-center text-textmuted py-12">
                    <i class="fa-solid fa-circle-notch fa-spin"></i> Loading Categories...
                </div>
            </div>
        </section>

        <!-- ========================================== -->
        <!-- VIEW: STEPS LIST FOR SELECTED CATEGORY      -->
        <!-- ========================================== -->
        <section id="stepsSection" class="view-section hidden">
            <div class="flex justify-between items-center mb-6">
                <div>
                    <h2 class="text-base font-extrabold text-white" id="currentCategoryTitle">Category Steps</h2>
                    <p class="text-xs text-textsecondary">Sequence of instructional steps. Drag or re-order by step numbers.</p>
                </div>
                <div class="flex gap-3">
                    <button onclick="openAddStepModal(currentCategory)" class="bg-gradient-to-tr from-primary to-secondary text-white font-bold text-xs px-4 py-2.5 rounded-xl flex items-center gap-1.5 hover:-translate-y-0.5 hover:shadow-primaryglow transition duration-200 cursor-pointer">
                        <i class="fa-solid fa-plus"></i> Add Step to this Category
                    </button>
                </div>
            </div>

            <div class="flex flex-col gap-4" id="stepsListContainer">
                <!-- Syncing manual steps in category -->
            </div>
        </section>
    </main>
</div>

<!-- ========================================== -->
<!-- MODAL: ADD / EDIT STEP                     -->
<!-- ========================================== -->
<div class="modal-overlay fixed inset-0 bg-darkbg/85 backdrop-blur-md flex items-center justify-center z-[1000] opacity-0 pointer-events-none transition-opacity duration-300" id="stepModal">
    <div class="modal-content bg-darksec border border-bordercolor rounded-[28px] w-[95%] max-w-[650px] max-h-[90vh] flex flex-col overflow-hidden scale-90 transition-transform duration-300 shadow-2xl">
        <div class="p-6 border-b border-bordercolor flex items-center justify-between">
            <h3 class="text-base font-extrabold text-white leading-tight" id="stepModalTitle">Add Manual Step</h3>
            <button onclick="closeModal('stepModal')" class="border-none bg-white/5 text-textsecondary w-9 h-9 rounded-full cursor-pointer flex items-center justify-center hover:bg-white/10 hover:text-white transition duration-200 text-lg">&times;</button>
        </div>
        <div class="p-6 overflow-y-auto flex-1">
            <form id="stepForm" class="flex flex-col gap-4" onsubmit="event.preventDefault(); saveStep();">
                <input type="hidden" id="stepId" value="">
                
                <div class="grid grid-cols-2 gap-4">
                    <div class="flex flex-col gap-1.5">
                        <label for="stepCategory" class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Category</label>
                        <input type="text" id="stepCategory" list="existingCategoriesList" class="bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-xs outline-none focus:border-primary transition" placeholder="e.g. Installation" required>
                        <datalist id="existingCategoriesList"></datalist>
                    </div>
                    <div class="flex flex-col gap-1.5">
                        <label for="stepNumber" class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Step Number</label>
                        <input type="number" id="stepNumber" min="1" class="bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-xs outline-none focus:border-primary transition" placeholder="e.g. 1" required>
                    </div>
                </div>

                <div class="flex flex-col gap-1.5">
                    <label for="stepTitle" class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Step Title</label>
                    <input type="text" id="stepTitle" class="bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-xs outline-none focus:border-primary transition" placeholder="e.g. Choose Mounting Location" required>
                </div>

                <!-- Quill Rich Text Editor Container -->
                <div class="flex flex-col gap-1.5">
                    <label class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Description (HTML Content)</label>
                    <div id="editor-container" class="bg-white/5 border border-bordercolor rounded-xl text-white text-xs" style="height: 180px;"></div>
                </div>

                <div class="grid grid-cols-2 gap-4">
                    <div class="flex flex-col gap-1.5">
                        <label for="stepNoteType" class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Note Box Type</label>
                        <select id="stepNoteType" class="bg-darksec border border-bordercolor rounded-xl px-4 py-3 text-white text-xs outline-none focus:border-primary transition">
                            <option value="none">No Note Box</option>
                            <option value="info">Info Note (Primary Theme)</option>
                            <option value="warning">Warning Note (Amber Theme)</option>
                        </select>
                    </div>
                    <div class="flex flex-col gap-1.5">
                        <label for="stepNoteText" class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Note Text (Optional)</label>
                        <input type="text" id="stepNoteText" class="bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-xs outline-none focus:border-primary transition" placeholder="e.g. Maintain 30cm clearance.">
                    </div>
                </div>

                <div class="flex justify-end gap-3 mt-4">
                    <button type="button" onclick="closeModal('stepModal')" class="bg-transparent border border-bordercolor text-textsecondary px-4 py-2.5 rounded-xl text-xs font-semibold hover:bg-white/5 transition">Cancel</button>
                    <button type="submit" class="bg-gradient-to-tr from-primary to-secondary text-white font-bold text-xs px-4 py-2.5 rounded-xl transition">Save Step</button>
                </div>
            </form>
        </div>
    </div>
</div>

<style>
/* Quill Editor Dark Theme Customization */
.ql-toolbar.ql-snow {
    border-color: rgba(255, 255, 255, 0.08) !important;
    background-color: rgba(255, 255, 255, 0.02) !important;
    border-top-left-radius: 12px;
    border-top-right-radius: 12px;
}
.ql-container.ql-snow {
    border-color: rgba(255, 255, 255, 0.08) !important;
    border-bottom-left-radius: 12px;
    border-bottom-right-radius: 12px;
    font-family: inherit;
    font-size: 13px;
}
.ql-editor {
    color: #f8fafc;
}
.ql-snow .ql-stroke {
    stroke: #94a3b8 !important;
}
.ql-snow .ql-fill {
    fill: #94a3b8 !important;
}
.ql-snow .ql-picker {
    color: #94a3b8 !important;
}
</style>

<?php
require_once __DIR__ . '/includes/footer.php';
?>
