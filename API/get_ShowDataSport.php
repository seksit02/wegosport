<?php
include 'Connect.php'; // เชื่อมต่อกับฐานข้อมูล

$sql = "SELECT sport_name FROM sport"; // สร้างคำสั่ง SQL เพื่อดึงข้อมูลชื่อกีฬาจากตาราง sport
$result = $conn->query($sql); // รันคำสั่ง SQL และรับผลลัพธ์จากฐานข้อมูล

$sport_names = array(); // สร้างอาร์เรย์เปล่าสำหรับเก็บข้อมูลชื่อกีฬา

if ($result->num_rows > 0) { // ตรวจสอบว่ามีข้อมูลที่ดึงมาหรือไม่
    // วนลูปผ่านแต่ละแถวของผลลัพธ์
    while($row = $result->fetch_assoc()) {
        $sport_names[] = $row; // เพิ่มข้อมูลชื่อกีฬาแต่ละแถวลงในอาร์เรย์ $sport_names
    }
} else {
    // หากไม่มีผลลัพธ์ ส่งกลับข้อความแจ้งเตือนในรูปแบบ JSON และหยุดการทำงาน
    echo json_encode(array("message" => "0 results"));
    exit();
}

$conn->close(); // ปิดการเชื่อมต่อฐานข้อมูล

echo json_encode($sport_names); // แปลงอาร์เรย์ข้อมูลชื่อกีฬาเป็น JSON และส่งออก

?>
