import 'dart:math';
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
          hintText: 'กรอกชื่อผู้ใช้งาน',
          fillColor: Colors.white,
          filled: true,
          prefixIcon: Icon(
            Icons.edit, // เปลี่ยนเป็นไอคอนดินสอ
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

  Widget inputTwo() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
      child: TextFormField(
        controller: two_value,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
          hintText: 'กรอกอีเมล',
          fillColor: Colors.white, // กำหนดสีพื้นหลังเป็นสีขาว
          filled: true,
          prefixIcon: Icon(
            Icons.person,
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
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
          hintText: 'กรอกรหัสผ่าน',
          fillColor: Colors.white,
          filled: true,
          prefixIcon: Icon(
            Icons.email, // เปลี่ยนไอคอนเป็นจดหมาย
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

  Widget inputfour() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
      child: TextFormField(
        controller: four_value,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
          hintText: 'กรอกชื่อ-สกุล',
          fillColor: Colors.white,
          filled: true,
          prefixIcon: Icon(
            Icons.lock, // เปลี่ยนไอคอนเป็นกุญแจ
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
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
          hintText: 'กรอกอายุ',
          fillColor: Colors.white,
          filled: true,
          prefixIcon: Icon(
            Icons.format_list_numbered, // เปลี่ยนเป็นไอคอนตัวเลข
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

  Widget buttonProcesslogin() {
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
              borderRadius: BorderRadius.circular(30), // ปรับความโค้งของกรอบ
              side: BorderSide(color: Colors.black),
            ),
          ),
          onPressed: () {
            functionregister(); // โค้ดการเข้าสู่ระบบ
            setState(() {
              Navigator.of(this.context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginPage()));
            });
          },
        ),
      ),
    );
  }

  Future<void> functionregister() async {
    print("user_userID: ${one_value.text}");
    print("user_email: ${two_value.text}");
    print("user_pass: ${three_value.text}");
    print("user_name_lastname: ${four_value.text}");
    print("user_age: ${five_value.text}");

    // Prepare data to send
    Map<String, String> dataPost = {
      "user_userID": one_value.text,
      "user_email": two_value.text,
      "user_pass": three_value.text,
      "user_name_lastname": four_value.text,
      "user_age": five_value.text
    };

    // Prepare headers
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json"
    };

    var url = Uri.parse("http://10.0.2.2/flutter_webservice/get_register.php");

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
        "แก้ไขข้อมูล",
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
              title: Text("หน้าลืมรหัสผ่าน"),
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
                    buttonProcesslogin(),
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
