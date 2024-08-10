<?php
require 'Connect.php';

// รับคำขอจากลูกค้า
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $content = file_get_contents("php://input"); // ข้อความธรรมดา
    $json_data = json_decode($content, true); // แปลงข้อความธรรมดาเป็นรูปแบบ json (json_decode)
    $user_id = mysqli_real_escape_string($conn, trim($json_data["user_id"]));
    $user_email = mysqli_real_escape_string($conn, trim($json_data["user_email"]));
    $user_pass = mysqli_real_escape_string($conn, trim($json_data["user_pass"]));
    $user_name = mysqli_real_escape_string($conn, trim($json_data["user_name"]));
    $user_age = mysqli_real_escape_string($conn, trim($json_data["user_age"])); //
    $user_token = mysqli_real_escape_string($conn, trim($json_data["user_token"]));
    
    // ตรวจสอบว่า user_id หรือ user_email มีอยู่แล้วหรือไม่
    $checkSQL = "SELECT * FROM user_information WHERE user_id = '$user_id' OR user_email = '$user_email'";
    $checkQuery = mysqli_query($conn, $checkSQL);
    
    if (mysqli_num_rows($checkQuery) > 0) {
        // ถ้า user_id หรือ user_email มีอยู่แล้ว แสดงข้อความข้อผิดพลาด
        $result = 0;
        $message = "ชื่อผู้ใช้หรืออีเมลนี้มีผู้ใช้แล้ว";
        $datalist[] = null;
    } else {
        // ถ้า user_id หรือ user_email ไม่มีอยู่ ดำเนินการเพิ่มข้อมูล
        $strSQL = "INSERT INTO user_information (user_id, user_email, user_pass, user_name, user_age, user_token) VALUES ('$user_id','$user_email','$user_pass','$user_name','$user_age','$user_token')";
        $query = @mysqli_query($conn, $strSQL);
        $datalist = array();
        
        if ($query) {
            $result = 1;
            $message = "เพิ่มข้อมูลสำเร็จ";
            $datalist[] = array("ID" => mysqli_insert_id($conn), "user_id" => $user_id, "user_email" => $user_email, "user_pass" => $user_pass, "user_name" => $user_name, "user_age" => $user_age, "user_token" => $user_token);
        } else {
            $result = 0;
            $message = "การเพิ่มข้อมูลล้มเหลว";
            $datalist[] = null;
        }
    }

    echo json_encode(array("result" => $result, "message" => $message, "datalist" => $datalist));

    mysqli_close($conn);
    exit;
}
?>
