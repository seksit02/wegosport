<?php
include 'Connect.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // รับข้อมูลจาก POST request
    $input = json_decode(file_get_contents("php://input"), true);
    $user_id = $input['user_id'];
    $jwt = $input['jwt'];

    // ตรวจสอบว่าข้อมูลที่จำเป็นครบถ้วนหรือไม่
    if (isset($user_id) && isset($jwt)) {
        // สร้างคำสั่ง SQL สำหรับอัพเดทข้อมูล JWT
        $sql = "UPDATE user_information SET user_jwt = ? WHERE user_id = ?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("ss", $jwt, $user_id);

        if ($stmt->execute()) {
            echo json_encode(array("result" => "1", "message" => "JWT saved successfully"));
        } else {
            echo json_encode(array("result" => "0", "message" => "Error saving JWT"));
        }

        // ปิด statement
        $stmt->close();
    } else {
        echo json_encode(array("result" => "0", "message" => "Missing required fields"));
    }
} else {
    echo json_encode(array("result" => "0", "message" => "Invalid request method"));
}

// ปิดการเชื่อมต่อฐานข้อมูล
$conn->close();
?>
