<?php
include 'config.php';

$sql = "SELECT type_id,type_name FROM sport_type";
$result = $conn->query($sql);

$type_name = array();

if ($result->num_rows > 0) {
    // Output data of each row
    while($row = $result->fetch_assoc()) {
        $type_name[] = $row;
    }
} else {
    echo json_encode(array("message" => "0 results"));
    exit();
}
$conn->close();

echo json_encode($type_name);

?>