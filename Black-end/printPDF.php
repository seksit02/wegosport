<?php
require_once('tcpdf/tcpdf.php');
include 'config.php';

// รับค่าประเภทการรายงานจาก URL (GET method)
$reportType = isset($_GET['report-type']) ? $_GET['report-type'] : '';

class MYPDF extends TCPDF {
    public function Header() {
        $this->SetFont('thsarabunnew', '', 16);
        $this->Cell(0, 10, 'รายงานข้อมูล', 0, 1, 'C', 0, '', 0, false, 'T', 'M');
    }

    public function Footer() {
        $this->SetY(-15);
        $this->SetFont('thsarabunnew', '', 12);
        $this->Cell(0, 10, 'หน้าที่ ' . $this->getAliasNumPage() . '/' . $this->getAliasNbPages(), 0, 0, 'C');
    }
}

// สร้าง PDF ใหม่
$pdf = new MYPDF(PDF_PAGE_ORIENTATION, PDF_UNIT, PDF_PAGE_FORMAT, true, 'UTF-8', false);

// ตั้งค่าข้อมูลเอกสาร
$pdf->SetCreator(PDF_CREATOR);
$pdf->SetAuthor('Your Name');
$pdf->SetTitle('รายงานข้อมูล');
$pdf->SetSubject('รายงานข้อมูล');
$pdf->SetKeywords('รายงาน, TCPDF, PDF, ฟอนต์ไทย');

// ตั้งค่าฟอนต์ THSarabunNew
$pdf->SetFont('thsarabunnew', '', 14);

// เพิ่มหน้ากระดาษ
$pdf->AddPage();

// เช็คประเภทการรายงานและดึงข้อมูลจากฐานข้อมูลตามประเภทนั้น
$html = '';

