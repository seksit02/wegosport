<?php
require 'Connect.php';

header('Content-Type: application/json');

// รับข้อมูลจาก POST request
$input = file_get_contents('php://input');
$data = json_decode($input, true);

$userId = $data['id'];

// ตรวจสอบว่ามี id นี้ในฐานข้อมูลหรือไม่
$sql = "SELECT user_token FROM user_information WHERE user_token='$userId'";
$result = $conn->query($sql);

$response = array();

if ($result->num_rows > 0) {
    $response['exists'] = true;
} else {
    $response['exists'] = false;
}

echo json_encode($response);

$conn->close();
?>
