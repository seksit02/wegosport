<?php
require 'Connect.php'; // เชื่อมต่อกับฐานข้อมูล

$sql = "SELECT 
            a.activity_id,
            a.activity_name,
            a.activity_details,
            a.activity_date,
            l.location_id,
            l.location_name,
            l.location_time,
            l.location_photo,
            l.latitude,  
            l.longitude
        FROM 
            activity a
        JOIN 
            location l ON a.location_id = l.location_id";
$result = $conn->query($sql);

$activities = array();

if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $location_photo_url = 'http://10.0.2.2/flutter_webservice/upload/' . $row["location_photo"]; // Full URL
        
        
        $activity = array(
            "activity_id" => $row["activity_id"],
            "activity_name" => $row["activity_name"],
            "activity_details" => $row["activity_details"],
            "activity_date" => $row["activity_date"],
            "location_name" => $row["location_name"],
            "location_time" => $row["location_time"],
            "location_photo" => $location_photo_url,
            "latitude" => $row["latitude"],
            "longitude" => $row["longitude"] 
        );

        // ดึงข้อมูลสมาชิกในกิจกรรม
        $activity["members"] = getMembersInActivity($conn, $row["activity_id"]);
        // ดึงข้อมูลประเภทกีฬาในสถานที่
        $activity["sport_types"] = getSportTypesInLocation($conn, $row["location_id"]);
        // ดึงข้อมูล hashtags ในกิจกรรม
        $activity["hashtags"] = getHashtagsInActivity($conn, $row["activity_id"]);
        
        $activities[] = $activity;
    }
}

echo json_encode($activities);

$conn->close();

function getMembersInActivity($conn, $activity_id) {
    $sql = "SELECT 
                m.user_id,
                u.user_name,
                u.user_email,
                u.user_age,
                u.user_photo
            FROM 
                member_in_activity m
            JOIN 
                user_information u ON m.user_id = u.user_id
            WHERE 
                m.activity_id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $activity_id);
    $stmt->execute();
    $result = $stmt->get_result();

    $members = array();

    if ($result->num_rows > 0) {
        while($row = $result->fetch_assoc()) {
            $member = array(
                "user_id" => $row["user_id"],
                "user_name" => $row["user_name"],
                "user_email" => $row["user_email"],
                "user_age" => $row["user_age"],
                "user_photo" => 'http://10.0.2.2/flutter_webservice/upload/' . $row["user_photo"]
            );
            $members[] = $member;
        }
    }

    $stmt->close();
    return $members;
}


function getSportTypesInLocation($conn, $location_id) {
    $sql = "SELECT 
                s.type_id,
                s.type_name
            FROM 
                sport_type_in_location stl
            JOIN 
                sport_type s ON stl.type_id = s.type_id
            WHERE 
                stl.location_id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $location_id);
    $stmt->execute();
    $result = $stmt->get_result();

    $sport_types = array();

    if ($result->num_rows > 0) {
        while($row = $result->fetch_assoc()) {
            $sport_type = array(
                "type_id" => $row["type_id"],
                "type_name" => $row["type_name"]
            );
            $sport_types[] = $sport_type;
        }
    }

    $stmt->close();
    return $sport_types;
}

function getHashtagsInActivity($conn, $activity_id) {
    $sql = "SELECT 
                h.hashtag_id,
                h.hashtag_message
            FROM 
                hashtags_in_activities hia
            JOIN 
                hashtag h ON hia.hashtag_id = h.hashtag_id
            WHERE 
                hia.activity_id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $activity_id);
    $stmt->execute();
    $result = $stmt->get_result();

    $hashtags = array();

    if ($result->num_rows > 0) {
        while($row = $result->fetch_assoc()) {
            $hashtag = array(
                "hashtag_id" => $row["hashtag_id"],
                "hashtag_message" => $row["hashtag_message"]
            );
            $hashtags[] = $hashtag;
        }
    }

    $stmt->close();
    return $hashtags;
}
?>
