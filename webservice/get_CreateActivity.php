<?php
require 'Connect.php';

//3.request from client
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $content = file_get_contents("php://input"); //plaintext
    $json_data = json_decode($content, true); // เอา plaintext มาจัดรูปแบบเป็น json (json_decode)
    $activity_name = mysqli_real_escape_string($conn, trim($json_data["activity_name"]));
    $activity_details = mysqli_real_escape_string($conn, trim($json_data["activity_details"]));
    $activity_date = mysqli_real_escape_string($conn, trim($json_data["activity_date"]));
    
        
//4.sql command / process
    $strSQL = "INSERT INTO activity (activity_name, activity_details, activity_date) VALUES ('$activity_name','$activity_details','$activity_date')";
    $query = @mysqli_query($conn,$strSQL);
    $datalist = array();
    
if ($query) {
    $result = 1;
    $message = "เพิ่มข้อมูลสำเร็จ";
    $datalist[] = array("ID" => mysqli_insert_id($conn), "activity_name" => $activity_name, "activity_details" => $activity_details, "activity_date" => $activity_date );
} else {
    $result = 0;
    $message = "มีข้อมูลซ้ำในระบบ";
    $datalist[] = null;
    }
    

echo json_encode(array("result"=>@$result,"message"=>@$message,"datalist"=>@$datalist));

mysqli_close($conn);
exit;
    }
?>
