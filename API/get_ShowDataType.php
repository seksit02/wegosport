<?php
include 'Connect.php'; // เชื่อมต่อกับฐานข้อมูล

$sql = "SELECT type_id, type_name FROM sport_type"; // สร้างคำสั่ง SQL เพื่อดึงข้อมูล type_id และ type_name จากตาราง sport_type
$result = $conn->query($sql); // รันคำสั่ง SQL และรับผลลัพธ์จากฐานข้อมูล

$type_name = array(); // สร้างอาร์เรย์เปล่าสำหรับเก็บข้อมูล type_name

if ($result->num_rows > 0) { // ตรวจสอบว่ามีข้อมูลที่ดึงมาหรือไม่
    // วนลูปผ่านแต่ละแถวของผลลัพธ์
    while($row = $result->fetch_assoc()) {
        $type_name[] = $row; // เพิ่มข้อมูล type_id และ type_name แต่ละแถวลงในอาร์เรย์ $type_name
    }
} else {
    // หากไม่มีผลลัพธ์ ส่งกลับข้อความแจ้งเตือนในรูปแบบ JSON และหยุดการทำงาน
    echo json_encode(array("message" => "0 results"));
    exit();
}

$conn->close(); // ปิดการเชื่อมต่อฐานข้อมูล

echo json_encode($type_name); // แปลงอาร์เรย์ข้อมูล type_name เป็น JSON และส่งออก

?>
