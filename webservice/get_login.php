<?php

require 'Connect.php';

if($_SERVER["REQUEST_METHOD"]=="POST"){
    $content = @file_get_contents("php://input");
    $json_data = @json_decode($content,true);
    $user_id = trim($json_data["user_id"]);
    $user_pass = trim($json_data["user_pass"]);
} else { //GET
    echo json_encode(array("result"=>0,"message"=>"method invaild"));
    exit;
}
    
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

    $strSQL = "SELECT * FROM user_information WHERE user_id ='".@$user_id."' ";
    $query = @mysqli_query($conn,$strSQL);
    $datalist = array();
    while($resultObj = @mysqli_fetch_array($query,MYSQLI_ASSOC)){
        //echo $resultObj['cus_name'];
        if(trim($user_pass)===$resultObj['user_pass']){ //ถ้า login ได้
            //echo "GOOD LOGIN";
            $result ="1";
            $message = "success";
            $datalist[] = array("user_id"=>$resultObj['user_id'],"user_email"=>$resultObj['user_email'],"user_pass"=>$resultObj['user_pass']);
            
        }else{ //login ไม่ได้
            //echo "BAD LOGIN";
            $result ="0";
            $message = "password invaild";            
        }
    }

    echo json_encode(array("result"=>@$result,"message"=>@$message,"datalist"=>@$datalist));

mysqli_close($conn);
exit;

?>