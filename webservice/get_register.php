<?php
require 'Connect.php';

//3.request from client
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $content = file_get_contents("php://input"); //plaintext
    $json_data = json_decode($content, true); // เอา plaintext มาจัดรูปแบบเป็น json (json_decode)
    $user_id = mysqli_real_escape_string($conn, trim($json_data["user_id"]));
    $user_email = mysqli_real_escape_string($conn, trim($json_data["user_email"]));
    $user_pass = mysqli_real_escape_string($conn, trim($json_data["user_pass"]));
    $user_name = mysqli_real_escape_string($conn, trim($json_data["user_name"]));
    $user_age = mysqli_real_escape_string($conn, trim($json_data["user_age"]));
    $user_token = mysqli_real_escape_string($conn, trim($json_data["user_token"]));
        
//4.sql command / process
    $strSQL = "INSERT INTO user_information (user_id, user_email, user_pass, user_name,user_age,user_token) VALUES ('$user_id','$user_email','$user_pass','$user_name','$user_age','$user_token')";
    $query = @mysqli_query($conn,$strSQL);
    $datalist = array();
    
if ($query) {
    $result = 1;
    $message = "เพิ่มข้อมูลสำเร็จ";
    $datalist[] = array("ID" => mysqli_insert_id($conn), "user_id" => $user_id, "user_email" => $user_email, "user_pass" => $user_pass, "user_name" => $user_name,"user_age" => $user_age,"user_token" => $user_token  );
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
