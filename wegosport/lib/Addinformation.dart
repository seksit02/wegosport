import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:wegosport/Login.dart';

// หน้าแก้ไขข้อมูลผู้ใช้
class editinformation extends StatefulWidget {
  const editinformation(
      {Key? key,
      required this.name,
      required this.email,
      required this.six_value})
      : super(key: key);

  @override
  State<editinformation> createState() => _editinformationState();
  final String name;
  final String email;
  final String six_value;
}

class _editinformationState extends State<editinformation> {
  TextEditingController one_value =
      TextEditingController(); // ตัวควบคุมสำหรับชื่อผู้ใช้
  TextEditingController two_value =
      TextEditingController(); // ตัวควบคุมสำหรับอีเมล
  TextEditingController three_value =
      TextEditingController(); // ตัวควบคุมสำหรับรหัสผ่าน
  TextEditingController four_value =
      TextEditingController(); // ตัวควบคุมสำหรับชื่อ-สกุล
  TextEditingController five_value =
      TextEditingController(); // ตัวควบคุมสำหรับอายุ

  @override
  void initState() {
    super.initState();
    setState(() {
      one_value.text = widget.name;
      two_value.text = widget.email;
      six_value = widget.six_value;
    });
  }

  String? six_value;

  // วิดเจ็ตฟิลด์ชื่อผู้ใช้งาน
  Widget inputOne() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
      child: TextFormField(
        controller: one_value,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
          hintText: 'ชื่อผู้ใช้งาน "มากกว่า 6 ตัว"',
          fillColor: Colors.white,
          filled: true,
          prefixIcon: Icon(
            Icons.create,
            color: Colors.red,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return 'กรุณากรอกชื่อผู้ใช้งาน';
          }
          if (value.length <= 6) {
            return 'ชื่อผู้ใช้งานควรมีมากกว่า 6 ตัวอักษร';
          }
          if (!value.contains(RegExp(r'[a-zA-Z]'))) {
            return 'ชื่อผู้ใช้งานควรมีตัวอักษรประกอบด้วยอย่างน้อย 1 ตัว';
          }
          return null;
        },
      ),
    );
  }

  // วิดเจ็ตฟิลด์อีเมล
  Widget inputTwo() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
      child: TextFormField(
        controller: two_value,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
          hintText: 'อีเมล "ใช้อีเมลที่ติดต่อได้เท่านั้น"',
          fillColor: Colors.white,
          filled: true,
          prefixIcon: Icon(
            Icons.edit,
            color: Colors.red,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  // วิดเจ็ตฟิลด์รหัสผ่าน
  Widget inputthree() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
      child: TextFormField(
        controller: three_value,
        keyboardType: TextInputType.text,
        obscureText: true, // ทำเป็นรหัสผ่านที่ถูกซ่อนไว้
        validator: (value) {
          if (value!.isEmpty) {
            return 'กรุณากรอกรหัสผ่าน';
          }
          if (value.length <= 6) {
            return 'รหัสผ่านควรมีอย่างน้อย 6 ตัว';
          }
          bool hasDigits = value.contains(RegExp(r'\d'));
          bool hasLetters = value.contains(RegExp(r'[a-zA-Z]'));
          if (!hasDigits || !hasLetters) {
            return 'รหัสผ่านควรประกอบด้วยตัวเลขและตัวอักษร';
          }
          return null;
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
          hintText: 'รหัสผ่าน "มากกว่า 6 ตัว"',
          fillColor: Colors.white,
          filled: true,
          prefixIcon: Icon(
            Icons.edit,
            color: Colors.red,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(
              RegExp(r'[a-zA-Z0-9]')), // อนุญาตให้กรอกได้เฉพาะตัวเลขและตัวอักษร
        ],
      ),
    );
  }

  // วิดเจ็ตฟิลด์ชื่อ-สกุล
  Widget inputfour() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
      child: TextFormField(
        controller: four_value,
        keyboardType: TextInputType.text,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(
              r'[a-zA-Zก-๏เ-๙]')), // อนุญาตให้กรอกเฉพาะตัวอักษรภาษาไทยและอักษรภาษาอังกฤษ
        ],
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
          hintText: 'ชื่อ-สกุล',
          fillColor: Colors.white,
          filled: true,
          prefixIcon: Icon(
            Icons.edit,
            color: Colors.red,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  // วิดเจ็ตฟิลด์วัน/เดือน/ปีเกิด
  Widget inputfive() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
      child: TextFormField(
        controller: five_value,
        keyboardType: TextInputType.datetime,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
          LengthLimitingTextInputFormatter(10),
          DateInputFormatter(),
        ],
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
          hintText: 'วัน/เดือน/ปีเกิด',
          fillColor: Colors.white,
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
      ),
    );
  }

  // วิดเจ็ตแสดงโลโก้
  Widget appLogo() {
    return Container(
      width: 100,
      height: 100,
      margin: EdgeInsets.fromLTRB(0, 50, 0, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          "images/logo.png",
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // วิดเจ็ตปุ่มยืนยันข้อมูล
  Widget buttonProcesslogin(BuildContext context) {
    return ButtonTheme(
      minWidth: double.infinity,
      child: Container(
        margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
        child: ElevatedButton(
          child: Text(
            "ยืนยัน",
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
              side: BorderSide(color: const Color.fromARGB(255, 255, 0, 0)),
            ),
          ),
          onPressed: () {
            if (_validateInputs()) {
              functionregister(context);
            } else {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("กรุณากรอกข้อมูลให้ครบถ้วน"),
                    actions: <Widget>[
                      TextButton(
                        child: Text("ตกลง"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  // ฟังก์ชันตรวจสอบข้อมูล
  bool _validateInputs() {
    // ตรวจสอบรูปแบบวันที่
    RegExp dateRegEx = RegExp(
      r'^(\d{2})/(\d{2})/(\d{4})$',
    );

    return one_value.text.isNotEmpty &&
        one_value.text.length >= 6 &&
        one_value.text.contains(RegExp(r'[a-zA-Z]')) &&
        two_value.text.isNotEmpty &&
        two_value.text.contains('@') &&
        three_value.text.isNotEmpty &&
        three_value.text.length >= 6 &&
        three_value.text.contains(RegExp(r'\d')) &&
        three_value.text.contains(RegExp(r'[a-zA-Z]')) &&
        four_value.text.isNotEmpty &&
        five_value.text.isNotEmpty &&
        dateRegEx.hasMatch(
            five_value.text); // ตรวจสอบว่าข้อความตรงกับรูปแบบวันที่ที่ถูกต้อง
  }

  // แปลงรูปแบบวันที่ให้เป็น YYYY-MM-DD ก่อนส่งไปยัง PHP
  String formatDate(String date) {
    List<String> parts = date.split('/');
    if (parts.length == 3) {
      return '${parts[2]}-${parts[1]}-${parts[0]}';
    }
    return date;
  }

  Future<void> functionregister(BuildContext context) async {
    print("user_id: ${one_value.text}");
    print("user_email: ${two_value.text}");
    print("user_pass: ${three_value.text}");
    print("user_name: ${four_value.text}");
    print("user_age: ${five_value.text}"); 
    print("user_token: ${six_value}");

    // แปลงรูปแบบวันที่ให้เป็น YYYY-MM-DD ก่อนส่งไปยัง PHP
    String formattedDob = formatDate(five_value.text);

    // เตรียมข้อมูลที่จะส่ง
    Map<String, String> dataPost = {
      "user_id": one_value.text,
      "user_email": two_value.text,
      "user_pass": three_value.text,
      "user_name": four_value.text,
      "user_age": formattedDob, // ใช้วันที่ที่แปลงแล้ว
      "user_token": six_value.toString()
    };

    // เตรียมหัวเรื่อง
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json"
    };

    var url = Uri.parse("http://10.0.2.2/flutter_webservice/get_Register.php");

    try {
      var response = await http.post(
        url,
        headers: headers,
        body: json.encode(dataPost),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        print(jsonResponse);

        // เช็คผลลัพธ์ที่ได้จากเซิร์ฟเวอร์
        if (jsonResponse['result'] == 1) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("กรอกข้อมูลสำเร็จ"),
                actions: <Widget>[
                  TextButton(
                    child: Text("ตกลง"),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => LoginPage()));
                    },
                  ),
                ],
              );
            },
          );
        } else {
          // ตรวจสอบข้อความข้อผิดพลาด
          if (jsonResponse['message'] == "ชื่อผู้ใช้หรืออีเมลนี้มีผู้ใช้แล้ว") {
            _showDialog(context, 'ผิดพลาด',
                'ชื่อผู้ใช้หรืออีเมลนี้มีผู้ใช้แล้ว กรุณากรอกข้อมูลใหม่');
          } else {
            _showDialog(context, 'ผิดพลาด',
                jsonResponse['message'] ?? 'การเพิ่มข้อมูลล้มเหลว');
          }
        }
      } else {
        print("Request failed with status: ${response.statusCode}");
        _showDialog(
            context, 'ผิดพลาด', 'เกิดข้อผิดพลาดในการเชื่อมต่อกับเซิร์ฟเวอร์');
      }
    } catch (error) {
      print("Error: $error");
      _showDialog(context, 'ผิดพลาด', 'เกิดข้อผิดพลาด: $error');
    }
  }


  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("ปิด"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // วิดเจ็ตข้อความหัวข้อ
  Widget text1() {
    return Container(
      child: Text(
        "สมัครสมาชิก",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
          fontFamily: 'YourFontFamily',
        ),
      ),
    );
  }

  // วิดเจ็ตปุ่มย้อนกลับ
  Widget backButton() {
    return IconButton(
      icon: Icon(Icons.arrow_back,
          color: const Color.fromARGB(255, 255, 255, 255)),
      onPressed: () {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginPage()));
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
              backgroundColor: Color.fromARGB(255, 255, 0, 0),
              title: Text("หน้าเพิ่มข้อมูลผู้ใช้",
                  style: TextStyle(color: Colors.white)),
              leading: backButton(),
            ),
            body: SafeArea(
              child: ListView(
                children: [
                  Center(
                      child: Column(mainAxisSize: MainAxisSize.max, children: [
                    appLogo(),
                    text1(),
                    inputOne(),
                    inputTwo(),
                    inputthree(),
                    inputfour(),
                    inputfive(),
                    buttonProcesslogin(context),
                  ])),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

// Custom Input Formatter สำหรับรูปแบบวัน/เดือน/ปีเกิด
class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Handle backspace
    if (newValue.text.length < oldValue.text.length) {
      return newValue;
    }

    var newText = newValue.text;
    if (newText.length == 2 || newText.length == 5) {
      newText += '/';
    } else if (newText.length > 10) {
      newText = newText.substring(0, 10);
    }

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
