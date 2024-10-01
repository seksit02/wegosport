<?php
ini_set('display_errors', 1); // แสดงข้อผิดพลาดทั้งหมด
ini_set('display_startup_errors', 1); // แสดงข้อผิดพลาดที่เกิดขึ้นในขั้นตอนเริ่มต้น
error_reporting(E_ALL); // รายงานข้อผิดพลาดทั้งหมด

@header('Content-Type: application/json; charset=utf-8'); // กำหนดให้ Content-Type เป็น JSON
include 'Connect.php'; // เชื่อมต่อกับฐานข้อมูล

require 'vendor/autoload.php'; // โหลด autoload.php สำหรับใช้ JWT
use \Firebase\JWT\JWT; // ใช้คลาส JWT จาก Firebase
use \Firebase\JWT\Key; // ใช้คลาส Key จาก Firebase

$key = "your_secret_key"; // กำหนด secret key สำหรับ JWT

if ($_SERVER['REQUEST_METHOD'] == 'POST') { // ตรวจสอบว่า request เป็น POST หรือไม่
    $headers = getallheaders(); // รับ headers ทั้งหมดจาก request
    error_log(print_r($headers, true), 3, "C:/xampp/tmp/error.log"); // บันทึก headers ลงในไฟล์ log

    if (isset($headers['authorization'])) { // ตรวจสอบว่ามี header 'authorization' หรือไม่
        $jwt = str_replace('Bearer ', '', $headers['authorization']); // เอา "Bearer " ออกจาก JWT
        error_log("JWT: $jwt", 3, "C:/xampp/tmp/error.log"); // บันทึก JWT ลงในไฟล์ log

        try {
            $decoded = JWT::decode($jwt, new Key($key, 'HS256')); // ถอดรหัส JWT
            $decoded_array = (array) $decoded; // แปลงผลลัพธ์เป็นอาร์เรย์
            error_log(print_r($decoded_array, true), 3, "C:/xampp/tmp/error.log"); // บันทึกข้อมูลที่ถอดรหัสแล้วลงในไฟล์ log

            $user_email = $decoded_array['user_email']; // ดึง user_email จาก JWT
            error_log("User Email: $user_email", 3, "C:/xampp/tmp/error.log"); // บันทึก user_email ลงในไฟล์ log

            $sql = "SELECT user_id, user_name, user_text, user_photo, user_age FROM user_information WHERE user_email = ?"; // สร้าง SQL query
            $stmt = $conn->prepare($sql); // เตรียม statement
            $stmt->bind_param("s", $user_email); // ผูกค่า user_email กับ statement
            $stmt->execute(); // รัน query
            $result = $stmt->get_result(); // รับผลลัพธ์จากการรัน query
            
            if ($result->num_rows > 0) { // ถ้ามีข้อมูลผู้ใช้
                $user_data = $result->fetch_assoc(); // ดึงข้อมูลผู้ใช้จากผลลัพธ์
                $user_data['user_photo'] = 'http://10.0.2.2/flutter_webservice/upload/' . $user_data['user_photo']; // ปรับ URL ของรูปภาพ
                echo json_encode([$user_data]); // ส่งข้อมูลผู้ใช้กลับไปในรูปแบบ JSON เป็น array
            } else {
                echo json_encode(array("message" => "ไม่พบชื่อผู้ใช้")); // ส่งข้อความว่าหาไม่พบผู้ใช้
            }
        } catch (Exception $e) { // ถ้ามีข้อผิดพลาดในการถอดรหัส JWT
            echo json_encode(array(
                "message" => "Access denied", // ส่งข้อความปฏิเสธการเข้าถึง
                "error" => $e->getMessage() // ส่งข้อความข้อผิดพลาดที่เกิดขึ้น
            ));
        }
    } else {
        error_log('ไม่พบส่วนหัวการอนุญาต', 3, "C:/xampp/tmp/error.log"); // บันทึก log ว่าไม่พบ header 'authorization'
        echo json_encode(array("message" => "ไม่พบส่วนหัวการอนุญาต")); // ส่งข้อความว่าไม่พบ header 'authorization'
    }
} else {
    echo json_encode(array("message" => "วิธีการร้องขอไม่ถูกต้อง")); // ส่งข้อความว่า request method ไม่ถูกต้อง
}

$conn->close(); // ปิดการเชื่อมต่อฐานข้อมูล

?>
