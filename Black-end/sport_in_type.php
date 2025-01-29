<?php
include 'config.php';

$message = '';
$error = '';

// Handle delete request
if (isset($_GET['delete'])) {
    $sport_in_type_id = $_GET['delete'];
    $sql = "DELETE FROM sport_in_type WHERE sport_in_type_id='$sport_in_type_id'";
    if ($conn->query($sql) === TRUE) {
        $message = "ลบข้อมูลสำเร็จ";
    } else {
        $error = "เกิดข้อผิดพลาด: " . $conn->error;
    }
}

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $sport_in_type_id = $_POST["sport_in_type_id"] ?? '';
    $type_id = $_POST["type_id"] ?? '';
    $sport_id = $_POST["sport_id"] ?? '';

    if (!empty($sport_in_type_id)) {

        // Update existing record
        $stmt = $conn->prepare("UPDATE sport_in_type SET type_id=?, sport_id=? WHERE sport_in_type_id=?");
        $stmt->bind_param("sss", $type_id, $sport_id, $sport_in_type_id);

        if ($stmt->execute()) {
            $message = "อัปเดตข้อมูลสำเร็จ";
        } else {
            $error = "Error: " . $stmt->error;
        }
        $stmt->close();
    } else {

        // Insert new record
        $stmt = $conn->prepare("INSERT INTO sport_in_type (type_id, sport_id) VALUES (?, ?)");
        $stmt->bind_param("ss", $type_id, $sport_id);

        if ($stmt->execute()) {
            $message = "สร้างข้อมูลใหม่สำเร็จ";
            header("Location: " . $_SERVER['PHP_SELF']);
            exit();
        } else {
            $error = "Error: " . $stmt->error;
        }
        $stmt->close();
    }
    // Handle suspend request
if (isset($_GET['suspend'])) {
    $sport_in_type_id = $_GET['suspend'];
    $sql = "UPDATE sport_in_type SET status='inactive' WHERE sport_in_type_id='$sport_in_type_id'";
    if ($conn->query($sql) === TRUE) {
        $message = "ระงับข้อมูลสำเร็จ";
        header("Location: " . $_SERVER['PHP_SELF']);
        exit();
    } else {
        $error = "Error: " . $sql . "<br>" . $conn->error;
    }
}

// Handle activate request
if (isset($_GET['activate'])) {
    $sport_in_type_id = $_GET['activate'];
    $sql = "UPDATE sport_in_type SET status='active' WHERE sport_in_type_id='$sport_in_type_id'";
    if ($conn->query($sql) === TRUE) {
        $message = "เปิดใช้งานข้อมูลสำเร็จ";
        header("Location: " . $_SERVER['PHP_SELF']);
        exit();
    } else {
        $error = "Error: " . $sql . "<br>" . $conn->error;
    }
}
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ข้อมูลกีฬาในสนาม</title>
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
    <a href="index.php" class="btn-logout" onclick="return confirm('คุณแน่ใจว่าต้องการออกจากระบบหรือไม่?');">ออกจากระบบ</a><br>
</div>

<div class="container">
    <h2>ข้อมูลกีฬาในสนาม</h2>

    <?php if ($message) { echo "<div class='message'>".htmlspecialchars($message)."</div>"; } ?>
    <?php if ($error) { echo "<div class='error'>".htmlspecialchars($error)."</div>"; } ?>

    <form method="POST" action="sport_in_type.php">
        <input type="hidden" id="sport_in_type_id" name="sport_in_type_id">
        <div class="form-group">
            <label for="type_id">ประเภทกีฬา:</label>
            <select id="type_id" name="type_id" required>
                <option value="">เลือกประเภทกีฬา</option>
                <?php
                $sql = "SELECT type_id, type_name FROM sport_type";
                $result = $conn->query($sql);
                while ($row = $result->fetch_assoc()) {
                    echo "<option value='".htmlspecialchars($row['type_id'])."'>".htmlspecialchars($row['type_name'])."</option>";
                }
                ?>
            </select>
        </div>
        <div class="form-group">
            <label for="sport_id">กีฬา:</label>
            <select id="sport_id" name="sport_id" required>
                <option value="">เลือกกีฬา</option>
                <?php
                $sql = "SELECT sport_id, sport_name FROM sport";
                $result = $conn->query($sql);
                while ($row = $result->fetch_assoc()) {
                    echo "<option value='".htmlspecialchars($row['sport_id'])."'>".htmlspecialchars($row['sport_name'])."</option>";
                }
                ?>
            </select>
        </div>
        <button type="submit" class="btn-submit">บันทึก</button>
    </form>

    <h2>รายการ</h2>

    <?php
    $sql = "SELECT s.sport_in_type_id, s.type_id, s.sport_id, s.status, t.type_name, sp.sport_name 
            FROM sport_in_type s
            LEFT JOIN sport_type t ON s.type_id = t.type_id
            LEFT JOIN sport sp ON s.sport_id = sp.sport_id";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        echo "<table><tr><th>ประเภทกีฬา</th><th>กีฬา</th><th>การดำเนินการ</th></tr>";
        while($row = $result->fetch_assoc()) {
            echo "<tr><td>".htmlspecialchars($row["type_name"])."</td><td>".htmlspecialchars($row["sport_name"])."</td>
            <td class='btn-container'>
                <button class='btn btn-edit' onclick='editSportInType(\"".htmlspecialchars($row["sport_in_type_id"])."\", \"".htmlspecialchars($row["type_id"])."\", \"".htmlspecialchars($row["sport_id"])."\")'>แก้ไข</button>
                <a class='btn btn-delete' href='sport_in_type.php?delete=".htmlspecialchars($row["sport_in_type_id"])."'>ลบ</a>";
            
            // ปุ่มระงับและเปิดใช้งาน
            if ($row["status"] == 'inactive') {
                echo "<a class='btn btn-reactivate' href='sport_in_type.php?activate=".htmlspecialchars($row["sport_in_type_id"])."'>เปิดใช้งาน</a>";
            } else {
                echo "<a class='btn btn-suspend' href='sport_in_type.php?suspend=".htmlspecialchars($row["sport_in_type_id"])."'>ระงับ</a>";
            }

            echo "</td></tr>";
        }
        echo "</table>";
    } else {
        echo "ไม่มีข้อมูล";
    }
    $conn->close();
    ?>

    <script>
    function editSportInType(sport_in_type_id, type_id, sport_id) {
        document.getElementById('sport_in_type_id').value = sport_in_type_id;
        document.getElementById('type_id').value = type_id;
        document.getElementById('sport_id').value = sport_id;
    }
    </script>

</div>

</body>
</html>