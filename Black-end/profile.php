<?php
include 'config.php';

$message = '';
$error = '';

// Function to generate the next user_id
function getNextProId($conn) {
    $sql = "SELECT user_id FROM user_information ORDER BY user_id DESC LIMIT 1";
    $result = $conn->query($sql);
    $lastId = $result->fetch_assoc();
    if ($lastId) {
        $num = (int)substr($lastId['user_id'], 1) + 1;
        return 'P' . str_pad($num, 3, '0', STR_PAD_LEFT);
    } else {
        return 'P001';
    }
}

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $user_id = $_POST["user_id"] ?? '';
    $user_name = $_POST["user_name"] ?? '';
    $user_age = $_POST["user_age"] ?? '';
    $user_text = $_POST["user_text"] ?? '';

    if (!empty($user_id)) {
        // Update existing record
        $sql = "UPDATE user_information SET user_name='$user_name', user_age='$user_age', user_text='$user_text' WHERE user_id='$user_id'";
        if ($conn->query($sql) === TRUE) {
            $message = "แก้ไขข้อมูลสำเร็จ";
        } else {
            $error = "Error: " . $sql . "<br>" . $conn->error;
        }
    } else {
        // Check for duplicate user_name or user_age
        $sql = "SELECT * FROM user_information WHERE user_name='$user_name' OR user_age='$user_age'";
        $result = $conn->query($sql);
        if ($result->num_rows > 0) {
            $error = "ข้อมูลซ้ำกรุณากรอกใหม่";
        } else {
            // Generate new user_id
            $user_id = getNextProId($conn);

            // Insert new record
            $sql = "INSERT INTO user_information (user_id, user_name, user_age, user_text) VALUES ('$user_id', '$user_name', '$user_age', '$user_text')";
            if ($conn->query($sql) === TRUE) {
                $message = "เพิ่มข้อมูลสำเร็จ";
            } else {
                $error = "Error: " . $sql . "<br>" . $conn->error;
            }
        }
    }
}

if (isset($_GET['delete'])) {
    $user_id = $_GET['delete'];
    $sql = "DELETE FROM user_information WHERE user_id='$user_id'";
    if ($conn->query($sql) === TRUE) {
        $message = "ลบข้อมูลสำเร็จ";
    } else {
        $error = "Error: " . $sql . "<br>" . $conn->error;
    }
}
?>


