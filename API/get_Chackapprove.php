<?php
include 'Connect.php'; // นำเข้าไฟล์ Connect.php เพื่อเชื่อมต่อฐานข้อมูล

// ตรวจสอบว่าคำขอที่เข้ามาเป็นแบบ POST หรือไม่
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    
    $location_id = $_POST['location_id']; // รับค่า location_id จากคำขอ POST

    // สร้างคำสั่ง SQL เพื่อดึงสถานะของ location ตาม location_id ที่ส่งมา
    $query = "SELECT status FROM location WHERE location_id = '$location_id'";
    $result = mysqli_query($conn, $query); // รันคำสั่ง SQL และเก็บผลลัพธ์

    if ($result) { // ตรวจสอบว่าการรันคำสั่ง SQL สำเร็จหรือไม่
        $row = mysqli_fetch_assoc($result); // ดึงแถวข้อมูลที่ได้จากการรันคำสั่ง SQL
        echo json_encode(['status' => $row['status']]); // ส่งสถานะของ location กลับไปในรูปแบบ JSON
    } else {
        echo json_encode(['status' => 'error']); // ส่งข้อความ error กลับไปในรูปแบบ JSON หากเกิดข้อผิดพลาด
    }
}

mysqli_close($conn); // ปิดการเชื่อมต่อกับฐานข้อมูล
?>
