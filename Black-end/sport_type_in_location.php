<?php
include 'config.php';

$message = '';
$error = '';

// ฟังก์ชันสำหรับสร้างรหัสใหม่
function getNextTypeInLocationId($conn) {
    $sql = "SELECT type_in_location_id FROM sport_type_in_location ORDER BY type_in_location_id DESC LIMIT 1";
    $result = $conn->query($sql);
    $lastId = $result->fetch_assoc();
    
    if ($lastId) {
        $num = (int)substr($lastId['type_in_location_id'], 1) + 1;
        return 'L' . str_pad($num, 3, '0', STR_PAD_LEFT);
    } else {
        return 'L001';
    }
}

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $location_id = $_POST["location_id"] ?? '';
    $type_ids = $_POST["type_id"] ?? []; // รับข้อมูลเป็น array

    // ตรวจสอบว่ามีข้อมูลประเภทสนามกีฬาในสถานที่นี้อยู่แล้วหรือไม่
    $sql = "SELECT * FROM sport_type_in_location WHERE location_id='$location_id'";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        // ข้อมูลมีอยู่แล้ว แสดงว่าเป็นการแก้ไข
        $isEdit = true;
        $sql = "DELETE FROM sport_type_in_location WHERE location_id='$location_id'";
        if ($conn->query($sql) !== TRUE) {
            $error = "Error: " . $conn->error;
        }
    } else {
        // ไม่มีข้อมูลเดิม แสดงว่าเป็นการเพิ่มข้อมูลใหม่
        $isEdit = false;
    }

    // เพิ่มข้อมูลชุดใหม่
    foreach ($type_ids as $type_id) {
        $type_in_location_id = getNextTypeInLocationId($conn); // สร้างรหัสใหม่
        
        $sql = "INSERT INTO sport_type_in_location (type_in_location_id, location_id, type_id) 
                VALUES ('$type_in_location_id', '$location_id', '$type_id')";
        if ($conn->query($sql) !== TRUE) {
            $error = "Error: " . $conn->error;
            break; // หยุดการวนลูปหากเกิดข้อผิดพลาด
        }
    }

    // แสดงข้อความว่ากำลังทำการเพิ่มหรือแก้ไขข้อมูล
    if (!$error) {
        if ($isEdit) {
            $message = "แก้ไขข้อมูลสำเร็จ";
        } else {
            $message = "เพิ่มข้อมูลสำเร็จ";
        }
    }
}

if (isset($_GET['delete'])) {
    $type_in_location_id = $_GET['delete'];
    $sql = "DELETE FROM sport_type_in_location WHERE type_in_location_id='$type_in_location_id'";
    if ($conn->query($sql) === TRUE) {
        $message = "ลบข้อมูลสำเร็จ";
        // ไม่มีการรีเฟรชหน้าด้วย header()
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
    <title>ข้อมูลสนามกีฬา</title>
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
    <h2>ข้อมูลสนามกีฬา</h2>

    <?php if ($message) { echo "<div class='message'>$message</div>"; } ?>
    <?php if ($error) { echo "<div class='error'>$error</div>"; } ?>

    <form method="POST" action="sport_type_in_location.php" onsubmit="return confirmSave()">
        <input type="hidden" id="type_in_location_id" name="type_in_location_id">
        <div class="form-group">
            <label for="location_id">สถานที่เล่นกีฬา:</label>
            <select id="location_id" name="location_id" required>
                <option value="">กรุณาเลือกสถานที่เล่นกีฬา</option>
                <?php
                $sql = "SELECT location_id, location_name FROM location WHERE status IN ('approved', 'active')";
                $result = $conn->query($sql);
                while ($row = $result->fetch_assoc()) {
                    echo "<option value='" . $row['location_id'] . "'>" . $row['location_name'] . "</option>";
                }
                ?>
            </select>
        </div>

        <div class="form-group">
            <label for="type_id">ประเภทสนามกีฬา:</label>
            <button type="button" class="btn-select-all" onclick="toggleCheckboxes()">เลือกทั้งหมด</button>
            <div class="checkbox-group">
                <?php
                $sql = "SELECT type_id, type_name FROM sport_type";
                $result = $conn->query($sql);
                while ($row = $result->fetch_assoc()) {
                    echo "<label><input type='checkbox' name='type_id[]' value='" . htmlspecialchars($row['type_id']) . "'>" . htmlspecialchars($row['type_name']) . "</label>";
                }
                ?>
            </div>
        </div>
        <button type="submit" class="btn-submit">บันทึก</button>
    </form>

    <h2>รายการ</h2>

    <?php
    $sql = "SELECT s.type_in_location_id, l.location_id, l.location_name, GROUP_CONCAT(t.type_name SEPARATOR ', ') as type_names, GROUP_CONCAT(t.type_id SEPARATOR ',') as type_ids
            FROM sport_type_in_location s
            JOIN location l ON s.location_id = l.location_id
            JOIN sport_type t ON s.type_id = t.type_id
            GROUP BY s.location_id";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        $counter = 1;
        echo "<table><tr><th>ลำดับ</th><th>สถานที่เล่นกีฬา</th><th>ประเภทกีฬา</th><th>การดำเนินการ</th></tr>";
        while($row = $result->fetch_assoc()) {
            echo "<tr>
                    <td>".$counter."</td>
                    <td>".htmlspecialchars($row["location_name"])."</td>
                    <td>".htmlspecialchars($row["type_names"])."</td>
                    <td>
                        <button class='btn btn-edit' onclick='editTypeInLocation(\"".htmlspecialchars($row["type_in_location_id"])."\", \"".htmlspecialchars($row["location_id"])."\", \"".htmlspecialchars($row["type_ids"])."\")'>แก้ไข</button>
                        <a class='btn btn-delete' href='javascript:void(0);' onclick='confirmDelete(\"".htmlspecialchars($row["type_in_location_id"])."\")'>ลบ</a>
                    </td>
                </tr>";
            $counter++;
        }
        echo "</table>";
    } else {
        echo "ไม่มีข้อมูล";
    }

$conn->close();
?>

<script>
    function toggleCheckboxes() {
        const checkboxes = document.querySelectorAll('.checkbox-group input[type="checkbox"]');
        const allChecked = Array.from(checkboxes).every(checkbox => checkbox.checked);
        checkboxes.forEach(checkbox => checkbox.checked = !allChecked);
    }

    function confirmSave() {
        return confirm("คุณแน่ใจว่าต้องการบันทึกข้อมูลนี้หรือไม่?");
    }

    function confirmDelete(type_in_location_id) {
        if (confirm("คุณแน่ใจว่าต้องการลบข้อมูลนี้หรือไม่?")) {
            window.location.href = 'sport_type_in_location.php?delete=' + type_in_location_id;
        }
    }

    function editTypeInLocation(type_in_location_id, location_id, type_ids) {
        if (confirm("คุณแน่ใจว่าต้องการแก้ไขข้อมูลนี้หรือไม่?")) {
            document.getElementById('type_in_location_id').value = type_in_location_id;
            document.getElementById('location_id').value = location_id;

            const checkboxes = document.querySelectorAll('.checkbox-group input[type="checkbox"]');
            checkboxes.forEach(checkbox => checkbox.checked = false);

            const typeIdArray = type_ids.split(',');
            checkboxes.forEach(checkbox => {
                if (typeIdArray.includes(checkbox.value)) {
                    checkbox.checked = true;
                }
            });

            document.querySelector('.container').scrollIntoView({ behavior: 'smooth' });
        }
    }
</script>

</div>


</body>
</html>