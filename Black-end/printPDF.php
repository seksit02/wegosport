<?php
require_once('tcpdf/tcpdf.php');
include 'config.php';

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

// สร้างวัตถุ TCPDF
$pdf = new TCPDF();

// ตั้งค่าขอบกระดาษ
$pdf->SetMargins(20, 20, 20);

// เพิ่มหน้า
$pdf->AddPage();

// ตั้งค่าฟอนต์ (ต้องแปลงฟอนต์ TH Sarabun New ให้ใช้งานได้ใน TCPDF ก่อน)
$pdf->SetFont('thsarabunnew', '', 16);

// เนื้อหาของรายงาน
$html = '
<h2>รายงานข้อมูลระบบ</h2>

<p>จำนวนผู้ใช้งานทั้งหมด: ' . $total_users . ' คน</p>
<p>จำนวนกีฬาทั้งหมด: ' . $total_sports . ' ประเภท</p>
<p>จำนวนประเภทสนามกีฬาทั้งหมด: ' . $total_sport_types . ' ประเภท</p>
<p>จำนวนแฮชแท็กทั้งหมด: ' . $total_hashtags . ' รายการ</p>
</br>
';

// แทรกเนื้อหา HTML เข้าไปใน PDF
$pdf->writeHTML($html, true, false, true, false, '');

// เริ่มสร้างตาราง
$table = '<h2>ข้อมูลสถานที่เล่นกีฬา</h2>';
$table .= '<table border="1" cellpadding="5">
<thead>
    <tr>
        <th>ชื่อสถานที่เล่นกีฬา</th>
        <th>จำนวนสถานที่ถูกเรียกใช้ (ครั้ง)</th>
    </tr>
</thead>
<tbody>';

if (mysqli_num_rows($result_location) > 0) {
    while ($row = mysqli_fetch_assoc($result_location)) {
        $table .= '<tr>';
        $table .= '<td>' . $row['location_name'] . '</td>';
        $table .= '<td>' . $row['total_locations'] . '</td>';
        $table .= '</tr>';
    }
} else {
    $table .= '<tr><td colspan="2">ไม่มีข้อมูลสถานที่</td></tr>';
}

$table .= '</tbody></table>';

// แทรกตารางเข้าไปใน PDF
$pdf->writeHTML($table, true, false, true, false, '');

// ส่งออกไฟล์ PDF
$pdf->Output('report.pdf', 'I');
?>