<?php
include 'Connect.php';

// ดึงค่าจาก body ของ request
$input = file_get_contents("php://input");
$data = json_decode($input, true);

$user_id = $data['user_id'];

$sql = "SELECT user_photo FROM user_information WHERE user_id = '$user_id'";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    echo json_encode(['photo_url' => $row['user_photo']]);
} else {
    echo json_encode(['error' => 'User not found']);
}

$conn->close();
?>