<?php
/**
 * Video Uploader Script
 * Extreme Medical Web Administration
 */
require_once __DIR__ . '/config.php';
check_auth();

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['status' => 'error', 'message' => 'Invalid request method.']);
    exit;
}

if (!isset($_FILES['video']) || $_FILES['video']['error'] !== UPLOAD_ERR_OK) {
    $errCode = isset($_FILES['video']) ? $_FILES['video']['error'] : 'no_file';
    echo json_encode(['status' => 'error', 'message' => 'No file uploaded or upload error occurred. Error code: ' . $errCode]);
    exit;
}

$file = $_FILES['video'];
$fileName = $file['name'];
$fileTmp = $file['tmp_name'];
$fileSize = $file['size'];

// Check file size limit (100MB)
if ($fileSize > 100 * 1024 * 1024) {
    echo json_encode(['status' => 'error', 'message' => 'Video file size exceeds maximum limit of 100MB.']);
    exit;
}

// Check allowed extensions
$allowedExtensions = ['mp4', 'mov', 'avi', 'webm', 'mkv', '3gp'];
$extension = strtolower(pathinfo($fileName, PATHINFO_EXTENSION));

if (!in_array($extension, $allowedExtensions)) {
    echo json_encode(['status' => 'error', 'message' => 'Only video files (MP4, MOV, AVI, WEBM, MKV, 3GP) are allowed.']);
    exit;
}

// Create uploads directory if it does not exist
$targetDir = __DIR__ . '/uploads/videos';
if (!file_exists($targetDir)) {
    if (!mkdir($targetDir, 0777, true)) {
        echo json_encode(['status' => 'error', 'message' => 'Failed to create upload directory. Check file system permissions.']);
        exit;
    }
}

// Generate unique filename to avoid collision
$newFileName = uniqid('video_', true) . '.' . $extension;
$targetPath = $targetDir . '/' . $newFileName;

if (move_uploaded_file($fileTmp, $targetPath)) {
    // Return relative url path starting with uploads/videos/
    $relativeUrl = 'uploads/videos/' . $newFileName;
    echo json_encode([
        'status' => 'success',
        'url' => $relativeUrl
    ]);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Failed to save uploaded file.']);
}
?>
