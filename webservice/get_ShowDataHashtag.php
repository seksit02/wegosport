<?php
include 'Connect.php';

$sql = "SELECT hashtag_message FROM hashtag";
$result = $conn->query($sql);

$hashtag_messages = array();

if ($result->num_rows > 0) {
    // Output data of each row
    while($row = $result->fetch_assoc()) {
        $hashtag_messages[] = $row;
    }
} else {
    echo json_encode(array("message" => "0 results"));
    exit();
}
$conn->close();

echo json_encode($hashtag_messages);

?>
