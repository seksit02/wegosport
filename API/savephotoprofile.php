<?php
include 'Connect.php'; // เชื่อมต่อกับฐานข้อมูล

// ตรวจสอบว่าการร้องขอเป็นแบบ POST หรือไม่
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // ตรวจสอบว่ามีการส่ง user_id มาหรือไม่
    $user_id = isset($_POST['user_id']) ? $_POST['user_id'] : '';

    // ตรวจสอบว่ามีการอัปโหลดไฟล์รูปภาพและไม่มีข้อผิดพลาดในการอัปโหลด
    if (isset($_FILES['image']) && $_FILES['image']['error'] === UPLOAD_ERR_OK) {
        // ดึงข้อมูลไฟล์ที่อัปโหลด
        $fileTmpPath = $_FILES['image']['tmp_name']; // ที่อยู่ชั่วคราวของไฟล์ที่อัปโหลด
        $fileName = $_FILES['image']['name']; // ชื่อไฟล์ดั้งเดิมของไฟล์ที่อัปโหลด
        $fileSize = $_FILES['image']['size']; // ขนาดไฟล์
        $fileType = $_FILES['image']['type']; // ประเภทของไฟล์ (เช่น image/jpeg)
        
        // แยกส่วนขยายของไฟล์ออกจากชื่อไฟล์
        $fileNameCmps = explode(".", $fileName);
        $fileExtension = strtolower(end($fileNameCmps)); // นำส่วนขยายไฟล์มาใช้งาน
        
        // สร้างชื่อไฟล์ใหม่โดยใช้เวลาในการสร้างเป็นฐาน แล้วตามด้วยส่วนขยายเดิม
        $newFileName = md5(time() . $fileName) . '.' . $fileExtension;
        
        // กำหนดเส้นทางสำหรับเก็บไฟล์อัปโหลด
        $uploadFileDir = 'C:/xampp/htdocs/flutter_webservice/upload/';
        $dest_path = $uploadFileDir . $newFileName;
        $relative_url = '' . $newFileName; // กำหนด URL สำหรับเข้าถึงไฟล์ที่อัปโหลด

        // ย้ายไฟล์จากตำแหน่งชั่วคราวไปยังตำแหน่งถาวร
        if(move_uploaded_file($fileTmpPath, $dest_path)) {
            $user_photo = $relative_url; // เก็บชื่อไฟล์ใหม่ลงในตัวแปร user_photo

            // อัปเดตข้อมูลรูปภาพผู้ใช้ในฐานข้อมูล
            $sql = "UPDATE user_information SET user_photo = '$user_photo' WHERE user_id = '$user_id'";
            if (mysqli_query($conn, $sql)) {
                // ส่งผลลัพธ์กลับไปที่ไคลเอนต์ในรูปแบบ JSON
                echo json_encode(array("status" => "success", "image_url" => $user_photo));
            } else {
                // หากเกิดข้อผิดพลาดในการอัปเดตฐานข้อมูล
                echo json_encode(array("status" => "error", "message" => "Error: " . mysqli_error($conn)));
            }
        } else {
            // หากเกิดข้อผิดพลาดในการย้ายไฟล์อัปโหลด
            echo json_encode(array("status" => "error", "message" => "There was an error uploading the file."));
        }
    } else {
        // หากไม่มีการอัปโหลดไฟล์หรือมีข้อผิดพลาดในการอัปโหลด
        echo json_encode(array("status" => "error", "message" => "No file uploaded or there was an upload error."));
    }
} else {
    // หากการร้องขอไม่ใช่แบบ POST
    echo json_encode(array("status" => "error", "message" => "Invalid request method."));
}
?>
