import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:wegosport/Addinformation.dart';
import 'package:wegosport/Profile.dart';

// หน้าจอแก้ไขโปรไฟล์
class EditProfile extends StatefulWidget {
  const EditProfile({super.key, required this.jwt});

  final String jwt; // รับค่า JWT สำหรับการตรวจสอบสิทธิ์

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  Map<String, dynamic>? userData; // เก็บข้อมูลผู้ใช้

  final TextEditingController _userIdController =
      TextEditingController(); // ตัวควบคุมสำหรับฟิลด์ user_id
  final TextEditingController _userNameController =
      TextEditingController(); // ตัวควบคุมสำหรับฟิลด์ user_name
  final TextEditingController _userTextController =
      TextEditingController(); // ตัวควบคุมสำหรับฟิลด์ user_text
  final TextEditingController _userAgeController =
      TextEditingController(); // ตัวควบคุมสำหรับฟิลด์ user_age

  @override
  void initState() {
    super.initState();
    fetchUserData(widget.jwt); // ดึงข้อมูลผู้ใช้เมื่อเริ่มต้น
  }

  // ฟังก์ชันแปลงวันที่เป็น DD/MM/YYYY
  String formatDate(String date) {
    // แปลงสตริงวันที่เป็น DateTime object
    DateTime parsedDate = DateTime.parse(date);

    // แปลง DateTime object เป็นสตริงในรูปแบบ DD/MM/YYYY
    String formattedDate = "${parsedDate.day.toString().padLeft(2, '0')}/"
        "${parsedDate.month.toString().padLeft(2, '0')}/"
        "${parsedDate.year}";

    return formattedDate;
  }

// ฟังก์ชันดึงข้อมูลผู้ใช้จากเซิร์ฟเวอร์
  Future<void> fetchUserData(String jwt) async {
    var url =
        Uri.parse('http://10.0.2.2/flutter_webservice/get_ShowDataUser.php');

    Map<String, String> headers = {
      'Authorization': 'Bearer $jwt',
    };

    try {
      var response = await http.post(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List<dynamic> &&
            data.isNotEmpty &&
            data[0] is Map<String, dynamic> &&
            data[0].containsKey('user_id')) {
          setState(() {
            userData = data[0];
            _userIdController.text = userData!['user_id'];
            _userNameController.text = userData!['user_name'];
            _userTextController.text = userData!['user_text'];
            _userAgeController.text =
                formatDate(userData!['user_age']); // แปลงวันที่ก่อนแสดงผล
          });
        } else {
          throw Exception('Failed to load user data');
        }
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (error) {
      throw Exception('Failed to load user data');
    }
  }


  // ฟังก์ชันอัปเดตโปรไฟล์ผู้ใช้
  Future<void> updateUserProfile() async {
    var url =
        Uri.parse('http://10.0.2.2/flutter_webservice/get_UpdateProfile.php');

    Map<String, String> headers = {
      'Authorization': 'Bearer ${widget.jwt}',
    };

    Map<String, String> body = {
      'jwt': widget.jwt,
      'user_id': _userIdController.text,
      'user_name': _userNameController.text,
      'user_text': _userTextController.text,
      'user_age': _userAgeController.text,
    };

    print('ข้อมูล headers : $headers');
    print('ข้อมูล body : $body');

    try {
      var response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        print('Response status edit : ${response.statusCode}');
        print('Response body edit : ${response.body}');
        // อัปเดตสำเร็จ
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(jwt: widget.jwt),
          ),
        );
      } else {
        throw Exception('Failed to update user data');
      }
    } catch (error) {
      throw Exception('Failed to update user data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 255, 0, 0),
          title: Text(
            "หน้าแก้ไขข้อมูล",
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: Color.fromARGB(255, 255, 255, 255)),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(jwt: widget.jwt),
                ),
              );
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _userIdController,
                decoration: InputDecoration(
                  labelText: 'ชื่อผู้ใช้',
                ),
                enabled: false, // ปิดการแก้ไขฟิลด์ user_id
                style: TextStyle(
                  color: Colors.grey, // แสดงข้อความเป็นสีจาง
                ),
              ),
              TextField(
                controller: _userNameController,
                decoration: InputDecoration(labelText: 'ชื่อ'),
              ),
              TextField(
                controller: _userTextController,
                decoration: InputDecoration(labelText: 'ข้อความขังเขป'),
              ),
              TextFormField(
                controller: _userAgeController,
                keyboardType: TextInputType.datetime,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                  LengthLimitingTextInputFormatter(10),
                  DateInputFormatter(), // ตัวจัดการการป้อนข้อมูลสำหรับวันที่
                ],
                decoration: InputDecoration(
                  labelText: 'วัน/เดือน/ปีเกิด',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed:
                    updateUserProfile, // เรียกใช้ฟังก์ชัน updateUserProfile เมื่อกดปุ่ม
                child: Text('อัปเดตข้อมูล'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
