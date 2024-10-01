<?php
include 'Connect.php'; // นำเข้าไฟล์ Connect.php เพื่อเชื่อมต่อฐานข้อมูล

// ตรวจสอบว่าคำขอเป็น POST หรือไม่
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // รับค่าจาก POST request และกำหนดค่าให้กับตัวแปรต่างๆ
    $location_name = isset($_POST['location_name']) ? $_POST['location_name'] : ''; // ชื่อสถานที่
    $location_time = isset($_POST['location_time']) ? $_POST['location_time'] : ''; // เวลาเปิด-ปิด
    $latitude = isset($_POST['latitude']) ? $_POST['latitude'] : ''; // ละติจูดของสถานที่
    $longitude = isset($_POST['longitude']) ? $_POST['longitude'] : ''; // ลองจิจูดของสถานที่
    $location_day = isset($_POST['location_day']) ? $_POST['location_day'] : ''; // วันที่เลือก
    $types_id = isset($_POST['types_id']) ? json_decode($_POST['types_id']) : []; // ประเภทกีฬาที่เลือก

    // ตรวจสอบว่ามีประเภทกีฬาถูกเลือกหรือไม่
    $primary_type_id = !empty($types_id) ? $types_id[0] : null; // เลือกประเภทแรกเป็นประเภทหลัก

    // ตรวจสอบว่ามีการอัปโหลดไฟล์รูปภาพและไม่มีข้อผิดพลาด
    if (isset($_FILES['image']) && $_FILES['image']['error'] === UPLOAD_ERR_OK) {
        $fileTmpPath = $_FILES['image']['tmp_name']; // เส้นทางไฟล์ชั่วคราว
        $fileName = $_FILES['image']['name']; // ชื่อไฟล์ต้นฉบับ
        $fileSize = $_FILES['image']['size']; // ขนาดไฟล์
        $fileType = $_FILES['image']['type']; // ประเภทของไฟล์
        $fileNameCmps = explode(".", $fileName); // แยกชื่อไฟล์และนามสกุล
        $fileExtension = strtolower(end($fileNameCmps)); // นามสกุลไฟล์ (เป็นตัวพิมพ์เล็ก)
        $newFileName = md5(time() . $fileName) . '.' . $fileExtension; // ตั้งชื่อไฟล์ใหม่โดยใช้ md5
        $uploadFileDir = 'C:/xampp/htdocs/flutter_webservice/upload/'; // กำหนดโฟลเดอร์ที่จะอัปโหลดไฟล์
        $dest_path = $uploadFileDir . $newFileName; // เส้นทางไฟล์ที่อัปโหลด
        $relative_url = '' . $newFileName; // URL แบบสัมพัทธ์สำหรับเข้าถึงไฟล์

        // ย้ายไฟล์ที่อัปโหลดไปยังตำแหน่งปลายทาง
        if(move_uploaded_file($fileTmpPath, $dest_path)) {
            $location_photo = $relative_url; // เก็บ URL ของรูปภาพ

            // สร้างคำสั่ง SQL สำหรับแทรกข้อมูลสถานที่ในฐานข้อมูล
            $sql = "INSERT INTO location (location_name, location_time, location_photo, latitude, longitude, location_day) VALUES ('$location_name', '$location_time', '$location_photo', '$latitude', '$longitude', '$location_day')";
            if (mysqli_query($conn, $sql)) { // รันคำสั่ง SQL
                $location_id = mysqli_insert_id($conn); // เก็บ ID ของสถานที่ที่เพิ่งแทรก

                // แทรกประเภทสนามลงในตาราง sport_type_in_location
                foreach ($types_id as $type_id) {
                    $type_id = mysqli_real_escape_string($conn, $type_id); // ป้องกัน SQL injection
                    $sql_type = "INSERT INTO sport_type_in_location (location_id, type_id) VALUES ('$location_id', '$type_id')";
                    if (!mysqli_query($conn, $sql_type)) { // รันคำสั่ง SQL และตรวจสอบข้อผิดพลาด
                        echo json_encode(array("status" => "error", "message" => "Error: " . mysqli_error($conn)));
                        exit(); // ถ้ามีข้อผิดพลาดให้หยุดการทำงาน
                    }
                }
                // ส่งผลลัพธ์กลับมาในรูปแบบ JSON
                echo json_encode(array("status" => "success", "message" => "Location added successfully.", "location_id" => $location_id));
                
            } else {
                // ส่งผลลัพธ์เมื่อมีข้อผิดพลาดในการแทรกข้อมูลสถานที่
                echo json_encode(array("status" => "error", "message" => "Error: " . mysqli_error($conn)));
            }
        } else {
            // ส่งผลลัพธ์เมื่อการอัปโหลดไฟล์ล้มเหลว
            echo json_encode(array("status" => "error", "message" => "There was an error uploading the file."));
        }
    } else {
        // ส่งผลลัพธ์เมื่อไม่มีการอัปโหลดไฟล์หรือเกิดข้อผิดพลาด
        echo json_encode(array("status" => "error", "message" => "No file uploaded or there was an upload error."));
    }
}
?>
