<?php
include 'Connect.php'; // นำเข้าไฟล์ Connect.php เพื่อเชื่อมต่อฐานข้อมูล

require 'vendor/autoload.php'; // นำเข้า autoload.php สำหรับใช้ Library ต่าง ๆ
use \Firebase\JWT\JWT; // นำเข้า Firebase JWT Library สำหรับการสร้าง JSON Web Tokens

$key = "your_secret_key"; // กำหนดคีย์ลับสำหรับการเข้ารหัส JWT

if ($_SERVER['REQUEST_METHOD'] == 'POST') { // ตรวจสอบว่าคำขอเป็น POST หรือไม่
    // รับข้อมูลจาก POST request และแปลง JSON เป็น array
    $input = json_decode(file_get_contents("php://input"), true);
    $user_email = $input['user_email']; // รับค่า user_email จากคำขอ
    $user_pass = $input['user_pass']; // รับค่า user_pass จากคำขอ

    // ตรวจสอบว่าข้อมูลที่จำเป็นครบถ้วนหรือไม่
    if (isset($user_email) && isset($user_pass)) {
        // ตรวจสอบข้อมูลผู้ใช้ในฐานข้อมูล
        $sql = "SELECT * FROM user_information WHERE user_email = ? AND user_pass = ?";
        $stmt = $conn->prepare($sql); // เตรียมคำสั่ง SQL
        $stmt->bind_param("ss", $user_email, $user_pass); // ผูกค่า user_email และ user_pass เข้ากับคำสั่ง SQL
        $stmt->execute(); // รันคำสั่ง SQL
        $result = $stmt->get_result(); // รับผลลัพธ์จากการรันคำสั่ง SQL

        if ($result->num_rows > 0) { // ตรวจสอบว่าพบข้อมูลผู้ใช้หรือไม่
            $row = $result->fetch_assoc(); // ดึงข้อมูลผู้ใช้ที่พบ

            // สร้าง JWT (JSON Web Token)
            $payload = array(
                "user_email" => $user_email // ใส่ user_id ลงใน payload ของ JWT
            );
            $jwt = JWT::encode($payload, $key, 'HS256'); // เข้ารหัส JWT โดยใช้คีย์ลับและอัลกอริธึม HS256

            // ส่งผลลัพธ์กลับในรูปแบบ JSON พร้อม JWT และข้อมูลผู้ใช้
            echo json_encode(array(
                "result" => "1",
                "jwt" => $jwt, // ส่งค่า JWT กลับไป
                "user_email" => $user_email,
                "user_pass" => $user_pass, // ส่งค่า user_pass กลับไป
                "status" => $row['status'] // ส่งค่า status กลับไปด้วย
            ));
        } else {
            // กรณีไม่พบข้อมูลผู้ใช้ ส่งผลลัพธ์กลับในรูปแบบ JSON พร้อมข้อความแจ้งเตือน
            echo json_encode(array("result" => "0", "message" => "Invalid credentials"));
        }
    } else {
        // กรณีข้อมูลที่จำเป็นไม่ครบถ้วน ส่งผลลัพธ์กลับในรูปแบบ JSON พร้อมข้อความแจ้งเตือน
        echo json_encode(array("result" => "0", "message" => "Missing required fields"));
    }
} else {
    // กรณีคำขอไม่ใช่ POST ส่งผลลัพธ์กลับในรูปแบบ JSON พร้อมข้อความแจ้งเตือน
    echo json_encode(array("result" => "0", "message" => "Invalid request method"));
}

$conn->close(); // ปิดการเชื่อมต่อกับฐานข้อมูล
