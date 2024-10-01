<?php
require 'Connect.php'; // นำเข้าไฟล์ Connect.php เพื่อเชื่อมต่อกับฐานข้อมูล

if ($_SERVER["REQUEST_METHOD"] == "POST") { // ตรวจสอบว่าคำขอเป็น POST หรือไม่
    $content = file_get_contents("php://input"); // รับข้อมูลดิบจากอินพุต
    $json_data = json_decode($content, true); // แปลงข้อมูล JSON ที่ได้รับเป็น array

    if ($json_data === null) { // ตรวจสอบว่าการแปลง JSON สำเร็จหรือไม่
        echo json_encode(array("result" => 0, "message" => "Invalid JSON input", "datalist" => null));
        http_response_code(400); // ส่งรหัสสถานะ 400 (Bad Request)
        exit; // หยุดการทำงานถ้าข้อมูล JSON ไม่ถูกต้อง
    }

    // ดึงข้อมูลที่จำเป็นจาก JSON
    $activity_name = trim($json_data["activity_name"]); // ชื่อกิจกรรม
    $activity_details = trim($json_data["activity_details"]); // รายละเอียดกิจกรรม
    $activity_date = trim($json_data["activity_date"]); // วันที่กิจกรรม
    $location_name = trim($json_data["location_name"]); // ชื่อสถานที่
    $sport_id = trim($json_data["sport_id"]); // รหัสประเภทกีฬา
    $hashtags = $json_data["hashtags"]; // แฮชแท็กของกิจกรรม
    $user_id = trim($json_data["user_id"]); // รหัสผู้ใช้ที่สร้างกิจกรรม
    $status = trim($json_data["status"]);

    // ตรวจสอบว่า user_id มีอยู่ในตาราง user_information หรือไม่
    $stmt = $conn->prepare("SELECT 1 FROM user_information WHERE user_id = ? LIMIT 1");
    $stmt->bind_param("s", $user_id); // ผูกค่า user_id เข้ากับคำสั่ง SQL
    $stmt->execute(); // รันคำสั่ง SQL
    $stmt->store_result(); // เก็บผลลัพธ์

    if ($stmt->num_rows == 0) { // ตรวจสอบว่าพบ user_id หรือไม่
        echo json_encode(array("result" => 0, "message" => "Invalid user ID", "datalist" => null));
        http_response_code(400); // ส่งรหัสสถานะ 400 (Bad Request)
        exit; // หยุดการทำงานถ้าข้อมูล user_id ไม่พบ
    }
    $stmt->close(); // ปิด statement

    // ดึง location_id จาก location_name
    $stmt = $conn->prepare("SELECT location_id FROM location WHERE location_name = ?");
    $stmt->bind_param("s", $location_name); // ผูกค่า location_name เข้ากับคำสั่ง SQL
    $stmt->execute(); // รันคำสั่ง SQL
    $stmt->store_result(); // เก็บผลลัพธ์
    if ($stmt->num_rows > 0) { // ตรวจสอบว่าพบ location_name หรือไม่
        $stmt->bind_result($location_id); // เก็บผลลัพธ์ในตัวแปร $location_id
        $stmt->fetch(); // ดึงค่าจากผลลัพธ์
    } else {
        echo json_encode(array("result" => 0, "message" => "Invalid location", "datalist" => null));
        http_response_code(400); // ส่งรหัสสถานะ 400 (Bad Request)
        exit; // หยุดการทำงานถ้าไม่พบ location_name
    }
    $stmt->close(); // ปิด statement

    // แทรกข้อมูลกิจกรรมลงในตาราง activity โดยไม่รวม user_id
    $stmt = $conn->prepare("INSERT INTO activity (activity_name, activity_details, activity_date, location_id, sport_id, status) VALUES (?, ?, ?, ?, ?, ?)");
    $status = $json_data["status"]; // ดึงค่า status จาก JSON
    $stmt->bind_param("ssssss", $activity_name, $activity_details, $activity_date, $location_id, $sport_id, $status); // ผูกค่าข้อมูลกิจกรรมเข้ากับคำสั่ง SQL
    $query = $stmt->execute(); // รันคำสั่ง SQL


    if ($query) { // ตรวจสอบว่าการแทรกข้อมูลสำเร็จหรือไม่
        $activity_id = $stmt->insert_id; // เก็บ activity_id ที่เพิ่งสร้างขึ้น

        // แทรกข้อมูล user_id ลงในตาราง creator
        $stmt = $conn->prepare("INSERT INTO creator (user_id, activity_id) VALUES (?, ?)");
        $stmt->bind_param("si", $user_id, $activity_id); // ผูกค่า user_id และ activity_id เข้ากับคำสั่ง SQL
        $stmt->execute(); // รันคำสั่ง SQL
        $stmt->close(); // ปิด statement

        // แทรกข้อมูลผู้ใช้ที่สร้างกิจกรรมลงในตาราง member_in_activity
        $stmt = $conn->prepare("INSERT INTO member_in_activity (activity_id, user_id) VALUES (?, ?)");
        $stmt->bind_param("is", $activity_id, $user_id); // ผูกค่า activity_id และ user_id เข้ากับคำสั่ง SQL
        $stmt->execute(); // รันคำสั่ง SQL
        $stmt->close(); // ปิด statement

        // แทรกข้อมูลแฮชแท็ก (เหมือนกับโค้ดเดิม)
        foreach ($hashtags as $hashtag_message) {
            $hashtag_message = trim($hashtag_message); // ตัดช่องว่างออกจากแฮชแท็ก

            // ตรวจสอบว่า hashtag มีอยู่หรือไม่ในตาราง hashtag
            $stmt = $conn->prepare("SELECT hashtag_id FROM hashtag WHERE hashtag_message = ? LIMIT 1");
            $stmt->bind_param("s", $hashtag_message); // ผูกค่า hashtag_message เข้ากับคำสั่ง SQL
            $stmt->execute(); // รันคำสั่ง SQL
            $stmt->store_result(); // เก็บผลลัพธ์
            if ($stmt->num_rows > 0) { // ตรวจสอบว่าพบ hashtag หรือไม่
                $stmt->bind_result($hashtag_id); // เก็บผลลัพธ์ในตัวแปร $hashtag_id
                $stmt->fetch(); // ดึงค่าจากผลลัพธ์
            } else {
                $stmt->close(); // ปิด statement ก่อนแทรกข้อมูลใหม่
                $stmt = $conn->prepare("INSERT INTO hashtag (hashtag_message) VALUES (?)");
                $stmt->bind_param("s", $hashtag_message); // ผูกค่า hashtag_message เข้ากับคำสั่ง SQL
                $stmt->execute(); // รันคำสั่ง SQL
                $hashtag_id = $stmt->insert_id; // เก็บ hashtag_id ที่เพิ่งสร้างขึ้น
            }
            $stmt->close(); // ปิด statement

            // แทรก hashtag_id และ activity_id ลงในตาราง hashtags_in_activities
            $stmt = $conn->prepare("INSERT INTO hashtags_in_activities (activity_id, hashtag_id) VALUES (?, ?)");
            $stmt->bind_param("ii", $activity_id, $hashtag_id); // ผูกค่า activity_id และ hashtag_id เข้ากับคำสั่ง SQL
            $stmt->execute(); // รันคำสั่ง SQL
            $stmt->close(); // ปิด statement
        }

                // ส่งผลลัพธ์กลับในรูปแบบ JSON พร้อมข้อความสำเร็จและ activity_id
                echo json_encode(array("result" => 1, "message" => "Activity created successfully", "datalist" => array("activity_id" => $activity_id)));
            } else {
                // ส่งผลลัพธ์กลับในรูปแบบ JSON พร้อมข้อความล้มเหลว
                echo json_encode(array("result" => 0, "message" => "Failed to create activity", "datalist" => null));
                http_response_code(400); // ส่งรหัสสถานะ 400 (Bad Request)
                exit; // หยุดการทำงานถ้าการแทรกข้อมูลล้มเหลว
            }

        $conn->close(); // ปิดการเชื่อมต่อฐานข้อมูล

    exit;
}
?>
