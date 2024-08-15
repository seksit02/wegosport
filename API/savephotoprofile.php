<?php
include 'Connect.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $user_id = isset($_POST['user_id']) ? $_POST['user_id'] : '';

    // Upload file
    if (isset($_FILES['image']) && $_FILES['image']['error'] === UPLOAD_ERR_OK) {
        $fileTmpPath = $_FILES['image']['tmp_name'];
        $fileName = $_FILES['image']['name'];
        $fileSize = $_FILES['image']['size'];
        $fileType = $_FILES['image']['type'];
        $fileNameCmps = explode(".", $fileName);
        $fileExtension = strtolower(end($fileNameCmps));
        $newFileName = md5(time() . $fileName) . '.' . $fileExtension;
        $uploadFileDir = 'C:/xampp/htdocs/flutter_webservice/upload/';
        $dest_path = $uploadFileDir . $newFileName;
        $relative_url = '' . $newFileName; // Relative URL for access

        if(move_uploaded_file($fileTmpPath, $dest_path)) {
            $user_photo = $relative_url;

            // Update user photo in database
            $sql = "UPDATE user_information SET user_photo = '$user_photo' WHERE user_id = '$user_id'";
            if (mysqli_query($conn, $sql)) {
                echo json_encode(array("status" => "success", "image_url" => $user_photo));
            } else {
                echo json_encode(array("status" => "error", "message" => "Error: " . mysqli_error($conn)));
            }
        } else {
            echo json_encode(array("status" => "error", "message" => "There was an error uploading the file."));
        }
    } else {
        echo json_encode(array("status" => "error", "message" => "No file uploaded or there was an upload error."));
    }
} else {
    echo json_encode(array("status" => "error", "message" => "Invalid request method."));
}
?>
