<?php
require 'Connect.php'; // เชื่อมต่อกับฐานข้อมูล

// ฟังก์ชันเพื่อดึงข้อมูลจากฐานข้อมูล
function getActivities($conn) {
    $sql = "SELECT 
                a.activity_id,
                a.activity_name,
                a.activity_details,
                a.activity_date,
                l.location_name,
                l.location_time
            FROM 
                activity a
            JOIN 
                location l ON a.location_id = l.location_id";
                
    $result = $conn->query($sql);
    
    $activities = array();
    
    if ($result->num_rows > 0) {
        while($row = $result->fetch_assoc()) {
            $activity = array(
                "activity_id" => $row["activity_id"],
                "activity_name" => $row["activity_name"],
                "activity_details" => $row["activity_details"],
                "activity_date" => $row["activity_date"],
                "location_name" => $row["location_name"],
                "location_time" => $row["location_time"]
            );
            
            // ดึงข้อมูลสมาชิกในกิจกรรม
            $activity["members"] = getMembersInActivity($conn, $row["activity_id"]);
            
            $activities[] = $activity;
        }
    }
    
    return $activities;
}

function getMembersInActivity($conn, $activity_id) {
    $sql = "SELECT 
                m.user_id,
                u.user_name,
                u.user_email,
                u.user_age
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
                "user_age" => $row["user_age"]
            );
            $members[] = $member;
        }
    }
    
    $stmt->close();
    return $members;
}

// ดึงข้อมูลกิจกรรมทั้งหมด
$activities = getActivities($conn);

// ปิดการเชื่อมต่อฐานข้อมูล
$conn->close();

// ส่งข้อมูลในรูปแบบ JSON
echo json_encode($activities);

?>
