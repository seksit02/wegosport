<?php
include 'Connect.php'; // เชื่อมต่อกับฐานข้อมูล

$sql = "SELECT hashtag_message FROM hashtag"; // สร้างคำสั่ง SQL เพื่อดึงข้อมูลข้อความ hashtag จากตาราง hashtag
$result = $conn->query($sql); // รันคำสั่ง SQL และรับผลลัพธ์จากฐานข้อมูล

$hashtag_messages = array(); // สร้างอาร์เรย์สำหรับเก็บข้อมูลข้อความ hashtag

if ($result->num_rows > 0) { // ตรวจสอบว่ามีข้อมูล hashtag ในผลลัพธ์หรือไม่
    // วนลูปผ่านแต่ละแถวของผลลัพธ์
    while($row = $result->fetch_assoc()) {
        $hashtag_messages[] = $row; // เพิ่มข้อมูลแถวลงในอาร์เรย์ของข้อความ hashtag
    }
} else {
    // หากไม่มีผลลัพธ์ ส่งกลับข้อความแจ้งเตือนในรูปแบบ JSON และหยุดการทำงาน
    echo json_encode(array("message" => "0 results"));
    exit();
}

$conn->close(); // ปิดการเชื่อมต่อฐานข้อมูล

echo json_encode($hashtag_messages); // แปลงอาร์เรย์ข้อมูลข้อความ hashtag เป็น JSON และส่งออก

?>
