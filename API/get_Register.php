<?php
require 'Connect.php'; // นำเข้าไฟล์ Connect.php เพื่อเชื่อมต่อกับฐานข้อมูล

// รับคำขอจากลูกค้า
if ($_SERVER["REQUEST_METHOD"] == "POST") { // ตรวจสอบว่าคำขอเป็น POST หรือไม่
    $content = file_get_contents("php://input"); // รับข้อมูลดิบจากอินพุต (ข้อความธรรมดา)
    $json_data = json_decode($content, true); // แปลงข้อความธรรมดาเป็นรูปแบบ JSON

    // กำหนดค่าจาก JSON ที่รับเข้ามา พร้อมทั้งทำการ escape ข้อมูลเพื่อความปลอดภัย
    $user_id = mysqli_real_escape_string($conn, trim($json_data["user_id"])); 
    $user_email = mysqli_real_escape_string($conn, trim($json_data["user_email"]));
    $user_pass = mysqli_real_escape_string($conn, trim($json_data["user_pass"]));
    $user_name = mysqli_real_escape_string($conn, trim($json_data["user_name"]));
    $user_age = mysqli_real_escape_string($conn, trim($json_data["user_age"])); 
    $user_token = mysqli_real_escape_string($conn, trim($json_data["user_token"]));
    
    // ตรวจสอบว่า user_id หรือ user_email มีอยู่แล้วในฐานข้อมูลหรือไม่
    $checkSQL = "SELECT * FROM user_information WHERE user_id = '$user_id' OR user_email = '$user_email'";
    $checkQuery = mysqli_query($conn, $checkSQL);
    
    if (mysqli_num_rows($checkQuery) > 0) { // ถ้า user_id หรือ user_email มีอยู่แล้ว
        // ถ้า user_id หรือ user_email มีอยู่แล้ว แสดงข้อความข้อผิดพลาด
        $result = 0;
        $message = "ชื่อผู้ใช้หรืออีเมลนี้มีผู้ใช้แล้ว";
        $datalist[] = null; // ไม่ส่งข้อมูลรายการกลับ
    } else {
        // ถ้า user_id หรือ user_email ไม่มีอยู่ ดำเนินการเพิ่มข้อมูลลงในตาราง user_information
        $strSQL = "INSERT INTO user_information (user_id, user_email, user_pass, user_name, user_age, user_token) VALUES ('$user_id','$user_email','$user_pass','$user_name','$user_age','$user_token')";
        $query = @mysqli_query($conn, $strSQL);
        $datalist = array(); // สร้าง array สำหรับเก็บข้อมูลที่จะส่งกลับ
        
        if ($query) { // ถ้าการเพิ่มข้อมูลสำเร็จ
            $result = 1;
            $message = "เพิ่มข้อมูลสำเร็จ";
            $datalist[] = array(
                "ID" => mysqli_insert_id($conn), // ดึง ID ที่เพิ่งถูกเพิ่มเข้ามา
                "user_id" => $user_id,
                "user_email" => $user_email,
                "user_pass" => $user_pass,
                "user_name" => $user_name,
                "user_age" => $user_age,
                "user_token" => $user_token
            );
        } else { // ถ้าการเพิ่มข้อมูลล้มเหลว
            $result = 0;
            $message = "การเพิ่มข้อมูลล้มเหลว";
            $datalist[] = null; // ไม่ส่งข้อมูลรายการกลับ
        }
    }

    // ส่งผลลัพธ์กลับในรูปแบบ JSON
    echo json_encode(array("result" => $result, "message" => $message, "datalist" => $datalist));

    mysqli_close($conn); // ปิดการเชื่อมต่อกับฐานข้อมูล
    exit; // หยุดการทำงานของสคริปต์
}
?>