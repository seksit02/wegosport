<?php
include 'Connect.php'; // นำเข้าไฟล์ Connect.php เพื่อเชื่อมต่อกับฐานข้อมูล

if ($_SERVER['REQUEST_METHOD'] == 'POST') { // ตรวจสอบว่าคำขอเป็น POST หรือไม่
    // รับข้อมูลจาก POST request และแปลง JSON เป็น array
    $input = json_decode(file_get_contents("php://input"), true); 
    $user_email = $input['user_email']; // ดึงค่า user_email จากข้อมูลที่รับมา
    $jwt = $input['jwt']; // ดึงค่า JWT จากข้อมูลที่รับมา

    // ตรวจสอบว่าข้อมูลที่จำเป็นครบถ้วนหรือไม่
    if (isset($user_email) && isset($jwt)) {
        // สร้างคำสั่ง SQL สำหรับอัพเดทข้อมูล JWT ในตาราง user_information
        $sql = "UPDATE user_information SET user_jwt = ? WHERE user_email = ?";
        $stmt = $conn->prepare($sql); // เตรียมคำสั่ง SQL
        $stmt->bind_param("ss", $jwt, $user_email); // ผูกค่า JWT และ user_email เข้ากับคำสั่ง SQL

        if ($stmt->execute()) { // รันคำสั่ง SQL และตรวจสอบผลลัพธ์
            echo json_encode(array("result" => "1", "message" => "JWT saved successfully")); // ส่งผลลัพธ์สำเร็จในรูปแบบ JSON
        } else {
            echo json_encode(array("result" => "0", "message" => "Error saving JWT")); // ส่งผลลัพธ์ล้มเหลวในรูปแบบ JSON
        }

        // ปิด statement
        $stmt->close(); 
    } else {
        // กรณีข้อมูลที่จำเป็นไม่ครบถ้วน ส่งผลลัพธ์กลับในรูปแบบ JSON พร้อมข้อความแจ้งเตือน
        echo json_encode(array("result" => "0", "message" => "Missing required fields"));
    }
} else {
    // กรณีคำขอไม่ใช่ POST ส่งผลลัพธ์กลับในรูปแบบ JSON พร้อมข้อความแจ้งเตือน
    echo json_encode(array("result" => "0", "message" => "Invalid request method"));
}

// ปิดการเชื่อมต่อฐานข้อมูล
$conn->close();
?>
