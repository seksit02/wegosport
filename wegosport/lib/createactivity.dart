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
  State<CreateActivityPage> createState() => _CreateActivityPageState();
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

  @override
  void initState() {
    super.initState();
    fetchLocations();
    fetchHashtags();
    fetchUserData(widget.jwt);
  }
  
  void _showTagPicker(BuildContext context) {
    showMaterialCheckboxPicker(
      context: context,
      title: 'เลือกแฮชแท็ก',
      items: ['กีฬา', 'ฟิตเนส', 'สุขภาพ', 'วิ่ง', 'ว่ายน้ำ'],
      selectedItems: _selectedTags,
      onChanged: (List<String> value) {
        setState(() {
          _selectedTags.clear();
          _selectedTags.addAll(value);
        });
      },
    );
  }

  // ฟังก์ชันดึงข้อมูลสถานที่จากเซิร์ฟเวอร์
  Future<void> fetchLocations() async {
    final response = await http.get(Uri.parse(
        'http://10.0.2.2/flutter_webservice/get_ShowDataLocation.php'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      print('DataCreat :$data');

      setState(() {
        locationData = List<Map<String, dynamic>>.from(
            data.where((item) => item['status'] == 'approved'));
        locations = locationData
            .map((item) => item['location_name'].toString())
            .toList();
      });
    } else {
      print('Failed to load locations. Status code: ${response.statusCode}');
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
      } else {
        sport = []; // ถ้าไม่มีข้อมูลกีฬาก็เคลียร์รายการกีฬา
      }
    });
  }

  // ฟังก์ชันดึงข้อมูลแฮชแท็กจากเซิร์ฟเวอร์
  Future<void> fetchHashtags() async {
    final response = await http.get(Uri.parse(
        'http://10.0.2.2/flutter_webservice/get_ShowDataHashtag.php'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _allHashtags = List<String>.from(data
            .map((item) => item['hashtag_message'])
            .where((item) => item != null)
            .toSet());
      });
    } else {
      print('Failed to load hashtags. Status code: ${response.statusCode}');
      throw Exception('Failed to load hashtags');
    }
  }

  // ฟังก์ชันดึงข้อมูลผู้ใช้จากเซิร์ฟเวอร์
  Future<void> fetchUserData(String jwt) async {
    var url =
        Uri.parse('http://10.0.2.2/flutter_webservice/get_ShowDataUser.php');

    Map<String, String> headers = {
      'Authorization': 'Bearer $jwt',
    };

    print('Headers: $headers'); // พิมพ์ headers เพื่อการตรวจสอบ

    try {
      var response = await http.post(
        url,
        headers: headers,
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List<dynamic> &&
            data.isNotEmpty &&
            data[0] is Map<String, dynamic> &&
            data[0].containsKey('user_id')) {
          setState(() {
            userData = data[0];
          });
          print('User data: $userData');
        } else {
          print("No user data found");
          throw Exception('Failed to load user data');
        }
      } else {
        print("Failed to load user data: ${response.body}");
        throw Exception('Failed to load user data');
      }
    } catch (error) {
      print("Error: $error");
      throw Exception('Failed to load user data');
    }
  }

  // วิดเจ็ตฟิลด์ชื่อกิจกรรม
  Widget nameActivity() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
      child: TextFormField(
        controller: nameController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
          hintText: 'เพิ่มชื่อกิจกรรม',
          fillColor: Color.fromARGB(255, 255, 255, 255),
          filled: true,
          prefixIcon: Padding(
            padding: const EdgeInsets.all(15.0), // เพิ่ม padding ให้ตัวอักษร
            child: Text(
              'A',
              style: TextStyle(
                color: Colors.red,
                fontSize: 18.0, // ขนาดตัวอักษร
                fontWeight: FontWeight.bold, // ทำให้ตัวอักษรหนา
              ),
            ),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  // วิดเจ็ตฟิลด์เลือกสถานที่
  Widget location() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
      child: TypeAheadFormField(
        textFieldConfiguration: TextFieldConfiguration(
          controller: locationController,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
            hintText: 'เพิ่มสถานที่',
            hintStyle: TextStyle(fontFamily: 'THSarabunNew'),
            fillColor: Color.fromARGB(255, 255, 255, 255),
            filled: true,
            prefixIcon: Icon(
              Icons.location_on,
              color: Colors.red,
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          style: TextStyle(fontFamily: 'THSarabunNew'),
        ),
        suggestionsCallback: (pattern) {
          return locations.where((location) =>
              location.toLowerCase().contains(pattern.toLowerCase()));
        },
        itemBuilder: (context, suggestion) {
          return ListTile(
            title:
                Text(suggestion, style: TextStyle(fontFamily: 'THSarabunNew')),
          );
        },
        onSuggestionSelected: (suggestion) {
          setState(() {
            locationController.text = suggestion;
            selectedLocation = suggestion;
            updateSportsForLocation(
                suggestion); // อัพเดทข้อมูลกีฬาตามสถานที่ที่เลือก
          });
        },
        noItemsFoundBuilder: (context) {
          return Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'ไม่พบสถานที่',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 18.0,
                fontFamily: 'THSarabunNew',
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
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
      child: TypeAheadFormField(
        textFieldConfiguration: TextFieldConfiguration(
          controller: sportController,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
            hintText: 'เพิ่มกีฬา',
            hintStyle: TextStyle(fontFamily: 'THSarabunNew'),
            fillColor: Color.fromARGB(255, 255, 255, 255),
            filled: true,
            prefixIcon: Icon(
              Icons.sports_soccer,
              color: Colors.red,
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          style: TextStyle(fontFamily: 'THSarabunNew'),
        ),
        suggestionsCallback: (pattern) {
          return sport.where(
              (sport) => sport.toLowerCase().contains(pattern.toLowerCase()));
        },
        itemBuilder: (context, suggestion) {
          return ListTile(
            title:
                Text(suggestion, style: TextStyle(fontFamily: 'THSarabunNew')),
          );
        },
        onSuggestionSelected: (suggestion) {
          setState(() {
            sportController.text = suggestion;
            selectedSport = suggestion;
          });
        },
        noItemsFoundBuilder: (context) {
          return Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'ไม่พบกีฬา',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 18.0,
                fontFamily: 'THSarabunNew',
              ),
            ),
          );
        },
      ),
    );
  }

  // วิดเจ็ตฟิลด์วันที่และเวลา
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
          DateTime now = DateTime.now();
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: now,
            firstDate: now,
            lastDate: DateTime(2101),
          );

          if (pickedDate != null) {
            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
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

              if (finalDateTime.isAfter(now)) {
                setState(() {
                  dateController.text = finalDateTime.toString();
                });
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('ข้อผิดพลาด'),
                      content: Text('ไม่สามารถเลือกเวลาที่ผ่านมาแล้วได้'),
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
                      label: Text(tag),
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
                          !_selectedTags.contains('#$newTag')) {
                        setState(() {
                          _selectedTags.add('#$newTag'); // เพิ่ม #
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
              return _allHashtags.where((hashtag) =>
                  hashtag.toLowerCase().contains(pattern.toLowerCase()));
            },
            itemBuilder: (context, suggestion) {
              return ListTile(
                title: Text(suggestion),
              );
            },
            onSuggestionSelected: (suggestion) {
              if (_selectedTags.length < 3 &&
                  !_selectedTags.contains('#$suggestion')) {
                setState(() {
                  _selectedTags.add('#$suggestion'); // เพิ่ม #
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
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
      child: TextFormField(
        controller: detailsController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
          hintText: 'เพิ่มรายละเอียดกิจกรรม',
          fillColor: Color.fromARGB(255, 255, 255, 255),
          filled: true,
          prefixIcon: Container(
            margin: EdgeInsets.all(11), // จัดการระยะขอบให้เหมาะสม
            child: Text(
              'ABC', // ตัวอักษรที่ต้องการใช้
              style: TextStyle(
                color: Colors.red,
                fontSize: 20, // ขนาดของตัวอักษร
                fontWeight: FontWeight.bold, // ทำให้ตัวอักษรหนา
              ),
            ),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  // วิดเจ็ตปุ่มสร้างกิจกรรม
  Widget createGroupButton() {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 20, 10, 0),
      child: SizedBox(
        width: 200, // กำหนดความกว้างของปุ่มตามที่ต้องการ
        child: ElevatedButton(
          child: Text(
            "สร้างกิจกรรม",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
            backgroundColor: Color.fromARGB(249, 255, 4, 4),
            shadowColor: Color.fromARGB(255, 255, 255, 255),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: BorderSide(color: Colors.black),
            ),
          ),
          onPressed: () {
            functionCreateActivity();
          },
        ),
      ),
    );
  }

  // ฟังก์ชันสร้างกิจกรรม
  Future<void> functionCreateActivity() async {
    String hashtags = _selectedTags.join(" ");
    List<String> hashtagList =
        hashtags.split(RegExp(r'\s+')).where((tag) => tag.isNotEmpty).toList();

    if (hashtagList.length > 3 || hashtagList.any((tag) => tag.length > 20)) {
      print("Invalid hashtag input");
      return;
    }

    print("activity_name: ${nameController.text}");
    print("activity_details: ${detailsController.text}");
    print("activity_date: ${dateController.text}");
    print("location_name: ${selectedLocation ?? ''}");
    print("sport_id: $selectedSportId");
    print("hashtags: $hashtagList");
    print("user_id: ${userData!['user_id']}");

    // สมมุติว่า userData มี user_id ของผู้ใช้ที่ล็อกอินอยู่
    String userId = userData!['user_id'];

    // เพิ่ม user_id ในการส่งข้อมูล
    Map<String, dynamic> dataPost = {
      "activity_name": nameController.text,
      "activity_details": detailsController.text,
      "activity_date": dateController.text,
      "location_name": selectedLocation ?? '',
      "sport_id": selectedSportId, // Ensure this value is set appropriately
      "hashtags": hashtagList,
      "user_id": userId, // ส่ง user_id ของผู้สร้างกิจกรรมไปด้วย
    };

    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer ${widget.jwt}"
    };

    var url =
        Uri.parse("http://10.0.2.2/flutter_webservice/get_CreateActivity.php");

    try {
      var response = await http.post(
        url,
        headers: headers,
        body: json.encode(dataPost),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        print(jsonResponse);
        if (jsonResponse["result"] == 1) {
          showSuccessDialog(); // แสดง dialog เมื่อสร้างกิจกรรมสำเร็จ
        }
      } else {
        print("Request failed with status: ${response.statusCode}");
      }
    } catch (error) {
      print("Error: $error");
    }
  }
  
  // ฟังก์ชันแสดง dialog เมื่อสร้างกิจกรรมสำเร็จ
  Future<void> showSuccessDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("สำเร็จ"),
          content: Text("สร้างกิจกรรมสำเร็จ"),
          actions: <Widget>[
            TextButton(
              child: Text("ตกลง"),
              onPressed: () {
                Navigator.of(context).pop(); // ปิด dialog
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (context) =>
                          Homepage(jwt: widget.jwt)), // แก้ไขตรงนี้
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
          color: const Color.fromARGB(255, 255, 255, 255)),
      onPressed: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) => Homepage(jwt: widget.jwt)), // แก้ไขตรงนี้
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
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
            appBar: AppBar(
              title: Text(
                "หน้าสร้างกิจกรรม",
                style:
                    TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),
              ),
              leading: backButton(),
              backgroundColor: Color.fromARGB(255, 255, 0, 0),
            ),
            body: SafeArea(
              child: ListView(
                children: [
                  Center(
                      child:
                          Column(mainAxisSize: MainAxisSize.max, children: [])),
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
