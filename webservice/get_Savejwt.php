<?php
require 'vendor/autoload.php';
include 'Connect.php';
use \Firebase\JWT\JWT;

$key = "your_secret_key"; // ใช้คีย์เดียวกันกับใน Dart
$algorithm = 'HS256'; // อัลกอริธึมที่ใช้ในการเข้ารหัส

// รับข้อมูลที่ส่งมาจาก Flutter
$data = json_decode(file_get_contents("php://input"));

$user_id = $data->user_id;
$jwt = $data->jwt;

// เชื่อมต่อฐานข้อมูล
require 'Connect.php';

// เก็บ JWT ลงในฐานข้อมูล
$stmt = $conn->prepare("UPDATE user_information SET user_jwt = ? WHERE user_id = ?");
$stmt->bind_param("ss", $jwt, $user_id);
$stmt->execute();

$response['result'] = "1";
echo json_encode($response);
?>
