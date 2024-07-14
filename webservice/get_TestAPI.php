<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: X-Requested-With, content-type, access-control-allow-origin, access-control-allow-methods, access-control-allow-headers");

require "connect.php";

// Check connection
if (!$con) {
    die("Connection error: " . mysqli_connect_error());
}

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // ตรวจสอบว่ามีค่า email ที่ส่งมาหรือไม่
    if (isset($_GET['email'])) {
        $email = $_GET['email'];

        // ใช้ prepared statement เพื่อป้องกัน SQL injection
        $stmt = $con->prepare("SELECT * FROM barber WHERE ba_email = ?");
        $stmt->bind_param("s", $email);
        $stmt->execute();

        // ดึงข้อมูลลูกค้า
        $result = $stmt->get_result();
        if ($result->num_rows > 0) {
            $row = $result->fetch_assoc();
            $barberData = array(
                'id' => $row['ba_id'],
                'name' => $row['ba_name'],
                'lastname' => $row['ba_lastname'],
                'phone' => $row['ba_phone'],
                'email' => $row['ba_email'],
                'idcard' => $row['ba_idcard'],
                'certificate' => $row['ba_certificate'],
                'namelocation' => $row['ba_namelocation'],
                'latitude' => $row['ba_latitude'],
                'longitude' => $row['ba_longitude'],
            );
            $response = array(
                'result' => 1,
                'data' => $barberData
            );
        } else {
            $response = array(
                'result' => 0,
                'message' => 'ไม่พบข้อมูลช่างตัดผม'
            );
        }

        // ปิด prepared statement
        $stmt->close();
    } else {
        // กรณีไม่มีค่า email ที่ส่งมา
        $response = array(
            'result' => -1,
            'message' => 'ไม่ได้ระบุ Email'
        );
    }
} else {
    // กรณีไม่ได้ใช้วิธี GET ในการเรียก API
    $response = array(
        'result' => -2,
        'message' => 'ไม่ใช้วิธี GET'
    );
}

echo json_encode($response);

exit();