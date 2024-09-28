<?php
include 'config.php';

$message = '';
$error = '';

// การร้องขอ (Request) นั้นเป็นแบบ POST หรือไม่
if ($_SERVER["REQUEST_METHOD"] == "POST") {

    //การดึงข้อมูลจากฟอร์มที่ถูกส่งเข้ามา โดย edit_user_id ใช้เพื่อตรวจสอบว่ากำลังทำการแก้ไขข้อมูลผู้ใช้เดิมหรือเป็นการเพิ่มข้อมูลใหม่
    $edit_user_id = $_POST['edit_user_id'] ?? '';
    $user_id = $_POST['user_id'];
    $user_email = $_POST['user_email'];
    $user_pass = $_POST['user_pass'];
    $user_name = $_POST['user_name'];
    $user_age = $_POST['user_age'];
    $user_photo = $_FILES['user_photo']['name'];

    // ตรวจสอบว่าอีเมลที่ผู้ใช้กรอกเข้ามาซ้ำกับอีเมลที่มีอยู่ในฐานข้อมูลหรือไม่ 
    $sql = "SELECT * FROM user_information WHERE user_email='$user_email' AND user_id != '$edit_user_id'";
    $result = $conn->query($sql);
    if ($result->num_rows > 0) {
        $error = "อีเมลนี้มีการใช้งานแล้ว กรุณากรอกอีเมลใหม่";
    } else {

    //กำหนดโฟลเดอร์ที่ใช้เก็บไฟล์อัปโหลด และสร้างชื่อไฟล์ที่ต้องการอัปโหลด จากนั้นทำการอัปโหลดรูปภาพไปยังโฟลเดอร์ที่กำหนด
    $upload_dir = $_SERVER['DOCUMENT_ROOT'] . '/flutter_webservice/upload/';
    $upload_file = $upload_dir . basename($_FILES['user_photo']['name']);
    $filename = basename($_FILES['user_photo']['name']); // เก็บแค่ชื่อไฟล์

    if (move_uploaded_file($_FILES['user_photo']['tmp_name'], $upload_file)) {
        $conn->begin_transaction();
        try {
            if (!empty($edit_user_id)) {
                // อัปเดตข้อมูลผู้ใช้ที่มี user_id ตรงกับ edit_user_id ในฐานข้อมูลด้วยข้อมูลใหม่จากฟอร์ม
                $sql = "UPDATE user_information 
                        SET user_email='$user_email', user_pass='$user_pass', user_name='$user_name', user_age='$user_age', user_photo='$filename'
                        WHERE user_id='$edit_user_id'";
                $conn->query($sql);
            } else {
                $sql = "INSERT INTO user_information (user_id, user_email, user_pass, user_name, user_age, user_photo, status)
                        VALUES ('$user_id', '$user_email', '$user_pass', '$user_name', '$user_age', '$filename', 'active')";
                $conn->query($sql);
            }
            $conn->commit();
            $message = "เพิ่มข้อมูลสำเร็จ";
            header("Location: " . $_SERVER['PHP_SELF']);
            exit();
        } catch (Exception $e) {
            $conn->rollback();
            $error = " " . $e->getMessage();
        }
    } else {
            $error = "เกิดข้อผิดพลาดในการอัพโหลดรูปภาพ";
        }
    }
}

// Delete user
if (isset($_GET['delete'])) {
    $user_id = $_GET['delete'];

    $conn->begin_transaction();

    try {
        $sql = "DELETE FROM messages WHERE user_id='$user_id'";
        $conn->query($sql);

        $sql = "DELETE FROM creator WHERE user_id='$user_id'";
        $conn->query($sql);

        $sql = "DELETE FROM member_in_activity WHERE user_id='$user_id'";
        $conn->query($sql);

        $sql = "DELETE FROM user_information WHERE user_id='$user_id'";
        $conn->query($sql);

        $conn->commit();
        $message = "ลบข้อมูลสำเร็จ";
        header("Location: " . $_SERVER['PHP_SELF']);
        exit();
    } catch (Exception $e) {
        $conn->rollback();
        $error = "Error : " . $e->getMessage();
    }
}

// Handle suspend and reactivate requests
if (isset($_GET['suspend'])) {
    $user_id = $_GET['suspend'];
    $sql = "UPDATE user_information SET status='inactive' WHERE user_id='$user_id'";
    if ($conn->query($sql) === TRUE) {
        $message = "ระงับข้อมูลสำเร็จ";
    } else {
        $error = "Error: " . $sql . "<br>" . $conn->error;
    }
}

