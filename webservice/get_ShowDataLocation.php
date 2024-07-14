<?php
include 'Connect.php';

header('Content-Type: application/json');

$sql = "SELECT location_name, location_time, location_photo FROM location";
$result = mysqli_query($conn, $sql);

$locations = array();

if (mysqli_num_rows($result) > 0) {
    while($row = mysqli_fetch_assoc($result)) {
        $locations[] = $row;
    }
}

echo json_encode($locations);

mysqli_close($conn);
?>
