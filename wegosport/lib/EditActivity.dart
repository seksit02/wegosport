import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// หน้าจอแก้ไขกิจกรรม
class EditActivity extends StatefulWidget {
  const EditActivity({Key? key, required this.activityId, required this.jwt})
      : super(key: key);

  final String activityId; // รับค่า ID ของกิจกรรมสำหรับการแก้ไข
  final String jwt; // รับค่า JWT สำหรับการตรวจสอบสิทธิ์

  @override
  State<EditActivity> createState() =>
      _EditActivityState(); // สร้างสถานะของ EditActivity
}

class _EditActivityState extends State<EditActivity> {
  final _formKey = GlobalKey<FormState>(); // กุญแจสำหรับฟอร์ม
  TextEditingController nameController =
      TextEditingController(); // ตัวควบคุมสำหรับฟิลด์ชื่อกิจกรรม
  TextEditingController detailsController =
      TextEditingController(); // ตัวควบคุมสำหรับฟิลด์รายละเอียดกิจกรรม
  TextEditingController dateController =
      TextEditingController(); // ตัวควบคุมสำหรับฟิลด์วันที่
  TextEditingController hashtagController =
      TextEditingController(); // ตัวควบคุมสำหรับฟิลด์แฮชแท็ก
  Map<String, int> locationMap = {}; // แผนที่สำหรับจับคู่ชื่อสถานที่กับ ID
  Map<String, int> sportMap = {}; // แผนที่สำหรับจับคู่ชื่อกีฬากับ ID
  String? selectedLocation; // สถานที่ที่ถูกเลือก
  String? selectedSport; // กีฬาที่ถูกเลือก
  List<String> _selectedTags = []; // แฮชแท็กที่ถูกเลือก
  List<String> locations = []; // เก็บสถานที่ทั้งหมด
  List<String> sport = []; // เก็บกีฬาทั้งหมด
  List<Map<String, dynamic>> locationData =
      []; // จัดเก็บข้อมูลสถานที่ในรูปแบบที่ถูกต้อง

  @override
  void initState() {
    super.initState();
    fetchLocations(); // ดึงข้อมูลสถานที่เมื่อเริ่มต้น
    fetchActivityDetails(); // ดึงข้อมูลกิจกรรมเมื่อเริ่มต้น
  }

