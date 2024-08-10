<?php
include 'Connect.php'; // ไฟล์เชื่อมต่อกับฐานข้อมูล

// รับข้อมูลจาก headers และ body
$headers = apache_request_headers();
if (isset($headers['authorization'])) {
    $jwt = $headers['authorization'];

    // ตรวจสอบและตัดคำว่า "Bearer " ออกถ้ามี
    if (strpos($jwt, 'Bearer ') === 0) {
        $jwt = substr($jwt, 7);
    }

    // รับข้อมูลจาก POST
    $user_name = $_POST['user_name'];
    $user_text = $_POST['user_text'];
    $user_age = $_POST['user_age'];

    // Debug: แสดงค่าที่ได้รับ
    error_log("JWT : " . $jwt);
    error_log("User_Name : " . $user_name);
    error_log("User_Text : " . $user_text);
    error_log("User_Age : " . $user_age);

    // ตรวจสอบ user_jwt ก่อนว่าเป็นของผู้ใช้คนไหน
    $sql_check = $conn->prepare("SELECT user_id FROM user_information WHERE user_jwt = ?");
    $sql_check->bind_param("s", $jwt);
    $sql_check->execute();
    $result = $sql_check->get_result();

    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $user_id = $row['user_id'];
        
        // อัปเดตข้อมูล
        $sql_update = $conn->prepare("UPDATE user_information SET user_name = ?, user_text = ?, user_age = ? WHERE user_jwt = ?");
        $sql_update->bind_param("ssss", $user_name, $user_text, $user_age, $jwt);

        // Debug: แสดง SQL Query สำหรับอัปเดต
        error_log("SQL Update: UPDATE user_information SET user_name = '$user_name', user_text = '$user_text', user_age = '$user_age' WHERE user_jwt = '$jwt'");

        if ($sql_update->execute()) {
            echo json_encode(array("message" => "User updated successfully"));
        } else {
            echo json_encode(array("message" => "Error updating user: " . $sql_update->error));
        }
    } else {
        echo json_encode(array("message" => "Invalid JWT"));
    }
} else {
    echo json_encode(array("message" => "Authorization header not found"));
}

$conn->close();
?>
