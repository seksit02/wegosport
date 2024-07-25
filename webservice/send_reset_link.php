<?php
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

require 'vendor/autoload.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $email = $_POST['email'];

    // เชื่อมต่อฐานข้อมูล
    include 'Connect.php';
    
    // ตรวจสอบว่าอีเมลนี้อยู่ในฐานข้อมูลหรือไม่
    $sql = "SELECT user_id FROM user_information WHERE user_email = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param('s', $email);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        // สร้างโทเค็นเป็นตัวเลขสุ่มสำหรับรีเซ็ตรหัสผ่าน
        $token = mt_rand(100000, 999999);
        $resetLink = "http://172.24.139.236/test/reset_password.php?token=$token";

        // บันทึกโทเค็นลงฐานข้อมูล
        $sql = "UPDATE user_information SET user_tokenmail = ? WHERE user_email = ?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param('ss', $token, $email);
        $stmt->execute();

        // ส่งอีเมลลิ้งก์รีเซ็ตรหัสผ่าน
        $mail = new PHPMailer(true);
        try {
            // ตั้งค่าเซิร์ฟเวอร์อีเมล
            $mail->isSMTP();
            $mail->Host = 'smtp.gmail.com';
            $mail->Port = 587;
            $mail->SMTPAuth = true;
            $mail->SMTPSecure = 'tls';
            $mail->Username = 'wegosport.67@gmail.com';
            $mail->Password = 'iosj tuno uzlj frpm';

            // ตั้งค่าผู้ส่งและผู้รับ
            $mail->setFrom('wegosport.67@gmail.com', 'wegosport');
            $mail->addAddress($email);

            // ตั้งค่าหัวเรื่องและเนื้อหาอีเมล
            $mail->isHTML(true);
            $mail->Subject = 'Recover your password';
            $mail->Body    = "คลิกลิ้งก์นี้เพื่อรีเซ็ตรหัสผ่านของคุณ: <a href='$resetLink'>$resetLink</a>";

            $mail->send();
            echo json_encode(['status' => 'success', 'message' => 'ลิ้งก์รีเซ็ตรหัสผ่านได้ถูกส่งไปที่อีเมลของคุณแล้ว']);
        } catch (Exception $e) {
            echo json_encode(['status' => 'error', 'message' => 'เกิดข้อผิดพลาดในการส่งอีเมล: ', $mail->ErrorInfo]);
        }
    } else {
        echo json_encode(['status' => 'error', 'message' => 'ไม่มีอีเมลนี้ในระบบของเรา']);
    }

    $stmt->close();
    $conn->close();
}
?>
