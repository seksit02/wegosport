<?php
include 'Connect.php';

// สร้างคำสั่ง SQL
$sql = "SELECT user_id, user_name, user_text FROM user_information";

// ดำเนินการคำสั่ง SQL
$result = $conn->query($sql);

// สร้าง array เพื่อเก็บผลลัพธ์
$data = array();

if ($result->num_rows > 0) {
    // วน loop ผลลัพธ์และเพิ่มเข้าไปใน array
    while($row = $result->fetch_assoc()) {
        $data[] = $row;
    }
} else {
    echo "0 results";
}

// แปลง array เป็น JSON
echo json_encode($data);

// ปิดการเชื่อมต่อฐานข้อมูล
$conn->close();
?>