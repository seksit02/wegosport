<?php
// เรียกใช้ PHPMailer และ Exception จาก library ของ PHPMailer
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

// เรียกใช้ autoload ของ Composer เพื่อโหลด class ต่าง ๆ ที่ต้องใช้
require 'vendor/autoload.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // รับค่าที่ส่งมาจากฟอร์ม
    $email = $_POST['email'];

    // เชื่อมต่อฐานข้อมูล
    include 'Connect.php';
    
    // ตรวจสอบว่าอีเมลนี้มีอยู่ในฐานข้อมูลหรือไม่
    $sql = "SELECT user_id FROM user_information WHERE user_email = ?";
    $stmt = $conn->prepare($sql); // เตรียมคำสั่ง SQL
    $stmt->bind_param('s', $email); // ผูกค่าของอีเมลที่ได้รับมา
    $stmt->execute(); // รันคำสั่ง SQL
    $result = $stmt->get_result(); // รับผลลัพธ์

    if ($result->num_rows > 0) {
        // สร้างโทเค็นแบบสุ่มเพื่อใช้ในการรีเซ็ตรหัสผ่าน
        $token = mt_rand(100000, 999999);
        $resetLink = "http://localhost/flutter_webservice/reset_password.php?token=$token"; // สร้างลิ้งก์สำหรับรีเซ็ตรหัสผ่าน

        // บันทึกโทเค็นลงฐานข้อมูล
        $sql = "UPDATE user_information SET user_tokenmail = ? WHERE user_email = ?";
        $stmt = $conn->prepare($sql); // เตรียมคำสั่ง SQL สำหรับการอัพเดตโทเค็น
        $stmt->bind_param('ss', $token, $email); // ผูกค่าของโทเค็นและอีเมล
        $stmt->execute(); // รันคำสั่ง SQL

        // ส่งอีเมลลิ้งก์รีเซ็ตรหัสผ่าน
        $mail = new PHPMailer(true); // สร้าง instance ของ PHPMailer
        try {
            // ตั้งค่าเซิร์ฟเวอร์ SMTP
            $mail->isSMTP(); // ใช้ SMTP
            $mail->Host = 'smtp.gmail.com'; // กำหนดโฮสต์ของ SMTP
            $mail->Port = 587; // กำหนดพอร์ตสำหรับการเชื่อมต่อ SMTP
            $mail->SMTPAuth = true; // เปิดการยืนยันตัวตน
            $mail->SMTPSecure = 'tls'; // กำหนดการเข้ารหัสที่ใช้ในการส่งข้อมูล
            $mail->Username = 'wegosport.67@gmail.com'; // กำหนดอีเมลที่ใช้ส่ง
            $mail->Password = 'iosj tuno uzlj frpm'; // กำหนดรหัสผ่านของอีเมลที่ใช้ส่ง

            // ตั้งค่าผู้ส่งและผู้รับ
            $mail->setFrom('wegosport.67@gmail.com', 'wegosport'); // ตั้งค่าผู้ส่ง
            $mail->addAddress($email); // เพิ่มผู้รับ (คืออีเมลที่ได้รับจาก POST request)

            // ตั้งค่าหัวเรื่องและเนื้อหาอีเมล
            $mail->isHTML(true); // กำหนดว่าอีเมลจะเป็น HTML
            $mail->Subject = 'Recover your password'; // หัวเรื่องของอีเมล
            $mail->Body    = "คลิกลิ้งก์นี้เพื่อรีเซ็ตรหัสผ่านของคุณ: <a href='$resetLink'>$resetLink</a>"; // เนื้อหาในอีเมล

            // ส่งอีเมล
            $mail->send();
            echo json_encode(['status' => 'success', 'message' => 'ลิ้งก์รีเซ็ตรหัสผ่านได้ถูกส่งไปที่อีเมลของคุณแล้ว']);
        } catch (Exception $e) {
            // จัดการข้อผิดพลาดหากการส่งอีเมลล้มเหลว
            echo json_encode(['status' => 'error', 'message' => 'เกิดข้อผิดพลาดในการส่งอีเมล: ', $mail->ErrorInfo]);
        }
    } else {
        // กรณีที่อีเมลไม่พบในฐานข้อมูล
        echo json_encode(['status' => 'error', 'message' => 'ไม่มีอีเมลนี้ในระบบของเรา']);
    }

    // ปิด statement และการเชื่อมต่อกับฐานข้อมูล
    $stmt->close();
    $conn->close();
}
?>
