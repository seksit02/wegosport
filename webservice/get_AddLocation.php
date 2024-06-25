<?php
require 'Connect.php';

//3.request from client
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $content = file_get_contents("php://input"); //plaintext
    $json_data = json_decode($content, true); // เอา plaintext มาจัดรูปแบบเป็น json (json_decode)
    $location_name = mysqli_real_escape_string($conn, trim($json_data["location_name"]));
    $location_time = mysqli_real_escape_string($conn, trim($json_data["location_time"]));
    $location_rules = mysqli_real_escape_string($conn, trim($json_data["location_rules"]));
    
    
        
//4.sql command / process
    $strSQL = "INSERT INTO location (location_name, location_time, location_rules) VALUES ('$location_name','$location_time','$location_rules')";
    $query = @mysqli_query($conn,$strSQL);
    $datalist = array();
    
if ($query) {
    $result = 1;
    $message = "เพิ่มข้อมูลสำเร็จ";
    $datalist[] = array("ID" => mysqli_insert_id($conn), "location_name" => $location_name, "location_time" => $location_time, "location_rules" => $location_rules );
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
