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

    $activity_name = trim($json_data["activity_name"]);
    $activity_details = trim($json_data["activity_details"]);
    $activity_date = trim($json_data["activity_date"]);
    $location_name = trim($json_data["location_name"]);
    $sport_id = trim($json_data["sport_id"]);
    $hashtags = $json_data["hashtags"];
    $creator = $json_data["creator"]; // รับข้อมูลผู้สร้างกิจกรรม

    if ($conn->connect_error) {
        echo json_encode(array("result" => 0, "message" => "Database connection failed", "datalist" => null));
        http_response_code(500);
        exit;
    }

    // Get location_id from location_name
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
    $datalist = array();

    if ($query) {
        $activity_id = $stmt->insert_id;
        $result = 1;
        $message = "เพิ่มข้อมูลสำเร็จ";
        $datalist[] = array("ID" => $activity_id, "activity_name" => $activity_name, "activity_details" => $activity_details, "activity_date" => $activity_date);

        // Insert creator into member_in_activity table
        $stmt = $conn->prepare("INSERT INTO member_in_activity (activity_id, user_id) VALUES (?, ?)");
        $stmt->bind_param("is", $activity_id, $creator['user_id']);
        $stmt->execute();
        $stmt->close();

        // Insert hashtags
        foreach ($hashtags as $hashtag_message) {
            $hashtag_message = trim($hashtag_message);

            // Check if hashtag exists
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
    } else {
        $result = 0;
        $message = "มีข้อมูลซ้ำในระบบ";
        $datalist[] = null;
    }

    echo json_encode(array("result" => $result, "message" => $message, "datalist" => $datalist));
    $conn->close();
    exit;
}
?>
