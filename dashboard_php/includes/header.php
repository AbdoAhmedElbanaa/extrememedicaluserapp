<?php
require_once __DIR__ . '/../config.php';
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo isset($page_title) ? $page_title . ' - ' . SITE_NAME : SITE_NAME; ?></title>

    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link
        href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800;900&family=Poppins:wght@300;400;500;600;700&display=swap"
        rel="stylesheet">

    <!-- FontAwesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <!-- Leaflet.js Mapping Library (For interactive map overlays) -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
        integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=" crossorigin="" />

    <!-- Chart.js (For dashboard charts) -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <!-- Dynamic Page Styles Injections -->
    <?php if (isset($page_styles) && is_array($page_styles)): ?>
        <?php foreach ($page_styles as $style): ?>
            <link rel="stylesheet" href="<?php echo $style; ?>">
        <?php endforeach; ?>
    <?php endif; ?>

    <!-- Theme CSS (Using Tailwind CSS CDN) -->
    <!-- Tailwind CSS CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        darkbg: '#0a0d16',
                        darksec: '#111523',
                        darksurface: 'rgba(20, 26, 45, 0.65)',
                        darkcard: 'rgba(28, 36, 62, 0.45)',
                        bordercolor: 'rgba(255, 255, 255, 0.08)',
                        primary: {
                            DEFAULT: '#6366f1',
                            glow: 'rgba(99, 102, 241, 0.4)',
                        },
                        secondary: '#a855f7',
                        success: {
                            DEFAULT: '#10b981',
                            glow: 'rgba(16, 185, 129, 0.25)',
                        },
                        danger: {
                            DEFAULT: '#ef4444',
                            glow: 'rgba(239, 68, 68, 0.25)',
                        },
                        warning: {
                            DEFAULT: '#f59e0b',
                            glow: 'rgba(245, 158, 11, 0.25)',
                        },
                        textprimary: '#f8fafc',
                        textsecondary: '#94a3b8',
                        textmuted: '#64748b',
                    },
                    fontFamily: {
                        sans: ['Outfit', 'Poppins', 'sans-serif'],
                    },
                    boxShadow: {
                        primaryglow: '0 4px 15px rgba(99, 102, 241, 0.25)',
                        primaryglowhover: '0 6px 20px rgba(99, 102, 241, 0.45)',
                        dangerglow: '0 4px 15px rgba(239, 68, 68, 0.25)',
                        dangerglowhover: '0 6px 20px rgba(239, 68, 68, 0.45)',
                    },
                }
            }
        }
    </script>

    <style type="text/tailwind">
        @layer base {
            body {
                @apply bg-darkbg text-textprimary font-sans min-h-screen overflow-x-hidden;
            }
        }
        
        /* Stepper Node state styles */
        .step-node {
            @apply flex items-center gap-2 text-xs font-bold text-textmuted transition-colors duration-200;
        }
        .step-node > div {
            @apply w-6 h-6 rounded-full bg-white/5 border border-bordercolor flex items-center justify-center text-[10px] transition-all duration-200;
        }
        .step-node.active {
            @apply text-primary;
        }
        .step-node.active > div {
            @apply bg-primary border-primary text-white shadow-primaryglow;
        }
        .step-node.completed {
            @apply text-success;
        }
        .step-node.completed > div {
            @apply bg-success border-success text-white shadow-primaryglow;
        }
        
        /* Status Badges */
        .status-badge {
            @apply px-2.5 py-1 rounded-lg text-[10px] font-bold inline-flex items-center gap-1.5 transition-colors duration-200;
        }
        .status-badge > i {
            @apply text-[8px];
        }
        .status-badge.success {
            @apply bg-success/15 text-success;
        }
        .status-badge.danger {
            @apply bg-danger/15 text-danger;
        }
        .status-badge.warning {
            @apply bg-warning/15 text-warning;
        }
        
        /* Custom overrides for Leaflet map tiles & controls */
        .leaflet-bar a {
            background-color: #111523 !important;
            color: #f8fafc !important;
            border-bottom: 1px solid rgba(255, 255, 255, 0.08) !important;
        }
        .leaflet-bar a:hover {
            background-color: #6366f1 !important;
        }
        .leaflet-control-attribution {
            background: rgba(10, 13, 22, 0.8) !important;
            color: #94a3b8 !important;
        }

        /* --- Custom Professional Overrides for DataTables in Dark Theme --- */
        .dataTables_wrapper {
            @apply text-textsecondary text-xs;
            padding: 1.5rem 0 0 0;
        }
        
        /* Table headers */
        table.dataTable thead th {
            @apply border-b border-bordercolor text-textsecondary text-[11px] font-bold uppercase tracking-wider p-4 !important;
        }
        
        /* Table body rows */
        table.dataTable tbody td {
            @apply border-b border-bordercolor text-xs text-white p-4 !important;
        }
        
        /* Sorting Icons */
        table.dataTable thead .sorting::after,
        table.dataTable thead .sorting_asc::after,
        table.dataTable thead .sorting_desc::after {
            color: #6366f1 !important;
            opacity: 0.6;
        }
        
        /* Length select dropdown */
        .dataTables_length {
            @apply mb-4 text-textsecondary font-medium !important;
        }
        .dataTables_length select {
            @apply bg-white/5 border border-bordercolor rounded-xl px-3 py-1.5 text-white text-xs outline-none focus:border-primary transition duration-200 ml-2 mr-2 cursor-pointer !important;
        }
        
        /* Info section */
        .dataTables_info {
            @apply text-textsecondary font-medium text-xs py-4 !important;
        }
        
        /* Pagination buttons */
        .dataTables_paginate {
            @apply py-4 flex gap-1 justify-end items-center !important;
        }
        .dataTables_paginate .paginate_button {
            @apply bg-white/5 border border-bordercolor text-textsecondary rounded-xl px-3.5 py-2 text-xs font-bold transition duration-200 cursor-pointer hover:bg-gradient-to-tr hover:from-primary hover:to-secondary hover:text-white hover:border-transparent hover:shadow-primaryglow !important;
            margin: 0 !important;
        }
        .dataTables_paginate .paginate_button.current {
            @apply bg-gradient-to-tr from-primary to-secondary text-white border-transparent shadow-primaryglow font-extrabold !important;
        }
        .dataTables_paginate .paginate_button.disabled, 
        .dataTables_paginate .paginate_button.disabled:hover {
            @apply bg-white/5 border border-bordercolor text-textmuted cursor-not-allowed shadow-none hover:bg-white/5 hover:text-textmuted hover:border-bordercolor !important;
        }
        
        /* Responsive details toggle button */
        table.dataTable.dtr-inline.collapsed > tbody > tr > td.dtr-control::before {
            @apply bg-gradient-to-tr from-primary to-secondary text-white border-none shadow-primaryglow font-sans flex items-center justify-center !important;
            height: 16px !important;
            width: 16px !important;
            line-height: 16px !important;
            border-radius: 6px !important;
            font-size: 12px !important;
            content: "+" !important;
        }
        table.dataTable.dtr-inline.collapsed > tbody > tr.parent > td.dtr-control::before {
            @apply bg-gradient-to-tr from-danger to-danger/80 !important;
            content: "-" !important;
        }
        
        /* Responsive child details row */
        table.dataTable > tbody > tr.child {
            @apply bg-darksec/40 !important;
        }
        table.dataTable > tbody > tr.child ul.dtr-details {
            @apply w-full bg-darksec/60 border border-bordercolor rounded-[18px] p-4 flex flex-col gap-2.5 !important;
        }
        table.dataTable > tbody > tr.child li {
            @apply flex justify-between items-center border-b border-bordercolor/40 pb-2.5 last:border-none last:pb-0 !important;
        }
        table.dataTable > tbody > tr.child span.dtr-title {
            @apply text-[11px] font-bold text-textsecondary uppercase tracking-wider !important;
        }
        table.dataTable > tbody > tr.child span.dtr-data {
            @apply text-xs text-white font-medium !important;
        }
        
        /* Export Buttons Container positioning */
        .dt-buttons {
            @apply flex flex-wrap gap-2.5 mb-4 !important;
        }
    </style>

    <!-- Firebase SDK (Compat Mode for pure JS script-tag environment) -->
    <script src="https://www.gstatic.com/firebasejs/10.8.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/10.8.0/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/10.8.0/firebase-firestore-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/10.8.0/firebase-database-compat.js"></script>
</head>

<body class="bg-darkbg text-textprimary font-sans min-h-screen overflow-x-hidden">
    <!-- Main App Layout Wrapper -->
    <div class="flex min-h-screen">