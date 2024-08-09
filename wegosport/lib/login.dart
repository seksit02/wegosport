import 'package:flutter/material.dart';

import 'package:wegosport/Profile.dart';
import 'package:wegosport/Addinformation.dart';
import 'package:wegosport/Homepage.dart';
import 'package:wegosport/forgetpassword.dart';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart'; // ใช้สำหรับการสร้าง JWT

import 'package:flutter_facebook_auth/flutter_facebook_auth.dart'; // ใช้สำหรับการเข้าสู่ระบบด้วย Facebook
import 'package:http/http.dart' as http; // ใช้สำหรับการเรียก HTTP
import 'dart:async'; // ใช้สำหรับการทำงานแบบ asynchronous
import 'dart:convert'; // ใช้สำหรับการแปลง JSON

// หน้าจอล็อกอิน
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController inputone =
      TextEditingController(); // ตัวควบคุมสำหรับฟิลด์ชื่อผู้ใช้
  TextEditingController inputtwo =
      TextEditingController(); // ตัวควบคุมสำหรับฟิลด์รหัสผ่าน

  // วิดเจ็ตแสดงโลโก้
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

  // วิดเจ็ตฟิลด์ชื่อผู้ใช้
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

  // วิดเจ็ตฟิลด์รหัสผ่าน
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

  // วิดเจ็ตปุ่มเข้าสู่ระบบ
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
              borderRadius: BorderRadius.circular(30),
              side: BorderSide(color: Colors.black),
            ),
          ),
          onPressed: () async {
            if (inputone.text.isEmpty || inputtwo.text.isEmpty) {
              _showErrorDialog(
                  "กรุณากรอกข้อมูล"); // แสดงกล่องข้อความแจ้งเตือนหากยังไม่ได้กรอกข้อมูล
            } else {
              var loginResult =
                  await FunctionLogin(); // เรียกใช้ฟังก์ชันล็อกอิน

              bool loginSuccess = loginResult['success'] ??
                  false; // กำหนดค่าดีฟอลต์เป็น false หาก 'success' เป็น null
              String jwt = loginResult['jwt'] ??
                  ''; // กำหนดค่าดีฟอลต์เป็นสตริงว่างหาก 'jwt' เป็น null

              if (loginSuccess) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => Homepage(
                        jwt:
                            jwt), // ส่งค่า jwt ที่ได้รับจากฟังก์ชันไปยังหน้า Homepage
                  ),
                );
              } else {
                _showErrorDialog(
                    "การเข้าสู่ระบบล้มเหลว"); // แสดงข้อความแจ้งเตือนหากการเข้าสู่ระบบล้มเหลว
              }

            }
          },
        ),
      ),
    );
  }

  // ฟังก์ชันแสดงกล่องข้อความแจ้งเตือน
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

  // ฟังก์ชันสร้าง JWT
  String generateJwt(String userId ) {
    final jwt = JWT(
      {
        'user_id': userId,
      },
    );

    final secretKey = 'your_secret_key';
    final token = jwt.sign(SecretKey(secretKey), algorithm: JWTAlgorithm.HS256);

    print("Generated JWT: $token"); // สำหรับการดีบัก

    return token;
  }

  // ฟังก์ชันล็อกอิน
  Future<Map<String, dynamic>> FunctionLogin() async {
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

          String userId = jsonResponse['user_id'];
          String jwt = jsonResponse['jwt']; // ใช้ JWT ที่ได้รับจากเซิร์ฟเวอร์

          // เก็บ JWT ลงในฐานข้อมูล
          var saveJwtResponse = await http.post(
            Uri.parse('http://10.0.2.2/flutter_webservice/get_Savejwt.php'),
            headers: headers,
            body: json.encode({
              "user_id": userId,
              "jwt": jwt,
            }),
          );

          if (saveJwtResponse.statusCode == 200) {
            Map<String, dynamic> saveJwtJsonResponse =
                json.decode(saveJwtResponse.body);

            if (saveJwtJsonResponse['result'] == "1") {
              return {
                'success': true,
                'jwt': jwt
              }; // ส่งค่าผลลัพธ์การเข้าสู่ระบบและ JWT กลับ
            } else {
              _showErrorDialog("การเก็บ JWT ล้มเหลว");
              return {'success': false};
            }
          } else {
            _showErrorDialog("การเก็บ JWT ล้มเหลว");
            return {'success': false};
          }
        } else {
          return {'success': false};
        }
      } else {
        print("Request failed with status: ${response.statusCode}");
        return {'success': false};
      }
    } catch (error) {
      print("Error: $error");
      return {'success': false};
    }
  }

  // วิดเจ็ตปุ่มล็อกอินด้วย Facebook
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

  // วิดเจ็ตปุ่มลืมรหัสผ่าน
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
                      ForgotPasswordPage())); // ไปยังหน้าลืมรหัสผ่านเมื่อกดปุ่ม
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

  // วิดเจ็ตปุ่มสมัครสมาชิก
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
                  builder: (context) => editinformation(
                        name: '',
                        six_value: '',
                        email: '',
                      ))); // ไปยังหน้าสมัครสมาชิกเมื่อกดปุ่ม
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

          print('ข้อมูลจาก ChackToken : $jsonResponse');

          if (jsonResponse['exists']) {
            // ตรวจสอบว่า jwt ไม่มีค่า
            if (jsonResponse['jwt'] == null || jsonResponse['jwt'].isEmpty) {
              print("เข้าเงื่อนไขไม่มี jwt");

              // ถ้ามี user_token แต่ไม่มี user_jwt ให้สร้าง jwt ก่อนและบันทึกลง database แล้วส่งไปหน้า home
              String jwt = generateJwt(jsonResponse['user_id']);

              // เก็บ JWT ลงในฐานข้อมูล
              var saveJwtResponse = await http.post(
                Uri.parse('http://10.0.2.2/flutter_webservice/get_Savejwt.php'),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode({
                  "user_id":
                      jsonResponse['user_id'], // ใช้ userId จาก jsonResponse
                  "jwt": jwt,
                }),
              );

              print('ข้อมูล saveJwt : $saveJwtResponse[result]');

              if (jwt.isNotEmpty) {
              var saveJwtJsonResponse = jsonDecode(saveJwtResponse.body);

              if (saveJwtJsonResponse['result'] == "1") {
                // แสดงป๊อปอัพเพื่อแจ้งให้ผู้ใช้เข้าสู่ระบบอีกครั้ง
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("บันทึกข้อมูลสำเร็จ"),
                      content: Text("กรุณาเข้าสู่ระบบอีกครั้ง"),
                      actions: [
                        TextButton(
                          child: Text("ตกลง"),
                          onPressed: () {
                            Navigator.of(context).pop();
                            // ส่งผู้ใช้กลับไปหน้า login
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              } else {
                _showErrorDialog("การเก็บ JWT ล้มเหลว");
              }
            } else {
              _showErrorDialog("การเก็บ JWT ล้มเหลว");
            }
            } else {
              print("เข้าเงื่อนไขมี jwt");

              // ถ้ามี user_token และ user_jwt อยู่ในฐานข้อมูล
              String jwt = jsonResponse['jwt'];

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => Homepage(jwt: jwt),
                ),
              );
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


  // การสร้าง UI ของหน้าจอล็อกอิน
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
                    appLogo(), // แสดงโลโก้
                    inputOne(), // ฟิลด์ชื่อผู้ใช้
                    inputTwo(), // ฟิลด์รหัสผ่าน
                    buttonProcesslogin(), // ปุ่มเข้าสู่ระบบ
                    buttonfacebook(), // ปุ่มเข้าสู่ระบบด้วย Facebook
                    buttonregister(), // ปุ่มสมัครสมาชิก
                    buttonforget(), // ปุ่มลืมรหัสผ่าน
                    SizedBox(height: 10)
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
