<?php
include 'config.php';

$message = '';
$error = '';

// Function to get location data
function getLocationData($conn) {
    $query = "SELECT location_name, COUNT(*) as total_locations FROM location GROUP BY location_name";
    $result = mysqli_query($conn, $query);
    $data = array();
    while ($row = mysqli_fetch_assoc($result)) {
        $data[] = $row;
    }
    return $data;
}

// Function to get detailed location info with usage count
function getDetailedLocationData($conn) {
    $query = "
        SELECT 
            location.location_name, 
            location.latitude, 
            location.longitude, 
            sport_type.type_name,  
            location.location_day, 
            location.location_time, 
            COUNT(activity.activity_id) AS usage_count
        FROM location
        LEFT JOIN sport_type_in_location ON location.location_id = sport_type_in_location.location_id
        LEFT JOIN sport_type ON sport_type_in_location.type_id = sport_type.type_id
        LEFT JOIN activity ON location.location_id = activity.location_id
        GROUP BY location.location_id
    ";
    $result = mysqli_query($conn, $query);
    $data = array();
    while ($row = mysqli_fetch_assoc($result)) {
        $data[] = $row;
    }
    return $data;
}

// Function to get activity data with names, member count, and member names
function getActivityDataWithNames($conn) {
    $query = "
        SELECT 
            activity.activity_name, 
            activity.activity_date, 
            activity.activity_details, 
            location.location_name, 
            sport.sport_name, 
            user_information.user_name AS creator_name, 
            activity.status,
            COUNT(member_in_activity.member_id) AS member_count,
            GROUP_CONCAT(member_info.user_name SEPARATOR ', ') AS member_names
        FROM activity
        JOIN location ON activity.location_id = location.location_id
        JOIN sport ON activity.sport_id = sport.sport_id
        JOIN creator ON activity.activity_id = creator.activity_id
        JOIN user_information ON creator.user_id = user_information.user_id
        LEFT JOIN member_in_activity ON activity.activity_id = member_in_activity.activity_id
        LEFT JOIN user_information AS member_info ON member_in_activity.user_id = member_info.user_id
        GROUP BY activity.activity_id
        ORDER BY activity.activity_date ASC
    ";
    $result = mysqli_query($conn, $query);
    $data = array();
    while ($row = mysqli_fetch_assoc($result)) {
        $data[] = $row;
    }
    return $data;
}



// Function to get user information data with created and joined activities (show activity names)
function getUserInformationData($conn) {
    $query = "
        SELECT 
            user_information.user_name, 
            user_information.user_age, 
            user_information.user_token, 
            user_information.user_id, 
            GROUP_CONCAT(DISTINCT created_activity.activity_name SEPARATOR ', ') AS created_activities, 
            GROUP_CONCAT(DISTINCT joined_activity.activity_name SEPARATOR ', ') AS joined_activities
        FROM user_information
        LEFT JOIN creator ON user_information.user_id = creator.user_id
        LEFT JOIN activity AS created_activity ON creator.activity_id = created_activity.activity_id
        LEFT JOIN member_in_activity ON user_information.user_id = member_in_activity.user_id
        LEFT JOIN activity AS joined_activity ON member_in_activity.activity_id = joined_activity.activity_id
        GROUP BY user_information.user_id
    ";
    $result = mysqli_query($conn, $query);
    $data = array();
    while ($row = mysqli_fetch_assoc($result)) {
        $data[] = $row;
    }
    return $data;
}

