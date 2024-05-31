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
    $conn = mysqli_connect($serName, $userNameDB, $userNamePassword, $dbName);
?>

<?php
    //3.request from client
    if ($_SERVER["REQUEST_METHOD"] == "POST") {
        $content = file_get_contents("php://input"); //plaintext
        $json_data = json_decode($content, true); // เอา plaintext มาจัดรูปแบบเป็น json (json_decode)

        $user_userID = mysqli_real_escape_string($conn, trim($json_data["user_userID"]));
        $user_email = mysqli_real_escape_string($conn, trim($json_data["user_email"]));
        $user_pass = mysqli_real_escape_string($conn, trim($json_data["user_pass"]));
        $user_name_lastname = mysqli_real_escape_string($conn, trim($json_data["user_name_lastname"]));
        $user_age = mysqli_real_escape_string($conn, trim($json_data["user_age"]));
        
        //4.sql command / process
    $strSQL = "INSERT INTO information (user_userID, user_email, user_pass, user_name_lastname,user_age) VALUES ('$user_userID','$user_email','$user_pass','$user_name_lastname','$user_age')";
    $query = @mysqli_query($conn,$strSQL);
    $datalist = array();
    
        if ($query) {
            $result = 1;
            $message = "เพิ่มข้อมูลสำเร็จ";
            $datalist[] = array("ID" => mysqli_insert_id($conn), "user_userID" => $user_userID, "user_email" => $user_email, "user_pass" => $user_pass, "user_name_lastname" => $user_name_lastname,"user_age" => $user_age  );
        } 
        else {
            $result = 0;
            $message = "มีข้อมูลซ้ำในระบบ";
            $datalist[] = null;
        }
    

    echo json_encode(array("result"=>@$result,"message"=>@$message,"datalist"=>@$datalist));

mysqli_close($conn);
exit;
    }
?>
