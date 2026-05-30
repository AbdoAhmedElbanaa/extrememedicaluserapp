<?php
/**
 * Help & Knowledge Center Management Dashboard
 */
require_once __DIR__ . '/config.php';
check_auth();

$page_title = 'Help & Knowledge Center';
$page_scripts = ['assets/js/help_center.js'];

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/sidebar.php';
?>

<div class="flex-1 flex flex-col min-w-0 bg-darkbg">
    <!-- Navbar / Header -->
    <header class="h-20 border-b border-bordercolor px-8 flex items-center justify-between bg-darkbg/80 backdrop-blur-md sticky top-0 z-[90]">
        <div class="flex flex-col">
            <h1 class="text-xl font-extrabold text-white">Help & Knowledge Center</h1>
            <p class="text-xs text-textsecondary">Manage FAQs, Error Codes, and Diagnostics interactive tools in the user app</p>
        </div>
    </header>

    <!-- Sub Navigation Tabs -->
    <div class="px-8 pt-6 border-b border-bordercolor bg-darksec/30">
        <div class="flex gap-6" id="helpCenterTabs">
            <button class="tab-btn pb-4 text-sm font-bold text-primary border-b-2 border-primary cursor-pointer transition" data-tab="faqs">
                <i class="fa-solid fa-circle-question mr-1.5"></i> FAQs
            </button>
            <button class="tab-btn pb-4 text-sm font-medium text-textsecondary border-b-2 border-transparent hover:text-white cursor-pointer transition" data-tab="errors">
                <i class="fa-solid fa-triangle-exclamation mr-1.5"></i> Error Codes
            </button>
            <button class="tab-btn pb-4 text-sm font-medium text-textsecondary border-b-2 border-transparent hover:text-white cursor-pointer transition" data-tab="diagnose">
                <i class="fa-solid fa-toolbox mr-1.5"></i> Diagnose Options
            </button>
        </div>
    </div>

    <!-- Page Content -->
    <main class="p-8 flex-1 overflow-y-auto">
        <!-- ========================================== -->
        <!-- TAB PANEL: FAQs                            -->
        <!-- ========================================== -->
        <section id="faqsTabPanel" class="tab-panel">
            <div class="flex justify-between items-center mb-6">
                <div>
                    <h2 class="text-base font-extrabold text-white">Frequently Asked Questions</h2>
                    <p class="text-xs text-textsecondary">Accordion help list visible under the FAQs section</p>
                </div>
                <button onclick="openAddFaqModal()" class="bg-gradient-to-tr from-primary to-secondary text-white font-bold text-xs px-4 py-2.5 rounded-xl flex items-center gap-1.5 hover:-translate-y-0.5 hover:shadow-primaryglow transition duration-200 cursor-pointer">
                    <i class="fa-solid fa-plus"></i> Add FAQ
                </button>
            </div>
            
            <div class="grid grid-cols-1 gap-4" id="faqsListContainer">
                <div class="text-center text-textmuted py-12">
                    <i class="fa-solid fa-circle-notch fa-spin"></i> Syncing FAQs...
                </div>
            </div>
        </section>

        <!-- ========================================== -->
        <!-- TAB PANEL: ERROR CODES                    -->
        <!-- ========================================== -->
        <section id="errorsTabPanel" class="tab-panel hidden">
            <div class="flex justify-between items-center mb-6">
                <div>
                    <h2 class="text-base font-extrabold text-white">System Error Codes & Fixes</h2>
                    <p class="text-xs text-textsecondary">Catalog of error codes, possible causes, step-by-step guides, and video tutorials</p>
                </div>
                <button onclick="openAddErrorModal()" class="bg-gradient-to-tr from-primary to-secondary text-white font-bold text-xs px-4 py-2.5 rounded-xl flex items-center gap-1.5 hover:-translate-y-0.5 hover:shadow-primaryglow transition duration-200 cursor-pointer">
                    <i class="fa-solid fa-plus"></i> Add Error Code
                </button>
            </div>

            <div class="bg-darksec border border-bordercolor rounded-[24px] overflow-hidden">
                <div class="overflow-x-auto">
                    <table class="w-full text-left text-xs border-collapse">
                        <thead>
                            <tr class="border-b border-bordercolor bg-black/10 text-[10px] font-bold text-textsecondary uppercase tracking-wider">
                                <th class="py-4 px-6">Code</th>
                                <th class="py-4 px-6">Title</th>
                                <th class="py-4 px-6">Severity</th>
                                <th class="py-4 px-6">Causes & Steps</th>
                                <th class="py-4 px-6 text-right">Actions</th>
                            </tr>
                        </thead>
                        <tbody id="errorsTableBody">
                            <tr>
                                <td colspan="5" class="py-12 text-center text-textmuted">
                                    <i class="fa-solid fa-circle-notch fa-spin"></i> Syncing Error Codes...
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </section>

        <!-- ========================================== -->
        <!-- TAB PANEL: DIAGNOSE OPTIONS               -->
        <!-- ========================================== -->
        <section id="diagnoseTabPanel" class="tab-panel hidden">
            <div class="flex justify-between items-center mb-6">
                <div>
                    <h2 class="text-base font-extrabold text-white">Interactive Diagnostic Options</h2>
                    <p class="text-xs text-textsecondary">Problem categories showing up in the interactive troubleshoot grid</p>
                </div>
                <button onclick="openAddDiagnoseModal()" class="bg-gradient-to-tr from-primary to-secondary text-white font-bold text-xs px-4 py-2.5 rounded-xl flex items-center gap-1.5 hover:-translate-y-0.5 hover:shadow-primaryglow transition duration-200 cursor-pointer">
                    <i class="fa-solid fa-plus"></i> Add Diagnose Option
                </button>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-3 gap-6" id="diagnoseGridContainer">
                <div class="col-span-full text-center text-textmuted py-12">
                    <i class="fa-solid fa-circle-notch fa-spin"></i> Syncing Diagnose Options...
                </div>
            </div>
        </section>
    </main>
