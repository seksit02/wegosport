<?php
include 'Connect.php'; // เชื่อมต่อกับฐานข้อมูล

$data = json_decode(file_get_contents('php://input'), true); // รับและแปลงข้อมูล JSON ที่ถูกส่งเข้ามาจาก request

if ($_SERVER['REQUEST_METHOD'] == 'POST') { // ตรวจสอบว่า request ที่เข้ามาเป็น POST หรือไม่
    
    if (!$data) { // ตรวจสอบว่าได้รับข้อมูล JSON หรือไม่
        echo json_encode(["message" => "Invalid JSON"]); // ถ้าไม่ได้รับข้อมูล JSON หรือ JSON ไม่ถูกต้อง ส่งข้อความแสดงข้อผิดพลาดกลับไป
        exit; // ออกจากการทำงาน
    }

    // ตรวจสอบและรับค่าต่างๆ จาก $data
    $activity_id = $data['activity_id'] ?? null; 
    $activity_name = $data['activity_name'] ?? null; 
    $activity_date = $data['activity_date'] ?? null; 
    $location_name = $data['location_name'] ?? null;
    $sport_name = $data['sport_name'] ?? null;
    $activity_details = $data['activity_details'] ?? null; 
    $hashtags = $data['hashtags'] ?? []; 

    // แปลง location_name เป็น location_id
    $location_id = null;
    if ($location_name) {
        $sql = "SELECT location_id FROM location WHERE location_name = ?";
        $stmt = mysqli_prepare($conn, $sql);
        mysqli_stmt_bind_param($stmt, "s", $location_name);
        mysqli_stmt_execute($stmt);
        mysqli_stmt_bind_result($stmt, $location_id);
        mysqli_stmt_fetch($stmt);
        mysqli_stmt_close($stmt);
    }

    // แปลง sport_name เป็น sport_id
    $sport_id = null;
    if ($sport_name) {
        $sql = "SELECT sport_id FROM sport WHERE sport_name = ?";
        $stmt = mysqli_prepare($conn, $sql);
        mysqli_stmt_bind_param($stmt, "s", $sport_name);
        mysqli_stmt_execute($stmt);
        mysqli_stmt_bind_result($stmt, $sport_id);
        mysqli_stmt_fetch($stmt);
        mysqli_stmt_close($stmt);
    }

    // ตรวจสอบว่า location_id และ sport_id ถูกส่งมาหรือไม่
    if (!$location_id || !$sport_id) {
        echo json_encode(["message" => "location_id and sport_id are required"]);
        exit;
    }

    // เริ่มการทำธุรกรรม (transaction)
    mysqli_begin_transaction($conn);

    try {
        // เตรียมคำสั่ง SQL เพื่ออัปเดตข้อมูลกิจกรรมในตาราง activity
        $sql = "UPDATE activity SET 
                    activity_name = ?, 
                    activity_date = ?, 
                    location_id = ?, 
                    sport_id = ?, 
                    activity_details = ? 
                WHERE activity_id = ?";
        $stmt = mysqli_prepare($conn, $sql); // เตรียมคำสั่ง SQL
        mysqli_stmt_bind_param($stmt, "ssiisi", $activity_name, $activity_date, $location_id, $sport_id, $activity_details, $activity_id); // ผูกพารามิเตอร์กับคำสั่ง SQL

        if (mysqli_stmt_execute($stmt)) { // ถ้าอัปเดตข้อมูลสำเร็จ
            // ลบรายการจากตาราง hashtags_in_activities ที่เกี่ยวข้องกับ activity_id นี้
            $deleteHashtagSql = "DELETE FROM hashtags_in_activities WHERE activity_id = ?";
            $deleteStmt = mysqli_prepare($conn, $deleteHashtagSql); // เตรียมคำสั่ง SQL
            mysqli_stmt_bind_param($deleteStmt, "i", $activity_id); // ผูก activity_id กับคำสั่ง SQL
            mysqli_stmt_execute($deleteStmt); // ลบรายการ

            // ตรวจสอบว่า hashtag ที่ส่งมามีอยู่จริงในตาราง hashtag ก่อนทำการเพิ่ม
            $insertHashtagSql = "INSERT INTO hashtags_in_activities (activity_id, hashtag_id) VALUES (?, ?)";
            $insertStmt = mysqli_prepare($conn, $insertHashtagSql); // เตรียมคำสั่ง SQL

            foreach ($hashtags as $hashtag) {
                $hashtag_id = null;
                $hashtagCheckSql = "SELECT hashtag_id FROM hashtag WHERE hashtag_message = ?";
                $hashtagCheckStmt = mysqli_prepare($conn, $hashtagCheckSql);
                mysqli_stmt_bind_param($hashtagCheckStmt, "s", $hashtag);
                mysqli_stmt_execute($hashtagCheckStmt);
                mysqli_stmt_bind_result($hashtagCheckStmt, $hashtag_id);
                mysqli_stmt_fetch($hashtagCheckStmt);
                mysqli_stmt_close($hashtagCheckStmt);

                // ถ้าแฮชแท็กไม่มีในฐานข้อมูล ให้เพิ่มใหม่
                if (!$hashtag_id) {
                    $insertNewHashtagSql = "INSERT INTO hashtag (hashtag_message) VALUES (?)";
                    $insertNewHashtagStmt = mysqli_prepare($conn, $insertNewHashtagSql);
                    mysqli_stmt_bind_param($insertNewHashtagStmt, "s", $hashtag);
                    mysqli_stmt_execute($insertNewHashtagStmt);
                    $hashtag_id = mysqli_insert_id($conn); // รับค่า hashtag_id ของแฮชแท็กใหม่
                    mysqli_stmt_close($insertNewHashtagStmt);
                }

                // เพิ่ม hashtag_id ลงใน hashtags_in_activities
                if ($hashtag_id) {
                    mysqli_stmt_bind_param($insertStmt, "ii", $activity_id, $hashtag_id); // ผูก activity_id และ hashtag_id กับคำสั่ง SQL
                    mysqli_stmt_execute($insertStmt); // เพิ่มรายการ
                }
            }

            // ยืนยันการเปลี่ยนแปลงทั้งหมดในธุรกรรมนี้
            mysqli_commit($conn);

            echo json_encode(["message" => "Activity updated successfully"]); // ส่งข้อความแสดงความสำเร็จกลับไป
        } else { // ถ้าอัปเดตไม่สำเร็จ
            throw new Exception("Failed to update activity"); // โยนข้อยกเว้น
        }
    } catch (Exception $e) { // จับข้อยกเว้นที่เกิดขึ้น
        // ยกเลิกการเปลี่ยนแปลงทั้งหมดถ้ามีข้อผิดพลาดเกิดขึ้น
        mysqli_rollback($conn);
        echo json_encode(["message" => $e->getMessage()]); // ส่งข้อความข้อผิดพลาดกลับไป
    }

    // ปิด statement ทั้งหมด
    if (isset($stmt)) {
        mysqli_stmt_close($stmt);
    }
    if (isset($deleteStmt)) {
        mysqli_stmt_close($deleteStmt);
    }
    if (isset($insertStmt)) {
        mysqli_stmt_close($insertStmt);
    }
}

mysqli_close($conn); // ปิดการเชื่อมต่อฐานข้อมูล
?>
