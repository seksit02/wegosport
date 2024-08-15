<?php
include 'Connect.php';

// Query เพื่อดึงข้อมูลทุก location พร้อมกับประเภทกีฬา (ถ้ามี)
$sql = "
    SELECT l.location_name, st.type_id, st.type_name
    FROM location l
    LEFT JOIN sport_type_in_location stil ON l.location_id = stil.location_id
    LEFT JOIN sport_type st ON stil.type_id = st.type_id
";
$result = mysqli_query($conn, $sql);

$locations = array();

if (mysqli_num_rows($result) > 0) {
    while($row = mysqli_fetch_assoc($result)) {
        $location_name = $row['location_name'];
        $sport_type = array(
            "type_id" => $row['type_id'],
            "type_name" => $row['type_name']
        );

        // ตรวจสอบว่ามี location นี้ใน array แล้วหรือยัง
        if (!isset($locations[$location_name])) {
            $locations[$location_name] = array(
                "location_name" => $location_name,
                "sport_types" => array()
            );
        }

        // เพิ่มประเภทกีฬาลงใน location ถ้า type_id และ type_name ไม่เป็น null
        if ($sport_type['type_id'] !== null && $sport_type['type_name'] !== null) {
            $locations[$location_name]['sport_types'][] = $sport_type;
        }
    }
}

// แปลง associative array ให้เป็น array ที่มี index เป็นตัวเลข
$locations = array_values($locations);

echo json_encode($locations, JSON_UNESCAPED_UNICODE);

mysqli_close($conn);
?>
