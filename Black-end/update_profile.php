<?php
include 'config.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] == 'PUT') {
    parse_str(file_get_contents("php://input"), $put_vars);
    
    if (isset($put_vars['userId']) && isset($put_vars['name']) && isset($put_vars['email'])) {
        $userId = $put_vars['userId'];
        $name = $put_vars['name'];
        $email = $put_vars['email'];
        // Add other fields as needed

        $sql = "UPDATE profile SET name='$name', email='$email' WHERE user_id='$userId'";

        if ($conn->query($sql) === TRUE) {
            echo json_encode(["message" => "Profile updated successfully"]);
        } else {
            http_response_code(500);
            echo json_encode(["message" => "Error updating profile: " . $conn->error]);
        }
    } else {
        http_response_code(400);
        echo json_encode(["message" => "Incomplete data"]);
    }
} else {
    http_response_code(405);
    echo json_encode(["message" => "Method not allowed"]);
}

$conn->close();
?>
