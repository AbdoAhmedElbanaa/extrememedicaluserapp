<?php
/**
 * Configuration & Session Management
 * Extreme Medical Admin Dashboard
 */

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

define('SITE_NAME', 'Extreme Medical Admin');
define('APP_VERSION', '2.0.0');

// Simple helper to restrict page access
function check_auth() {
    if (!isset($_SESSION['admin_logged_in']) || $_SESSION['admin_logged_in'] !== true) {
        header('Location: login.php');
        exit;
    }
}
?>
