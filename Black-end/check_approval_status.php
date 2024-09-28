<?php

include 'config.php';



if (isset($_GET['location_id'])) {
    $location_id = $_GET['location_id'];
    $sql = "SELECT status FROM location WHERE location_id = $location_id";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        echo json_encode(['status' => $row['status']]);
    } else {
        echo json_encode(['status' => 'not_found']);
    }
}

$conn->close();
?>