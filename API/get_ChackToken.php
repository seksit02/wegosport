<?php
require 'Connect.php'; // นำเข้าไฟล์ Connect.php เพื่อเชื่อมต่อฐานข้อมูล

// รับข้อมูลจาก POST request
$input = file_get_contents('php://input'); // รับข้อมูลดิบจากอินพุต
$data = json_decode($input, true); // แปลงข้อมูล JSON ที่ได้รับเป็น array

$userId = $data['id']; // ดึงค่าของ 'id' จาก array ที่ได้รับ

// ตรวจสอบว่ามี id นี้ในฐานข้อมูลหรือไม่
$sql = "SELECT user_token, user_jwt, user_id, user_email, status FROM user_information WHERE user_token='$userId'"; 
// สร้างคำสั่ง SQL เพื่อตรวจสอบข้อมูลในตาราง user_information
$result = $conn->query($sql); // รันคำสั่ง SQL

$response = array(); // สร้าง array สำหรับเก็บผลลัพธ์ที่จะส่งกลับ

if ($result->num_rows > 0) { // ตรวจสอบว่ามีแถวที่ตรงกับเงื่อนไขในคำสั่ง SQL หรือไม่
    $row = $result->fetch_assoc(); // ดึงข้อมูลแถวที่พบออกมาเป็น array แบบ associative
    $response['exists'] = true; // ระบุว่าข้อมูลนี้มีอยู่ในฐานข้อมูล
    $response['jwt'] = $row['user_jwt']; // ส่งค่า user_jwt กลับไป
    $response['user_id'] = $row['user_id']; // ส่งค่า user_id กลับไป
    $response['user_email'] = $row['user_email']; // ส่งค่า user_id กลับไป
    $response['user_token'] = $row['user_token']; // ส่งค่า user_token กลับไป
    $response['status'] = $row['status']; // ส่งค่า status กลับไป
} else {
    $response['exists'] = false; // ระบุว่าไม่มีข้อมูลนี้ในฐานข้อมูล
}

echo json_encode($response); // ส่งผลลัพธ์กลับไปในรูปแบบ JSON

$conn->close(); // ปิดการเชื่อมต่อกับฐานข้อมูล
?>
