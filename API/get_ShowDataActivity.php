<?php
require 'Connect.php'; // เชื่อมต่อกับฐานข้อมูล

// สร้างคำสั่ง SQL เพื่อดึงข้อมูลกิจกรรมและข้อมูลที่เกี่ยวข้องจากหลายตาราง
$sql = "SELECT 
            a.activity_id,
            a.activity_name,
            a.activity_details,
            a.activity_date,
            a.status,
            c.user_id,  
            l.location_id,
            l.location_name,
            l.location_time,
            l.location_photo,
            l.latitude,  
            l.longitude,
            s.sport_name  
        FROM 
            activity a
        JOIN 
            location l ON a.location_id = l.location_id
        JOIN 
            sport s ON a.sport_id = s.sport_id
        JOIN 
            creator c ON a.activity_id = c.activity_id";


$result = $conn->query($sql); // รันคำสั่ง SQL และรับผลลัพธ์จากฐานข้อมูล

$activities = array(); // สร้างอาร์เรย์สำหรับเก็บข้อมูลกิจกรรม

if ($result->num_rows > 0) { // ตรวจสอบว่ามีกิจกรรมในผลลัพธ์หรือไม่
    while($row = $result->fetch_assoc()) { // วนลูปผ่านแต่ละกิจกรรมที่พบ
        $location_photo_url = 'http://10.0.2.2/flutter_webservice/upload/' . $row["location_photo"]; // สร้าง URL สำหรับภาพสถานที่
        
        // สร้างอาร์เรย์สำหรับเก็บข้อมูลกิจกรรมแต่ละกิจกรรม
        $activity = array(
            "activity_id" => $row["activity_id"],
            "activity_name" => $row["activity_name"],
            "activity_details" => $row["activity_details"],
            "activity_date" => $row["activity_date"],
            "status" => $row["status"],  // เพิ่มค่า status ของกิจกรรม
            "location_name" => $row["location_name"],
            "location_time" => $row["location_time"],
            "location_photo" => $location_photo_url, // เพิ่ม URL รูปภาพสถานที่
            "latitude" => $row["latitude"],
            "longitude" => $row["longitude"],
            "creator" => $row["user_id"], 
            "sport_name" => $row["sport_name"] // เพิ่ม sport_name จากตาราง sport
        );

        // ดึงข้อมูลสมาชิกในกิจกรรม
        $activity["members"] = getMembersInActivity($conn, $row["activity_id"]);
        // ดึงข้อมูลประเภทกีฬาในสถานที่
        $activity["sport_types"] = getSportTypesInLocation($conn, $row["location_id"]);
        // ดึงข้อมูล hashtags ในกิจกรรม
        $activity["hashtags"] = getHashtagsInActivity($conn, $row["activity_id"]);
        
        $activities[] = $activity; // เพิ่มข้อมูลกิจกรรมลงในอาร์เรย์ของกิจกรรมทั้งหมด
    }
}

// แปลงอาร์เรย์ข้อมูลกิจกรรมทั้งหมดเป็น JSON และส่งออก
echo json_encode($activities);

$conn->close(); // ปิดการเชื่อมต่อฐานข้อมูล

// ฟังก์ชันสำหรับดึงข้อมูลสมาชิกในกิจกรรม
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
    $stmt = $conn->prepare($sql); // เตรียมคำสั่ง SQL
    $stmt->bind_param("i", $activity_id); // ผูกค่า activity_id เข้ากับคำสั่ง SQL
    $stmt->execute(); // รันคำสั่ง SQL
    $result = $stmt->get_result(); // รับผลลัพธ์จากคำสั่ง SQL

    $members = array(); // สร้างอาร์เรย์สำหรับเก็บข้อมูลสมาชิก

    if ($result->num_rows > 0) { // ตรวจสอบว่ามีสมาชิกในกิจกรรมหรือไม่
        while($row = $result->fetch_assoc()) { // วนลูปผ่านแต่ละสมาชิก
            $member = array(
                "user_id" => $row["user_id"],
                "user_name" => $row["user_name"],
                "user_email" => $row["user_email"],
                "user_age" => $row["user_age"],
                "user_photo" => 'http://10.0.2.2/flutter_webservice/upload/' . $row["user_photo"] // สร้าง URL สำหรับรูปภาพสมาชิก
            );
            $members[] = $member; // เพิ่มข้อมูลสมาชิกลงในอาร์เรย์ของสมาชิก
        }
    }

    $stmt->close(); // ปิด statement
    return $members; // ส่งคืนอาร์เรย์ของสมาชิก
}

// ฟังก์ชันสำหรับดึงข้อมูลประเภทกีฬาในสถานที่
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
    $stmt = $conn->prepare($sql); // เตรียมคำสั่ง SQL
    $stmt->bind_param("i", $location_id); // ผูกค่า location_id เข้ากับคำสั่ง SQL
    $stmt->execute(); // รันคำสั่ง SQL
    $result = $stmt->get_result(); // รับผลลัพธ์จากคำสั่ง SQL

    $sport_types = array(); // สร้างอาร์เรย์สำหรับเก็บข้อมูลประเภทกีฬา

    if ($result->num_rows > 0) { // ตรวจสอบว่ามีประเภทกีฬาในสถานที่หรือไม่
        while($row = $result->fetch_assoc()) { // วนลูปผ่านแต่ละประเภทกีฬา
            $sport_type = array(
                "type_id" => $row["type_id"],
                "type_name" => $row["type_name"]
            );
            $sport_types[] = $sport_type; // เพิ่มข้อมูลประเภทกีฬาลงในอาร์เรย์ของประเภทกีฬา
        }
    }

    $stmt->close(); // ปิด statement
    return $sport_types; // ส่งคืนอาร์เรย์ของประเภทกีฬา
}

// ฟังก์ชันสำหรับดึงข้อมูล hashtags ในกิจกรรม
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
    $stmt = $conn->prepare($sql); // เตรียมคำสั่ง SQL
    $stmt->bind_param("i", $activity_id); // ผูกค่า activity_id เข้ากับคำสั่ง SQL
    $stmt->execute(); // รันคำสั่ง SQL
    $result = $stmt->get_result(); // รับผลลัพธ์จากคำสั่ง SQL

    $hashtags = array(); // สร้างอาร์เรย์สำหรับเก็บข้อมูล hashtags

    if ($result->num_rows > 0) { // ตรวจสอบว่ามี hashtags ในกิจกรรมหรือไม่
        while($row = $result->fetch_assoc()) { // วนลูปผ่านแต่ละ hashtag
            $hashtag = array(
                "hashtag_id" => $row["hashtag_id"],
                "hashtag_message" => $row["hashtag_message"]
            );
            $hashtags[] = $hashtag; // เพิ่มข้อมูล hashtag ลงในอาร์เรย์ของ hashtags
        }
    }

    $stmt->close(); // ปิด statement
    return $hashtags; // ส่งคืนอาร์เรย์ของ hashtags
}
?>