if ($reportType == 'location') {
    // ดึงข้อมูลสถานที่เล่นกีฬา
    $html .= '<h1 style="text-align:center;">รายงานข้อมูลสถานที่</h1>';
    $html .= '<table border="1" cellpadding="4">
                <tr>
                    <th>ลำดับ</th>
                    <th>ชื่อสถานที่</th>
                    <th>ละติจูด</th>
                    <th>ลองจิจูด</th>
                    <th>ประเภทสนามกีฬา</th>
                    <th>วันทำการ</th>
                    <th>เวลาเปิด-ปิด</th>
                    <th>จำนวนครั้งที่ถูกเรียกใช้</th>
                </tr>';

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
    $counter = 1;
    
    while ($row = mysqli_fetch_assoc($result)) {
        // แปลงวันทำการเป็นชื่อวัน
        $dayNumbers = explode(',', $row['location_day']);
        $dayNames = array('อาทิตย์', 'จันทร์', 'อังคาร', 'พุธ', 'พฤหัสบดี', 'ศุกร์', 'เสาร์');
        $dayList = implode(', ', array_map(function($dayNumber) use ($dayNames) {
            return $dayNames[trim($dayNumber)];
        }, $dayNumbers));

        $html .= '<tr>
                    <td>' . $counter . '</td>
                    <td>' . htmlspecialchars($row['location_name']) . '</td>
                    <td>' . htmlspecialchars($row['latitude']) . '</td>
                    <td>' . htmlspecialchars($row['longitude']) . '</td>
                    <td>' . htmlspecialchars($row['type_name']) . '</td>
                    <td>' . $dayList . '</td>
                    <td>' . htmlspecialchars($row['location_time']) . '</td>
                    <td>' . htmlspecialchars($row['usage_count']) . '</td>
                </tr>';
        $counter++;
    }

    $html .= '</table>';
} elseif ($reportType == 'activity') {
    // ดึงข้อมูลกิจกรรม
    $html .= '<h1 style="text-align:center;">รายงานข้อมูลกิจกรรม</h1>';
    $html .= '<table border="1" cellpadding="4">
                <tr>
                    <th>ลำดับ</th>
                    <th>ชื่อกิจกรรม</th>
                    <th>ชื่อคนสร้าง</th>
                    <th>ประเภทกีฬา</th>
                    <th>วัน/เดือน/ปี</th>
                    <th>เวลา</th>
                    <th>จำนวนสมาชิก</th>
                    <th>รายชื่อสมาชิก</th>
                </tr>';

    $query = "
        SELECT 
            activity.activity_name, 
            activity.activity_date, 
            location.location_name, 
            sport.sport_name, 
            user_information.user_name AS creator_name, 
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
    ";
    $result = mysqli_query($conn, $query);
    $counter = 1;

    while ($row = mysqli_fetch_assoc($result)) {
        $activityDate = date('d-m-Y', strtotime($row['activity_date']));
        $activityTime = date('H:i:s', strtotime($row['activity_date']));

        $html .= '<tr>
                    <td>' . $counter . '</td>
                    <td>' . htmlspecialchars($row['activity_name']) . '</td>
                    <td>' . htmlspecialchars($row['creator_name']) . '</td>
                    <td>' . htmlspecialchars($row['sport_name']) . '</td>
                    <td>' . htmlspecialchars($activityDate) . '</td>
                    <td>' . htmlspecialchars($activityTime) . '</td>
                    <td>' . htmlspecialchars($row['member_count']) . '</td>
                    <td>' . htmlspecialchars($row['member_names']) . '</td>
                </tr>';
        $counter++;
    }

    $html .= '</table>';
} elseif ($reportType == 'user') {
    // ดึงข้อมูลสมาชิก
    $html .= '<h1 style="text-align:center;">รายงานข้อมูลสมาชิก</h1>';
    $html .= '<table border="1" cellpadding="4">
                <tr>
                    <th>ลำดับ</th>
                    <th>ชื่อสมาชิก</th>
                    <th>วันเกิด</th>
                    <th>วิธีการสมัคร</th>
                    <th>สร้างกิจกรรม</th>
                    <th>เข้าร่วมกิจกรรม</th>
                </tr>';

    $query = "
        SELECT 
            user_information.user_name, 
            user_information.user_age, 
            user_information.user_token, 
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
    $counter = 1;

    while ($row = mysqli_fetch_assoc($result)) {
        $formattedBirthday = date('d-m-Y', strtotime($row['user_age']));
        $registrationType = $row['user_token'] ? 'สมัครผ่านเฟสบุ๊ค' : 'สมัครธรรมดา';

        $html .= '<tr>
                    <td>' . $counter . '</td>
                    <td>' . htmlspecialchars($row['user_name']) . '</td>
                    <td>' . htmlspecialchars($formattedBirthday) . '</td>
                    <td>' . htmlspecialchars($registrationType) . '</td>
                    <td>' . htmlspecialchars($row['created_activities']) . '</td>
                    <td>' . htmlspecialchars($row['joined_activities']) . '</td>
                </tr>';
        $counter++;
    }

    $html .= '</table>';
} elseif ($reportType == 'location1') {
    // ดึงข้อมูลสนามกีฬา
    $html .= '<h1 style="text-align:center;">รายงานข้อมูลสนามกีฬา</h1>';
    $html .= '<table border="1" cellpadding="4">
                <tr>
                    <th>ลำดับ</th>
                    <th>ชื่อสนามกีฬา</th>
                    <th>ละติจูด</th>
                    <th>ลองจิจูด</th>
                    <th>ประเภทกีฬา</th>
                    <th>จำนวนครั้งที่ถูกใช้งาน</th>
                </tr>';

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
    $counter = 1;

    while ($row = mysqli_fetch_assoc($result)) {
        $html .= '<tr>
                    <td>' . $counter . '</td>
                    <td>' . htmlspecialchars($row['location_name']) . '</td>
                    <td>' . htmlspecialchars($row['latitude']) . '</td>
                    <td>' . htmlspecialchars($row['longitude']) . '</td>
                    <td>' . htmlspecialchars($row['type_name']) . '</td>
                    <td>' . htmlspecialchars($row['usage_count']) . '</td>
                </tr>';
        $counter++;
    }

    $html .= '</table>';
}

// แสดง HTML ใน PDF
$pdf->writeHTML($html, true, false, true, false, '');

// ส่งไฟล์ PDF ไปยัง browser
$pdf->Output('report.pdf', 'I');
?>