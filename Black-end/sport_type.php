<?php
include 'config.php';

$message = '';
$error = '';

// ฟังก์ชันสำหรับสร้าง `hashtag_id` อัตโนมัติ
function getNextHashtagId($conn) {
    $sql = "SELECT hashtag_id FROM hashtag ORDER BY hashtag_id DESC LIMIT 1";
    $result = $conn->query($sql);
    $lastId = $result->fetch_assoc();
    if ($lastId) {
        $num = (int)substr($lastId['hashtag_id'], 1) + 1;
        return 'H' . str_pad($num, 3, '0', STR_PAD_LEFT);
    } else {
        return 'H001';
    }
}

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $hashtag_id = $_POST["hashtag_id"] ?? '';
    $hashtag_message = $_POST["hashtag_message"] ?? '';

    if (!empty($hashtag_id)) {
        // อัปเดตข้อมูลที่มีอยู่
        $sql = "UPDATE hashtag SET hashtag_message='$hashtag_message' WHERE hashtag_id='$hashtag_id'";
        if ($conn->query($sql) === TRUE) {
            $message = "แก้ไขข้อมูลสำเร็จ";
        } else {
            $error = "Error: " . $sql . "<br>" . $conn->error;
        }
    } else {
        // ตรวจสอบว่ามีข้อความแฮชแท็กซ้ำหรือไม่
        $sql = "SELECT * FROM hashtag WHERE hashtag_message='$hashtag_message'";
        $result = $conn->query($sql);
        if ($result->num_rows > 0) {
            $error = "ข้อมูลซ้ำกรุณากรอกใหม่";
        } else {
            // สร้าง `hashtag_id` ใหม่
            $hashtag_id = getNextHashtagId($conn);

            // เพิ่มข้อมูลใหม่
            $sql = "INSERT INTO hashtag (hashtag_id, hashtag_message) VALUES ('$hashtag_id', '$hashtag_message')";
            if ($conn->query($sql) === TRUE) {
                $message = "เพิ่มข้อมูลสำเร็จ";
            } else {
                $error = "Error: " . $sql . "<br>" . $conn->error;
            }
        }
    }
}

if (isset($_GET['delete'])) {
    $hashtag_id = $_GET['delete'];

    // ลบข้อมูลแฮชแท็ก
    $sql = "DELETE FROM hashtag WHERE hashtag_id='$hashtag_id'";
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
    <title>ข้อมูลประเภทสนามกีฬา</title>
    <style>
        body {
            display: flex;
            min-height: 100vh;
            font-family: Arial, sans-serif;
            margin: 0;
            background: #f4f7f6;
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
        .btn-suspend {
            background: #e67e22;
            margin-left: 5px;
        }
        .btn-reactivate {
            background: #2ecc71;
            margin-left: 5px;
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
    <h2>ข้อมูลประเภทสนามกีฬา</h2>

    <?php if ($message) { echo "<div class='message'>".htmlspecialchars($message)."</div>"; } ?>
    <?php if ($error) { echo "<div class='error'>".htmlspecialchars($error)."</div>"; } ?>

    <form method="POST" action="sport_type.php" onsubmit="return confirmSave()">
        <input type="hidden" id="type_id" name="type_id">
        <div class="form-group">
            <label for="type_name">ชื่อประเภทกีฬา:</label>
            <input type="text" id="type_name" name="type_name" required>
        </div>
        <button type="submit" class="btn-submit">บันทึก</button>
    </form>

    <h2>รายการ</h2>

    <?php
    $sql = "SELECT type_id, type_name FROM sport_type";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        $counter = 1; // เริ่มตัวนับที่ 1
        echo "<table><tr><th>ลำดับ</th><th>ชื่อ</th><th>การดำเนินการ</th></tr>";
        while($row = $result->fetch_assoc()) {
            echo "<tr>
                <td>".$counter."</td> <!-- แสดงลำดับ -->
                <td>".htmlspecialchars($row["type_name"])."</td>
                <td>
                    <button class='btn btn-edit' onclick='editType(\"".htmlspecialchars($row["type_id"])."\", \"".htmlspecialchars($row["type_name"])."\")'>แก้ไข</button>
                    <a class='btn btn-delete' href='sport_type.php?delete=".htmlspecialchars($row["type_id"])."' onclick='return confirmDelete()'>ลบ</a>
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
    
    // ฟังก์ชันยืนยันก่อนบันทึกข้อมูล
    function confirmSave() {
        return confirm("คุณแน่ใจว่าต้องการบันทึกข้อมูลนี้หรือไม่?");
    }

    // ฟังก์ชันสำหรับการแก้ไขข้อมูล พร้อมยืนยันการแก้ไข
    function editType(type_id, type_name) {
        if (confirm("คุณแน่ใจว่าต้องการแก้ไขข้อมูลนี้หรือไม่?")) {
            document.getElementById('type_id').value = type_id;
            document.getElementById('type_name').value = type_name;
        }
    }

    // ฟังก์ชันยืนยันก่อนการลบข้อมูล
    function confirmDelete() {
        return confirm("คุณแน่ใจว่าต้องการลบข้อมูลนี้หรือไม่?");
    }

    </script>

</div>

</body>
</html>