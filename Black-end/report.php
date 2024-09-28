<?php
include 'config.php';

$message = '';
$error = '';

// Query เพื่อดึงจำนวนผู้ใช้ทั้งหมด
$query_users = "SELECT COUNT(*) as total_users FROM user_information";
$result_users = mysqli_query($conn, $query_users);
$row_users = mysqli_fetch_assoc($result_users);
$total_users = $row_users['total_users'];

// Query เพื่อดึงจำนวนกีฬาทั้งหมด
$query_sports = "SELECT COUNT(*) as total_sports FROM sport WHERE status = 'active'";
$result_sports = mysqli_query($conn, $query_sports);
$row_sports = mysqli_fetch_assoc($result_sports);
$total_sports = $row_sports['total_sports'];

// Query เพื่อดึงจำนวนประเภทสนามกีฬาทั้งหมด
$query_sport_types = "SELECT COUNT(*) as total_sport_types FROM sport_type WHERE status = 'active'";
$result_sport_types = mysqli_query($conn, $query_sport_types);
$row_sport_types = mysqli_fetch_assoc($result_sport_types);
$total_sport_types = $row_sport_types['total_sport_types'];

// Query เพื่อดึงจำนวนแฮชแท็กทั้งหมด
$query_hashtags = "SELECT COUNT(*) as total_hashtags FROM hashtag";
$result_hashtags = mysqli_query($conn, $query_hashtags);
$row_hashtags = mysqli_fetch_assoc($result_hashtags);
$total_hashtags = $row_hashtags['total_hashtags'];

// Query เพื่อดึงชื่อสถานที่และนับจำนวนทั้งหมด
$query_location = "SELECT location_name, COUNT(*) as total_locations FROM location GROUP BY location_name";
$result_location = mysqli_query($conn, $query_location);
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
    display: flex;
    flex-direction: column;
    align-items: flex-start; /* ปรับจาก center เป็น flex-start เพื่อชิดซ้าย */
    justify-content: flex-start; /* ปรับจาก center เป็น flex-start เพื่อชิดบน */
}

        h2 {
            margin-top: 0;
            color: #2c3e50;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
            background: #ecf0f1;
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
    <a href="index.php" class="btn-logout" onclick="return confirm('คุณแน่ใจว่าต้องการออกจากระบบหรือไม่?');">ออกจากระบบ</a>
</div>

<div class="container">
    <h2>รายงานข้อมูลระบบ</h2>
    <p>จำนวนผู้ใช้งานทั้งหมด: <?php echo $total_users; ?> คน</p>
    <p>จำนวนกีฬาทั้งหมด: <?php echo $total_sports; ?> ประเภท</p>
    <p>จำนวนประเภทสนามกีฬาทั้งหมด: <?php echo $total_sport_types; ?> ประเภท</p>
    <p>จำนวนแฮชแท็กทั้งหมด: <?php echo $total_hashtags; ?> รายการ</p>

    <a href="printPDF.php" class="print-btn">พิมพ์ PDF</a>

    <h2>ข้อมูลสถานที่เล่นกีฬา</h2>
    <table>
    <thead>
        <tr>
            <th>ชื่อสถานที่เล่นกีฬา</th>
            <th>จำนวนสถานที่ถูกเรียกใช้ (ครั้ง)</th>
        </tr>
    </thead>
    <tbody>
        <?php
        // Loop แสดงข้อมูลในตาราง
        if (mysqli_num_rows($result_location) > 0) {
            while ($row = mysqli_fetch_assoc($result_location)) {
                echo "<tr>";
                echo "<td>" . $row['location_name'] . "</td>";
                echo "<td>" . $row['total_locations'] . "</td>";
                echo "</tr>";
            }
        } else {
            echo "<tr><td colspan='2'>ไม่มีข้อมูลสถานที่</td></tr>";
        }
        ?>
    </tbody>
</table>
    </br>

<h2>กราฟแสดงข้อมูลทั้งหมด</h2>

    <canvas id="reportChart"></canvas> <!-- ที่สำหรับแสดงกราฟ -->

    <script>
        var ctx = document.getElementById('reportChart').getContext('2d');
        var reportChart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: ['ผู้ใช้งาน', 'กีฬา', 'ประเภทสนามกีฬา', 'แฮชแท็ก'],
                datasets: [{
                    label: 'จำนวน',
                    data: [<?php echo $total_users; ?>, <?php echo $total_sports; ?>, <?php echo $total_sport_types; ?>, <?php echo $total_hashtags; ?>],
                    backgroundColor: ['#3498db', '#2ecc71', '#f1c40f', '#e74c3c'],
                    borderColor: ['#2980b9', '#27ae60', '#f39c12', '#c0392b'],
                    borderWidth: 1
                }]
            },
            options: {
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });
    </script>
</div>

</body>
</html>