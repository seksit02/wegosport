<?php
include 'Connect.php';

$sql = "SELECT sport_name FROM sport";
$result = $conn->query($sql);

$sport_names = array();

if ($result->num_rows > 0) {
    // Output data of each row
    while($row = $result->fetch_assoc()) {
        $sport_names[] = $row;
    }
} else {
    echo json_encode(array("message" => "0 results"));
    exit();
}
$conn->close();

echo json_encode($sport_names);

?>