if (isset($_GET['reactivate'])) {
    $user_id = $_GET['reactivate'];
    $sql = "UPDATE user_information SET status='active' WHERE user_id='$user_id'";
    if ($conn->query($sql) === TRUE) {
        $message = "เปิดใช้งานข้อมูลสำเร็จ";
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
    <title>ข้อมูลสมาชิก</title>
    <style>
        body {
            display: flex;
            font-family: Arial, sans-serif;
            margin: 0;
        }
        .sidebar {
            position: fixed;
            top: 0;
            left: 0;
            height: 100%;
            width: 250px;
            background: #2c3e50;
            color: white;
            padding: 20px;
            box-shadow: 2px 0 5px rgba(0,0,0,0.1);
            overflow-y: auto;
        }
        .sidebar h2 {
            text-align: center;
            margin-bottom: 20px;
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
        }
        .form-group {
            margin-bottom: 15px;
        }
        .form-group label {
            display: block;
            margin-bottom: 5px;
        }
        .form-group input, .form-group select {
            width: 100%;
            padding: 10px;
            box-sizing: border-box;
            border: 1px solid #bdc3c7;
            border-radius: 5px;
        }
        .btn-submit {
            margin-top: 10px;
            display: inline-block;
            padding: 10px 20px;
            color: white;
            background: #2ecc71;
            border: none;
            border-radius: 5px;
            cursor: pointer;
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
        }
        table, th, td {
            border: 1px solid #bdc3c7;
        }
        th, td {
            padding: 15px;
            text-align: left;
        }
        .btn {
            display: inline-block;
            padding: 5px 10px;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            margin-right: 5px;
            text-align: center;
        }
        .btn-edit {
            background: #f1c40f;
        }
        .btn-delete {
            background: #e74c3c;
        }
        .btn-suspend {
            background: #e67e22;
        }
        .btn-reactivate {
            background: #2ecc71;
        }
        .form-group img {
            display: block;
            margin-top: 10px;
            max-width: 100%;
            height: auto;
        }
    
        #user_photo_preview_container {
            display: none;
            margin-top: 10px;
            position: relative;
        }

        #user_photo_preview {
            max-width: 150px;
            height: 100px;
            border-radius: 5px;
            box-shadow: 0 0 5px rgba(0, 0, 0, 0.1);
        }

        #remove_photo_btn {
            position: absolute;
            top: 0;
            right: 0;
            background: transparent;
            border: none;
            cursor: pointer;
        }

        #remove_photo_btn img {
            width: 20px;
            height: 20px;
        }
        .sidebar a.btn-logout {
            background: #e74c3c;
            color: white; 
            padding: 15px 20px;
            text-decoration: none;
            display: block;
            border-radius: 5px;
            margin-bottom: 10px;
            text-align: center;
        }

        .sidebar a.btn-logout:hover {
            background: #c0392b;
        }
    </style>
    <script>

        //ฟังก์ชัน previewFile() ใช้สำหรับแสดงตัวอย่างรูปภาพที่เลือกอัปโหลด
        function previewFile() {
            const preview = document.getElementById('user_photo_preview');
            const previewContainer = document.getElementById('user_photo_preview_container');
            const file = document.getElementById('user_photo').files[0];
            const reader = new FileReader();

            reader.addEventListener("load", function () {
                preview.src = reader.result;
                previewContainer.style.display = 'block';
            }, false);

            if (file) {  //ถ้ามีไฟล์รูปภาพที่ถูกเลือก, จะอ่านไฟล์นั้นเป็น Data URL (รูปแบบข้อมูลที่สามารถแสดงผลเป็นรูปภาพได้)
                reader.readAsDataURL(file);
            }
        }
        
        //ฟังก์ชัน removePhoto() ใช้สำหรับลบรูปภาพที่แสดงในตัวอย่างและรีเซ็ตการเลือกไฟล์
        function removePhoto() {
            const preview = document.getElementById('user_photo_preview');
            const previewContainer = document.getElementById('user_photo_preview_container');
            const input = document.getElementById('user_photo');

            input.value = '';
            previewContainer.style.display = 'none';
            preview.src = '';
        }
        
        //ฟังก์ชัน editUser() ใช้สำหรับดึงข้อมูลผู้ใช้ที่ต้องการแก้ไข และแสดงข้อมูลนั้นในฟอร์ม รวมถึงแสดงตัวอย่างรูปภาพหากมี
        function editUser(user_id) {
            fetch('get_user.php?user_id=' + user_id)
            .then(response => response.json())
            .then(data => {
                document.getElementById('edit_user_id').value = data.user_id;
                document.getElementById('user_id').value = data.user_id;
                document.getElementById('user_email').value = data.user_email;
                document.getElementById('user_pass').value = data.user_pass;
                document.getElementById('user_name').value = data.user_name;
                document.getElementById('user_age').value = data.user_age;
                
                if (data.user_photo) {
                    document.getElementById('user_photo_preview').src = data.user_photo;
                    document.getElementById('user_photo_preview_container').style.display = 'block';
                } else {
                    document.getElementById('user_photo_preview_container').style.display = 'none';
                }
            });
        }
    </script>
