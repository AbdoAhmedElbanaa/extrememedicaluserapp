<?php
/**
 * Image Uploader Script
 * Extreme Medical Web Administration
 */
require_once __DIR__ . '/config.php';
check_auth();

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['status' => 'error', 'message' => 'Invalid request method.']);
    exit;
}

if (!isset($_FILES['image']) || $_FILES['image']['error'] !== UPLOAD_ERR_OK) {
    $errCode = isset($_FILES['image']) ? $_FILES['image']['error'] : 'no_file';
    echo json_encode(['status' => 'error', 'message' => 'No file uploaded or upload error occurred. Error code: ' . $errCode]);
    exit;
}

$file = $_FILES['image'];
$fileName = $file['name'];
$fileTmp = $file['tmp_name'];
$fileSize = $file['size'];

// Check file size limit (5MB)
if ($fileSize > 5 * 1024 * 1024) {
    echo json_encode(['status' => 'error', 'message' => 'File size exceeds maximum limit of 5MB.']);
    exit;
}

// Check if valid image extension and mime type
$allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
$extension = strtolower(pathinfo($fileName, PATHINFO_EXTENSION));

if (!in_array($extension, $allowedExtensions)) {
    echo json_encode(['status' => 'error', 'message' => 'Only image files (JPG, PNG, GIF, WEBP) are allowed.']);
    exit;
}

// Validate mime type using getimagesize
$imageInfo = @getimagesize($fileTmp);
if ($imageInfo === false) {
    echo json_encode(['status' => 'error', 'message' => 'File is not a valid image.']);
    exit;
}

// Create uploads directory if it does not exist
$targetDir = __DIR__ . '/uploads/devices';
if (!file_exists($targetDir)) {
    if (!mkdir($targetDir, 0777, true)) {
        echo json_encode(['status' => 'error', 'message' => 'Failed to create upload directory. Check file system permissions.']);
        exit;
    }
}

// Generate unique filename to avoid collision
$newFileName = uniqid('device_', true) . '.' . $extension;
$targetPath = $targetDir . '/' . $newFileName;

if (move_uploaded_file($fileTmp, $targetPath)) {
    // Return relative url path starting with uploads/devices/
    $relativeUrl = 'uploads/devices/' . $newFileName;
    echo json_encode([
        'status' => 'success',
        'url' => $relativeUrl
    ]);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Failed to save uploaded file.']);
}
?>
