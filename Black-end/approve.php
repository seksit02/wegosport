<?php
include 'config.php';

$message = '';
$error = '';

if (isset($_POST['approve']) || isset($_POST['reject'])) { //ส่งข้อมูลจากฟอร์มด้วยปุ่ม approve หรือ reject ผ่าน POST หรือไม่
    $location_id = $_POST['location_id'];
    $status = isset($_POST['approve']) ? 'approved' : 'rejected';

    $sql = "UPDATE location SET status='$status' WHERE location_id='$location_id'";

    if ($conn->query($sql) === TRUE) {
        $message = "อัปเดตสถานะการอนุมัติเรียบร้อยแล้ว";
    } else {
        $error = "เกิดข้อผิดพลาด: " . $conn->error;
    }
}
        //ใช้ GROUP_CONCAT เพื่อรวมชื่อของประเภทกีฬา (type_name) เป็นสตริงที่คั่นด้วยเครื่องหมาย ,
        $sql = "SELECT l.*, GROUP_CONCAT(s.type_name SEPARATOR ', ') as type_names 
        FROM location l 
        LEFT JOIN sport_type_in_location stl ON l.location_id = stl.location_id
        LEFT JOIN sport_type s ON stl.type_id = s.type_id
        WHERE l.status='pending'
        GROUP BY l.location_id";
  
$result = $conn->query($sql);

?>

<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>อนุมัติสถานที่</title>
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
        .btn-container {
            display: inline-block;
            white-space: nowrap;
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
        .btn-approve {
            background: #2ecc71;
        }
        .btn-reject {
            background: #e74c3c;
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
    <h2>อนุมัติสถานที่</h2>

    <?php
    if ($message) { echo "<div class='message'>$message</div>"; }
    if ($error) { echo "<div class='error'>$error</div>"; }
    ?>

<table>
    <tr>
        <th>ลำดับ</th>
        <th>ชื่อสถานที่</th>
        <th>วันและเวลาเปิด - ปิด</th>
        <th>ละติจูด</th>
        <th>ลองจิจูด</th>
        <th>รูปภาพ</th>
        <th>ประเภทสนามกีฬา</th>
        <th>การดำเนินการ</th>
    </tr>
    <?php
    if ($result->num_rows > 0) {
        $counter = 1; // เริ่มตัวนับที่ 1
        while($row = $result->fetch_assoc()) {
            $latitude = htmlspecialchars($row['latitude']);
            $longitude = htmlspecialchars($row['longitude']);
            $mapsLink = "https://www.google.com/maps/place/$latitude,$longitude";

            // Convert the stored location_day back to readable format
            $days = htmlspecialchars($row["location_day"]);
            $daysArray = explode(',', $days);
            $daysReadable = array_map(function($day) {
                switch($day) {
                    case '0': return 'อาทิตย์';
                    case '1': return 'จันทร์';
                    case '2': return 'อังคาร';
                    case '3': return 'พุธ';
                    case '4': return 'พฤหัสบดี';
                    case '5': return 'ศุกร์';
                    case '6': return 'เสาร์';
                    default: return '';
                }
            }, $daysArray);
            $daysStr = implode(', ', $daysReadable);

            // Combine days and time into one string
            $dayTimeStr = $daysStr . " " . htmlspecialchars($row['location_time']);

            echo "<tr>";
            echo "<td>" . $counter . "</td>"; // เพิ่มลำดับ
            echo "<td>" . htmlspecialchars($row['location_name']) . "</td>";
            echo "<td>" . $dayTimeStr . "</td>";
            echo "<td><a href='$mapsLink' target='_blank'>" . $latitude . "</a></td>";
            echo "<td><a href='$mapsLink' target='_blank'>" . $longitude . "</a></td>";
            echo "<td><img src='/flutter_webservice/upload/" . htmlspecialchars($row['location_photo']) . "' width='100'></td>";
            echo "<td>" . htmlspecialchars($row['type_names']) . "</td>";
            echo "<td>
                    <form method='post' action=''>
                        <input type='hidden' name='location_id' value='" . htmlspecialchars($row['location_id']) . "'>
                        <button type='submit' name='approve' class='btn btn-approve'>อนุมัติ</button>
                        <button type='submit' name='reject' class='btn btn-reject'>ไม่อนุมัติ</button>
                    </form>
                  </td>";
            echo "</tr>";

            $counter++; // เพิ่มลำดับในแต่ละแถว
        }
    } else {
        echo "<tr><td colspan='8'>ไม่มีสถานที่ที่รอการอนุมัติ</td></tr>";
    }
    ?>
</table>

</div>

</body>
</html>

<?php
$conn->close();
?>