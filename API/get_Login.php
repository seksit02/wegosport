<?php
include 'Connect.php';

require 'vendor/autoload.php';
use \Firebase\JWT\JWT;

$key = "your_secret_key";

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // รับข้อมูลจาก POST request
    $input = json_decode(file_get_contents("php://input"), true);
    $user_id = $input['user_id'];
    $user_pass = $input['user_pass'];

    // ตรวจสอบว่าข้อมูลที่จำเป็นครบถ้วนหรือไม่
    if (isset($user_id) && isset($user_pass)) {
        // ตรวจสอบข้อมูลผู้ใช้ในฐานข้อมูล
        $sql = "SELECT * FROM user_information WHERE user_id = ? AND user_pass = ?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("ss", $user_id, $user_pass);
        $stmt->execute();
        $result = $stmt->get_result();

        if ($result->num_rows > 0) {
            // สร้าง JWT
            $payload = array(
                "user_id" => $user_id
            );
            $jwt = JWT::encode($payload, $key, 'HS256');

            echo json_encode(array(
                "result" => "1",
                "jwt" => $jwt,
                "user_id" => $user_id,
                "user_pass" => $user_pass
            ));
        } else {
            echo json_encode(array("result" => "0", "message" => "Invalid credentials"));
        }
    } else {
        echo json_encode(array("result" => "0", "message" => "Missing required fields"));
    }
} else {
    echo json_encode(array("result" => "0", "message" => "Invalid request method"));
}

$conn->close();
?>