</div>

<!-- ========================================== -->
<!-- MODAL: ADD / EDIT FAQ                      -->
<!-- ========================================== -->
<div class="modal-overlay fixed inset-0 bg-darkbg/85 backdrop-blur-md flex items-center justify-center z-[1000] opacity-0 pointer-events-none transition-opacity duration-300" id="faqModal">
    <div class="modal-content bg-darksec border border-bordercolor rounded-[28px] w-[90%] max-w-[500px] flex flex-col overflow-hidden scale-90 transition-transform duration-300 shadow-2xl">
        <div class="p-6 border-b border-bordercolor flex items-center justify-between">
            <h3 class="text-base font-extrabold text-white leading-tight" id="faqModalTitle">Add FAQ</h3>
            <button onclick="closeModal('faqModal')" class="border-none bg-white/5 text-textsecondary w-9 h-9 rounded-full cursor-pointer flex items-center justify-center hover:bg-white/10 hover:text-white transition duration-200 text-lg">&times;</button>
        </div>
        <form id="faqForm" class="p-6 flex flex-col gap-4" onsubmit="event.preventDefault(); saveFaq();">
            <input type="hidden" id="faqId" value="">
            <div class="flex flex-col gap-1.5">
                <label for="faqQuestion" class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Question</label>
                <input type="text" id="faqQuestion" class="bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-xs outline-none focus:border-primary transition" placeholder="e.g. How do I change the temperature unit?" required>
            </div>
            <div class="flex flex-col gap-1.5">
                <label for="faqAnswer" class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Answer</label>
                <textarea id="faqAnswer" rows="4" class="bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-xs outline-none focus:border-primary transition resize-none" placeholder="Explain the answer clearly..." required></textarea>
            </div>
            <div class="flex justify-end gap-3 mt-2">
                <button type="button" onclick="closeModal('faqModal')" class="bg-transparent border border-bordercolor text-textsecondary px-4 py-2.5 rounded-xl text-xs font-semibold hover:bg-white/5 transition">Cancel</button>
                <button type="submit" class="bg-gradient-to-tr from-primary to-secondary text-white font-bold text-xs px-4 py-2.5 rounded-xl transition">Save FAQ</button>
            </div>
        </form>
    </div>
</div>

