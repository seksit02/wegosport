<?php
include 'Connect.php'; // ตรวจสอบให้แน่ใจว่าเส้นทางนี้ถูกต้องและไฟล์ Connect.php มีอยู่

require 'vendor/autoload.php'; // ตรวจสอบให้แน่ใจว่าเส้นทางนี้ถูกต้องและไฟล์ autoload.php มีอยู่

use \Firebase\JWT\JWT;

$key = "your_secret_key"; // ใช้คีย์เดียวกันกับใน Dart
$algorithm = 'HS256'; // อัลกอริธึมที่ใช้ในการเข้ารหัส

// รับ JWT จากคำขอ
$headers = getallheaders();

$jwt = isset($headers['Authorization']) ? str_replace('Bearer ', '', $headers['Authorization']) : null;

error_log("Received JWT: " . $jwt); // สำหรับการดีบัก

if ($jwt) {

    try {
        // ถอดรหัส JWT
        $decoded = JWT::decode($jwt, new \Firebase\JWT\Key($key, 'HS256'));
        error_log("Decoded JWT: " . print_r($decoded, true)); // สำหรับการดีบัก
        $user_id = $decoded->id;

        // สร้างคำสั่ง SQL เพื่อดึงข้อมูลที่ต้องการ
        $stmt = $conn->prepare("SELECT user_id, user_name, user_text, user_photo FROM user_information WHERE user_id = ?");
        $stmt->bind_param("s", $user_id);
        $stmt->execute();
        $result = $stmt->get_result();

        $user_data = array();

        // ตรวจสอบและเก็บผลลัพธ์
        if ($result->num_rows > 0) {
            while($row = $result->fetch_assoc()) {
                $user_data[] = $row;
            }
        } else {
            http_response_code(404);
            echo json_encode(array("message" => "No user found."));
            exit();
        }

        // ปิดการเชื่อมต่อ
        $stmt->close();
        $conn->close();

        // แปลงข้อมูลเป็น JSON และส่งออก
        echo json_encode($user_data);

    } catch (Exception $e) {
        error_log("JWT Decode Error: " . $e->getMessage()); // สำหรับการดีบัก
        http_response_code(401);
        echo json_encode(array("message" => "การเข้าถึงถูกปฏิเสธ", "error" => $e->getMessage()));
    }

} else {
    error_log("No JWT received"); // สำหรับการดีบัก
    http_response_code(401);
    echo json_encode(array("message" => "การเข้าถึงถูกปฏิเสธ (ไม่มี jwt)"));
}
?>
