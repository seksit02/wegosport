import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:wegosport/Addinformation.dart';
import 'package:wegosport/Profile.dart'; // นำเข้าไลบรารีที่จำเป็นและหน้า Profile

// หน้าจอแก้ไขโปรไฟล์
class EditProfile extends StatefulWidget {
  const EditProfile({super.key, required this.jwt});

  final String jwt; // รับค่า JWT สำหรับการตรวจสอบสิทธิ์

  @override
  State<EditProfile> createState() =>
      _EditProfileState(); // สร้างสถานะของ EditProfile
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

  // ฟังก์ชันดึงข้อมูลผู้ใช้จากเซิร์ฟเวอร์
  Future<void> fetchUserData(String jwt) async {
    var url = Uri.parse(
        'http://10.0.2.2/flutter_webservice/get_ShowDataUser.php'); // กำหนด URL สำหรับดึงข้อมูลผู้ใช้

    Map<String, String> headers = {
      'Authorization': 'Bearer $jwt', // ใส่ JWT ในส่วนของ Authorization Header
    };

    try {
      var response = await http.post(
        url,
        headers: headers, // ส่งค่า JWT ไปพร้อมกับคำขอ
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List<dynamic> &&
            data.isNotEmpty &&
            data[0] is Map<String, dynamic> &&
            data[0].containsKey('user_id')) {
          setState(() {
            userData = data[0]; // เก็บข้อมูลผู้ใช้ในตัวแปร userData
            _userIdController.text =
                userData!['user_id']; // กำหนดค่าให้กับฟิลด์ user_id
            _userNameController.text =
                userData!['user_name']; // กำหนดค่าให้กับฟิลด์ user_name
            _userTextController.text =
                userData!['user_text']; // กำหนดค่าให้กับฟิลด์ user_text
            _userAgeController.text = formatDate(
                userData!['user_age']); // แปลงวันที่ก่อนแสดงผลในฟิลด์ user_age
          });
        } else {
          throw Exception(
              'Failed to load user data'); // โยนข้อผิดพลาดหากไม่สามารถดึงข้อมูลได้
        }
      } else {
        throw Exception(
            'Failed to load user data'); // โยนข้อผิดพลาดหากการตอบกลับไม่สำเร็จ
      }
    } catch (error) {
      throw Exception(
          'Failed to load user data'); // โยนข้อผิดพลาดหากมีข้อผิดพลาดเกิดขึ้น
    }
  }

  // ฟังก์ชันแปลงวันที่เป็น DD/MM/YYYY
  String formatDate(String date) {
    // แปลงสตริงวันที่เป็น DateTime object
    DateTime parsedDate = DateTime.parse(date);
    // แปลง DateTime object เป็นสตริงในรูปแบบ DD/MM/YYYY
    String formattedDate = "${parsedDate.day.toString().padLeft(2, '0')}/"
        "${parsedDate.month.toString().padLeft(2, '0')}/"
        "${parsedDate.year}";

    return formattedDate; // ส่งคืนสตริงวันที่ในรูปแบบ DD/MM/YYYY
  }

  // แปลงรูปแบบวันที่ให้เป็น YYYY-MM-DD ก่อนส่งไปยัง PHP
  String formatDate1(String date) {
    List<String> parts = date.split('/'); // แยกวันที่ตาม '/'
    if (parts.length == 3) {
      return '${parts[2]}-${parts[1]}-${parts[0]}'; // คืนค่าวันที่ในรูปแบบ YYYY-MM-DD
    }
    return date; // คืนค่ากลับถ้ารูปแบบไม่ถูกต้อง
  }

  // ฟังก์ชันอัปเดตโปรไฟล์ผู้ใช้
  Future<void> updateUserProfile() async {
    var url = Uri.parse(
        'http://10.0.2.2/flutter_webservice/get_UpdateProfile.php'); // กำหนด URL สำหรับอัปเดตข้อมูลผู้ใช้

    Map<String, String> headers = {
      'Authorization':
          'Bearer ${widget.jwt}', // ใส่ JWT ในส่วนของ Authorization Header
    };

    Map<String, String> body = {
      'jwt': widget.jwt, // ใส่ JWT ใน body ของคำขอ
      'user_id': _userIdController.text, // ใส่ค่า user_id ใน body ของคำขอ
      'user_name': _userNameController.text, // ใส่ค่า user_name ใน body ของคำขอ
      'user_text': _userTextController.text, // ใส่ค่า user_text ใน body ของคำขอ
      'user_age': _userAgeController.text, // ใส่ค่า user_age ใน body ของคำขอ
    };


    print('ข้อมูล headers : $headers'); // พิมพ์ headers เพื่อการตรวจสอบ
    print('ข้อมูล body : $body'); // พิมพ์ body เพื่อการตรวจสอบ

    try {
      var response = await http.post(
        url,
        headers: headers, // ส่งค่า JWT ไปพร้อมกับคำขอ
        body: body, // ส่งข้อมูลที่ต้องการอัปเดตไปพร้อมกับคำขอ
      );

      if (response.statusCode == 200) {
        print('Response status edit : ${response.statusCode}');
        print('Response body edit : ${response.body}');
        // อัปเดตสำเร็จ
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(
                jwt: widget.jwt), // กลับไปที่หน้า ProfilePage พร้อม JWT
          ),
        );
      } else {
        throw Exception(
            'Failed to update user data'); // โยนข้อผิดพลาดหากการตอบกลับไม่สำเร็จ
      }
    } catch (error) {
      throw Exception(
          'Failed to update user data'); // โยนข้อผิดพลาดหากมีข้อผิดพลาดเกิดขึ้น
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor:
            Color.fromARGB(255, 255, 255, 255), // กำหนดสีพื้นหลังของหน้าจอ
        appBar: AppBar(
          backgroundColor:
              Color.fromARGB(255, 255, 0, 0), // กำหนดสีพื้นหลังของ AppBar
          title: Text(
            "หน้าแก้ไขข้อมูล", // ชื่อหน้าจอ
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: Color.fromARGB(
                    255, 255, 255, 255)), // ไอคอนกลับไปหน้าก่อนหน้า
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(
                      jwt: widget.jwt), // กลับไปที่หน้า ProfilePage พร้อม JWT
                ),
              );
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0), // กำหนดขนาด padding ของฟอร์ม
          child: Column(
            children: [
              TextField(
                controller: _userIdController, // ตัวควบคุมฟิลด์ user_id
                decoration: InputDecoration(
                  labelText: 'ชื่อผู้ใช้', // ป้ายกำกับฟิลด์ user_id
                ),
                enabled: false, // ปิดการแก้ไขฟิลด์ user_id
                style: TextStyle(
                  color: Colors.grey, // แสดงข้อความเป็นสีจาง
                ),
              ),
              TextField(
                controller: _userNameController, // ตัวควบคุมฟิลด์ user_name
                decoration: InputDecoration(
                    labelText: 'ชื่อ'), // ป้ายกำกับฟิลด์ user_name
              ),
              TextField(
                controller: _userTextController, // ตัวควบคุมฟิลด์ user_text
                decoration: InputDecoration(
                    labelText: 'ข้อความสังเขป'), // ป้ายกำกับฟิลด์ user_text
              ),
              TextFormField(
                controller: _userAgeController, // ตัวควบคุมฟิลด์ user_age
                keyboardType:
                    TextInputType.datetime, // กำหนดประเภทคีย์บอร์ดเป็นวันที่
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(
                      r'[0-9/]')), // กรองให้ป้อนเฉพาะตัวเลขและเครื่องหมาย /
                  LengthLimitingTextInputFormatter(
                      10), // กำหนดขนาดความยาวสูงสุดของการป้อนข้อมูลเป็น 10 ตัวอักษร
                  DateInputFormatter(), // ตัวจัดการการป้อนข้อมูลสำหรับวันที่
                ],
                decoration: InputDecoration(
                  labelText: 'วัน/เดือน/ปีเกิด', // ป้ายกำกับฟิลด์ user_age
                ),
              ),
              SizedBox(height: 20), // ระยะห่างระหว่างฟิลด์กับปุ่ม
              ElevatedButton(
                onPressed: () {
                  // แปลงวันที่จาก DD/MM/YYYY ให้เป็น YYYY-MM-DD ก่อนส่งไปอัปเดต
                  _userAgeController.text =
                      formatDate1(_userAgeController.text);
                  updateUserProfile(); // เรียกใช้ฟังก์ชัน updateUserProfile เมื่อกดปุ่ม
                },
                child: Text('อัปเดตข้อมูล'), // ข้อความในปุ่ม
              ),

            ],
          ),
        ),
      ),
    );
  }
}