// Function to get location report with usage count
function getLocationReport($conn) {
    $query = "
        SELECT 
            location.location_name, 
            location.latitude, 
            location.longitude, 
            sport_type.type_name, 
            COUNT(activity.activity_id) AS usage_count
        FROM location
        LEFT JOIN sport_type_in_location ON location.location_id = sport_type_in_location.location_id
        LEFT JOIN sport_type ON sport_type_in_location.type_id = sport_type.type_id
        LEFT JOIN activity ON location.location_id = activity.location_id
        GROUP BY location.location_id, sport_type.type_id
    ";
    $result = mysqli_query($conn, $query);
    $data = array();
    while ($row = mysqli_fetch_assoc($result)) {
        $data[] = $row;
    }
    return $data;
}
function getHashtagReport($conn) {
    $query = "
        SELECT 
            hashtag.hashtag_message AS hashtag_name, 
            activity.activity_name, 
            user_information.user_name 
        FROM hashtags_in_activities
        JOIN hashtag ON hashtags_in_activities.hashtag_id = hashtag.hashtag_id
        JOIN activity ON hashtags_in_activities.activity_id = activity.activity_id
        JOIN creator ON activity.activity_id = creator.activity_id
        JOIN user_information ON creator.user_id = user_information.user_id
        GROUP BY hashtag.hashtag_message, activity.activity_name, user_information.user_name
    ";
    $result = mysqli_query($conn, $query);
    $data = array();
    while ($row = mysqli_fetch_assoc($result)) {
        $data[] = $row;
    }
    return $data;
}



/// Check if form is submitted
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $reportType = $_POST['report-type'];
    
    if ($reportType == 'location') {
        $locationData = getLocationData($conn);
        $detailedLocationData = getDetailedLocationData($conn);
    } elseif ($reportType == 'activity') {
        $activityData = getActivityDataWithNames($conn);
    } elseif ($reportType == 'user') {
        $userData = getUserInformationData($conn);
    } elseif ($reportType == 'location1') {
        $location1Data = getLocationReport($conn);  // กำหนดค่า $location1Data อย่างถูกต้อง
    } elseif ($reportType == 'hashtag') {
        $hashtagData = getHashtagReport($conn);
    }
}

// ฟังก์ชันสำหรับแปลงหมายเลขวันเป็นชื่อวันภาษาไทยและเรียงลำดับตามหมายเลข
function getThaiDayNamesList($days) {
    // สร้างอาเรย์สำหรับชื่อวันภาษาไทย
    $dayNames = array(
        '1' => 'จันทร์',
        '2' => 'อังคาร',
        '3' => 'พุธ',
        '4' => 'พฤหัสบดี',
        '5' => 'ศุกร์',
        '6' => 'เสาร์',
        '7' => 'อาทิตย์'
    );
    
    // แยกวันทำการที่เก็บเป็นหมายเลขด้วยเครื่องหมายจุลภาค
    $dayNumbers = explode(',', $days); 
    
    // จัดเรียงวันตามลำดับหมายเลข
    sort($dayNumbers);
    
    // เริ่มต้นรายการ (list) สำหรับชื่อวัน
    $dayList = '<ul>';
    
    // แปลงหมายเลขเป็นชื่อวันและเพิ่มลงในรายการ
    foreach ($dayNumbers as $dayNumber) {
        $dayList .= '<li>' . $dayNames[trim($dayNumber)] . '</li>';
    }
    
    // ปิดรายการ
    $dayList .= '</ul>';
    
    // คืนค่าเป็น HTML ที่เป็นรายการของชื่อวัน
    return $dayList;
}


?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>รายงาน</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script> <!-- เพิ่ม Chart.js -->
   
    <style>
          body {
            display: flex;
            min-height: 100vh;
            font-family: Arial, sans-serif;
            margin: 0;
            background: #f4f7f6;
        }
        /* Modal styles */
        .modal {
    display: none;
    position: fixed;
    z-index: 1;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0, 0, 0, 0.5);
    overflow: auto; /* เพิ่ม overflow เพื่อให้เลื่อนดูเนื้อหาที่เกินได้ */
}


