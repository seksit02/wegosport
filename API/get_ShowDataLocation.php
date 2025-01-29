<?php
include 'Connect.php'; // เชื่อมต่อกับฐานข้อมูล

// Query เพื่อดึงข้อมูล location รวมถึงวันและเวลาที่เปิดใช้งาน
$sql = "
    SELECT l.location_name, l.status, l.location_time, l.location_day, st.type_id, st.type_name, s.sport_id, s.sport_name
    FROM location l
    LEFT JOIN sport_type_in_location stil ON l.location_id = stil.location_id
    LEFT JOIN sport_type st ON stil.type_id = st.type_id
    LEFT JOIN sport_in_type sit ON st.type_id = sit.type_id
    LEFT JOIN sport s ON sit.sport_id = s.sport_id
";
$result = mysqli_query($conn, $sql); // รันคำสั่ง SQL และรับผลลัพธ์จากฐานข้อมูล

$locations = array(); // สร้างอาร์เรย์เปล่าสำหรับเก็บข้อมูล location

if (mysqli_num_rows($result) > 0) { // ตรวจสอบว่ามีข้อมูลที่ดึงมาหรือไม่
    while($row = mysqli_fetch_assoc($result)) { // วนลูปผ่านแต่ละแถวของผลลัพธ์
        $location_name = $row['location_name']; // เก็บชื่อ location จากแถวปัจจุบัน
        $status = $row['status']; // เก็บสถานะของ location
        $location_time = $row['location_time']; // เก็บเวลาที่เปิดให้บริการ
        $location_day = $row['location_day']; // เก็บวันเปิดใช้งาน

        $sport_type = array( // เก็บข้อมูลประเภทกีฬา
            "type_id" => $row['type_id'],
            "type_name" => $row['type_name'],
            "sports" => array() // สร้างอาร์เรย์เปล่าสำหรับเก็บข้อมูลกีฬาในประเภทนี้
        );

        $sport = array( // เก็บข้อมูลกีฬา
            "sport_id" => $row['sport_id'],
            "sport_name" => $row['sport_name']
        );

        // ตรวจสอบว่ามี location นี้ใน array แล้วหรือยัง
        if (!isset($locations[$location_name])) {
            $locations[$location_name] = array( // หากยังไม่มี location นี้ใน array ให้เพิ่มเข้าไป
                "location_name" => $location_name,
                "status" => $status, // เพิ่มสถานะของ location เข้าไปในข้อมูล
                "location_time" => $location_time, // เพิ่มเวลาเปิดใช้งานของ location
                "location_day" => $location_day, // เพิ่มวันเปิดใช้งานของ location
                "sport_types" => array() // สร้างอาร์เรย์เปล่าสำหรับเก็บข้อมูลประเภทกีฬา
            );
        }

        // ตรวจสอบว่ามีประเภทกีฬาใน location นี้แล้วหรือยัง
        if (!isset($locations[$location_name]['sport_types'][$sport_type['type_id']])) {
            $locations[$location_name]['sport_types'][$sport_type['type_id']] = array( // หากยังไม่มีประเภทกีฬานี้ใน location ให้เพิ่มเข้าไป
                "type_id" => $sport_type['type_id'],
                "type_name" => $sport_type['type_name'],
                "sports" => array() // สร้างอาร์เรย์เปล่าสำหรับเก็บข้อมูลกีฬาในประเภทนี้
            );
        }

        // เพิ่มกีฬาลงในประเภทกีฬา
        $locations[$location_name]['sport_types'][$sport_type['type_id']]['sports'][] = $sport; // เพิ่มข้อมูลกีฬาเข้าไปในประเภทกีฬานั้น
    }
}

// แปลง associative array ให้เป็น array ที่มี index เป็นตัวเลข
$locations = array_values($locations);

// แปลง sport_types array ให้เป็น array ที่มี index เป็นตัวเลข
foreach ($locations as &$location) {
    $location['sport_types'] = array_values($location['sport_types']); // แปลง array ของประเภทกีฬาให้มี index เป็นตัวเลข
}

echo json_encode($locations, JSON_UNESCAPED_UNICODE); // ส่งข้อมูลในรูปแบบ JSON และรองรับภาษาไทย

mysqli_close($conn); // ปิดการเชื่อมต่อฐานข้อมูล
?>
