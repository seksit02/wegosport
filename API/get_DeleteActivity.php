<?php
include 'Connect.php'; // เชื่อมต่อกับฐานข้อมูล

$data = json_decode(file_get_contents('php://input'), true); // รับข้อมูล JSON ที่ถูกส่งเข้ามาจาก request

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    
    if (!$data) {
        echo json_encode(["message" => "Invalid JSON"]);
        exit;
    }

    $activity_id = $data['activity_id'] ?? null;

    if (!$activity_id) {
        echo json_encode(["message" => "Activity ID is required"]);
        exit;
    }

    // เริ่มการทำธุรกรรม (transaction)
    mysqli_begin_transaction($conn);

    try {
        // ลบข้อมูลในตาราง member_in_activity ที่อ้างอิงถึง activity_id
        $deleteMemberSql = "DELETE FROM member_in_activity WHERE activity_id = ?";
        $deleteMemberStmt = mysqli_prepare($conn, $deleteMemberSql);
        mysqli_stmt_bind_param($deleteMemberStmt, "i", $activity_id);
        mysqli_stmt_execute($deleteMemberStmt);
        mysqli_stmt_close($deleteMemberStmt);

        // ลบข้อมูลในตาราง creator ที่อ้างอิงถึง activity_id
        $deleteCreatorSql = "DELETE FROM creator WHERE activity_id = ?";
        $deleteCreatorStmt = mysqli_prepare($conn, $deleteCreatorSql);
        mysqli_stmt_bind_param($deleteCreatorStmt, "i", $activity_id);
        mysqli_stmt_execute($deleteCreatorStmt);
        mysqli_stmt_close($deleteCreatorStmt);

        // ลบรายการจากตาราง hashtags_in_activities ที่เกี่ยวข้องกับ activity_id นี้
        $deleteHashtagSql = "DELETE FROM hashtags_in_activities WHERE activity_id = ?";
        $deleteStmt = mysqli_prepare($conn, $deleteHashtagSql);
        mysqli_stmt_bind_param($deleteStmt, "i", $activity_id);
        mysqli_stmt_execute($deleteStmt);

        // ลบข้อมูลกิจกรรมในตาราง activity
        $deleteActivitySql = "DELETE FROM activity WHERE activity_id = ?";
        $deleteActivityStmt = mysqli_prepare($conn, $deleteActivitySql);
        mysqli_stmt_bind_param($deleteActivityStmt, "i", $activity_id);
        mysqli_stmt_execute($deleteActivityStmt);

        // ยืนยันการเปลี่ยนแปลงทั้งหมดในธุรกรรมนี้
        mysqli_commit($conn);

        echo json_encode(["result" => "success", "message" => "Activity deleted successfully"]);
    } catch (Exception $e) {
        mysqli_rollback($conn);
        echo json_encode(["result" => "error", "message" => $e->getMessage()]);
    }

    // ปิด statement ทั้งหมด
    if (isset($deleteStmt)) {
        mysqli_stmt_close($deleteStmt);
    }
    if (isset($deleteActivityStmt)) {
        mysqli_stmt_close($deleteActivityStmt);
    }
}

mysqli_close($conn);
?>
