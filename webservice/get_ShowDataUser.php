<?php
include 'Connect.php';

// สร้างการเชื่อมต่อกับฐานข้อมูล
$conn = new mysqli($servername, $username, $password, $dbname);

// ตรวจสอบการเชื่อมต่อ
if ($conn->connect_error) {
    die("การเชื่อมต่อล้มเหลว: " . $conn->connect_error);
}

// สร้างคำสั่ง SQL เพื่อดึงข้อมูลที่ต้องการ
$sql = "SELECT user_id, user_name, user_text, user_photo FROM user_information";
$result = $conn->query($sql);

$user_data = array();

// ตรวจสอบและเก็บผลลัพธ์
if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $user_data[] = $row;
    }
} else {
    echo "0 results";
}

// ปิดการเชื่อมต่อ
$conn->close();

// แปลงข้อมูลเป็น JSON และส่งออก
echo json_encode($user_data);
?>
