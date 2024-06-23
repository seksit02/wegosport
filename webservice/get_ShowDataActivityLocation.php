<?php
require 'Connect.php';

// สร้างคำสั่ง SQL
$sql = "SELECT location_name FROM location";

// รันคำสั่ง SQL
$result = $conn->query($sql);

$activities1 = array();

if ($result->num_rows > 0) {
    // เก็บผลลัพธ์ลงใน array
    while($row = $result->fetch_assoc()) {
        $activities1[] = $row;
    }
}

// ปิดการเชื่อมต่อฐานข้อมูล
$conn->close();

// ส่งข้อมูลในรูปแบบ JSON
echo json_encode($activities1, JSON_UNESCAPED_UNICODE);
?>
