import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:wegosport/activity.dart';
import 'package:wegosport/editforget.dart';
import 'package:wegosport/homepage.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController inputone = TextEditingController();
  TextEditingController inputtwo = TextEditingController();

  Widget appLogo() {
    return Container(
      width: 300,
      height: 250,
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

  Widget inputOne() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
      child: TextFormField(
        controller: inputone,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
          hintText: 'ชื่อผู้ใช้',
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

  Widget inputTwo() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
      child: TextFormField(
        controller: inputtwo,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
          hintText: 'รหัสผ่าน',
          fillColor: Color.fromARGB(255, 255, 255, 255),
          filled: true,
          prefixIcon: Icon(
            Icons.lock,
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

  Widget buttonProcesslogin() {
    return ButtonTheme(
      minWidth: double.infinity,
      child: Container(
        margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
        child: ElevatedButton(
          child: Text(
            "เข้าสู่ระบบ",
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
            FunctionLogin(); // โค้ดการเข้าสู่ระบบ
            setState(() {
              Navigator.of(this.context).pushReplacement(
                  MaterialPageRoute(builder: (context) => editinformation()));
            });
          },
        ),
      ),
    );
  }

  Widget buttonfacebook() {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
      child: ElevatedButton.icon(
        icon: Icon(
          Icons.facebook,
          color: Colors.white,
        ),
        label: Text(
          "Sign up with Facebook",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        onPressed: () {
          facebookLogin(); // โค้ดที่ต้องการทำเมื่อกดปุ่ม Facebook
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.fromLTRB(15, 10, 20, 8),
          backgroundColor: Color.fromARGB(255, 31, 136, 234),
          shadowColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // ปรับความโค้งของกรอบ
          ),
          side: BorderSide(color: Colors.black),
        ),
      ),
    );
  }

  facebookLogin() async {
    try {
      final result =
          await FacebookAuth.i.login(permissions: ['public_profile', 'email']);
      if (result.status == LoginStatus.success) {
        final userData = await FacebookAuth.i.getUserData();
        print('facebook_login_data:-');
        print(userData);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => homepage(
                    image: userData['picture']['data']['url'],
                    name: userData['name'],
                    email: userData['email'])));
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> FunctionLogin() async {
    print("user_userID: ${inputone.text}");
    print("user_pass: ${inputtwo.text}");

    // Prepare data to send
    Map<String, String> dataPost = {
      "user_userID": inputone.text,
      "user_pass": inputtwo.text,
    };

    // Prepare headers
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json"
    };

    var url = Uri.parse("http://127.0.0.1/flutter_webservice/get_login.php");

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Stack(
        children: [
          Scaffold(
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
            appBar: AppBar(
              title: Text("หน้าล็อกอิน"),
            ),
            body: SafeArea(
              child: ListView(
                children: [
                  Center(
                      child: Column(mainAxisSize: MainAxisSize.max, children: [
                    appLogo(),
                    inputOne(),
                    inputTwo(),
                    buttonProcesslogin(),
                    buttonfacebook()
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
