<?php
include 'Connect.php'; // เชื่อมต่อกับฐานข้อมูล

// รับข้อมูลจาก headers และ body
$headers = apache_request_headers(); // รับ headers จาก request
if (isset($headers['authorization'])) { // ตรวจสอบว่ามี header authorization หรือไม่
    $jwt = $headers['authorization']; // รับค่า JWT จาก header

    // ตรวจสอบและตัดคำว่า "Bearer " ออกถ้ามี
    if (strpos($jwt, 'Bearer ') === 0) { 
        $jwt = substr($jwt, 7); // ตัดคำว่า "Bearer " ออกเหลือเฉพาะ JWT
    }

    // รับข้อมูลจาก POST
    $user_name = $_POST['user_name']; // รับค่า user_name จาก POST request
    $user_text = $_POST['user_text']; // รับค่า user_text จาก POST request
    $user_age = $_POST['user_age']; // รับค่า user_age จาก POST request

    // Debug: แสดงค่าที่ได้รับ
    error_log("JWT : " . $jwt); // บันทึก JWT ลงใน log file
    error_log("User_Name : " . $user_name); // บันทึก user_name ลงใน log file
    error_log("User_Text : " . $user_text); // บันทึก user_text ลงใน log file
    error_log("User_Age : " . $user_age); // บันทึก user_age ลงใน log file

    // ตรวจสอบ user_jwt ก่อนว่าเป็นของผู้ใช้คนไหน
    $sql_check = $conn->prepare("SELECT user_id FROM user_information WHERE user_jwt = ?"); // เตรียม SQL statement เพื่อค้นหา user_id โดยใช้ JWT
    $sql_check->bind_param("s", $jwt); // ผูก JWT กับคำสั่ง SQL
    $sql_check->execute(); // รันคำสั่ง SQL
    $result = $sql_check->get_result(); // รับผลลัพธ์จากคำสั่ง SQL

    if ($result->num_rows > 0) { // ถ้าพบ user_id ที่ตรงกับ JWT
        $row = $result->fetch_assoc();
        $user_id = $row['user_id']; // เก็บค่า user_id ที่ค้นพบ
        
        // อัปเดตข้อมูลของผู้ใช้
        $sql_update = $conn->prepare("UPDATE user_information SET user_name = ?, user_text = ?, user_age = ? WHERE user_jwt = ?"); // เตรียม SQL statement เพื่ออัปเดตข้อมูลผู้ใช้
        $sql_update->bind_param("ssss", $user_name, $user_text, $user_age, $jwt); // ผูกข้อมูลที่ได้รับจาก POST กับคำสั่ง SQL

        // Debug: แสดง SQL Query สำหรับอัปเดต
        error_log("SQL Update: UPDATE user_information SET user_name = '$user_name', user_text = '$user_text', user_age = '$user_age' WHERE user_jwt = '$jwt'"); // บันทึกคำสั่ง SQL ลงใน log file

        if ($sql_update->execute()) { // ถ้าอัปเดตข้อมูลสำเร็จ
            echo json_encode(array("message" => "User updated successfully")); // ส่งข้อความแสดงความสำเร็จกลับไปในรูปแบบ JSON
        } else { // ถ้าอัปเดตข้อมูลไม่สำเร็จ
            echo json_encode(array("message" => "Error updating user: " . $sql_update->error)); // ส่งข้อความแสดงข้อผิดพลาดกลับไปในรูปแบบ JSON
        }
    } else { // ถ้าไม่พบ user_id ที่ตรงกับ JWT
        echo json_encode(array("message" => "Invalid JWT")); // ส่งข้อความแสดงข้อผิดพลาดกลับไปในรูปแบบ JSON
    }
} else { // ถ้าไม่พบ header authorization
    echo json_encode(array("message" => "Authorization header not found")); // ส่งข้อความแสดงข้อผิดพลาดกลับไปในรูปแบบ JSON
}

$conn->close(); // ปิดการเชื่อมต่อฐานข้อมูล
?>
