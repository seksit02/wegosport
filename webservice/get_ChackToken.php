<?php
require 'Connect.php';

// รับข้อมูลจาก POST request
$input = file_get_contents('php://input');
$data = json_decode($input, true);

$userId = $data['id'];

// ตรวจสอบว่ามี id นี้ในฐานข้อมูลหรือไม่
$sql = "SELECT user_token, user_jwt, user_id FROM user_information WHERE user_token='$userId'";
$result = $conn->query($sql);

$response = array();

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    $response['exists'] = true;
    $response['jwt'] = $row['user_jwt']; // เพิ่มการส่งค่า user_jwt กลับไปด้วย
    $response['user_id'] = $row['user_id']; // เพิ่มการส่งค่า user_id กลับไปด้วย
    $response['user_token'] = $row['user_token']; // เพิ่มการส่งค่า user_id กลับไปด้วย
} else {
    $response['exists'] = false;
}

echo json_encode($response);

$conn->close();
?>