<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ข้อมูลโปรไฟล์</title>
    <style>
        body {
            display: flex;
            min-height: 100vh;
            font-family: Arial, sans-serif;
            margin: 0;
            background: #f4f7f6;
        }
        .sidebar {
            position: fixed; /* ล็อคแถบด้านข้าง */
            top: 0;
            left: 0;
            height: 100%; /* ทำให้แถบด้านข้างสูงเต็มหน้าจอ */
            width: 250px;
            background: #2c3e50;
            color: white;
            padding: 20px;
            box-shadow: 2px 0 5px rgba(0,0,0,0.1);
            overflow-y: auto; /* ถ้ามีเนื้อหาในแถบด้านข้างมาก จะสามารถเลื่อนลงได้ */
        }
        .sidebar h2 {
            text-align: center;
            margin-bottom: 20px;
            color: white;
        }
        .sidebar .menu-group {
            margin-bottom: 20px;
            border-bottom: 2px solid #1abc9c;
            padding-bottom: 0;
        }
        .sidebar p {
            margin-bottom: 0;
            padding-bottom: 5px;
        }
        .sidebar a {
            color: white;
            padding: 15px 20px;
            text-decoration: none;
            display: block;
            border-radius: 5px;
            margin-bottom: 10px;
            background: #34495e;
            text-align: center;
        }
        .sidebar a:hover {
            background: #1abc9c;
        }
        .container {
            margin-left: 290px;
            padding: 20px;
            background: #ecf0f1;
            flex: 1;
            height: auto;
        }
        h2 {
            margin-top: 0;
            color: #2c3e50;
        }
        .form-group {
            margin-bottom: 15px;
        }
        .form-group label {
            display: block;
            margin-bottom: 5px;
            color: #2c3e50;
        }
        .form-group input, .form-group select {
            width: 100%;
            padding: 10px;
            box-sizing: border-box;
            border: 1px solid #bdc3c7;
            border-radius: 5px;
        }
        .checkbox-group {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }
        .checkbox-group label {
            display: flex;
            align-items: center;
            gap: 5px;
            background: #fff;
            border: 1px solid #bdc3c7;
            padding: 5px 10px;
            border-radius: 5px;
            white-space: nowrap;
        }
        .btn-submit, .btn-select-all {
            display: inline-block;
            padding: 10px 20px;
            color: white;
            background: #2ecc71;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }
        .btn-select-all {
            background: #3498db;
            margin-bottom: 10px;
        }
        .message, .error {
            padding: 15px;
            margin: 15px 0;
            border-radius: 5px;
        }
        .message {
            background: #2ecc71;
            color: white;
        }
        .error {
            background: #e74c3c;
            color: white;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
            background:  #ecf0f1;
        }
        table, th, td {
            border: 1px solid #bdc3c7;
        }
        th, td {
            padding: 15px;
            text-align: left;
        }
        th {
            background: #ecf0f1;
            color: #2c3e50;
        }
        .btn {
            display: inline-block;
            padding: 5px 10px;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            text-align: center;
        }
        .btn-edit {
            background: #f1c40f;
        }
        .btn-delete {
            background: #e74c3c;
        }
        .btn-container {
            display: flex;
            gap: 5px;
            justify-content: center;
        }
        .sidebar a.btn-logout {
            background: #e74c3c; /* สีแดง */
            color: white; 
            padding: 15px 20px;
            text-decoration: none;
            display: block;
            border-radius: 5px;
            margin-bottom: 10px;
            text-align: center;
        }

        .sidebar a.btn-logout:hover {
            background: #c0392b; /* สีแดงเข้มขึ้นเมื่อเมาส์อยู่เหนือ */
        }
    </style>
</head>
<body>

<div class="sidebar">
    <h2>เมนู</h2>
    <br>
    <div class="menu-group">
        <p>จัดการข้อมูลพื้นฐาน</p>
    </div>
    
    <div class="menu-group">
        <a href="user.php">ข้อมูลสมาชิก</a>
        <a href="sport.php">ข้อมูลกีฬา</a>
        <a href="location.php">ข้อมูลสถานที่เล่นกีฬา</a>
        <a href="sport_type.php">ข้อมูลประเภทสนามกีฬา</a>
        <a href="hashtag.php">ข้อมูลแฮชแท็ก</a>
        <br>
        <p>ข้อมูลทั่วไป</p>
    </div>
    
    <div class="menu-group">
        <a href="sport_type_in_location.php">ข้อมูลสนามกีฬา</a>
        <a href="activity.php">ข้อมูลกิจกรรม</a>
        <a href="member_in_activity.php">ข้อมูลสมาชิกกิจกรรม</a>
        <a href="profile.php">ข้อมูลโปรไฟล์</a>
    </div>
    <p>การอนุมัติ</p>
    <div class="menu-group">
        <a href="approve.php">อนุมัติสถานที่</a>
    </div>
    <div class="menu-group">
        <a href="report.php">รายงาน</a>
    </div>
    <a href="index.php" class="btn-logout" onclick="return confirm('คุณแน่ใจว่าต้องการออกจากระบบหรือไม่?');">ออกจากระบบ</a>
</div>

<div class="container">
    <h2>ข้อมูลโปรไฟล์</h2>

    <?php if ($message) { echo "<div class='message'>$message</div>"; } ?>
    <?php if ($error) { echo "<div class='error'>$error</div>"; } ?>

    <form method="POST" action="profile.php" onsubmit="return confirmSave()">
        <input type="hidden" id="user_id" name="user_id">
        <div class="form-group">
            <label for="user_name">ชื่อ - สกุล:</label>
            <input type="text" id="user_name" name="user_name" required>
        </div>
        <div class="form-group">
            <label for="user_age">วัน/เดือน/ปีเกิด:</label>
            <input type="date" id="user_age" name="user_age" required>
        </div>
        <div class="form-group">
            <label for="user_text">คำอธิบาย:</label>
            <input type="text" id="user_text" name="user_text">
        </div>
        <button type="submit" class="btn-submit">บันทึก</button>
    </form>

    <h2>รายการ</h2>

    <?php
    $sql = "SELECT user_id, user_name, user_age, user_text FROM user_information";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        $counter = 1; // เริ่มตัวนับที่ 1
        echo "<table><tr><th>ลำดับ</th><th>ชื่อ</th><th>วัน/เดือน/ปีเกิด</th><th>คำอธิบาย</th><th>การดำเนินการ</th></tr>";
        while($row = $result->fetch_assoc()) {
            echo "<tr>
                    <td>".$counter."</td>
                    <td>".htmlspecialchars($row["user_name"])."</td>
                    <td>".htmlspecialchars($row["user_age"])."</td>
                    <td>".htmlspecialchars($row["user_text"])."</td>
                    <td>
                        <button class='btn btn-edit' onclick='edituser_information(\"".htmlspecialchars($row["user_id"])."\", \"".htmlspecialchars($row["user_name"])."\", \"".htmlspecialchars($row["user_age"])."\", \"".htmlspecialchars($row["user_text"])."\")'>แก้ไข</button>
                        <a class='btn btn-delete' href='javascript:void(0);' onclick='confirmDelete(\"".htmlspecialchars($row["user_id"])."\")'>ลบ</a>
                    </td>
                </tr>";
            $counter++; // เพิ่มลำดับในแต่ละแถว
        }
        echo "</table>";
    } else {
        echo "0 results";
    }

    $conn->close();
    ?>

    <script>
    function confirmSave() {
        return confirm("คุณแน่ใจว่าต้องการบันทึกข้อมูลนี้หรือไม่?");
    }

    function confirmDelete(user_id) {
        if (confirm("คุณแน่ใจว่าต้องการลบข้อมูลนี้หรือไม่?")) {
            window.location.href = 'profile.php?delete=' + user_id;
        }
    }

    function edituser_information(user_id, user_name, user_age, user_text) {
        if (confirm("คุณแน่ใจว่าต้องการแก้ไขข้อมูลนี้หรือไม่?")) {
            document.getElementById('user_id').value = user_id;
            document.getElementById('user_name').value = user_name;
            document.getElementById('user_age').value = user_age;
            document.getElementById('user_text').value = user_text;
        }
    }

    document.addEventListener('DOMContentLoaded', function() {
        const today = new Date();
        const buddhistYear = today.getFullYear() + 543; // แปลงปี ค.ศ. เป็น พ.ศ.
        const month = String(today.getMonth() + 1).padStart(2, '0'); // เดือน (มกราคม = 0 ต้องบวก 1)
        const day = String(today.getDate()).padStart(2, '0'); // วัน
        const formattedDate = `${buddhistYear}-${month}-${day}`; // จัดรูปแบบวันที่ พ.ศ.-เดือน-วัน
        document.getElementById("user_age").setAttribute('max', formattedDate); // ตั้งค่าวันที่สูงสุด
    });
    </script>

</div>

</body>
</html>
