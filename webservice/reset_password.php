<?php
// เชื่อมต่อฐานข้อมูล
$servername = "localhost"; // ชื่อ server
$username = "root"; // ชื่อผู้ใช้ของฐานข้อมูล
$password = ""; // รหัสผ่านของฐานข้อมูล
$dbname = "wegosport"; // ชื่อฐานข้อมูล

// สร้างการเชื่อมต่อ
$conn = new mysqli($servername, $username, $password, $dbname);

// ตรวจสอบการเชื่อมต่อ
if ($conn->connect_error) {
    die("การเชื่อมต่อล้มเหลว : " . $conn->connect_error);
}

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $newPassword = $_POST['password'];
    $token = $_POST['token'];

    // ตรวจสอบโทเค็น
    $sql = "SELECT user_email FROM user_information WHERE user_tokenmail = ?";
    $stmt = $conn->prepare($sql);
    if ($stmt === false) {
        die(json_encode(array("status" => "error", "message" => "Prepare failed: " . $conn->error)));
    }
    $stmt->bind_param('s', $token);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $email = $row['user_email'];

        // อัปเดตรหัสผ่านในตารางผู้ใช้เป็น plain text
        $sql = "UPDATE user_information SET user_pass = ?, user_tokenmail = NULL WHERE user_email = ?";
        $stmt = $conn->prepare($sql);
        if ($stmt === false) {
            die(json_encode(array("status" => "error", "message" => "Prepare failed: " . $conn->error)));
        }
        $stmt->bind_param('ss', $newPassword, $email);
        $stmt->execute();

        // แสดงผลการรีเซ็ตรหัสผ่านในรูปแบบข้อความ
        echo json_encode(array(
            "status" => "success",
            "message" => "Password reset successful",
            "newPassword" => $newPassword
        ));
    } else {
        echo json_encode(array(
            "status" => "error",
            "message" => "โทเค็นไม่ถูกต้องหรือหมดอายุ"
        ));
    }

    $stmt->close();
    $conn->close();
} else {
    if (isset($_GET['token'])) {
        $token = $_GET['token'];

        // ตรวจสอบโทเค็นและอีเมล
        $sql = "SELECT user_email FROM user_information WHERE user_tokenmail = ?";
        $stmt = $conn->prepare($sql);
        if ($stmt === false) {
            die(json_encode(array("status" => "error", "message" => "Prepare failed: " . $conn->error)));
        }
        $stmt->bind_param('s', $token);
        $stmt->execute();
        $result = $stmt->get_result();

        if ($result->num_rows > 0) {
            // แสดงฟอร์มรีเซ็ตรหัสผ่าน
            ?>

            <!DOCTYPE html>
            <html lang="en">
            <head>
                <meta charset="UTF-8">
                <title>Password Reset Form</title>
                <style>
                    body {
                        font-family: Arial, sans-serif;
                        background-color: #f2f2f2;
                        display: flex;
                        justify-content: center;
                        align-items: center;
                        height: 100vh;
                        margin: 0;
                    }
                    .container {
                        background-color: #fff;
                        padding: 20px;
                        border-radius: 10px;
                        box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
                        width: 300px;
                    }
                    .container h2 {
                        text-align: center;
                        margin-bottom: 20px;
                    }
                    .form-group {
                        margin-bottom: 15px;
                    }
                    .form-group label {
                        display: block;
                        margin-bottom: 5px;
                    }
                    .form-group input {
                        width: 100%;
                        padding: 8px;
                        box-sizing: border-box;
                        border: 1px solid #ccc;
                        border-radius: 5px;
                    }
                    .form-group button {
                        width: 100%;
                        padding: 10px;
                        background-color: #4CAF50;
                        color: white;
                        border: none;
                        border-radius: 5px;
                        cursor: pointer;
                    }
                    .form-group button:hover {
                        background-color: #45a049;
                    }
                </style>
            </head>
            <body>
                <div class="container">
                    <h2>รีเซ็ตรหัสผ่าน</h2>
                    <form action="reset_password.php" method="post">
                        <input type="hidden" name="token" value="<?php echo htmlspecialchars($token); ?>">
                        <div class="form-group">
                            <label for="password">รหัสผ่านใหม่</label>
                            <input type="password" id="password" name="password" required>
                        </div>
                        <div class="form-group">
                            <button type="submit">แก้ไข</button>
                        </div>
                    </form>
                </div>
            </body>
            </html>

            <?php
        } else {
            echo json_encode(array("status" => "error", "message" => "โทเค็นไม่ถูกต้องหรือหมดอายุ"));
        }
    } else {
        echo json_encode(array("status" => "error", "message" => "ไม่พบโทเค็น"));
    }
}
?>
