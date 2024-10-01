<?php
// การเชื่อมต่อกับฐานข้อมูล
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "wegosport";

$conn = new mysqli($servername, $username, $password, $dbname);

// ตรวจสอบการเชื่อมต่อ
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// ตรวจสอบว่ามีการส่งข้อมูล user_id และ activity_id มาหรือไม่
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $user_id = $_POST['user_id'];
    $activity_id = $_POST['activity_id'];

    // ลบสมาชิกออกจากกิจกรรม
    $sql = "DELETE FROM member_in_activity WHERE user_id = ? AND activity_id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("si", $user_id, $activity_id);

    if ($stmt->execute()) {
        echo json_encode(array("status" => "success", "message" => "Member removed successfully."));
    } else {
        echo json_encode(array("status" => "error", "message" => "Failed to remove member."));
    }

    $stmt->close();
} else {
    echo json_encode(array("status" => "error", "message" => "Invalid request."));
}

$conn->close();
?>
