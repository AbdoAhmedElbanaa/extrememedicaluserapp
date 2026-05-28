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

    <!-- Theme CSS (Removed local style.css link and using Tailwind CSS) -->
    <!-- Tailwind CSS CDN -->
    <script src="/assets/css/tailwandcss.js"></script>
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