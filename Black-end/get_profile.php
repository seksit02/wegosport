<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");


include 'config.php';

$sql = "SELECT pro_id, pro_name, pro_username, pro_brief FROM profile";
$result = $conn->query($sql);

$data = array();

if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $data[] = $row;
    }
} 

$conn->close();

echo json_encode($data);
?>