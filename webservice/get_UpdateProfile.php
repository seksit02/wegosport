<?php
include 'Connect.php';

// ตรวจสอบว่าเป็นการร้องขอแบบ POST หรือไม่
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // รับข้อมูลจาก POST request
    $user_id = $_POST['user_id'];
    $user_name = $_POST['user_name'];
    $user_text = $_POST['user_text'];

    // ตรวจสอบว่าข้อมูลที่จำเป็นครบถ้วนหรือไม่
    if (isset($user_id) && isset($user_name) && isset($user_text)) {
        // สร้างคำสั่ง SQL สำหรับอัพเดทข้อมูล
        $sql = "UPDATE users SET user_name=?, user_text=? WHERE user_id=?";

        // เตรียมคำสั่ง SQL
        if ($stmt = $conn->prepare($sql)) {
            // ผูกตัวแปรเข้ากับคำสั่ง SQL
            $stmt->bind_param("ssi", $user_name, $user_text, $user_id);

            // ดำเนินการคำสั่ง SQL
            if ($stmt->execute()) {
                echo json_encode(array("status" => "success", "message" => "User updated successfully"));
            } else {
                echo json_encode(array("status" => "error", "message" => "Error updating user"));
            }

            // ปิด statement
            $stmt->close();
        } else {
            echo json_encode(array("status" => "error", "message" => "Error preparing statement"));
        }
    } else {
        echo json_encode(array("status" => "error", "message" => "Missing required fields"));
    }
} else {
    echo json_encode(array("status" => "error", "message" => "Invalid request method"));
}

// ปิดการเชื่อมต่อฐานข้อมูล
$conn->close();
?>
