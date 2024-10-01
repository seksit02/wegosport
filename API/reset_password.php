<?php
// ตั้งค่าการเชื่อมต่อฐานข้อมูล
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
    // รับข้อมูลจากฟอร์ม
    $newPassword = $_POST['password'];
    $confirmPassword = $_POST['confirm_password'];
    $token = $_POST['token'];

    // ตรวจสอบว่ารหัสผ่านใหม่และการยืนยันตรงกัน
    if ($newPassword === $confirmPassword) {
        // ตรวจสอบโทเค็นในฐานข้อมูล
        $sql = "SELECT user_email FROM user_information WHERE user_tokenmail = ?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param('s', $token);
        $stmt->execute();
        $result = $stmt->get_result();

        // ถ้าโทเค็นถูกต้อง
        if ($result->num_rows > 0) {
            $row = $result->fetch_assoc();
            $email = $row['user_email'];

            // อัปเดตรหัสผ่านในตารางผู้ใช้และลบโทเค็น
            $sql = "UPDATE user_information SET user_pass = ?, user_tokenmail = NULL WHERE user_email = ?";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param('ss', $newPassword, $email);
            $stmt->execute();

            // แสดงผลการรีเซ็ตรหัสผ่านในรูปแบบการ์ด
            echo "
            <!DOCTYPE html>
            <html lang='en'>
            <head>
                <meta charset='UTF-8'>
                <title>Password Reset Successful</title>
                <style>
                    body {
                        display: flex;
                        justify-content: center;
                        align-items: center;
                        height: 100vh;
                        margin: 0;
                        font-family: Arial, sans-serif;
                        background-color: #f2f2f2;
                    }
                    .card {
                        background-color: #fff;
                        padding: 20px;
                        border-radius: 10px;
                        box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
                        text-align: center;
                        max-width: 300px;
                    }
                    .card h2 {
                        margin-top: 0;
                        color: #4CAF50;
                    }
                    .card p {
                        font-size: 16px;
                        color: #333;
                    }
                    .card p strong {
                        font-weight: bold;
                    }
                    .card button {
                        background-color: #4CAF50;
                        color: white;
                        padding: 10px 20px;
                        border: none;
                        border-radius: 5px;
                        cursor: pointer;
                        margin-top: 20px;
                    }
                    .card button:hover {
                        background-color: #45a049;
                   }
                    .card img {
                        max-width: 100px;
                        height: auto;
                        margin-bottom: 20px;
                    }
                </style>
            </head>
            <body>
                <div class='card'>
                    <img src='/flutter_webservice/upload/logo.png'>
                    <h2>รีเซ็ตรหัสผ่านสำเร็จแล้ว</h2>
                    <p>รหัสผ่านใหม่ของคุณถูกตั้งค่าเรียบร้อยแล้ว</p>
                </div>
            </body>
            </html>";
        } else {
            // ถ้าโทเค็นไม่ถูกต้องหรือหมดอายุ
            echo "โทเค็นไม่ถูกต้องหรือหมดอายุ";
        }

        $stmt->close();
    }

    $conn->close();
} else {
    // ถ้าเป็น GET request ให้แสดงฟอร์มรีเซ็ตรหัสผ่าน
    if (isset($_GET['token'])) {
        $token = $_GET['token'];

        // ตรวจสอบโทเค็นและอีเมล
        $sql = "SELECT user_email FROM user_information WHERE user_tokenmail = ?";
        $stmt = $conn->prepare($sql);
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
                <title>รีเซ็ตรหัสผ่าน</title>
                <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
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
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            max-width: 350px;
            width: 100%;
        }
        .container h2 {
            text-align: center;
            margin-bottom: 20px;
            color: #333;
        }
        .form-group {
            margin-bottom: 15px;
            position: relative;
        }
        .form-group label {
            display: block;
            margin-bottom: 5px;
            color: #666;
        }
        .input-group {
            display: flex;
            align-items: center;
            position: relative;
        }
        .input-group input {
            width: 100%;
            padding: 10px;
            padding-right: 40px;
            box-sizing: border-box;
            border: 1px solid #ccc;
            border-radius: 5px;
        }
        .input-group input:focus {
            outline: none;
            border-color: #4CAF50;
        }
        .input-group .toggle-password {
            position: absolute;
            right: 10px;
            top: 50%;
            transform: translateY(-50%);
            cursor: pointer;
            color: #666;
        }
        .form-group button {
            width: 100%;
            padding: 10px;
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            margin-top: 10px;
        }
        .form-group button:hover {
            background-color: #45a049;
        }
        .form-group p {
            font-size: 14px;
            color: #666;
            text-align: center;
        }
        .form-group .message {
            text-align: left;
            margin-top: 10px;
            font-size: 14px;
            color: #888;
            white-space: normal;
            overflow-wrap: break-word;
            word-wrap: break-word;
        }
        .form-group .error-message {
            text-align: left;
            margin-top: 10px;
            font-size: 14px;
            color: red;
        }
                </style>
               <script>
        function togglePasswordVisibility(id) {
            const passwordInput = document.getElementById(id);
            const toggleIcon = document.getElementById(id + '-toggle');
            if (passwordInput.type === 'password') {
                passwordInput.type = 'text';
                toggleIcon.classList.remove('fa-eye');
                toggleIcon.classList.add('fa-eye-slash');
            } else {
                passwordInput.type = 'password';
                toggleIcon.classList.remove('fa-eye-slash');
                toggleIcon.classList.add('fa-eye');
            }
        }

        function validatePassword() {
            const password = document.getElementById('password');
            const message = document.getElementById('message');

            // เปลี่ยนจาก 8 ตัวอักษรเป็น 6 ตัวอักษร และไม่บังคับใช้ตัวพิมพ์ใหญ่
            const pattern = /^(?=.*[a-z])(?=.*\d).{6,}$/;

            if (password.value === "") {
                message.style.color = '#888';
                message.textContent = 'รหัสผ่านของคุณต้องมีความยาว 6 ตัวอักษรและมีทั้งตัวพิมพ์เล็ก และตัวเลข';
            } else if (pattern.test(password.value)) {
                message.style.color = 'green';
                message.textContent = 'รหัสผ่านของคุณถูกต้อง';
            } else {
                message.style.color = 'red';
                message.textContent = 'รหัสผ่านของคุณต้องมีความยาว 6 ตัวอักษรและมีทั้งตัวพิมพ์เล็ก และตัวเลข';
            }
        }

        function validatePasswordMatch() {
            const password = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirm_password').value;
            const errorMessage = document.getElementById('error-message');

            if (confirmPassword === "") {
                errorMessage.textContent = "";
            } else if (password !== confirmPassword) {
                errorMessage.style.color = 'red';
                errorMessage.textContent = 'รหัสผ่านไม่ตรงกัน กรุณากรอกใหม่';
            } else {
                errorMessage.textContent = "";
            }
        }
    </script>
            </head>
            <body>
            <div class="container">
        <h2>ตั้งค่ารหัสผ่านใหม่</h2>
        <form action="reset_password.php" method="post">
            <input type="hidden" name="token" value="<?php echo htmlspecialchars($token); ?>">
            <div class="form-group">
                <label for="password">รหัสผ่านใหม่</label>
                <div class="input-group">
                    <input type="password" id="password" name="password" required minlength="6" oninput="validatePassword()">
                    <i class="fas fa-eye toggle-password" id="password-toggle" onclick="togglePasswordVisibility('password')"></i>
                </div>
                <div class="message" id="message">รหัสผ่านของคุณต้องมีความยาว 6 ตัวอักษรและมีทั้งตัวพิมพ์เล็ก และตัวเลข</div>
            </div>
            <div class="form-group">
                <label for="confirm_password">ยืนยันรหัสผ่าน</label>
                <div class="input-group">
                    <input type="password" id="confirm_password" name="confirm_password" required oninput="validatePasswordMatch()">
                    <i class="fas fa-eye toggle-password" id="confirm_password-toggle" onclick="togglePasswordVisibility('confirm_password')"></i>
                </div>
                <div class="error-message" id="error-message"></div>
            </div>
            <div class="form-group">
                <button type="submit">ยืนยัน</button>
            </div>
                    </form>
                </div>
            </body>
            </html>

            <?php
        } else {
            // ถ้าโทเค็นไม่ถูกต้องหรือหมดอายุ
            echo "โทเค็นไม่ถูกต้องหรือหมดอายุ";
        }
    } else {
        echo "ไม่พบโทเค็น";
    }
}
?>