<!-- ========================================== -->
<!-- MODAL: ADD / EDIT ERROR CODE               -->
<!-- ========================================== -->
<div class="modal-overlay fixed inset-0 bg-darkbg/85 backdrop-blur-md flex items-center justify-center z-[1000] opacity-0 pointer-events-none transition-opacity duration-300" id="errorModal">
    <div class="modal-content bg-darksec border border-bordercolor rounded-[28px] w-[95%] max-w-[650px] max-h-[90vh] flex flex-col overflow-hidden scale-90 transition-transform duration-300 shadow-2xl">
        <div class="p-6 border-b border-bordercolor flex items-center justify-between">
            <h3 class="text-base font-extrabold text-white leading-tight" id="errorModalTitle">Add Error Code</h3>
            <button onclick="closeModal('errorModal')" class="border-none bg-white/5 text-textsecondary w-9 h-9 rounded-full cursor-pointer flex items-center justify-center hover:bg-white/10 hover:text-white transition duration-200 text-lg">&times;</button>
        </div>
        <div class="p-6 overflow-y-auto flex-1">
            <form id="errorForm" class="flex flex-col gap-4" onsubmit="event.preventDefault(); saveError();">
                <input type="hidden" id="errorId" value="">
                <div class="grid grid-cols-2 gap-4">
                    <div class="flex flex-col gap-1.5">
                        <label for="errorCode" class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Error Code</label>
                        <input type="text" id="errorCode" class="bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-xs outline-none focus:border-primary transition" placeholder="e.g. E102" required>
                    </div>
                    <div class="flex flex-col gap-1.5">
                        <label for="errorTitle" class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Error Title</label>
                        <input type="text" id="errorTitle" class="bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-xs outline-none focus:border-primary transition" placeholder="e.g. Control Module Error" required>
                    </div>
                </div>
                <div class="grid grid-cols-2 gap-4">
                    <div class="flex flex-col gap-1.5">
                        <label for="errorSeverity" class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Severity</label>
                        <select id="errorSeverity" class="bg-darksec border border-bordercolor rounded-xl px-4 py-3 text-white text-xs outline-none focus:border-primary transition" required>
                            <option value="low">Low</option>
                            <option value="medium">Medium</option>
                            <option value="critical">Critical</option>
                        </select>
                    </div>
                    <div class="flex flex-col gap-1.5">
                        <label for="errorTutorialTitle" class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Tutorial Video Title</label>
                        <input type="text" id="errorTutorialTitle" class="bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-xs outline-none focus:border-primary transition" placeholder="e.g. Control Module Fix Video">
                    </div>
                </div>
                <div class="grid grid-cols-2 gap-4">
                    <div class="flex flex-col gap-1.5">
                        <label for="errorTutorialDuration" class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Video Duration</label>
                        <input type="text" id="errorTutorialDuration" class="bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-xs outline-none focus:border-primary transition" placeholder="e.g. 4:32 min">
                    </div>
                    <div class="flex flex-col gap-1.5 justify-end">
                        <p class="text-[10px] text-textmuted">Include a duration string to display the play button launcher in error details.</p>
                    </div>
                </div>
                <div class="flex flex-col gap-1.5">
                    <label for="errorDesc" class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Description</label>
                    <textarea id="errorDesc" rows="2" class="bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-xs outline-none focus:border-primary transition resize-none" placeholder="Provide a concise error description..." required></textarea>
                </div>

                <!-- Causes specs builder -->
                <div class="h-[1px] bg-bordercolor my-2"></div>
                <div class="flex justify-between items-center">
                    <span class="text-[10px] font-bold text-primary uppercase tracking-wider">Possible Causes</span>
                    <button type="button" onclick="addErrorCauseRow()" class="bg-primary/10 text-primary hover:bg-primary hover:text-white px-2 py-1 rounded text-[10px] font-bold transition">
                        <i class="fa-solid fa-plus mr-1"></i> Add Cause
                    </button>
                </div>
                <div class="flex flex-col gap-2" id="errorCausesContainer"></div>

                <!-- Steps specs builder -->
                <div class="h-[1px] bg-bordercolor my-2"></div>
                <div class="flex justify-between items-center">
                    <span class="text-[10px] font-bold text-primary uppercase tracking-wider">Step-by-step Fixes</span>
                    <button type="button" onclick="addErrorStepRow()" class="bg-primary/10 text-primary hover:bg-primary hover:text-white px-2 py-1 rounded text-[10px] font-bold transition">
                        <i class="fa-solid fa-plus mr-1"></i> Add Step
                    </button>
                </div>
                <div class="flex flex-col gap-2" id="errorStepsContainer"></div>

                <div class="flex justify-end gap-3 mt-4">
                    <button type="button" onclick="closeModal('errorModal')" class="bg-transparent border border-bordercolor text-textsecondary px-4 py-2.5 rounded-xl text-xs font-semibold hover:bg-white/5 transition">Cancel</button>
                    <button type="submit" class="bg-gradient-to-tr from-primary to-secondary text-white font-bold text-xs px-4 py-2.5 rounded-xl transition">Save Error Code</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- ========================================== -->