.modal-content {
    background-color: #fefefe;
    margin: 15% auto;
    padding: 20px;
    border: 1px solid #888;
    width: 40%; /* ปรับขนาดของการ์ด */
    max-width: 600px; /* กำหนดขนาดสูงสุด */
    min-width: 300px; /* กำหนดขนาดขั้นต่ำ */
    word-wrap: break-word; /* ทำให้ข้อความที่ยาวเกินขอบสามารถขึ้นบรรทัดใหม่ได้ */
    box-sizing: border-box; /* ปรับการคำนวณขนาดกล่องให้อยู่ภายในขอบ */
}

        .close {
            color: #aaa;
            float: right;
            font-size: 28px;
            font-weight: bold;
        }

        .close:hover,
        .close:focus {
            color: black;
            text-decoration: none;
            cursor: pointer;
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
            border: 1px solid #bdc3c7;
        }

        th {
            background: #2c3e50;
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
        canvas {
            max-width: 600px;
            margin-top: 20px;
            display: block;
        }
        .print-btn {
            background-color: #4CAF50;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            float: right;
            margin-bottom: 10px;
            text-decoration: none;
        }
        .print-btn:hover {
            background-color: #45a049;
        }   
        form {
    display: flex;
    justify-content: flex-start; /* จัดเรียงให้อยู่ทางซ้าย */
    align-items: center;
    gap: 10px; /* ลดระยะห่างระหว่างฟอร์มและปุ่ม */
}

.form-group {
    flex-grow: 0;
    margin-right: 10px; /* ลดระยะห่างด้านขวาของฟอร์ม */
}

button {
    margin-left: 0; /* ลดระยะห่างด้านซ้ายของปุ่ม */
}


        label {
            font-weight: bold;
            display: block;
            margin-bottom: 5px;
        }
        input[type="text"], input[type="date"] {
            width: 100%;
            padding: 10px;
            margin-bottom: 10px;
            border: 1px solid #ccc;
            border-radius: 5px;
            font-size: 16px;
        }
        .btn {
            background-color: #1abc9c;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
        }
        .btn:hover {
            background-color: #16a085;
        }

        .btn-secondary {
            background-color: #17a2b8;
        }

        .btn-secondary:hover {
            background-color: #138496;
        }
        h1 {
            text-align: center;
            color: #2c3e50;
        }
        select {
    width: 100%; /* ปรับให้กว้างเต็มที่ */
    max-width: 300px; /* หรือใช้ max-width เพื่อกำหนดขนาดสูงสุด */
    padding: 10px; /* เพิ่มช่องว่างภายใน */
    border: 1px solid #ccc; /* กำหนดขอบ */
    border-radius: 5px; /* เพิ่มมุมโค้ง */
    font-size: 16px; /* กำหนดขนาดฟอนต์ */
}

/* สไตล์สำหรับจุด ... */
.more-link {
            cursor: pointer;
            color: blue;
            text-decoration: underline;
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
    <h1>รายงาน</h1>
    <form method="POST" action="">
    <div class="form-group">
        <label for="report-type">ประเภทการรายงาน:</label>
        <select id="report-type" name="report-type">
            <option>เลือกรายงาน</option>
            <option value="location">รายงานข้อมูลสถานที่เล่นกีฬา</option>
            <option value="activity">รายงานข้อมูลกิจกรรม</option>
            <option value="user">รายงานข้อมูลสมาชิก</option>
            <option value="location1">รายงานข้อมูลสนามกีฬา</option>
            <option value="hashtag">รายงานข้อมูลแฮชแท็ก</option>
        </select>
    </div>

    <div class="form-group" style="align-self: center;">
        <button type="submit" class="btn">แสดงข้อมูล</button>

        <a href="printPDF.php?report-type=<?php echo isset($_POST['report-type']) ? $_POST['report-type'] : ''; ?>" class="btn">พิมพ์ PDF</a>

      
    </div>
</form>


<div id="reportData">
    <?php
    if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($detailedLocationData)) {
        echo "<h2>รายงานข้อมูลสถานที่เล่นกีฬา</h2>";
        echo "<table>";
        echo "<tr><th>ลำดับ</th><th>ชื่อสถานที่</th><th>ละติจูด ลองจิจูด</th><th>ประเภทสนามกีฬา</th><th>วันทำการ</th><th>เวลาเปิด-ปิด</th><th>จำนวนครั้งที่ถูกเรียกใช้</th></tr>";
        $counter = 1;
        foreach ($detailedLocationData as $location) {
            $latitude = $location['latitude'];
            $longitude = $location['longitude'];
            $coordinates = $latitude . "," . $longitude;
            $googleMapsLink = "https://www.google.com/maps/place/$coordinates";

            // เรียกใช้ฟังก์ชัน getThaiDayNamesList() เพื่อแสดงวันทำการเป็นรายการ
            $thaiDayList = getThaiDayNamesList($location['location_day']);

            echo "<tr>";
            echo "<td>" . $counter . "</td>";
            echo "<td>" . htmlspecialchars($location['location_name']) . "</td>";
            echo "<td><a href='" . htmlspecialchars($googleMapsLink) . "' target='_blank'>" . htmlspecialchars($coordinates) . "</a></td>";
            echo "<td>" . htmlspecialchars($location['type_name']) . "</td>";
            echo "<td>" . $thaiDayList . "</td>"; // แสดงรายการวันทำการเป็น list
            echo "<td>" . htmlspecialchars($location['location_time']) . "</td>";
            echo "<td>" . htmlspecialchars($location['usage_count']) . "</td>";
            echo "</tr>";
            $counter++;
        }
        echo "</table>";

    } elseif ($_SERVER["REQUEST_METHOD"] == "POST" && isset($activityData)) {
        echo "<h2>รายงานข้อมูลกิจกรรม</h2>";
        echo "<table>";
        echo "<tr><th>ลำดับ</th><th>กิจกรรมที่ใกล้มาถึง</th><th>เวลา</th><th>ชื่อกิจกรรม</th><th>ชื่อคนสร้าง</th><th>ประเภทกีฬา</th><th>จำนวนสมาชิก (คน)</th><th>รายชื่อสมาชิก</th></tr>";
        $counter = 1;
        foreach ($activityData as $activity) {
            $activityDate = date('d-m-Y', strtotime($activity['activity_date'])); // แยกวันที่
            $activityTime = date('H:i:s', strtotime($activity['activity_date'])); // แยกเวลา
            echo "<tr>";
            echo "<td>" . $counter . "</td>";
            echo "<td>" . htmlspecialchars($activityDate) . "</td>"; // แสดงวันที่
            echo "<td>" . htmlspecialchars($activityTime) . "</td>"; // แสดงเวลา
            echo "<td>" . htmlspecialchars($activity['activity_name']) . "</td>";
            echo "<td>" . htmlspecialchars($activity['creator_name']) . "</td>"; // ชื่อคนสร้าง
            echo "<td>" . htmlspecialchars($activity['sport_name']) . "</td>"; // ประเภทกีฬา
            echo "<td>" . htmlspecialchars($activity['member_count']) . "</td>"; // จำนวนสมาชิก
            
            // ตัดรายชื่อสมาชิกแค่ 3 คนและเพิ่มจุด ... พร้อมปุ่มสำหรับแสดง Modal
            $members = explode(", ", $activity['member_names']);
            $shown_members = array_slice($members, 0, 3); // ตัดรายชื่อสมาชิกแค่ 3 คน
            $hidden_members = array_slice($members, 3); // รายชื่อสมาชิกที่เหลือ

            echo "<td>" . htmlspecialchars(implode(", ", $shown_members));
            if (count($hidden_members) > 0) {
                echo ' <span class="more-link" onclick="openModal(' . $counter . ')">...ดูเพิ่มเติม</span>';
                echo '<div id="modal-' . $counter . '" class="modal">';
                echo '<div class="modal-content">';
                echo '<span class="close" onclick="closeModal(' . $counter . ')">&times;</span>';
                echo '<p>' . htmlspecialchars(implode(", ", $hidden_members)) . '</p>';
                echo '</div></div>';
            }
            echo "</td>";
            echo "</tr>";
            $counter++;
        }
        echo "</table>";

    } elseif($_SERVER["REQUEST_METHOD"] == "POST" && isset($userData)) {
        echo "<h2>รายงานข้อมูลสมาชิก</h2>";
        echo "<table>";
        echo "<tr><th>ลำดับ</th><th>ชื่อสมาชิก</th><th>วันเกิด</th><th>สร้างกิจกรรม</th><th>เข้าร่วมกิจกรรม</th></tr>";
        $counter = 1;
        foreach ($userData as $user) {
            $registrationType = $user['user_token'] ? 'สมัครผ่านเฟสบุ๊ค' : 'สมัครธรรมดา';
            // แปลงวันเกิดเป็นรูปแบบ d-m-Y
            $formattedBirthday = date('d-m-Y', strtotime($user['user_age']));

            echo "<tr>";
            echo "<td>" . $counter . "</td>";
            echo "<td>" . htmlspecialchars($user['user_name']) . "</td>";
            echo "<td>" . htmlspecialchars($formattedBirthday) . "</td>";
            echo "<td>" . htmlspecialchars($user['created_activities']) . "</td>";

            // ตัดรายชื่อกิจกรรมที่เข้าร่วมเหลือ 3 รายการ
            $joinedActivities = explode(", ", $user['joined_activities']);
            $shownActivities = array_slice($joinedActivities, 0, 3); // แสดงกิจกรรมแค่ 3 รายการ
            $hiddenActivities = array_slice($joinedActivities, 3); // เก็บกิจกรรมที่เหลือ

            echo "<td>" . htmlspecialchars(implode(", ", $shownActivities));
            if (count($hiddenActivities) > 0) {
                echo ' <span class="more-link" onclick="openModal(' . $counter . ')">...ดูเพิ่มเติม</span>';
                echo '<div id="modal-' . $counter . '" class="modal">';
                echo '<div class="modal-content">';
                echo '<span class="close" onclick="closeModal(' . $counter . ')">&times;</span>';
                echo '<p>' . htmlspecialchars(implode(", ", $hiddenActivities)) . '</p>';
                echo '</div></div>';
            }
            echo "</td>";

            echo "</tr>";
            $counter++;
        }
        echo "</table>";

    } elseif ($_SERVER["REQUEST_METHOD"] == "POST" && isset($location1Data)) {
        echo "<h2>รายงานข้อมูลสนามกีฬา</h2>";
        echo "<table>";
        echo "<tr><th>ลำดับ</th><th>ชื่อสนามกีฬา</th><th>ละติจูด ลองจิจูด</th><th>ประเภทกีฬา</th><th>จำนวนครั้งที่ถูกใช้งาน</th></tr>";
        $counter = 1;
        foreach ($location1Data as $location1) {
            // รวมละติจูดและลองจิจูดเข้าด้วยกันในคอลัมน์เดียว
            $latitude = $location1['latitude'];
            $longitude = $location1['longitude'];
            $coordinates = $latitude . "," . $longitude;
            $googleMapsLink = "https://www.google.com/maps/place/$coordinates";

            echo "<tr>";
            echo "<td>" . $counter . "</td>";
            echo "<td>" . htmlspecialchars($location1['location_name']) . "</td>";
            // แสดงละติจูดและลองจิจูดพร้อมลิงก์ไป Google Maps
            echo "<td><a href='" . htmlspecialchars($googleMapsLink) . "' target='_blank'>" . htmlspecialchars($coordinates) . "</a></td>";
            echo "<td>" . htmlspecialchars($location1['type_name']) . "</td>";
            echo "<td>" . htmlspecialchars($location1['usage_count']) . "</td>";
            echo "</tr>";
            $counter++;
        }
        echo "</table>";

    } elseif($_SERVER["REQUEST_METHOD"] == "POST" && isset($hashtagData)) {
        echo "<h2>รายงานข้อมูลแฮชแท็ก</h2>";
        echo "<table>";
        echo "<tr><th>ลำดับ</th><th>ชื่อแฮชแท็ก</th><th>ชื่อกิจกรรม</th><th>ชื่อสมาชิกที่เรียกใช้</th></tr>";
        $counter = 1;
        foreach ($hashtagData as $hashtag) {
            echo "<tr>";
            echo "<td>" . $counter . "</td>";
            echo "<td>" . htmlspecialchars($hashtag['hashtag_name']) . "</td>";
            echo "<td>" . htmlspecialchars($hashtag['activity_name']) . "</td>";
            echo "<td>" . htmlspecialchars($hashtag['user_name']) . "</td>";
            echo "</tr>";
            $counter++;
        }
        echo "</table>";
}
    ?>
</div>



</div>

<script>
function printReport() {
    window.print();
}
    // JavaScript สำหรับเปิดและปิด Modal
// JavaScript สำหรับเปิดและปิด Modal
function openModal(id) {
    document.getElementById('modal-' + id).style.display = 'block';
}

function closeModal(id) {
    document.getElementById('modal-' + id).style.display = 'none';
}
</script>

</body>
</html>