</head>
<body>

<div class="sidebar">
    <h2>เมนู</h2>
    <br>
    <div class="menu-group">
        <p>จัดการข้อมูลพื้นฐาน</p>
    </div>
    
    <div class="menu-group">
        <a href="user.php">ข้อมูลผู้ใช้งาน</a>
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
    <h2>ข้อมูลสมาชิก</h2>

    <?php
    if ($message) { echo "<div class='message'>$message</div>"; }
    if ($error) { echo "<div class='error'>$error</div>"; }
    ?>

    <form method="POST" action="user.php"  enctype="multipart/form-data">

        <input type="hidden" id="edit_user_id" name="edit_user_id">

        <div class="form-group">
            <label for="user_id">ชื่อสมาชิก:</label>
            <input type="text" id="user_id" name="user_id" required>
        </div>
        
        <div class="form-group">
            <label for="user_email">อีเมล:</label>
            <input type="text" id="user_email" name="user_email" required>
        </div>
        <div class="form-group">
            <label for="user_pass">รหัสผ่าน:</label>
            <input type="text" id="user_pass" name="user_pass" required>
        </div>
        <div class="form-group">
            <label for="user_name">ชื่อ - สกุล:</label>
            <input type="text" id="user_name" name="user_name" required>
        </div>
        <div class="form-group">
            <label for="user_age">วันเกิด:</label>
            <input type="date" id="user_age" name="user_age" required>
        </div>
        <div class="form-group">
            <label for="user_photo">รูปภาพ:</label>
            <input type="file" id="user_photo" name="user_photo" accept="image/*" onchange="previewFile()">
            <div id="user_photo_preview_container">
                <img id="user_photo_preview" src="" alt="รูปภาพ" width="100">
                <button type="button" id="remove_photo_btn" onclick="removePhoto()">
                    <img src="./images/close.png" alt="ลบรูป" style="width: 10px; height: 10px;">
                </button>
            </div>
        </div>
        <button type="submit" class="btn-submit">บันทึก</button>
    </form>
    <br>
    <h2>รายการ</h2>

    <?php
    $sql = "SELECT user_id, user_email, user_name, user_age, user_photo, status FROM user_information";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        $counter = 1; // เริ่มตัวนับที่ 1
        echo "<table><tr><th>ลำดับ</th><th>ชื่อสมาชิก</th><th>อีเมล</th><th>ชื่อ - สกุล</th><th>วันเกิด</th><th>รูปภาพ</th><th>การดำเนินการ</th></tr>";
        while($row = $result->fetch_assoc()) { //ดึงข้อมูลแต่ละแถวจากผลลัพธ์มาเป็นอาเรย์
            $formatted_date = date("d/m/Y", strtotime($row["user_age"]));
            echo "<tr><td>".$counter."</td><td>".$row["user_id"]."</td><td>".$row["user_email"]."</td><td>".$row["user_name"]."</td><td>".$formatted_date."</td><td><img src='/flutter_webservice/upload/".$row["user_photo"]."' width='100'></td>
            <td>
                <button class='btn btn-edit' onclick='editUser(\"".$row["user_id"]."\")'>แก้ไข</button>
                <a class='btn btn-delete' href='?delete=".$row['user_id']."'>ลบ</a>";
            
                if ($row['status'] == 'active') {
                    echo "<a class='btn btn-suspend' href='?suspend=".$row['user_id']."'>ระงับ</a>";
                } else {
                    echo "<a class='btn btn-reactivate' href='?reactivate=".$row['user_id']."'>เปิดใช้งาน</a>";
                }
            
            echo "</td></tr>";
            $counter++; // เพิ่มลำดับในแต่ละแถว
        }
        echo "</table>";
    } else {
        echo "0 results";
    }

    $conn->close();
    ?>

</div>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        const today = new Date();
        const buddhistYear = today.getFullYear() + 543; // แปลงปี ค.ศ. เป็น พ.ศ.
        const month = String(today.getMonth() + 1).padStart(2, '0'); // เดือน (มกราคม = 0 ต้องบวก 1)
        const day = String(today.getDate()).padStart(2, '0'); // วัน
        const formattedDate = `${buddhistYear}-${month}-${day}`; // จัดรูปแบบวันที่ พ.ศ.-เดือน-วัน
        document.getElementById("user_age").setAttribute('max', formattedDate); // ตั้งค่าวันที่สูงสุด
    });
</script>
</body>

</html>