<!-- MODAL: ADD / EDIT DIAGNOSE OPTION          -->
<!-- ========================================== -->
<div class="modal-overlay fixed inset-0 bg-darkbg/85 backdrop-blur-md flex items-center justify-center z-[1000] opacity-0 pointer-events-none transition-opacity duration-300" id="diagnoseModal">
    <div class="modal-content bg-darksec border border-bordercolor rounded-[28px] w-[95%] max-w-[550px] max-h-[90vh] flex flex-col overflow-hidden scale-90 transition-transform duration-300 shadow-2xl">
        <div class="p-6 border-b border-bordercolor flex items-center justify-between">
            <h3 class="text-base font-extrabold text-white leading-tight" id="diagnoseModalTitle">Add Diagnose Option</h3>
            <button onclick="closeModal('diagnoseModal')" class="border-none bg-white/5 text-textsecondary w-9 h-9 rounded-full cursor-pointer flex items-center justify-center hover:bg-white/10 hover:text-white transition duration-200 text-lg">&times;</button>
        </div>
        <div class="p-6 overflow-y-auto flex-1">
            <form id="diagnoseForm" class="flex flex-col gap-4" onsubmit="event.preventDefault(); saveDiagnose();">
                <input type="hidden" id="diagnoseId" value="">
                <div class="grid grid-cols-2 gap-4">
                    <div class="flex flex-col gap-1.5">
                        <label for="diagnoseTitle" class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Title</label>
                        <input type="text" id="diagnoseTitle" class="bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-xs outline-none focus:border-primary transition" placeholder="e.g. Device Not Responding" required>
                    </div>
                    <div class="flex flex-col gap-1.5">
                        <label for="diagnoseIcon" class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Icon</label>
                        <select id="diagnoseIcon" class="bg-darksec border border-bordercolor rounded-xl px-4 py-3 text-white text-xs outline-none focus:border-primary transition" required>
                            <option value="bolt">Bolt / Lightning</option>
                            <option value="wifi">Wi-Fi / Connectivity</option>
                            <option value="thermostat">Thermostat / Temperature</option>
                            <option value="battery">Battery / Power</option>
                            <option value="sync">Sync / Reload</option>
                            <option value="warning">Warning / Exclamation</option>
                        </select>
                    </div>
                </div>
                <div class="grid grid-cols-2 gap-4">
                    <div class="flex flex-col gap-1.5">
                        <label for="diagnoseColor" class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Highlight Color (HEX)</label>
                        <input type="text" id="diagnoseColor" class="bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-xs outline-none focus:border-primary transition" placeholder="e.g. #ef4444" required>
                    </div>
                    <div class="flex flex-col gap-1.5 justify-end">
                        <div class="flex items-center gap-2 mb-2">
                            <span class="text-[10px] text-textmuted">Common colors: Red: #ef4444 · Blue: #3b82f6 · Gold: #f59e0b · Green: #10b981 · Purple: #8b5cf6</span>
                        </div>
                    </div>
                </div>
                <div class="flex flex-col gap-1.5">
                    <label for="diagnoseDesc" class="text-[10px] font-bold text-textsecondary uppercase tracking-wider">Description</label>
                    <textarea id="diagnoseDesc" rows="2" class="bg-white/5 border border-bordercolor rounded-xl px-4 py-3 text-white text-xs outline-none focus:border-primary transition resize-none" placeholder="Provide a troubleshooting summary..." required></textarea>
                </div>

                <!-- Steps builder -->
                <div class="h-[1px] bg-bordercolor my-2"></div>
                <div class="flex justify-between items-center">
                    <span class="text-[10px] font-bold text-primary uppercase tracking-wider">Troubleshooting Steps</span>
                    <button type="button" onclick="addDiagnoseStepRow()" class="bg-primary/10 text-primary hover:bg-primary hover:text-white px-2 py-1 rounded text-[10px] font-bold transition">
                        <i class="fa-solid fa-plus mr-1"></i> Add Step
                    </button>
                </div>
                <div class="flex flex-col gap-2" id="diagnoseStepsContainer"></div>

                <div class="flex justify-end gap-3 mt-4">
                    <button type="button" onclick="closeModal('diagnoseModal')" class="bg-transparent border border-bordercolor text-textsecondary px-4 py-2.5 rounded-xl text-xs font-semibold hover:bg-white/5 transition">Cancel</button>
                    <button type="submit" class="bg-gradient-to-tr from-primary to-secondary text-white font-bold text-xs px-4 py-2.5 rounded-xl transition">Save Diagnose Option</button>
                </div>
            </form>
        </div>
    </div>
</div>

<?php
require_once __DIR__ . '/includes/footer.php';
?>
