<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

@header('Content-Type: application/json; charset=utf-8');
include 'Connect.php';

require 'vendor/autoload.php';
use \Firebase\JWT\JWT;
use \Firebase\JWT\Key;

$key = "your_secret_key";

// ตรวจสอบว่าเป็นการร้องขอแบบ POST หรือไม่
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // ดึงค่า Authorization header จากการร้องขอ
    $headers = [
        'Authorization' => 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoicyJ9.rbTOONy200kwybNDgzMDVu7Q5UFu63i3dQZfHKvTHx4'
    ];


    error_log(print_r($headers, true), 3, "C:/xampp/tmp/error.log");  // พิมพ์ headers ลงในไฟล์ log

    if (isset($headers['Authorization'])) {
        // แยก JWT จาก "Authorization" header
        $jwt = str_replace('Bearer ', '', $headers['Authorization']);
        error_log("JWT: $jwt", 3, "C:/xampp/tmp/error.log");  // พิมพ์ JWT ลงในไฟล์ log

        try {
            // ถอดรหัส JWT
            $decoded = JWT::decode($jwt, new Key($key, 'HS256'));
            
            $decoded_array = (array) $decoded;
            error_log(print_r($decoded_array, true), 3, "C:/xampp/tmp/error.log");  // พิมพ์ decoded_array ลงในไฟล์ log

            // ดึง user_id จาก decoded JWT
            $user_id = $decoded_array['user_id'];
            error_log("User ID: $user_id", 3, "C:/xampp/tmp/error.log");  // พิมพ์ user_id ลงในไฟล์ log

            // สร้างคำสั่ง SQL สำหรับดึงข้อมูลผู้ใช้
            $sql = "SELECT user_id, user_name, user_text, user_photo FROM user_information WHERE user_id = ?";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param("s", $user_id);
            $stmt->execute();
            $result = $stmt->get_result();
            
            if ($result->num_rows > 0) {
                $user_data = $result->fetch_assoc();
                
                // เพิ่ม URL สำหรับรูปภาพ
                $user_data['user_photo'] = 'http://10.0.2.2/flutter_webservice/upload/' . $user_data['user_photo'];
                
                echo json_encode([$user_data]);  // ส่งเป็น array
            } else {
                echo json_encode(array("message" => "ไม่พบชื่อผู้ใช้"));
            }
        } catch (Exception $e) {
            echo json_encode(array(
                "message" => "Access denied",
                "error" => $e->getMessage()
            ));
        }
    } else {
        error_log('ไม่พบส่วนหัวการอนุญาต', 3, "C:/xampp/tmp/error.log");
        echo json_encode(array("message" => "ไม่พบส่วนหัวการอนุญาต"));
    }
} else {
    echo json_encode(array("message" => "วิธีการร้องขอไม่ถูกต้อง"));
}

$conn->close();
?>
