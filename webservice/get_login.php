<?php
require 'vendor/autoload.php'; // ตรวจสอบว่ามีไฟล์นี้อยู่

use \Firebase\JWT\JWT;

$key = "your_secret_key"; // ใช้คีย์เดียวกันกับใน Dart
$algorithm = 'HS256'; // อัลกอริธึมที่ใช้ในการเข้ารหัส

// รับข้อมูลที่ส่งมาจาก Flutter
$data = json_decode(file_get_contents("php://input"));

$user_id = $data->user_id;
$user_pass = $data->user_pass;

// เชื่อมต่อฐานข้อมูล
require 'Connect.php';

// ตรวจสอบข้อมูลผู้ใช้ในฐานข้อมูล
$stmt = $conn->prepare("SELECT * FROM user_information WHERE user_id = ? AND user_pass = ?");
$stmt->bind_param("ss", $user_id, $user_pass);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $login_success = true;
    $user = $result->fetch_assoc();

    $token = array(
        "user_id" => $user_id,
        // ข้อมูลเพิ่มเติมที่ต้องการเก็บใน JWT
    );

    $jwt = JWT::encode($token, $key, $algorithm); // เพิ่มพารามิเตอร์ที่สามคืออัลกอริธึม
    $response['jwt'] = $jwt;
    $response['result'] = "1"; // หรือสถานะอื่น ๆ ที่คุณใช้

    // เก็บ JWT ในฐานข้อมูล
    $stmt = $conn->prepare("UPDATE user_information SET user_jwt = ? WHERE user_id = ?");
    $stmt->bind_param("ss", $jwt, $user_id);
    $stmt->execute();
} else {
    $login_success = false;
    $response['result'] = "0";
}

echo json_encode($response);
?>
