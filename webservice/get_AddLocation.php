<?php
include 'Connect.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $location_name = isset($_POST['location_name']) ? $_POST['location_name'] : '';
    $location_time = isset($_POST['location_time']) ? $_POST['location_time'] : '';
    $latitude = isset($_POST['latitude']) ? $_POST['latitude'] : '';
    $longitude = isset($_POST['longitude']) ? $_POST['longitude'] : '';
    $types_id = isset($_POST['types_id']) ? json_decode($_POST['types_id']) : [];
    

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
        $relative_url = 'upload/' . $newFileName; // Relative URL for access

        if(move_uploaded_file($fileTmpPath, $dest_path)) {
            $location_photo = $relative_url;

            // Insert data into database
            $sql = "INSERT INTO location (location_name, location_time, location_photo, latitude, longitude) VALUES ('$location_name', '$location_time', '$location_photo', '$latitude', '$longitude')";
            if (mysqli_query($conn, $sql)) {
                $location_id = mysqli_insert_id($conn);

                // แทรกประเภทสนามลงในตาราง sport_type_in_location
                foreach ($types_id as $type_id) {
                    $type_id = mysqli_real_escape_string($conn, $type_id);
                    $sql_type = "INSERT INTO sport_type_in_location (location_id, type_id) VALUES ('$location_id', '$type_id')";
                    if (!mysqli_query($conn, $sql_type)) {
                        echo json_encode(array("status" => "error", "message" => "Error: " . mysqli_error($conn)));
                        exit();
                    }
                }
                echo json_encode(array("status" => "success", "message" => "Location added successfully."));
                
            } else {
                echo json_encode(array("status" => "error", "message" => "Error: " . mysqli_error($conn)));
            }
        } else {
            echo json_encode(array("status" => "error", "message" => "There was an error uploading the file."));
        }
    } else {
        echo json_encode(array("status" => "error", "message" => "No file uploaded or there was an upload error."));
    }
}
?>