  // ฟังก์ชันดึงข้อมูลสถานที่จากเซิร์ฟเวอร์
  Future<void> fetchLocations() async {
    final response = await http.get(Uri.parse(
        'http://10.0.2.2/flutter_webservice/get_ShowDataLocation.php'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        locations = List<String>.from(data
            .where((item) => item['status'] == 'approved')
            .map((item) => item['location_name'])
            .toSet()); // กรองสถานที่ที่ถูกอนุมัติและเก็บชื่อในรูปแบบของ Set เพื่อหลีกเลี่ยงการซ้ำ
      });
    } else {
      print(
          'Failed to load locations. Status code: ${response.statusCode}'); // พิมพ์ข้อผิดพลาดหากไม่สามารถโหลดข้อมูลได้
    }
  }

  // ฟังก์ชันดึงข้อมูลกีฬาตามสถานที่จากเซิร์ฟเวอร์
  Future<void> fetchSportByLocation(String locationName) async {
    final response = await http.get(Uri.parse(
        'http://10.0.2.2/flutter_webservice/get_ShowSportByLocation.php?location=$locationName'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        sport = List<String>.from(data
            .map((item) => item['sport_name'])
            .toSet()); // เก็บชื่อกีฬาในรูปแบบของ Set เพื่อหลีกเลี่ยงการซ้ำ
      });
    } else {
      print(
          'Failed to load sport names. Status code: ${response.statusCode}'); // พิมพ์ข้อผิดพลาดหากไม่สามารถโหลดข้อมูลได้
    }
  }

  // ฟังก์ชันดึงข้อมูลกิจกรรมจากเซิร์ฟเวอร์
  Future<void> fetchActivityDetails() async {
    final response = await http.get(
      Uri.parse(
          'http://10.0.2.2/flutter_webservice/get_ShowDataActivity.php?id=${widget.activityId}'), // ดึงข้อมูลกิจกรรมตาม ID
    );

    if (response.statusCode == 200) {
      final List<dynamic> activities = json.decode(response.body);
      final activity = activities.firstWhere((activity) =>
          activity['activity_id'] ==
          widget.activityId); // ค้นหากิจกรรมที่ตรงกับ ID ที่ระบุ

      setState(() {
        nameController.text =
            activity['activity_name']; // กำหนดค่าชื่อกิจกรรมในฟิลด์
        dateController.text =
            activity['activity_date']; // กำหนดค่าวันที่ในฟิลด์
        detailsController.text =
            activity['activity_details']; // กำหนดค่ารายละเอียดในฟิลด์

        locationData = [
          {
            'location_name': activity['location_name'],
            'location_id': activity['location_id'] ??
                0, // เพิ่มการตรวจสอบ location_id เป็น null
          }
        ];

        selectedLocation =
            activity['location_name']; // กำหนดค่าสถานที่ที่ถูกเลือก

        // ตรวจสอบ sport_name และ sport_id ว่าไม่ใช่ null ก่อนกำหนดค่า
        if (activity['sport_name'] != null && activity['sport_id'] != null) {
          sportMap = {
            activity['sport_name']: activity['sport_id']
          }; // เก็บชื่อกีฬาและ ID ในแผนที่
          selectedSport = activity['sport_name']; // กำหนดค่ากีฬาที่ถูกเลือก
        } else {
          sportMap = {};
          selectedSport = null; // หรือกำหนดค่าเริ่มต้น
        }

        _selectedTags.addAll((activity['hashtags'] as List<dynamic>?)
                ?.map((hashtag) => "${hashtag['hashtag_message']}")
                .toList() ??
            []); // เก็บแฮชแท็กที่เกี่ยวข้องกับกิจกรรม

        fetchSportByLocation(
            selectedLocation!); // ดึงข้อมูลกีฬาตามสถานที่ที่เลือก
      });
    } else {
      print(
          'Failed to load activity details'); // พิมพ์ข้อผิดพลาดหากไม่สามารถโหลดข้อมูลได้
    }
  }

  // ฟังก์ชันอัปเดตข้อมูลกิจกรรม
  Future<void> updateActivity() async {
    //ฟังก์ชันอัพเดทข้อมูลกิจกรรม
    print('ข้อมูล ไอดีกิจกรรม : ${widget.activityId}');
    print('ข้อมูล ชื่อกิจกรรม : ${nameController.text}');
    print('ข้อมูล ข้อความสังเขปกิจกรรม : ${detailsController.text}');
    print('ข้อมูล วันที่ : ${dateController.text}');
    print('ข้อมูล สถานที่ : ${selectedLocation}');
    print('ข้อมูล กีฬา : ${selectedSport}');
    print('ข้อมูล hashtag : ${_selectedTags}');

    final locationId =
        locationMap[selectedLocation ?? '']; // ดึง location_id จากแผนที่สถานที่
    final sportId = sportMap[selectedSport ?? '']; // ดึง sport_id จากแผนที่กีฬา

    print('ข้อมูล สถานที่แปลงแล้ว : ${locationId}');
    print('ข้อมูล กีฬาแปลงแล้ว : ${sportId}');

    if (locationId == null || sportId == null) {
      print(
          'เลือกสถานที่หรือกีฬาไม่ถูกต้อง'); // พิมพ์ข้อผิดพลาดหากเลือกสถานที่หรือกีฬาไม่ถูกต้อง
      return;
    }

    String hashtags =
        _selectedTags.join(" "); // รวมแฮชแท็กเป็นสตริงเดียวโดยมีช่องว่างคั่น
    List<String> hashtagList = hashtags
        .split(RegExp(r'\s+'))
        .where((tag) => tag.isNotEmpty)
        .toList(); // แยกแฮชแท็กจากช่องว่างและกรองแฮชแท็กที่ไม่ใช่ null

    Map<String, dynamic> dataPost = {
      "activity_id": widget.activityId,
      "activity_name": nameController.text,
      "activity_details": detailsController.text,
      "activity_date": dateController.text,
      "location_id": locationId,
      "sport_id": sportId,
      "hashtags": hashtagList,
    }; // จัดเตรียมข้อมูลที่จะส่งไปยังเซิร์ฟเวอร์

    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer ${widget.jwt}"
    }; // กำหนด headers สำหรับการส่งคำขอ

    var url = Uri.parse(
        "http://10.0.2.2/flutter_webservice/get_UpdateActivity.php"); // URL สำหรับอัปเดตข้อมูลกิจกรรม

    var response = await http.post(
      url,
      headers: headers, // ส่ง headers ไปพร้อมกับคำขอ
      body: json.encode(dataPost), // ส่งข้อมูลกิจกรรมที่ถูกแก้ไขไปพร้อมกับคำขอ
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      // แสดงป๊อปอัพเมื่ออัปเดตสำเร็จ
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("สำเร็จ"),
            content: Text("แก้ไขกิจกรรมสำเร็จ"),
            actions: <Widget>[
              TextButton(
                child: Text("ตกลง"),
                onPressed: () {
                  Navigator.of(context).pop(); // ปิดป๊อปอัพ
                  Navigator.of(context).pop(); // กลับไปหน้าก่อนหน้า
                },
              ),
            ],
          );
        },
      );
    } else {
      // แสดงป๊อปอัพเมื่ออัปเดตล้มเหลว
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("ล้มเหลว"),
            content: Text("การแก้ไขกิจกรรมล้มเหลว"),
            actions: <Widget>[
              TextButton(
                child: Text("ตกลง"),
                onPressed: () {
                  Navigator.of(context).pop(); // ปิดป๊อปอัพ
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('แก้ไขกิจกรรม'), // ชื่อหน้าจอแก้ไขกิจกรรม
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // กำหนดขนาด padding ของฟอร์ม
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildTextField(nameController, 'ชื่อกิจกรรม',
                  Icons.event), // ฟิลด์สำหรับกรอกชื่อกิจกรรม
              buildDropdownButtonFormField(
                selectedLocation, // ยังคงใช้ตัวแปรนี้สำหรับแสดงผลสถานที่ที่ถูกเลือก
                Map<String, int>.fromIterable(
                  locationData, // ใช้ locationData
                  key: (item) =>
                      item['location_name'] as String, // ใช้ชื่อสถานที่เป็น key
                  value: (item) =>
                      item['location_id'] as int, // ใช้ ID ของสถานที่เป็น value
                ),
                'สถานที่', // ป้ายกำกับฟิลด์
                Icons.location_on, // ไอคอนของฟิลด์
                (value) {
                  setState(() {
                    selectedLocation = value; // กำหนดค่าสถานที่ที่เลือก
                    fetchSportByLocation(
                        value!); // อัพเดตข้อมูลกีฬาตามสถานที่ที่เลือก
                  });
                },
              ),
              buildDropdownButtonFormField(
                selectedSport, // ยังคงใช้ตัวแปรนี้สำหรับแสดงผลกีฬาที่ถูกเลือก
                sportMap, // คาดว่าจะถูกอัพเดตหลังจากเลือกสถานที่
                'กีฬา', // ป้ายกำกับฟิลด์
                Icons.sports_soccer, // ไอคอนของฟิลด์
                (value) {
                  setState(() {
                    selectedSport = value; // กำหนดค่ากีฬาที่เลือก
                  });
                },
              ),
              buildTextField(detailsController, 'รายละเอียดกิจกรรม',
                  Icons.description), // ฟิลด์สำหรับกรอกรายละเอียดกิจกรรม
              buildDatePickerField(dateController, 'วันที่และเวลา',
                  Icons.calendar_today), // ฟิลด์สำหรับเลือกวันที่และเวลา
              buildTagPickerField(hashtagController, 'แฮชแท็ก',
                  Icons.tag), // ฟิลด์สำหรับกรอกแฮชแท็ก
              SizedBox(height: 20),
              ElevatedButton(
                onPressed:
                    updateActivity, // เรียกใช้ฟังก์ชัน updateActivity เมื่อกดปุ่ม
                child: Text('บันทึกการเปลี่ยนแปลง'), // ข้อความในปุ่ม
              ),
            ],
          ),
        ),
      ),
    );
  }

  // วิดเจ็ตสำหรับสร้างฟิลด์ข้อความ
  Widget buildTextField(
      TextEditingController controller, String labelText, IconData icon) {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0), // กำหนดขนาด margin ของฟิลด์
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          contentPadding:
              EdgeInsets.fromLTRB(0, 15, 0, 0), // กำหนดขนาด padding ภายในฟิลด์
          hintText: labelText, // ข้อความแนะนำในฟิลด์
          fillColor: Color.fromARGB(255, 255, 255, 255), // กำหนดสีพื้นหลังฟิลด์
          filled: true,
          prefixIcon: Icon(icon, color: Colors.red), // ไอคอนด้านหน้าฟิลด์
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black), // กำหนดสีของขอบฟิลด์
            borderRadius: BorderRadius.circular(30), // ปรับความโค้งของขอบฟิลด์
          ),
        ),
      ),
    );
  }

  // วิดเจ็ตสำหรับสร้างฟิลด์ DropdownButtonFormField
  Widget buildDropdownButtonFormField(
      String? selectedItem,
      Map<String, int> itemMap,
      String labelText,
      IconData icon,
      ValueChanged<String?> onChanged) {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0), // กำหนดขนาด margin ของฟิลด์
      child: DropdownButtonFormField<String>(
        value: selectedItem, // ค่าเริ่มต้นที่เลือก
        decoration: InputDecoration(
          contentPadding:
              EdgeInsets.fromLTRB(0, 15, 0, 0), // กำหนดขนาด padding ภายในฟิลด์
          hintText: labelText, // ข้อความแนะนำในฟิลด์
          fillColor: Color.fromARGB(255, 255, 255, 255), // กำหนดสีพื้นหลังฟิลด์
          filled: true,
          prefixIcon: Icon(icon, color: Colors.red), // ไอคอนด้านหน้าฟิลด์
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black), // กำหนดสีของขอบฟิลด์
            borderRadius: BorderRadius.circular(30), // ปรับความโค้งของขอบฟิลด์
          ),
        ),
        onChanged: onChanged, // ฟังก์ชันที่เรียกใช้เมื่อมีการเปลี่ยนแปลงค่า
        items: itemMap.keys
            .map((itemName) => DropdownMenuItem<String>(
                  value: itemName, // กำหนดค่าในแต่ละรายการ
                  child: Text(itemName), // ข้อความที่แสดงในรายการ
                ))
            .toList(),
      ),
    );
  }

  // วิดเจ็ตสำหรับสร้างฟิลด์เลือกวันที่และเวลา
  Widget buildDatePickerField(
      TextEditingController controller, String labelText, IconData icon) {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0), // กำหนดขนาด margin ของฟิลด์
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          contentPadding:
              EdgeInsets.fromLTRB(0, 15, 0, 0), // กำหนดขนาด padding ภายในฟิลด์
          hintText: labelText, // ข้อความแนะนำในฟิลด์
          fillColor: Color.fromARGB(255, 255, 255, 255), // กำหนดสีพื้นหลังฟิลด์
          filled: true,
          prefixIcon: Icon(icon, color: Colors.red), // ไอคอนด้านหน้าฟิลด์
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black), // กำหนดสีของขอบฟิลด์
            borderRadius: BorderRadius.circular(30), // ปรับความโค้งของขอบฟิลด์
          ),
        ),
        readOnly: true, // ปิดการแก้ไขฟิลด์โดยตรง
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
          );

          if (pickedDate != null) {
            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );

            if (pickedTime != null) {
              DateTime finalDateTime = DateTime(
                pickedDate.year,
                pickedDate.month,
                pickedDate.day,
                pickedTime.hour,
                pickedTime.minute,
              );

              setState(() {
                controller.text = finalDateTime
                    .toString(); // กำหนดค่าวันที่และเวลาที่ถูกเลือกในฟิลด์
              });
            }
          }
        },
      ),
    );
  }

  // วิดเจ็ตสำหรับสร้างฟิลด์แฮชแท็ก
  Widget buildTagPickerField(
      TextEditingController controller, String labelText, IconData icon) {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0), // กำหนดขนาด margin ของฟิลด์
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8.0, // กำหนดระยะห่างระหว่างแฮชแท็ก
            children: _selectedTags
                .map((tag) => Chip(
                      label: Text(tag), // ข้อความในแฮชแท็ก
                      onDeleted: () {
                        setState(() {
                          _selectedTags.remove(tag); // ลบแฮชแท็กที่ถูกเลือกออก
                        });
                      },
                    ))
                .toList(),
          ),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(
                  0, 15, 0, 0), // กำหนดขนาด padding ภายในฟิลด์
              hintText: labelText, // ข้อความแนะนำในฟิลด์
              fillColor:
                  Color.fromARGB(255, 255, 255, 255), // กำหนดสีพื้นหลังฟิลด์
              filled: true,
              prefixIcon: Icon(icon, color: Colors.red), // ไอคอนด้านหน้าฟิลด์
              border: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Colors.black), // กำหนดสีของขอบฟิลด์
                borderRadius:
                    BorderRadius.circular(30), // ปรับความโค้งของขอบฟิลด์
              ),
            ),
            onFieldSubmitted: (value) {
              if (value.isNotEmpty && !_selectedTags.contains(value)) {
                setState(() {
                  _selectedTags.add(value); // เพิ่มแฮชแท็กใหม่ลงในรายการ
                  controller.clear(); // ล้างฟิลด์แฮชแท็กหลังจากเพิ่ม
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
