<?php

include 'config.php';

// ตรวจสอบว่ามีการส่งคำร้องแบบ POST หรือไม่
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $location_name = $_POST['location_name'];
    $location_time = $_POST['location_time'];
    $types_id = json_decode($_POST['types_id'], true);

    // เตรียมคำสั่ง SQL สำหรับบันทึกข้อมูลลงฐานข้อมูล
    $sql = "INSERT INTO location (location_name, location_time, status, type_id)
            VALUES ('$location_name', '$location_time', 'pending', '" . implode(",", $types_id) . "')";

    if ($conn->query($sql) === TRUE) {
        $location_id = $conn->insert_id; // ดึง location_id ที่เพิ่งเพิ่มเสร็จ
        echo json_encode(['location_id' => $location_id]);
    } else {
        echo "ข้อผิดพลาด: " . $sql . "<br>" . $conn->error;
    }
}

$conn->close();
?>