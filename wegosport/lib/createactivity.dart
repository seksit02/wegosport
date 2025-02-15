import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_typeahead/flutter_typeahead.dart'; // ใช้สำหรับแสดงรายการที่แนะนำ
import 'package:flutter_material_pickers/flutter_material_pickers.dart'; // ใช้สำหรับการเลือกแบบรายการ
import 'dart:async';
import 'dart:convert';
import 'package:wegosport/Homepage.dart';

// หน้าจอสร้างกิจกรรม
class CreateActivityPage extends StatefulWidget {
  const CreateActivityPage({Key? key, required this.jwt}) : super(key: key);

  final String jwt; // รับค่า JWT สำหรับการตรวจสอบสิทธิ์

  @override
  State<CreateActivityPage> createState() =>
      _CreateActivityPageState(); // สร้างสถานะของ CreateActivityPage
}

class _CreateActivityPageState extends State<CreateActivityPage> {
  TextEditingController nameController =
      TextEditingController(); // ตัวควบคุมสำหรับชื่อกิจกรรม
  TextEditingController detailsController =
      TextEditingController(); // ตัวควบคุมสำหรับรายละเอียดกิจกรรม
  TextEditingController dateController =
      TextEditingController(); // ตัวควบคุมสำหรับวันที่และเวลา
  TextEditingController hashtagController =
      TextEditingController(); // ตัวควบคุมสำหรับแฮชแท็ก
  TextEditingController locationController =
      TextEditingController(); // ตัวควบคุมสำหรับสถานที่
  TextEditingController sportController =
      TextEditingController(); // ตัวควบคุมสำหรับกีฬา
  Map<String, dynamic>? userData; // เก็บข้อมูลผู้ใช้
  final List<String> _selectedTags = []; // เก็บแฮชแท็กที่เลือก
  List<String> _allHashtags = []; // เก็บแฮชแท็กทั้งหมด
  String? selectedLocation; // สถานที่ที่เลือก
  String? selectedSport; // กีฬาที่เลือก
  List<String> locations = []; // เก็บสถานที่ทั้งหมด
  List<String> sport = []; // เก็บกีฬาทั้งหมด
  List<Map<String, dynamic>> locationData =
      []; // เก็บข้อมูลทั้งหมดของสถานที่และกีฬา
  get selectedSportId => 1; // ID ของกีฬาที่เลือก (แก้ไขตามความเหมาะสม)
  List<String> availableDays = [];
  String? locationTime;

  @override
  void initState() {
    super.initState();
    fetchLocations(); // ดึงข้อมูลสถานที่เมื่อเริ่มต้น
    fetchHashtags(); // ดึงข้อมูลแฮชแท็กเมื่อเริ่มต้น
    fetchUserData(widget.jwt); // ดึงข้อมูลผู้ใช้เมื่อเริ่มต้น
  }

  void _showTagPicker(BuildContext context) {
    showMaterialCheckboxPicker(
      context: context,
      title: 'เลือกแฮชแท็ก', // แสดงชื่อของ picker
      items: [
        'กีฬา',
        'ฟิตเนส',
        'สุขภาพ',
        'วิ่ง',
        'ว่ายน้ำ'
      ], // รายการแฮชแท็กที่สามารถเลือกได้
      selectedItems: _selectedTags, // แสดงแฮชแท็กที่ถูกเลือกแล้ว
      onChanged: (List<String> value) {
        setState(() {
          _selectedTags.clear();
          _selectedTags.addAll(value); // อัพเดทแฮชแท็กที่เลือก
        });
      },
    );
  }

