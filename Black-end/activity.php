<?php
    include 'config.php';

    $message = '';
    $error = '';

    function formatDateThai($date) {
        $months = array(
            'Jan' => 'ม.ค.',
            'Feb' => 'ก.พ.',
            'Mar' => 'มี.ค.',
            'Apr' => 'เม.ย.',
            'May' => 'พ.ค.',
            'Jun' => 'มิ.ย.',
            'Jul' => 'ก.ค.',
            'Aug' => 'ส.ค.',
            'Sep' => 'ก.ย.',
            'Oct' => 'ต.ค.',
            'Nov' => 'พ.ย.',
            'Dec' => 'ธ.ค.'
        );
        $date = strftime('%e %b %Y', strtotime($date));
        return strtr($date, $months);
    }

    function getNextActivityId($conn) {
        $sql = "SELECT activity_id FROM activity ORDER BY activity_id DESC LIMIT 1";
        $result = $conn->query($sql);
        $lastId = $result->fetch_assoc();
        if ($lastId) {
            $num = (int)substr($lastId['activity_id'], 1) + 1;
            return 'a' . str_pad($num, 3, '0', STR_PAD_LEFT);
        } else {
            return 'a001';
        }
    }

    if ($_SERVER["REQUEST_METHOD"] == "POST") {
        $activity_id = $_POST["activity_id"] ?? '';
        $activity_name = $_POST["activity_name"] ?? '';
        $activity_date = $_POST["activity_date"] ?? '';
        $location_id = $_POST["location_id"] ?? '';
        $sport_id = $_POST["sport_id"] ?? '';
        $user_id = $_POST["user_id"] ?? ''; // รับค่า user_id จากฟอร์ม

        // ตรวจสอบว่า user_id มีอยู่ใน user_information
        $user_check_sql = "SELECT user_id FROM user_information WHERE user_id = '$user_id'";
        $user_check_result = $conn->query($user_check_sql);

        if ($user_check_result->num_rows > 0) {
            // ตรวจสอบว่า activity_id ถูกสร้างแล้วหรือยัง
            if (!empty($activity_id)) {
                // Update existing record
                $sql = "UPDATE activity SET activity_name='$activity_name', activity_date='$activity_date', location_id='$location_id', sport_id='$sport_id' WHERE activity_id='$activity_id'";
                if ($conn->query($sql) === TRUE) {
                    // อัปเดตข้อมูลในตาราง creator และ member_in_activity
                    $sql_creator = "UPDATE creator SET user_id='$user_id' WHERE activity_id='$activity_id'";
                    $conn->query($sql_creator);

                    $sql_member = "UPDATE member_in_activity SET user_id='$user_id' WHERE activity_id='$activity_id'";
                    $conn->query($sql_member);

                    $message = "แก้ไขข้อมูลสำเร็จ";
                } else {
                    $error = "Error: " . $sql . "<br>" . $conn->error;
                }
            } else {
                // ถ้ายังไม่มี activity_id ให้สร้างใหม่
                $activity_id = getNextActivityId($conn);

                // เริ่ม transaction
                $conn->begin_transaction();

                try {
                    // Insert ข้อมูลใหม่ใน activity ก่อน
                    $sql = "INSERT INTO activity (activity_id, activity_name, activity_date, location_id, sport_id, status) 
                            VALUES ('$activity_id', '$activity_name', '$activity_date', '$location_id', '$sport_id', 'active')";
                    $conn->query($sql);

                    // หลังจาก insert ข้อมูลใน activity เสร็จแล้ว ให้ insert ข้อมูลในตาราง creator และ member_in_activity
                    $sql_creator = "INSERT INTO creator (activity_id, user_id) VALUES ('$activity_id', '$user_id')";
                    $conn->query($sql_creator);

                    $sql_member = "INSERT INTO member_in_activity (activity_id, user_id) VALUES ('$activity_id', '$user_id')";
                    $conn->query($sql_member);

                    // Commit transaction
                    $conn->commit();
                    $message = "เพิ่มข้อมูลสำเร็จ";
                } catch (Exception $e) {
                    // Rollback ถ้ามีข้อผิดพลาด
                    $conn->rollback();
                    $error = "Error: " . $e->getMessage();
                }
            }
        } else {
            $error = "ไม่พบ user_id ในตาราง user_information";
        }
    }

    if (isset($_GET['delete'])) {
        $activity_id = $_GET['delete'];

        // ลบข้อมูลในตาราง hashtags_in_activities
        $sql_hashtags = "DELETE FROM hashtags_in_activities WHERE activity_id='$activity_id'";
        $conn->query($sql_hashtags);

        // ลบข้อมูลในตาราง creator
        $sql_creator = "DELETE FROM creator WHERE activity_id='$activity_id'";
        $conn->query($sql_creator);

        // ลบข้อมูลในตาราง member_in_activity
        $sql_member = "DELETE FROM member_in_activity WHERE activity_id='$activity_id'";
        $conn->query($sql_member);

        // ลบข้อมูลในตาราง activity
        $sql = "DELETE FROM activity WHERE activity_id='$activity_id'";
        if ($conn->query($sql) === TRUE) {
            $message = "ลบข้อมูลสำเร็จ";
        } else {
            $error = "Error: " . $sql . "<br>" . $conn->error;
        }
    }

    if (isset($_GET['suspend'])) {
        $activity_id = $_GET['suspend'];
        $sql = "UPDATE activity SET status='inactive' WHERE activity_id='$activity_id'";
        if ($conn->query($sql) === TRUE) {
            $message = "ระงับข้อมูลสำเร็จ";
        } else {
            $error = "Error: " . $sql . "<br>" . $conn->error;
        }
    } elseif (isset($_GET['activate'])) {
        $activity_id = $_GET['activate'];
        $sql = "UPDATE activity SET status='active' WHERE activity_id='$activity_id'";
        if ($conn->query($sql) === TRUE) {
            $message = "เปิดใช้งานกิจกรรมสำเร็จ";
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
    <title>ข้อมูลกิจกรรม</title>
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
            background: #e67e22; /* สีส้มเข้ม */
            color: white;
        }

        .btn-activate {
            background: #2ecc71; /* สีเขียว */
            color: white;
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
    <h2>ข้อมูลกิจกรรม</h2>

    <?php if ($message) { echo "<div class='message'>$message</div>"; } ?>
    <?php if ($error) { echo "<div class='error'>$error</div>"; } ?>

    <form method="POST" action="activity.php" onsubmit="return confirm('คุณแน่ใจหรือว่าต้องการบันทึกข้อมูลนี้?');">
        <input type="hidden" id="activity_id" name="activity_id">

        <div class="form-group">
            <label for="activity_name">ชื่อกิจกรรม:</label>
            <input type="text" id="activity_name" name="activity_name" required>
        </div>

        <div class="form-group">
            <label for="activity_date">วันที่:</label>
            <input type="datetime-local" id="activity_date" name="activity_date" required>
        </div>

        <div class="form-group">
            <label for="location_id">สถานที่เล่นกีฬา:</label>
            <select id="location_id" name="location_id" required>
                <option value="">กรุณาเลือกสถานที่เล่นกีฬา</option>
                <?php
                // ปรับคำสั่ง SQL เพื่อดึงข้อมูลเฉพาะที่มีสถานะ approved และ active
                $sql = "SELECT location_id, location_name FROM location WHERE status IN ('approved', 'active')";
                $result = $conn->query($sql);
                while ($row = $result->fetch_assoc()) {
                    echo "<option value='" . $row['location_id'] . "'>" . $row['location_name'] . "</option>";
                }
                ?>
            </select>
        </div>

        <div class="form-group">
            <label for="sport_id">กีฬา:</label>
            <select id="sport_id" name="sport_id" required>
                <option value="">กรุณาเลือกข้อมูลกีฬา</option>
                <?php
                $sql = "SELECT sport_id, sport_name FROM sport";
                $result = $conn->query($sql);
                while ($row = $result->fetch_assoc()) {
                    echo "<option value='".$row['sport_id']."'>".$row['sport_name']."</option>";
                }
                ?>
            </select>
        </div>

        <div class="form-group">
            <label for="user_id">ผู้สร้างกิจกรรม:</label>
            <select id="user_id" name="user_id" required>
                <option value="">กรุณาเลือก</option>
                <?php
                $sql = "SELECT user_id FROM user_information";
                $result = $conn->query($sql);
                while ($row = $result->fetch_assoc()) {
                    echo "<option value='".$row['user_id']."'>".$row['user_id']."</option>";
                }
                ?>
            </select>
        </div>

        <button type="submit" class="btn-submit">บันทึก</button>

    </form>

    <h2>รายการ</h2>

    <?php
        $sql = "SELECT a.activity_id, a.activity_name, a.activity_details, a.activity_date, 
                    l.location_name, s.sport_name, c.user_id as user_id, 
                    GROUP_CONCAT(hs.hashtag_message SEPARATOR ', ') as hashtag_message, 
                    a.location_id, a.sport_id, a.status
                FROM activity a
                LEFT JOIN location l ON a.location_id = l.location_id
                LEFT JOIN sport s ON a.sport_id = s.sport_id
                LEFT JOIN creator c ON a.activity_id = c.activity_id
                LEFT JOIN hashtags_in_activities hia ON a.activity_id = hia.activity_id
                LEFT JOIN hashtag hs ON hia.hashtag_id = hs.hashtag_id
                GROUP BY a.activity_id";

        $result = $conn->query($sql);

        if ($result->num_rows > 0) {
            $counter = 1;
            echo "<table><tr><th>ลำดับ</th><th>ชื่อ</th><th>วันที่</th><th>รายละเอียด</th><th>สถานที่เล่นกีฬา</th><th>กีฬา</th><th>ผู้สร้างกิจกรรม</th><th>แฮชแท็ก</th><th>การดำเนินการ</th></tr>";
            while($row = $result->fetch_assoc()) {
                echo "<tr>
                <td>".$counter."</td>
                <td>".htmlspecialchars($row["activity_name"])."</td>
                <td>".formatDateThai($row["activity_date"])."</td>
                <td>".htmlspecialchars($row["activity_details"])."</td>
                <td>".htmlspecialchars($row["location_name"])."</td>
                <td>".htmlspecialchars($row["sport_name"])."</td>
                <td>".htmlspecialchars($row["user_id"])."</td>
                <td>".htmlspecialchars($row["hashtag_message"])."</td>
                <td>
                    <button class='btn btn-edit' onclick='return editActivity(\"".htmlspecialchars($row["activity_id"])."\", \"".htmlspecialchars($row["activity_name"])."\", \"".htmlspecialchars($row["activity_date"])."\", \"".htmlspecialchars($row["location_id"])."\", \"".htmlspecialchars($row["sport_id"])."\", \"".htmlspecialchars($row["user_id"])."\")'>แก้ไข</button>
                    
                    <a class='btn btn-delete' href='activity.php?delete=".htmlspecialchars($row["activity_id"])."' onclick='return confirm(\"คุณแน่ใจว่าต้องการลบข้อมูลนี้หรือไม่?\");'>ลบ</a>";

                if ($row['status'] == 'active') {
                    echo "<a class='btn btn-suspend' href='activity.php?suspend=".htmlspecialchars($row["activity_id"])."' onclick='return confirm(\"คุณแน่ใจว่าต้องการระงับกิจกรรมนี้หรือไม่?\");'>ระงับ</a>";
                } else {
                    echo "<a class='btn btn-activate' href='activity.php?activate=".htmlspecialchars($row["activity_id"])."' onclick='return confirm(\"คุณแน่ใจว่าต้องการเปิดใช้งานกิจกรรมนี้หรือไม่?\");'>เปิดใช้งาน</a>";
                }

                echo "</td></tr>";
                $counter++;
            }
            echo "</table>";
        } else {
            echo "0 results";
        }
    ?>

    <script>
        // เพิ่มการยืนยันเมื่อแก้ไขข้อมูล
        function editActivity(activity_id, activity_name, activity_date, location_id, sport_id, user_id) {
            if (confirm("คุณแน่ใจว่าต้องการแก้ไขข้อมูลนี้หรือไม่?")) {
                document.getElementById('activity_id').value = activity_id;
                document.getElementById('activity_name').value = activity_name;
                document.getElementById('activity_date').value = activity_date;
                document.getElementById('location_id').value = location_id;
                document.getElementById('sport_id').value = sport_id;
                document.getElementById('user_id').value = user_id;
                return true;  // ดำเนินการต่อเมื่อยืนยันการแก้ไข
            }
            return false;  // ยกเลิกการดำเนินการถ้าผู้ใช้ไม่ยืนยัน
        }
    </script>
</div>


</body>
</html>
