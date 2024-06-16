<?php
//1.header // ตั้งค่า header ให้ส่งกลับเป็น JSON
@header('Content-Type: application/json');
@header("Access-Control-Allow-Origin: *");
@header('Access-Control-Allow-Headers: X-Requested-With, content-type, access-control-allow-origin, access-control-allow-methods, access-control-allow-headers');

<?php
// ตั้งค่าการเชื่อมต่อฐานข้อมูล
$servername = "localhost"; // ชื่อ server
$username = "root"; // ชื่อผู้ใช้ของฐานข้อมูล
$password = ""; // รหัสผ่านของฐานข้อมูล
$dbname = "user_information"; // ชื่อฐานข้อมูล

// สร้างการเชื่อมต่อ
$conn = new mysqli($servername, $username, $password, $dbname);

// ตรวจสอบการเชื่อมต่อ
if ($conn->connect_error) {
    die("การเชื่อมต่อล้มเหลว: " . $conn->connect_error);
}

// สร้างคำสั่ง SQL
$sql = "SELECT ac_id, ac_name, ac_details, ac_location, ac_date FROM activity";

// รันคำสั่ง SQL
$result = $conn->query($sql);

$activities = array();

if ($result->num_rows > 0) {
    // เก็บผลลัพธ์ลงใน array
    while($row = $result->fetch_assoc()) {
        $activities[] = $row;
    }
}

// ปิดการเชื่อมต่อฐานข้อมูล
$conn->close();


// ส่งข้อมูลในรูปแบบ JSON
echo json_encode($activities, JSON_UNESCAPED_UNICODE);
?>