  // ฟังก์ชันดึงข้อมูลสถานที่จากเซิร์ฟเวอร์
  Future<void> fetchLocations() async {
    final response = await http.get(Uri.parse(
        'http://10.0.2.2/flutter_webservice/get_ShowDataLocation.php')); // เรียก API ดึงข้อมูลสถานที่

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      print('DataCreat :$data'); // พิมพ์ข้อมูลสถานที่เพื่อการตรวจสอบ

      setState(() {
        locationData = List<Map<String, dynamic>>.from(data.where((item) =>
            item['status'] == 'approved')); // กรองสถานที่ที่ถูกอนุมัติเท่านั้น
        locations = locationData
            .map((item) => item['location_name'].toString())
            .toList(); // เก็บชื่อสถานที่ในรูปแบบของ List
      });
    } else {
      print(
          'Failed to load locations. Status code: ${response.statusCode}'); // พิมพ์ข้อผิดพลาดหากไม่สามารถโหลดข้อมูลได้
      throw Exception('Failed to load locations');
    }
  }

  // ฟังก์ชันกรองกีฬาเมื่อเลือกสถานที่
  void updateSportsForLocation(String locationName) {
    // ดึงข้อมูลสถานที่ที่เลือกจาก locationData
    final selectedLocation = locationData.firstWhere(
      (location) => location['location_name'] == locationName,
      orElse: () => {},
    );

    setState(() {
      // ถ้าสถานที่ถูกต้องและมี sport_types ให้ดึง sport_name ออกมา
      if (selectedLocation.isNotEmpty &&
          selectedLocation['sport_types'] != null) {
        sport = selectedLocation['sport_types']
            .expand((type) =>
                type['sports'] as List) // ดึงรายการกีฬาออกมาจากแต่ละประเภท
            .map<String>((sport) =>
                sport['sport_name'].toString()) // ทำให้แน่ใจว่าเป็น String
            .toList();

        // เก็บข้อมูล location_day และ location_time
        availableDays = selectedLocation['location_day'].split(',');
        locationTime = selectedLocation['location_time'];
      } else {
        sport = [];
        availableDays = [];  
        locationTime = null;
      }
    });
  }

  // ฟังก์ชันดึงข้อมูลแฮชแท็กจากเซิร์ฟเวอร์
  Future<void> fetchHashtags() async {
    final response = await http.get(Uri.parse(
        'http://10.0.2.2/flutter_webservice/get_ShowDataHashtag.php')); // ใช้ API ดึงแฮชแท็ก + จำนวนการใช้

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _allHashtags = data.map<String>((item) {
          String hashtag = item['hashtag_message'];
          String count = '${item['usage_count']} กิจกรรม';
          return '$hashtag|$count'; // ใช้ `|` เป็นตัวแบ่งข้อมูล
        }).toList();
      });
    } else {
      print('Failed to load hashtags. Status code: ${response.statusCode}');
      throw Exception('Failed to load hashtags');
    }
  }

  // ฟังก์ชันดึงข้อมูลผู้ใช้จากเซิร์ฟเวอร์
  Future<void> fetchUserData(String jwt) async {
    var url = Uri.parse(
        'http://10.0.2.2/flutter_webservice/get_ShowDataUser.php'); // เรียก API ดึงข้อมูลผู้ใช้

    Map<String, String> headers = {
      'Authorization':
          'Bearer $jwt', // เพิ่ม JWT ใน headers เพื่อการตรวจสอบสิทธิ์
    };

    print('Headers: $headers'); // พิมพ์ headers เพื่อการตรวจสอบ

    try {
      var response = await http.post(
        url,
        headers: headers,
      );

      print(
          'Response status: ${response.statusCode}'); // พิมพ์สถานะการตอบกลับของเซิร์ฟเวอร์
      print(
          'Response body: ${response.body}'); // พิมพ์ข้อมูลที่ได้รับจากเซิร์ฟเวอร์

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List<dynamic> &&
            data.isNotEmpty &&
            data[0] is Map<String, dynamic> &&
            data[0].containsKey('user_id')) {
          setState(() {
            userData = data[0]; // เก็บข้อมูลผู้ใช้ในตัวแปร userData
          });
          print('User data: $userData');
        } else {
          print("No user data found");
          throw Exception('Failed to load user data');
        }
      } else {
        print(
            "Failed to load user data: ${response.body}"); // พิมพ์ข้อผิดพลาดหากไม่สามารถโหลดข้อมูลได้
        throw Exception('Failed to load user data');
      }
    } catch (error) {
      print("Error: $error"); // พิมพ์ข้อผิดพลาดหากมีการ exception เกิดขึ้น
      throw Exception('Failed to load user data');
    }
  }

  // วิดเจ็ตฟิลด์ชื่อกิจกรรม
  Widget nameActivity() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0), // กำหนด margin รอบฟิลด์
      child: TextFormField(
        controller: nameController,
        decoration: InputDecoration(
          contentPadding:
              EdgeInsets.fromLTRB(0, 15, 0, 0), // กำหนด padding ภายในฟิลด์
          hintText: 'เพิ่มชื่อกิจกรรม', // ข้อความแนะนำในฟิลด์
          fillColor: Color.fromARGB(255, 255, 255, 255), // สีพื้นหลังของฟิลด์
          filled: true,
          prefixIcon: Padding(
            padding: const EdgeInsets.all(15.0), // เพิ่ม padding ให้ตัวอักษร
            child: Text(
              'A',
              style: TextStyle(
                color: Colors.red, // กำหนดสีของตัวอักษร
                fontSize: 18.0, // ขนาดตัวอักษร
                fontWeight: FontWeight.bold, // ทำให้ตัวอักษรหนา
              ),
            ),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black), // กำหนดสีของขอบฟิลด์
            borderRadius: BorderRadius.circular(30), // ปรับความโค้งของขอบฟิลด์
          ),
        ),
      ),
    );
  }

  // วิดเจ็ตฟิลด์เลือกสถานที่
  Widget location() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0), // กำหนด margin รอบฟิลด์
      child: TypeAheadFormField(
        textFieldConfiguration: TextFieldConfiguration(
          controller: locationController,
          decoration: InputDecoration(
            contentPadding:
                EdgeInsets.fromLTRB(0, 15, 0, 0), // กำหนด padding ภายในฟิลด์
            hintText: 'เพิ่มสถานที่', // ข้อความแนะนำในฟิลด์
            hintStyle:
                TextStyle(fontFamily: 'THSarabunNew'), // กำหนดสไตล์ข้อความ
            fillColor: Color.fromARGB(255, 255, 255, 255), // สีพื้นหลังของฟิลด์
            filled: true,
            prefixIcon: Icon(
              Icons.location_on, // ไอคอนสถานที่
              color: Colors.red, // กำหนดสีของไอคอน
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black), // กำหนดสีของขอบฟิลด์
              borderRadius:
                  BorderRadius.circular(30), // ปรับความโค้งของขอบฟิลด์
            ),
          ),
          style: TextStyle(fontFamily: 'THSarabunNew'), // กำหนดสไตล์ข้อความ
        ),
        suggestionsCallback: (pattern) {
          return locations.where((location) => location
              .toLowerCase()
              .contains(pattern.toLowerCase())); // กรองรายการตามคำค้นหา
        },
        itemBuilder: (context, suggestion) {
          return ListTile(
            title: Text(suggestion,
                style: TextStyle(
                    fontFamily: 'THSarabunNew')), // แสดงรายการที่แนะนำ
          );
        },
        onSuggestionSelected: (suggestion) {
          setState(() {
            locationController.text =
                suggestion; // อัพเดทข้อความในฟิลด์เมื่อเลือกสถานที่
            selectedLocation = suggestion;
            updateSportsForLocation(
                suggestion); // อัพเดทข้อมูลกีฬาตามสถานที่ที่เลือก
          });
        },
        noItemsFoundBuilder: (context) {
          return Padding(
            padding: EdgeInsets.all(8.0), // เพิ่ม padding รอบข้อความ
            child: Text(
              'ไม่พบสถานที่', // ข้อความที่จะแสดงเมื่อไม่มีสถานที่ที่พบ
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey, // กำหนดสีของข้อความ
                fontSize: 18.0, // ขนาดของข้อความ
                fontFamily: 'THSarabunNew', // กำหนดฟอนต์
              ),
            ),
          );
        },
      ),
    );
  }

  // วิดเจ็ตฟิลด์กีฬา
  Widget field_name() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0), // กำหนด margin รอบฟิลด์
      child: TypeAheadFormField(
        textFieldConfiguration: TextFieldConfiguration(
          controller: sportController,
          decoration: InputDecoration(
            contentPadding:
                EdgeInsets.fromLTRB(0, 15, 0, 0), // กำหนด padding ภายในฟิลด์
            hintText: 'เพิ่มกีฬา', // ข้อความแนะนำในฟิลด์
            hintStyle:
                TextStyle(fontFamily: 'THSarabunNew'), // กำหนดสไตล์ข้อความ
            fillColor: Color.fromARGB(255, 255, 255, 255), // สีพื้นหลังของฟิลด์
            filled: true,
            prefixIcon: Icon(
              Icons.sports_soccer, // ไอคอนกีฬาที่จะใช้
              color: Colors.red, // กำหนดสีของไอคอน
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black), // กำหนดสีของขอบฟิลด์
              borderRadius:
                  BorderRadius.circular(30), // ปรับความโค้งของขอบฟิลด์
            ),
          ),
          style: TextStyle(fontFamily: 'THSarabunNew'), // กำหนดสไตล์ข้อความ
        ),
        suggestionsCallback: (pattern) {
          return sport.where((sport) => sport
              .toLowerCase()
              .contains(pattern.toLowerCase())); // กรองรายการตามคำค้นหา
        },
        itemBuilder: (context, suggestion) {
          return ListTile(
            title: Text(suggestion,
                style: TextStyle(
                    fontFamily: 'THSarabunNew')), // แสดงรายการที่แนะนำ
          );
        },
        onSuggestionSelected: (suggestion) {
          setState(() {
            sportController.text =
                suggestion; // อัพเดทข้อความในฟิลด์เมื่อเลือกกีฬา
            selectedSport = suggestion;
          });
        },
        noItemsFoundBuilder: (context) {
          return Padding(
            padding: EdgeInsets.all(8.0), // เพิ่ม padding รอบข้อความ
            child: Text(
              'ไม่พบกีฬา', // ข้อความที่จะแสดงเมื่อไม่พบกีฬา
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey, // กำหนดสีของข้อความ
                fontSize: 18.0, // ขนาดของข้อความ
                fontFamily: 'THSarabunNew', // กำหนดฟอนต์
              ),
            ),
          );
        },
      ),
    );
  }

  Widget date() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
      child: TextFormField(
        controller: dateController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
          hintText: 'เพิ่มวันที่และเวลา',
          fillColor: Color.fromARGB(255, 255, 255, 255),
          filled: true,
          prefixIcon: Icon(
            Icons.calendar_today,
            color: Colors.red,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        readOnly: true,
        onTap: () async {
          if (locationTime == null) {
            // แสดงข้อความแจ้งเตือนถ้ายังไม่ได้เลือกสถานที่
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('ข้อผิดพลาด'),
                  content: Text('กรุณาเลือกสถานที่ก่อนที่จะเลือกวันที่และเวลา'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('ตกลง'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
            return; // หยุดการทำงานถ้ายังไม่ได้เลือกสถานที่
          }

          DateTime now = DateTime.now();

          // กำหนดวันใน location_day ที่ให้เลือกได้เท่านั้น
          List<int> allowedDays =
              availableDays.map((day) => int.parse(day)).toList();

          // หา initialDate ที่ตรงกับวันแรกที่เลือกได้จาก availableDays
          DateTime initialDate = now;
          bool foundInitialDate = false;
          for (int day in allowedDays) {
            if (day >= now.weekday) {
              initialDate = now.add(Duration(days: day - now.weekday));
              foundInitialDate = true;
              break;
            }
          }

          // ถ้าไม่มีวันที่ตรงในสัปดาห์ปัจจุบัน ให้เลือกวันแรกในสัปดาห์ถัดไป
          if (!foundInitialDate) {
            initialDate =
                now.add(Duration(days: 7 - now.weekday + allowedDays.first));
          }

          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: initialDate,
            firstDate: now,
            lastDate: DateTime(2101),
            selectableDayPredicate: (DateTime date) {
              // อนุญาตให้เลือกวันที่ปัจจุบันถ้าเวลายังไม่เลยเวลาปิด
              if (date.day == now.day &&
                  date.month == now.month &&
                  date.year == now.year) {
                if (locationTime != null) {
                  List<String> timeRange = locationTime!.split(' - ');
                  int endHour = int.parse(timeRange[1].split(':')[0]);
                  int endMinute = int.parse(timeRange[1].split(':')[1]);

                  if (now.hour < endHour ||
                      (now.hour == endHour && now.minute < endMinute)) {
                    return true;
                  }
                }
              }
              return allowedDays.contains(date.weekday);
            },
          );

          if (pickedDate != null) {
            // แสดงเวลาที่อนุญาตตาม location_time
            if (locationTime != null) {
              List<String> timeRange = locationTime!.split(' - ');
              int startHour = int.parse(timeRange[0].split(':')[0]);
              int startMinute = int.parse(timeRange[0].split(':')[1]);
              int endHour = int.parse(timeRange[1].split(':')[0]);
              int endMinute = int.parse(timeRange[1].split(':')[1]);

              // ถ้าเลือกวันที่เป็นวันนี้ ให้ล็อกเวลาเริ่มต้นเป็นเวลาปัจจุบัน
              TimeOfDay initialTime;
              if (pickedDate.day == now.day &&
                  pickedDate.month == now.month &&
                  pickedDate.year == now.year) {
                // ตรวจสอบว่าเวลาปัจจุบันยังอยู่ในช่วงเวลาที่อนุญาต
                if (now.hour > endHour ||
                    (now.hour == endHour && now.minute > endMinute)) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('ข้อผิดพลาด'),
                        content: Text(
                            'เวลาปัจจุบันเกินเวลาที่อนุญาตในสถานที่นี้แล้ว'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('ตกลง'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }
                initialTime = TimeOfDay(hour: now.hour, minute: now.minute);
              } else {
                initialTime = TimeOfDay(hour: startHour, minute: startMinute);
              }

              TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: initialTime,
                builder: (context, child) {
                  return MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      alwaysUse24HourFormat: true,
                    ),
                    child: child!,
                  );
                },
              );

              if (pickedTime != null) {
                DateTime finalDateTime = DateTime(
                  pickedDate.year,
                  pickedDate.month,
                  pickedDate.day,
                  pickedTime.hour,
                  pickedTime.minute,
                );

                // ตรวจสอบว่าเวลาที่เลือกอยู่ในช่วงเวลาที่กำหนด
                if (pickedTime.hour >= startHour &&
                    pickedTime.minute >= startMinute &&
                    (pickedTime.hour < endHour ||
                        (pickedTime.hour == endHour &&
                            pickedTime.minute <= endMinute))) {
                  setState(() {
                    dateController.text = finalDateTime.toString();
                  });
                } else {
                  // แสดงการแจ้งเตือนถ้าเวลาที่เลือกไม่อยู่ในช่วงที่กำหนด
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('ข้อผิดพลาด'),
                        content: Text('กรุณาเลือกเวลาที่อยู่ในช่วงที่กำหนด'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('ตกลง'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              }
            }
          }
        },
      ),
    );
  }

  // วิดเจ็ตฟิลด์แฮชแท็ก
  Widget hashtag() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8.0,
            children: _selectedTags
                .map((tag) => Chip(
                      label: Text(tag), // แสดงเฉพาะชื่อแฮชแท็ก
                      onDeleted: () {
                        setState(() {
                          _selectedTags.remove(tag);
                        });
                      },
                    ))
                .toList(),
          ),
          TypeAheadFormField<String>(
            textFieldConfiguration: TextFieldConfiguration(
              controller: hashtagController,
              decoration: InputDecoration(
                hintText: 'เพิ่มแฮชแท็กที่ต้องการ',
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: TextButton(
                    onPressed: () {
                      String newTag = hashtagController.text.trim();
                      if (newTag.isNotEmpty &&
                          newTag.length <= 20 &&
                          _selectedTags.length < 3 &&
                          !_selectedTags.contains(newTag) &&
                          !_selectedTags.contains('#$newTag')) {
                        setState(() {
                          if (!newTag.startsWith('#')) {
                            newTag = '#$newTag';
                          }
                          _selectedTags.add(newTag);
                          hashtagController.clear();
                        });
                      }
                    },
                    child: Text('เพิ่ม'),
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            suggestionsCallback: (pattern) {
              return _allHashtags
                  .where((hashtag) =>
                      hashtag.toLowerCase().contains(pattern.toLowerCase()))
                  .toList();
            },
            itemBuilder: (context, suggestion) {
              List<String> parts = suggestion.split('|'); // แยกแฮชแท็กกับจำนวน
              String hashtag = parts[0].trim();
              String count = parts.length > 1 ? parts[1].trim() : '';

              return ListTile(
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        hashtag,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Text(
                      count,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.right, // จัดให้จำนวนกิจกรรมชิดขวา
                    ),
                  ],
                ),
              );
            },
            onSuggestionSelected: (suggestion) {
              List<String> parts = suggestion.split('|'); // แยกแฮชแท็กกับจำนวน
              String selectedTag = parts[0].trim(); // เอาเฉพาะชื่อแฮชแท็ก

              if (_selectedTags.length < 3 &&
                  !_selectedTags.contains(selectedTag) &&
                  !_selectedTags.contains('#$selectedTag')) {
                setState(() {
                  if (!selectedTag.startsWith('#')) {
                    selectedTag = '#$selectedTag';
                  }
                  _selectedTags.add(selectedTag); // เพิ่มเฉพาะชื่อแฮชแท็ก
                  hashtagController.clear();
                });
              }
            },
            noItemsFoundBuilder: (context) {
              return Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'ไม่พบแฮชแท็ก',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18.0,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // วิดเจ็ตฟิลด์รายละเอียดกิจกรรม
  Widget message() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0), // กำหนด margin รอบฟิลด์
      child: TextFormField(
        controller: detailsController,
        decoration: InputDecoration(
          contentPadding:
              EdgeInsets.fromLTRB(0, 15, 0, 0), // กำหนด padding ภายในฟิลด์
          hintText: 'เพิ่มรายละเอียดกิจกรรม', // ข้อความแนะนำในฟิลด์
          fillColor: Color.fromARGB(255, 255, 255, 255), // สีพื้นหลังของฟิลด์
          filled: true,
          prefixIcon: Container(
            margin: EdgeInsets.all(11), // จัดการระยะขอบให้เหมาะสม
            child: Text(
              'ABC', // ตัวอักษรที่ต้องการใช้
              style: TextStyle(
                color: Colors.red, // กำหนดสีของตัวอักษร
                fontSize: 20, // ขนาดของตัวอักษร
                fontWeight: FontWeight.bold, // ทำให้ตัวอักษรหนา
              ),
            ),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black), // กำหนดสีของขอบฟิลด์
            borderRadius: BorderRadius.circular(30), // ปรับความโค้งของขอบฟิลด์
          ),
        ),
      ),
    );
  }

  // วิดเจ็ตปุ่มสร้างกิจกรรม
  Widget createGroupButton() {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 20, 10, 0), // กำหนด margin รอบปุ่ม
      child: SizedBox(
        width: 200, // กำหนดความกว้างของปุ่มตามที่ต้องการ
        child: ElevatedButton(
          child: Text(
            "สร้างกิจกรรม", // ข้อความบนปุ่ม
            style: TextStyle(
              color: Colors.white, // กำหนดสีของข้อความบนปุ่ม
            ),
          ),
          style: ElevatedButton.styleFrom(
            padding:
                EdgeInsets.fromLTRB(20, 10, 20, 10), // กำหนด padding ภายในปุ่ม
            backgroundColor:
                Color.fromARGB(249, 255, 4, 4), // กำหนดสีพื้นหลังของปุ่ม
            shadowColor:
                Color.fromARGB(255, 255, 255, 255), // กำหนดสีเงาของปุ่ม
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30), // ปรับความโค้งของขอบปุ่ม
              side: BorderSide(color: Colors.black), // กำหนดสีของขอบปุ่ม
            ),
          ),
          onPressed: () {
            functionCreateActivity(); // เรียกใช้ฟังก์ชันเมื่อกดปุ่ม
          },
        ),
      ),
    );
  }

  // ฟังก์ชันสร้างกิจกรรม
  Future<void> functionCreateActivity() async {
    String activityName = nameController.text.trim();
    String locationName = selectedLocation ?? '';
    String sportName = selectedSport ?? '';
    String activityDate = dateController.text.trim();

    // ตรวจสอบว่ากรอกข้อมูลครบทุกช่องหรือไม่
    if (activityName.isEmpty ||
        locationName.isEmpty ||
        sportName.isEmpty ||
        activityDate.isEmpty) {
      // แสดงการแจ้งเตือนถ้าข้อมูลไม่ครบ
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('ข้อผิดพลาด'),
            content: Text('กรุณากรอกข้อมูลให้ครบถ้วน'),
            actions: <Widget>[
              TextButton(
                child: Text('ตกลง'),
                onPressed: () {
                  Navigator.of(context).pop(); // ปิด dialog
                },
              ),
            ],
          );
        },
      );
      return; // ออกจากฟังก์ชันถ้าข้อมูลไม่ครบ
    }

    String hashtags =
        _selectedTags.join(" "); // รวมแฮชแท็กทั้งหมดเป็นสตริงเดียว
    List<String> hashtagList = hashtags
        .split(RegExp(r'\s+'))
        .where((tag) => tag.isNotEmpty)
        .toList(); // แยกแฮชแท็กเป็นรายการ

    if (hashtagList.length > 3 || hashtagList.any((tag) => tag.length > 20)) {
      print("Invalid hashtag input"); // ตรวจสอบความถูกต้องของแฮชแท็ก
      return;
    }

    print("activity_name: $activityName"); // พิมพ์ชื่อกิจกรรมเพื่อการตรวจสอบ
    print(
        "activity_details: ${detailsController.text}"); // พิมพ์รายละเอียดกิจกรรมเพื่อการตรวจสอบ
    print("activity_date: $activityDate"); // พิมพ์วันที่และเวลาเพื่อการตรวจสอบ
    print("location_name: $locationName"); // พิมพ์สถานที่เพื่อการตรวจสอบ
    print("sport_id: $selectedSportId"); // พิมพ์ ID ของกีฬาเพื่อการตรวจสอบ
    print("hashtags: $hashtagList"); // พิมพ์แฮชแท็กเพื่อการตรวจสอบ
    print("user_id: ${userData!['user_id']}"); // พิมพ์ user_id เพื่อการตรวจสอบ

    String userId = userData!['user_id']; // เก็บ user_id ของผู้ใช้

    // เพิ่ม user_id ในการส่งข้อมูล
    Map<String, dynamic> dataPost = {
      "activity_name": activityName,
      "activity_details": detailsController.text,
      "activity_date": activityDate,
      "location_name": locationName,
      "sport_id": selectedSportId,
      "hashtags": hashtagList,
      "user_id": userId, // ส่ง user_id ของผู้สร้างกิจกรรมไปด้วย
      "status": "active"
    };

    Map<String, String> headers = {
      "Content-Type": "application/json", // กำหนดประเภทของเนื้อหาที่จะส่ง
      "Accept": "application/json", // กำหนดประเภทของเนื้อหาที่จะรับ
      "Authorization":
          "Bearer ${widget.jwt}" // เพิ่ม JWT ใน headers เพื่อการตรวจสอบสิทธิ์
    };

    var url = Uri.parse(
        "http://10.0.2.2/flutter_webservice/get_CreateActivity.php"); // เรียก API สำหรับสร้างกิจกรรม

    try {
      var response = await http.post(
        url,
        headers: headers,
        body: json.encode(dataPost), // แปลงข้อมูลเป็น JSON ก่อนส่ง
      );

      print(
          'Response status: ${response.statusCode}'); // พิมพ์สถานะการตอบกลับของเซิร์ฟเวอร์
      print(
          'Response body: ${response.body}'); // พิมพ์ข้อมูลที่ได้รับจากเซิร์ฟเวอร์

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);

        print(jsonResponse); // พิมพ์ข้อมูลตอบกลับเพื่อการตรวจสอบ

        if (jsonResponse["result"] == 1) {
          showSuccessDialog(); // แสดง dialog เมื่อสร้างกิจกรรมสำเร็จ
        }
      } else {
        print(
            "Request failed with status: ${response.statusCode}"); // พิมพ์ข้อผิดพลาดหากไม่สามารถส่งคำขอได้
      }
    } catch (error) {
      print("Error: $error"); // พิมพ์ข้อผิดพลาดหากมีการ exception เกิดขึ้น
    }
  }

  // ฟังก์ชันแสดง dialog เมื่อสร้างกิจกรรมสำเร็จ
  Future<void> showSuccessDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("สำเร็จ"), // ชื่อของ dialog
          content: Text("สร้างกิจกรรมสำเร็จ"), // ข้อความใน dialog
          actions: <Widget>[
            TextButton(
              child: Text("ตกลง"), // ข้อความบนปุ่ม
              onPressed: () {
                Navigator.of(context).pop(); // ปิด dialog
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (context) =>
                          Homepage(jwt: widget.jwt)), // กลับไปยังหน้า Homepage
                );
              },
            ),
          ],
        );
      },
    );
  }

  // วิดเจ็ตปุ่มกลับไปหน้าหลัก
  Widget backButton() {
    return IconButton(
      icon: Icon(Icons.arrow_back,
          color: const Color.fromARGB(255, 255, 255, 255)), // กำหนดสีของไอคอน
      onPressed: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) =>
                  Homepage(jwt: widget.jwt)), // กลับไปยังหน้า Homepage
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Stack(
        children: [
          Scaffold(
            backgroundColor:
                Color.fromARGB(255, 255, 255, 255), // สีพื้นหลังของหน้า
            appBar: AppBar(
              title: Text(
                "หน้าสร้างกิจกรรม", // ชื่อของหน้าจอ
                style: TextStyle(
                    color: const Color.fromARGB(
                        255, 255, 255, 255)), // กำหนดสีของข้อความ
              ),
              leading: backButton(), // แสดงปุ่มกลับ
              backgroundColor: Color.fromARGB(
                  255, 255, 0, 0), // กำหนดสีพื้นหลังของแถบ AppBar
            ),
            body: SafeArea(
              child: ListView(
                children: [
                  Center(
                      child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [])), // แสดงข้อความหรือรูปภาพเพิ่มเติม
                  nameActivity(), // แสดงฟิลด์ชื่อกิจกรรม
                  location(), // แสดงฟิลด์สถานที่
                  field_name(), // แสดงฟิลด์กีฬา
                  date(), // แสดงฟิลด์วันที่และเวลา
                  hashtag(), // แสดงฟิลด์แฮชแท็ก
                  message(), // แสดงฟิลด์รายละเอียดกิจกรรม
                  createGroupButton() // แสดงปุ่มสร้างกิจกรรม
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
