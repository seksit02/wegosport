<?php
include 'Connect.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $location_name = isset($_POST['location_name']) ? $_POST['location_name'] : '';
    $location_time = isset($_POST['location_time']) ? $_POST['location_time'] : '';
    $location_note = isset($_POST['location_note']) ? $_POST['location_note'] : '';

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
        $relative_url = '/flutter_webservice/upload/' . $newFileName; // Relative URL for access

        if(move_uploaded_file($fileTmpPath, $dest_path)) {
            $location_photo = $relative_url;

            // Insert data into database
            $sql = "INSERT INTO location (location_name, location_time, location_photo, location_map) VALUES ('$location_name', '$location_time', '$location_photo', '$location_note')";
            if (mysqli_query($conn, $sql)) {
                $response = array("status" => "success", "message" => "Location added successfully.");
            } else {
                $response = array("status" => "error", "message" => "Error: " . mysqli_error($conn));
            }
        } else {
            $response = array("status" => "error", "message" => "There was an error uploading the file.");
        }
    } else {
        $response = array("status" => "error", "message" => "No file uploaded or there was an upload error.");
    }

    echo json_encode($response);
}
?>
