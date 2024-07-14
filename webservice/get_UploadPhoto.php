<?php
require 'Connect.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    if (isset($_FILES['image']) && $_FILES['image']['error'] == UPLOAD_ERR_OK) {
        $uploadDir = 'C:/xampp/htdocs/flutter_webservice/upload/';
        $uploadFile = $uploadDir . basename($_FILES['image']['name']);

        if (move_uploaded_file($_FILES['image']['tmp_name'], $uploadFile)) {
            $userId = $_POST['user_id'];
            $imagePath = $uploadFile;

            $sql = "UPDATE user_information SET user_photo='$imagePath' WHERE user_id='$userId'";

            if ($conn->query($sql) === TRUE) {
                echo json_encode(['status' => 'success', 'message' => 'File uploaded and database updated successfully']);
            } else {
                echo json_encode(['status' => 'error', 'message' => 'Database update failed']);
            }
        } else {
            echo json_encode(['status' => 'error', 'message' => 'File upload failed']);
        }
    } else {
        echo json_encode(['status' => 'error', 'message' => 'No file uploaded or file upload error']);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid request method']);
}

$conn->close();
?>