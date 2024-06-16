<?php
//1.header
@header('Content-Type: application/json');
@header("Access-Control-Allow-Origin: *");
@header('Access-Control-Allow-Headers: X-Requested-With, content-type, access-control-allow-origin, access-control-allow-methods, access-control-allow-headers');

//2.connection DB
$serName = "127.0.0.1";
$userNameDB = "root";
$userNamePassword = "";
$dbName = "user_information";
$conn = @mysqli_connect($serName, $userNameDB, $userNamePassword, $dbName);
?>

<?php
    if($_SERVER["REQUEST_METHOD"]=="POST"){
        $content = @file_get_contents("php://input");
        $json_data = @json_decode($content,true);
        $username = trim($json_data["username"]);
        $password = trim($json_data["password"]);
    }else{ //GET
        echo json_encode(array("result"=>0,"message"=>"method invaild"));
        exit;
    }
    //$username = "sarawut@rmuti.ac.th";
    //$password = "7412";

    if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
?>

<?php
    $strSQL = "SELECT * FROM information WHERE user_userID ='".@$username."' ";
    $query = @mysqli_query($conn,$strSQL);
    $datalist = array();
    while($resultObj = @mysqli_fetch_array($query,MYSQLI_ASSOC)){
        //echo $resultObj['cus_name'];
        if(trim($password)===$resultObj['user_pass']){ //ถ้า login ได้
            //echo "GOOD LOGIN";
            $result ="1";
            $message = "success";
            $datalist[] = array("user_userID"=>$resultObj['user_userID'],"user_email"=>$resultObj['user_email'],"user_pass"=>$resultObj['user_pass']);
            
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