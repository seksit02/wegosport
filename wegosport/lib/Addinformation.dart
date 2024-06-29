import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:wegosport/login.dart';

class editinformation extends StatefulWidget {
  const editinformation({Key? key, this.image, this.name, this.email})
      : super(key: key);

  @override
  State<editinformation> createState() => _editinformationState();
  final image;
  final name;
  final email;
}

class _editinformationState extends State<editinformation> {
  TextEditingController one_value = TextEditingController();
  TextEditingController two_value = TextEditingController();
  TextEditingController three_value = TextEditingController();
  TextEditingController four_value = TextEditingController();
  TextEditingController five_value = TextEditingController();

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
            Icons.create, // เปลี่ยนไอคอนเป็นดินสอ
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

  Widget inputTwo() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
      child: TextFormField(
        controller: two_value,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
          hintText: 'อีเมล "ใช้อีเมลที่ติดต่อได้เท่านั้น"',
          fillColor: Colors.white, // กำหนดสีพื้นหลังเป็นสีขาว
          filled: true,
          prefixIcon: Icon(
            Icons.edit,
            color: Colors.red, // ตั้งค่าสีของไอคอนเป็นสีแดง
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(30), // ปรับความโค้งของกรอบ
          ),
        ),
      ),
    );
  }

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
          if (value!.length <= 6) {
            return 'รหัสผ่านควรมีอย่างน้อย 6 ตัว';
          }
          // ตรวจสอบว่ามีตัวเลขและตัวอักษรประกอบอยู่
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
            Icons.edit, // เปลี่ยนไอคอนเป็นจดหมาย
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
            Icons.edit, // เปลี่ยนไอคอนเป็นกุญแจ
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

  Widget inputfive() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
      child: TextFormField(
        controller: five_value,
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
          hintText: 'อายุ',
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

  Widget appLogo() {
    return Container(
      width: 100,
      height: 100,
      margin: EdgeInsets.fromLTRB(0, 50, 0, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50), // กำหนดรูปร่างของกรอบ
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(10), // ให้ Clip รูปภาพตามรูปร่างของกรอบ
        child: Image.asset(
          "images/login.png",
          fit: BoxFit.cover, // ให้รูปภาพปรับตามขนาดของ Container
        ),
      ),
    );
  }

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
              side: BorderSide(color: Colors.black),
            ),
          ),
          onPressed: () {
            if (_validateInputs()) {
              functionregister(context); // เรียกใช้งานฟังก์ชันสำหรับส่งข้อมูล
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
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()));
                        },
                      ),
                    ],
                  );
                },
              );
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

  bool _validateInputs() {
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
        int.tryParse(five_value.text) != null &&
        int.parse(five_value.text) > 0;
  }

  Future<void> functionregister(BuildContext context) async {
    print("user_id: ${one_value.text}");
    print("user_email: ${two_value.text}");
    print("user_pass: ${three_value.text}");
    print("user_name: ${four_value.text}");
    print("user_age: ${five_value.text}");

    // Prepare data to send
    Map<String, String> dataPost = {
      "user_id": one_value.text,
      "user_email": two_value.text,
      "user_pass": three_value.text,
      "user_name": four_value.text,
      "user_age": five_value.text
    };

    // Prepare headers
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
      } else {
        print("Request failed with status: ${response.statusCode}");
      }
    } catch (error) {
      print("Error: $error");
    }
  }

  Widget text1() {
    return Container(
      child: Text(
        "เพิ่มข้อมูลผู้ใช้",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
          fontFamily: 'YourFontFamily',
        ),
      ),
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
              title: Text("หน้าเพิ่มข้อมูลผู้ใช้"),
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
