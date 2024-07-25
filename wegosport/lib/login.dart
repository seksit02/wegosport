import 'package:flutter/material.dart';

import 'package:wegosport/Profile.dart';
import 'package:wegosport/Addinformation.dart';
import 'package:wegosport/Homepage.dart';
import 'package:wegosport/forgetpassword.dart';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
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
          "images/logo.png",
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
          onPressed: () async {
            if (inputone.text.isEmpty || inputtwo.text.isEmpty) {
              _showErrorDialog("กรุณากรอกข้อมูล");
            } else {
              bool loginSuccess = await FunctionLogin();
              if (loginSuccess) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => Homepage()),
                );
              } else {
                _showErrorDialog("การเข้าสู่ระบบล้มเหลว");
              }
            }
          },
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("ข้อผิดพลาด"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("ตกลง"),
          ),
        ],
      ),
    );
  }


  String generateJwt(String userId) {
    final jwt = JWT(
      {
        'id': userId,
      },
    );

    final secretKey = 'your_secret_key';
    final token = jwt.sign(SecretKey(secretKey), algorithm: JWTAlgorithm.HS256);

    print("Generated JWT: $token"); // สำหรับการดีบัก

    return token;
  }

  Future<bool> FunctionLogin() async {

    print("user_id: ${inputone.text}");
    print("user_pass: ${inputtwo.text}");

    // เตรียมข้อมูลที่จะส่ง
    Map<String, String> dataPost = {
      "user_id": inputone.text,
      "user_pass": inputtwo.text,
    };

    // เตรียมหัวเรื่อง
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json"
    };

    var url = Uri.parse("http://10.0.2.2/flutter_webservice/get_Login.php");

    try {
      var response = await http.post(
        url,
        headers: headers,
        body: json.encode(dataPost),
      );

      print("Response.body Login : ${response.body}");

      if (response.statusCode == 200) {

        Map<String, dynamic> jsonResponse = json.decode(response.body);

        // ตรวจสอบว่าการเข้าสู่ระบบสำเร็จหรือไม่
        if (jsonResponse['result'] == "1") {

          String jwt = jsonResponse['jwt'];

          // เก็บ JWT ลงในฐานข้อมูล
          var saveJwtResponse = await http.post(
            Uri.parse('http://10.0.2.2/flutter_webservice/get_Savejwt.php'),
            headers: headers,
            body: json.encode({
              "user_id": inputone.text,
              "jwt": jwt,
            }),
          );

          if (saveJwtResponse.statusCode == 200) {
            Map<String, dynamic> saveJwtJsonResponse =
                json.decode(saveJwtResponse.body);

            if (saveJwtJsonResponse['result'] == "1") {

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => ProfilePage(jwt: jwt),
                ),
              );
              return true;

            } else {
              _showErrorDialog("การเก็บ JWT ล้มเหลว");
              return false;
            }

          } else {
            _showErrorDialog("การเก็บ JWT ล้มเหลว");
            return false;
          }

        } else {
          return false;
        }

      } else {
        print("Request failed with status: ${response.statusCode}");
        return false;
      }
    } catch (error) {
      print("Error: $error");
      return false;
    }
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
          facebookLogin(context); // โค้ดที่ต้องการทำเมื่อกดปุ่ม Facebook
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

  Widget buttonforget() {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
      child: ElevatedButton.icon(
        icon: Icon(
          Icons.lock_open,
          color: const Color.fromARGB(255, 0, 0, 0),
        ),
        label: Text(
          "ลืมรหัสผ่าน",
          style: TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ForgotPasswordPage())); // โค้ดที่ต้องการทำเมื่อกดปุ่ม Facebook
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.fromLTRB(10, 10, 20, 8),
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          shadowColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // ปรับความโค้งของกรอบ
          ),
          side: BorderSide(color: Colors.black),
        ),
      ),
    );
  }

  Widget buttonregister() {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
      child: ElevatedButton.icon(
        icon: Icon(
          Icons.people,
          color: const Color.fromARGB(255, 0, 0, 0),
        ),
        label: Text(
          "สมัครสมาชิก",
          style: TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      editinformation(name: '', six_value: '', email: '',))); // โค้ดที่ต้องการทำเมื่อกดปุ่ม Facebook
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.fromLTRB(10, 10, 20, 8),
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          shadowColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // ปรับความโค้งของกรอบ
          ),
          side: BorderSide(color: Colors.black),
        ),
      ),
    );
  }


  Future<void> facebookLogin(BuildContext context) async {
    try {

      final result = await FacebookAuth.instance.login(
        permissions: ['public_profile', 'email'],
      );

      if (result.status == LoginStatus.success) {

        final userData = await FacebookAuth.instance.getUserData();

        print('facebook_login_data:-');
        print('ข้อมูล facebook : $userData');

        // แยกเฉพาะ id จาก userData
        String facebookUserId = userData['id'] ?? 'Unknown ID';
        String name = userData['name'] ?? 'Unknown Name';
        String email = userData['email'] ?? 'Unknown Email';

        // ตรวจสอบว่ามี user_token ใช้อยู่ในฐานข้อมูลหรือไม่
        var response = await http.post(
          Uri.parse('http://10.0.2.2/flutter_webservice/get_ChackToken.php'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"id": facebookUserId}),
        );

        if (response.statusCode == 200) {

          var jsonResponse = jsonDecode(response.body);

          if (jsonResponse['exists']) {

            // สร้าง JWT สำหรับผู้ใช้ที่มีอยู่แล้ว
            String jwt = generateJwt(facebookUserId);

            // เก็บ JWT ลงในฐานข้อมูล
            var saveJwtResponse = await http.post(
              Uri.parse('http://10.0.2.2/flutter_webservice/get_Savejwt.php'),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({
                "user_id": facebookUserId,
                "jwt": jwt,
              }),
            );

            if (saveJwtResponse.statusCode == 200) {

              var saveJwtJsonResponse = jsonDecode(saveJwtResponse.body);

              if (saveJwtJsonResponse['result'] == "1") {

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Homepage(),
                  ),
                );

              } else {
                _showErrorDialog("การเก็บ JWT ล้มเหลว");
              }

            } else {
              _showErrorDialog("การเก็บ JWT ล้มเหลว");
            }

          } else {

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => editinformation(
                  six_value: facebookUserId,
                  name: name,
                  email: email,
                ),
              ),
            );
          }

        } else {
          // จัดการข้อผิดพลาดของเซิร์ฟเวอร์
          print('Server error: ${response.statusCode}');
        }
      }
    } catch (error) {
      print(error);
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Stack(
        children: [
          Scaffold(
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
            body: SafeArea(
              child: ListView(
                children: [
                  Center(
                      child: Column(mainAxisSize: MainAxisSize.max, children: [
                    appLogo(),
                    inputOne(),
                    inputTwo(),
                    buttonProcesslogin(),
                    buttonfacebook(),
                    buttonregister(),
                    buttonforget(),
                    SizedBox(height:10)
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
