<?php
require 'Connect.php';

//3. request from client
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $content = file_get_contents("php://input"); // plaintext
    $json_data = json_decode($content, true); // เอา plaintext มาจัดรูปแบบเป็น json (json_decode)

    if ($json_data === null) {
        // JSON decode failed
        echo json_encode(array("result" => 0, "message" => "Invalid JSON input", "datalist" => null));
        http_response_code(400);
        exit;
    }

    $activity_name = mysqli_real_escape_string($conn, trim($json_data["activity_name"]));
    $activity_details = mysqli_real_escape_string($conn, trim($json_data["activity_details"]));
    $activity_date = mysqli_real_escape_string($conn, trim($json_data["activity_date"]));
    $location_name = mysqli_real_escape_string($conn, trim($json_data["location_name"]));
    $sport_id = mysqli_real_escape_string($conn, trim($json_data["sport_id"]));
    $hashtags = $json_data["hashtags"]; // this should be an array

    // Get location_id from location_name
    $location_query = "SELECT location_id FROM location WHERE location_name = '$location_name'";
    $location_result = mysqli_query($conn, $location_query);
    if (mysqli_num_rows($location_result) > 0) {
        $location_row = mysqli_fetch_assoc($location_result);
        $location_id = $location_row['location_id'];
    } else {
        // If location not found, return error
        echo json_encode(array("result" => 0, "message" => "Invalid location", "datalist" => null));
        http_response_code(400);
        exit;
    }

    //4. sql command / process
    $strSQL = "INSERT INTO activity (activity_name, activity_details, activity_date, location_id, sport_id) VALUES ('$activity_name','$activity_details','$activity_date', '$location_id', '$sport_id')";
    $query = @mysqli_query($conn, $strSQL);
    $datalist = array();

    if ($query) {
        $activity_id = mysqli_insert_id($conn);
        $result = 1;
        $message = "เพิ่มข้อมูลสำเร็จ";
        $datalist[] = array("ID" => $activity_id, "activity_name" => $activity_name, "activity_details" => $activity_details, "activity_date" => $activity_date );

        // Insert hashtags into hashtags_in_activities table
        foreach ($hashtags as $hashtag_message) {
            $hashtag_message = mysqli_real_escape_string($conn, trim($hashtag_message));
            
            // Check if hashtag exists
            $hashtag_query = "SELECT hashtag_id FROM hashtag WHERE hashtag_message = '$hashtag_message'";
            $hashtag_result = mysqli_query($conn, $hashtag_query);
            if (mysqli_num_rows($hashtag_result) > 0) {
                // Hashtag exists, get its ID
                $hashtag_row = mysqli_fetch_assoc($hashtag_result);
                $hashtag_id = $hashtag_row['hashtag_id'];
            } else {
                // Hashtag does not exist, insert it
                $insert_hashtag_query = "INSERT INTO hashtag (hashtag_message) VALUES ('$hashtag_message')";
                mysqli_query($conn, $insert_hashtag_query);
                $hashtag_id = mysqli_insert_id($conn);
            }

            // Insert into hashtags_in_activities table
            $insert_hashtag_activity_query = "INSERT INTO hashtags_in_activities (activity_id, hashtag_id) VALUES ('$activity_id', '$hashtag_id')";
            mysqli_query($conn, $insert_hashtag_activity_query);
        }
    } else {
        $result = 0;
        $message = "มีข้อมูลซ้ำในระบบ";
        $datalist[] = null;
    }

    echo json_encode(array("result" => $result, "message" => $message, "datalist" => $datalist));
    mysqli_close($conn);
    exit;
}
?>
