<?php
require 'Connect.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $content = file_get_contents("php://input");
    $json_data = json_decode($content, true);

    if ($json_data === null) {
        echo json_encode(array("result" => 0, "message" => "Invalid JSON input", "datalist" => null));
        http_response_code(400);
        exit;
    }

    // ข้อมูลที่จำเป็น
    $activity_name = trim($json_data["activity_name"]);
    $activity_details = trim($json_data["activity_details"]);
    $activity_date = trim($json_data["activity_date"]);
    $location_name = trim($json_data["location_name"]);
    $sport_id = trim($json_data["sport_id"]);
    $hashtags = $json_data["hashtags"];
    $user_id = trim($json_data["user_id"]); // รับ user_id ของผู้สร้างกิจกรรม

    // ตรวจสอบว่า user_id มีอยู่ในตาราง user_information หรือไม่
    $stmt = $conn->prepare("SELECT COUNT(*) FROM user_information WHERE user_id = ?");
    $stmt->bind_param("s", $user_id);
    $stmt->execute();
    $stmt->bind_result($count);
    $stmt->fetch();

    if ($count == 0) {
        echo json_encode(array("result" => 0, "message" => "Invalid user ID", "datalist" => null));
        http_response_code(400);
        exit;
    }
    $stmt->close();

    // Get location_id จาก location_name
    $stmt = $conn->prepare("SELECT location_id FROM location WHERE location_name = ?");
    $stmt->bind_param("s", $location_name);
    $stmt->execute();
    $stmt->store_result();
    if ($stmt->num_rows > 0) {
        $stmt->bind_result($location_id);
        $stmt->fetch();
    } else {
        echo json_encode(array("result" => 0, "message" => "Invalid location", "datalist" => null));
        http_response_code(400);
        exit;
    }
    $stmt->close();

    // Insert activity
    $stmt = $conn->prepare("INSERT INTO activity (activity_name, activity_details, activity_date, location_id, sport_id) VALUES (?, ?, ?, ?, ?)");
    $stmt->bind_param("sssii", $activity_name, $activity_details, $activity_date, $location_id, $sport_id);
    $query = $stmt->execute();

    if ($query) {
        // รับ activity_id ที่เพิ่งถูกสร้างขึ้น
        $activity_id = $stmt->insert_id;

        // แทรกข้อมูลลงในตาราง member_in_activity
        $stmt = $conn->prepare("INSERT INTO member_in_activity (activity_id, user_id) VALUES (?, ?)");
        $stmt->bind_param("is", $activity_id, $user_id);
        $stmt->execute();
        $stmt->close();

        // แทรกข้อมูลลงในตาราง creator
        $stmt = $conn->prepare("INSERT INTO creator (activity_id, user_id) VALUES (?, ?)");
        $stmt->bind_param("is", $activity_id, $user_id);
        $stmt->execute();
        $stmt->close();

        // Insert hashtags
        foreach ($hashtags as $hashtag_message) {
            $hashtag_message = trim($hashtag_message);

            // ตรวจสอบว่า hashtag มีอยู่หรือไม่
            $stmt = $conn->prepare("SELECT hashtag_id FROM hashtag WHERE hashtag_message = ?");
            $stmt->bind_param("s", $hashtag_message);
            $stmt->execute();
            $stmt->store_result();
            if ($stmt->num_rows > 0) {
                $stmt->bind_result($hashtag_id);
                $stmt->fetch();
            } else {
                $stmt->close();
                $stmt = $conn->prepare("INSERT INTO hashtag (hashtag_message) VALUES (?)");
                $stmt->bind_param("s", $hashtag_message);
                $stmt->execute();
                $hashtag_id = $stmt->insert_id;
            }
            $stmt->close();

            // Insert into hashtags_in_activities table
            $stmt = $conn->prepare("INSERT INTO hashtags_in_activities (activity_id, hashtag_id) VALUES (?, ?)");
            $stmt->bind_param("ii", $activity_id, $hashtag_id);
            $stmt->execute();
            $stmt->close();
        }

        echo json_encode(array("result" => 1, "message" => "Activity created successfully", "datalist" => array("activity_id" => $activity_id)));
    } else {
        echo json_encode(array("result" => 0, "message" => "Failed to create activity", "datalist" => null));
        http_response_code(400);
        exit;
    }

    $conn->close();
    exit;
}
?>
