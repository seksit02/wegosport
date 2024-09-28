<?php
session_start();
include 'config.php'; // เชื่อมต่อกับฐานข้อมูล

$error = '';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $username = $_POST['username'];
    $password = $_POST['password'];

    // เข้ารหัสรหัสผ่านถ้าจำเป็น
    // $password = md5($password); 

    // คำสั่ง SQL เพื่อตรวจสอบผู้ใช้และรหัสผ่านในฐานข้อมูล admin
    $sql = "SELECT * FROM admin WHERE admin_name='$username' AND admin_password='$password'";
    $result = $conn->query($sql);

    if ($result->num_rows == 1) {
        $_SESSION['admin_login'] = $username;
        header("Location: user.php"); // เปลี่ยนเส้นทางไปยังหน้าแดชบอร์ด
        exit();
    } else {
        $error = "ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง";
    }
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login</title>
    <link href="https://fonts.googleapis.com/css?family=Quicksand|Nanum+Gothic" rel="stylesheet">
    <style>
        body, html {
            height: 100%;
            margin: 0;
            font-family: 'Quicksand', sans-serif;
            background-color: #ffffff; /* พื้นหลังสีขาว */
        }

        .container {
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100%;
        }

        .content-form {
            width: 400px;
            padding: 50px 20px;
            background-color: rgba(255, 255, 255, 0.9);
            box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1), /* เงาหลัก */
                        0 12px 24px rgba(0, 0, 0, 0.2), /* เพิ่มเงาเข้มขึ้น */
                        inset 0 2px 4px rgba(255, 255, 255, 0.5); /* เงาภายในเพื่อให้นูน */
            border-radius: 15px;
            text-align: center;
            border: 2px solid #000000; /* เส้นขอบสีดำ */
        }

        .barra-icons img {
            max-width: 150px;
            height: auto;
            margin-bottom: 20px;
        }

        .input-text {
            width: 85%;
            height: 45px;
            margin: 10px 0;
            padding: 10px;
            font-family: 'Nanum Gothic', sans-serif;
            font-size: 18px;
            border: 1px solid #000000; /* เส้นขอบสีแดง */
            border-radius: 25px;
            box-shadow: inset 2px 2px 5px rgba(0, 0, 0, 0.1);
            transition: all 0.3s ease;
        }

        .input-text:focus {
            border-color: #c0392b; /* สีแดงเข้มเมื่อโฟกัส */
            box-shadow: 0 0 5px rgba(192, 57, 43, 0.5);
            outline: none;
        }

        .button {
            width: 90%;
            height: 50px;
            margin: 20px 0;
            padding: 10px;
            font-family: 'Nanum Gothic', sans-serif;
            font-size: 20px;
            border: none;
            border-radius: 25px;
            background: linear-gradient(135deg, #e74c3c 0%, #c0392b 100%); /* ไล่สีโทนแดง */
            color: white;
            cursor: pointer;
            transition: background 0.3s ease;
        }

        .button:hover {
            background: linear-gradient(135deg, #c0392b 0%, #e74c3c 100%); /* ไล่สีเมื่อ hover */
        }

        .error-message {
            color: #e74c3c;
            margin-bottom: 20px;
            font-size: 16px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="content-form">
            <div class="barra-icons">
                <img src="./images/logo.png" alt="Logo">
            </div>
            
            <form action="index.php" method="POST">
                <?php if ($error): ?>
                    <div class="error-message"><?php echo htmlspecialchars($error); ?></div>
                <?php endif; ?>
                <input type="text" class="input-text" name="username" placeholder="ชื่อผู้ใช้งาน" />
                <input type="password" class="input-text" name="password" placeholder="รหัสผ่าน" />
                
                <button class="button" type="submit">เข้าสู่ระบบ</button>
            </form>
        </div>
    </div>
</body>
</html>
