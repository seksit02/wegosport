<?php
// เชื่อมต่อกับฐานข้อมูล
include('Connect.php');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $user_id = $_POST['user_id'];
    $activity_id = $_POST['activity_id'];

    // SQL ในการเพิ่มข้อมูลลงในตาราง member_in_activity
    $sql = "INSERT INTO member_in_activity (activity_id, user_id) VALUES ('$activity_id', '$user_id')";

    if (mysqli_query($conn, $sql)) {
        echo "เข้าร่วมกิจกรรมสำเร็จ";
    } else {
        echo "เกิดข้อผิดพลาด: " . mysqli_error($conn);
    }

    // ปิดการเชื่อมต่อฐานข้อมูล
    mysqli_close($conn);
}
?>
