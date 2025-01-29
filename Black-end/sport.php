<?php
include 'config.php';

$message = '';
$error = '';

// Function to generate the next sport_id
function getNextSportId($conn) {
    $sql = "SELECT sport_id FROM sport ORDER BY sport_id DESC LIMIT 1";
    $result = $conn->query($sql);
    $lastId = $result->fetch_assoc();
    if ($lastId) {
        $num = (int)substr($lastId['sport_id'], 1) + 1;
        return 's' . str_pad($num, 3, '0', STR_PAD_LEFT);
    } else {
        return 's001';
    }
}

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $sport_id = $_POST["sport_id"] ?? '';
    $sport_name = $_POST["sport_name"] ?? '';

    if (!empty($sport_id)) {
        // Update existing record
        $sql = "UPDATE sport SET sport_name='$sport_name' WHERE sport_id='$sport_id'";
        if ($conn->query($sql) === TRUE) {
            $message = "แก้ไขข้อมูลสำเร็จ";
        } else {
            $error = "Error: " . $sql . "<br>" . $conn->error;
        }
    } else {
        // Check for duplicate sport_name
        $sql = "SELECT * FROM sport WHERE sport_name='$sport_name'";
        $result = $conn->query($sql);
        if ($result->num_rows > 0) {
            $error = "ข้อมูลซ้ำกรุณากรอกใหม่";
        } else {
            // Generate new sport_id
            $sport_id = getNextSportId($conn);

            // Insert new record
            $sql = "INSERT INTO sport (sport_id, sport_name) VALUES ('$sport_id', '$sport_name')";
            if ($conn->query($sql) === TRUE) {
                $message = "เพิ่มข้อมูลสำเร็จ";
            } else {
                $error = "Error: " . $sql . "<br>" . $conn->error;
            }
        }
    }
}

if (isset($_GET['delete'])) {
    $sport_id = $_GET['delete'];

    // ลบข้อมูลที่เกี่ยวข้องจากตาราง sport_in_type ก่อน
    $sql_delete_sport_in_type = "DELETE FROM sport_in_type WHERE sport_id='$sport_id'";
    $conn->query($sql_delete_sport_in_type);

    // ลบข้อมูลจากตาราง sport
    $sql_delete_sport = "DELETE FROM sport WHERE sport_id='$sport_id'";
    if ($conn->query($sql_delete_sport) === TRUE) {
        $message = "ลบข้อมูลสำเร็จ";
    } else {
        $error = "Error: " . $sql_delete_sport . "<br>" . $conn->error;
    }
}


?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ข้อมูลกีฬา</title>
    <style>
        body {
            display: flex;
            min-height: 100vh;
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
        <a href="sport_type.php">ข้อมูลประเภทสนามกีฬา</a>
        <a href="location.php">ข้อมูลสถานที่เล่นกีฬา</a>
        <a href="hashtag.php">ข้อมูลแฮชแท็ก</a>
        <br>
        <p>การอนุมัติ</p>
    </div>
    
    <div class="menu-group">
        <a href="approve.php">อนุมัติสถานที่</a>
    </div>

    <p>ข้อมูลทั่วไป</p>
    
    <div class="menu-group">
        <a href="sport_type_in_location.php">ข้อมูลสนามกีฬา</a>
        <a href="activity.php">ข้อมูลกิจกรรม</a>
        <a href="member_in_activity.php">ข้อมูลสมาชิกกิจกรรม</a>
        <a href="profile.php">ข้อมูลโปรไฟล์</a>
    </div>

    <div class="menu-group">
        <a href="report.php">รายงาน</a>
    </div>

    <a href="index.php" class="btn-logout" onclick="return confirm('คุณแน่ใจว่าต้องการออกจากระบบหรือไม่?');">ออกจากระบบ</a><br>
</div>

<div class="container">
    <h2>ข้อมูลกีฬา</h2>

    <?php if ($message) { echo "<div class='message'>$message</div>"; } ?>
    <?php if ($error) { echo "<div class='error'>$error</div>"; } ?>

    <form method="POST" action="sport.php" onsubmit="return confirmSave()">
        <input type="hidden" id="sport_id" name="sport_id">
        <div class="form-group">
            <label for="sport_name">ชื่อกีฬา:</label>
            <input type="text" id="sport_name" name="sport_name" required>
        </div>
        <button type="submit" class="btn-submit">บันทึก</button>
    </form>

    <h2>รายการ</h2>

    <?php
    $sql = "SELECT sport_id, sport_name FROM sport";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        $counter = 1; // เริ่มตัวนับที่ 1
        echo "<table><tr><th>ลำดับ</th><th>ชื่อ</th><th>การดำเนินการ</th></tr>";
        while($row = $result->fetch_assoc()) {
            echo "<tr>
                <td>".$counter."</td> <!-- แสดงลำดับ -->
                <td>".$row["sport_name"]."</td>
                <td>
                    <button class='btn btn-edit' onclick='confirmEdit(\"".$row["sport_id"]."\", \"".$row["sport_name"]."\")'>แก้ไข</button>
                    <form method='get' action='sport.php' style='display:inline;' onsubmit='return confirmDelete()'>
                        <input type='hidden' name='delete' value='".$row["sport_id"]."'>
                        <button class='btn btn-delete' type='submit'>ลบ</button>
                    </form>";

            echo "</td></tr>";
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

    function confirmDelete() {
        return confirm("คุณแน่ใจว่าต้องการลบข้อมูลนี้หรือไม่?");
    }

    function confirmEdit(sport_id, sport_name) {
        if (confirm("คุณแน่ใจว่าต้องการแก้ไขข้อมูลนี้หรือไม่?")) {
            document.getElementById('sport_id').value = sport_id;
            document.getElementById('sport_name').value = sport_name;
        }
    }
    </script>
</div>

</body>  
</html>
