import 'package:flutter/material.dart';
import 'package:wegosport/Addinformation.dart';
import 'package:wegosport/Homepage.dart';
import 'package:wegosport/forgetpassword.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart'; // ใช้สำหรับการสร้าง JWT
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart'; // ใช้สำหรับการเข้าสู่ระบบด้วย Facebook
import 'package:http/http.dart' as http; // ใช้สำหรับการเรียก HTTP
import 'dart:async'; // ใช้สำหรับการทำงานแบบ asynchronous
import 'dart:convert'; // ใช้สำหรับการแปลง JSON

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key})
      : super(key: key); // คอนสตรักเตอร์สำหรับ LoginPage

  @override
  State<LoginPage> createState() =>
      _LoginPageState(); // สร้างสถานะสำหรับ LoginPage
}

class _LoginPageState extends State<LoginPage> {
  // สร้างคลาสสำหรับจัดการสถานะ
  TextEditingController inputone =
      TextEditingController(); // ตัวควบคุมสำหรับฟิลด์ชื่อผู้ใช้
  TextEditingController inputtwo =
      TextEditingController(); // ตัวควบคุมสำหรับฟิลด์รหัสผ่าน

  // วิดเจ็ตแสดงโลโก้
  Widget appLogo() {
    return Container(
      width: 300,
      height: 250,
      margin: EdgeInsets.fromLTRB(
          0, 50, 0, 0), // กำหนดระยะห่างจากขอบ (ซ้าย, บน, ขวา, ล่าง)
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50), // กำหนดรูปร่างของกรอบให้โค้งมน
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(10), // ให้ Clip รูปภาพตามรูปร่างของกรอบ
        child: Image.asset(
          "images/logo.png", // แสดงโลโก้จากไฟล์ภาพ
          fit: BoxFit.cover, // ให้รูปภาพปรับตามขนาดของ Container
        ),
      ),
    );
  }

  // วิดเจ็ตฟิลด์ชื่อผู้ใช้
  Widget inputOne() {
    return Container(
      margin: EdgeInsets.fromLTRB(
          50, 20, 50, 0), // กำหนดระยะห่างจากขอบ (ซ้าย, บน, ขวา, ล่าง)
      child: TextFormField(
        controller: inputone, // กำหนดตัวควบคุมให้กับฟิลด์ชื่อผู้ใช้
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(
              0, 15, 0, 0), // กำหนดระยะห่างภายในฟิลด์ (ซ้าย, บน, ขวา, ล่าง)
          hintText: 'ชื่อผู้ใช้', // ข้อความที่แสดงเมื่อฟิลด์ว่าง
          fillColor: Colors.white, // กำหนดสีพื้นหลังเป็นสีขาว
          filled: true, // เปิดการใช้งานสีพื้นหลัง
          prefixIcon: Icon(
            Icons.person,
            color: Colors.red, // ตั้งค่าสีของไอคอนเป็นสีแดง
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black), // กำหนดสีของขอบฟิลด์
            borderRadius: BorderRadius.circular(30), // ปรับความโค้งของกรอบ
          ),
        ),
      ),
    );
  }

  // วิดเจ็ตฟิลด์รหัสผ่าน
  Widget inputTwo() {
    return Container(
      margin: EdgeInsets.fromLTRB(
          50, 20, 50, 0), // กำหนดระยะห่างจากขอบ (ซ้าย, บน, ขวา, ล่าง)
      child: TextFormField(
        controller: inputtwo, // กำหนดตัวควบคุมให้กับฟิลด์รหัสผ่าน
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(
              0, 15, 0, 0), // กำหนดระยะห่างภายในฟิลด์ (ซ้าย, บน, ขวา, ล่าง)
          hintText: 'รหัสผ่าน', // ข้อความที่แสดงเมื่อฟิลด์ว่าง
          fillColor:
              Color.fromARGB(255, 255, 255, 255), // กำหนดสีพื้นหลังเป็นสีขาว
          filled: true, // เปิดการใช้งานสีพื้นหลัง
          prefixIcon: Icon(
            Icons.lock,
            color: Colors.red, // ตั้งค่าสีของไอคอนเป็นสีแดง
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black), // กำหนดสีของขอบฟิลด์
            borderRadius: BorderRadius.circular(30), // ปรับความโค้งของกรอบ
          ),
        ),
      ),
    );
  }

  // วิดเจ็ตปุ่มเข้าสู่ระบบ
  Widget buttonProcesslogin() {
    return ButtonTheme(
      minWidth: double.infinity, // กำหนดความกว้างขั้นต่ำของปุ่มให้เต็มหน้าจอ
      child: Container(
        margin: EdgeInsets.fromLTRB(
            50, 20, 50, 0), // กำหนดระยะห่างจากขอบ (ซ้าย, บน, ขวา, ล่าง)
        child: ElevatedButton(
          child: Text(
            "เข้าสู่ระบบ", // ข้อความบนปุ่ม
            style: TextStyle(
              color: Colors.white, // กำหนดสีข้อความเป็นสีขาว
            ),
          ),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.fromLTRB(
                20, 10, 20, 10), // กำหนดระยะห่างภายในปุ่ม (ซ้าย, บน, ขวา, ล่าง)
            backgroundColor:
                Color.fromARGB(249, 255, 4, 4), // กำหนดสีพื้นหลังของปุ่ม
            shadowColor:
                Color.fromARGB(255, 255, 255, 255), // กำหนดสีเงาของปุ่ม
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(30), // ปรับความโค้งของกรอบปุ่ม
              side: BorderSide(color: Colors.black), // กำหนดสีขอบปุ่ม
            ),
          ),
          onPressed: () async {
            // เมื่อกดปุ่ม
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

  // ฟังก์ชันแสดงกล่องข้อความแจ้งเตือน buttonProcesslogin
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("ข้อผิดพลาด"), // หัวข้อของกล่องข้อความแจ้งเตือน
        content: Text(message), // ข้อความที่จะแสดง
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context)
                  .pop(); // ปิดกล่องข้อความแจ้งเตือนเมื่อกดปุ่ม "ตกลง"
            },
            child: Text("ตกลง"), // ข้อความบนปุ่ม
          ),
        ],
      ),
    );
  }

  // ฟังก์ชันล็อกอินธรรมดา
  Future<Map<String, dynamic>> FunctionLogin() async {
    print("user_id: ${inputone.text}"); // แสดง user_id ในคอนโซลสำหรับดีบัก
    print("user_pass: ${inputtwo.text}"); // แสดง user_pass ในคอนโซลสำหรับดีบัก

    // เตรียมข้อมูลที่จะส่ง
    Map<String, String> dataPost = {
      "user_id": inputone.text, // เก็บ user_id ที่ผู้ใช้กรอก
      "user_pass": inputtwo.text, // เก็บ user_pass ที่ผู้ใช้กรอก
    };

    // เตรียมหัวเรื่อง
    Map<String, String> headers = {
      "Content-Type": "application/json", // กำหนด Content-Type เป็น JSON
      "Accept": "application/json" // ยอมรับการตอบกลับเป็น JSON
    };

    var url = Uri.parse(
        "http://10.0.2.2/flutter_webservice/get_Login.php"); // กำหนด URL ของ API ที่ใช้ในการล็อกอิน

    try {
      var response = await http.post(
        url, // ส่งคำขอ POST ไปยัง URL ที่กำหนด
        headers: headers, // แนบ headers ไปกับคำขอ
        body: json.encode(dataPost), // แนบข้อมูลที่ถูกแปลงเป็น JSON ไปกับคำขอ
      );

      print(
          "Response.body Login : ${response.body}"); // แสดงเนื้อหาการตอบกลับในคอนโซลสำหรับดีบัก

      if (response.statusCode == 200) {
        // ตรวจสอบว่าได้รับการตอบกลับจากเซิร์ฟเวอร์หรือไม่
        Map<String, dynamic> jsonResponse =
            json.decode(response.body); // แปลงการตอบกลับจาก JSON เป็น Map

        // ตรวจสอบสถานะก่อน
        if (jsonResponse['status'] == 'inactive') {
          _showErrorDialog(
              "บัญชีของคุณถูกระงับ"); // แสดงกล่องข้อความแจ้งเตือนว่าบัญชีถูกระงับ
          return {'success': false}; // ส่งผลลัพธ์การล็อกอินล้มเหลว
        }

        // ตรวจสอบว่าการเข้าสู่ระบบสำเร็จหรือไม่
        if (jsonResponse['result'] == "1") {
          String userId = jsonResponse['user_id']; // ดึง user_id จากการตอบกลับ
          String jwt = jsonResponse['jwt']; // ดึง JWT จากการตอบกลับ

          // เก็บ JWT ลงในฐานข้อมูล
          var saveJwtResponse = await http.post(
            Uri.parse(
                'http://10.0.2.2/flutter_webservice/get_Savejwt.php'), // กำหนด URL ของ API ที่ใช้เก็บ JWT
            headers: headers, // แนบ headers ไปกับคำขอ
            body: json.encode({
              "user_id": userId, // ส่ง user_id ที่ได้รับจากการล็อกอิน
              "jwt": jwt, // ส่ง JWT ที่ได้รับจากการล็อกอิน
            }),
          );

          if (saveJwtResponse.statusCode == 200) {
            // ตรวจสอบว่าการบันทึก JWT สำเร็จหรือไม่
            Map<String, dynamic> saveJwtJsonResponse = json.decode(
                saveJwtResponse.body); // แปลงการตอบกลับจาก JSON เป็น Map

            if (saveJwtJsonResponse['result'] == "1") {
              return {
                'success': true, // การเข้าสู่ระบบสำเร็จ
                'jwt': jwt // ส่ง JWT กลับ
              };
            } else {
              _showErrorDialog(
                  "การเก็บ JWT ล้มเหลว"); // แสดงกล่องข้อความแจ้งเตือนว่าการเก็บ JWT ล้มเหลว
              return {'success': false}; // การเข้าสู่ระบบล้มเหลว
            }
          } else {
            _showErrorDialog(
                "การเก็บ JWT ล้มเหลว"); // แสดงกล่องข้อความแจ้งเตือนว่าการเก็บ JWT ล้มเหลว
            return {'success': false}; // การเข้าสู่ระบบล้มเหลว
          }
        } else {
          return {'success': false}; // การเข้าสู่ระบบล้มเหลว
        }
      } else {
        print(
            "Request failed with status: ${response.statusCode}"); // แสดงรหัสสถานะที่ล้มเหลวในคอนโซล
        return {'success': false}; // การเข้าสู่ระบบล้มเหลว
      }
    } catch (error) {
      print("Error: $error"); // แสดงข้อผิดพลาดในคอนโซลสำหรับดีบัก
      return {'success': false}; // การเข้าสู่ระบบล้มเหลว
    }
  }

  // วิดเจ็ตปุ่มล็อกอินด้วย Facebook
  Widget buttonfacebook() {
    return Container(
      margin: EdgeInsets.fromLTRB(
          0, 15, 0, 0), // กำหนดระยะห่างจากขอบ (ซ้าย, บน, ขวา, ล่าง)
      child: ElevatedButton.icon(
        icon: Icon(
          Icons.facebook,
          color: Colors.white, // กำหนดสีไอคอนเป็นสีขาว
        ),
        label: Text(
          "Sign up with Facebook", // ข้อความบนปุ่ม
          style: TextStyle(
            color: Colors.white, // กำหนดสีข้อความเป็นสีขาว
          ),
        ),
        onPressed: () {
          facebookLogin(context); // เรียกใช้ฟังก์ชัน facebookLogin เมื่อกดปุ่ม
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.fromLTRB(
              15, 10, 20, 8), // กำหนดระยะห่างภายในปุ่ม (ซ้าย, บน, ขวา, ล่าง)
          backgroundColor:
              Color.fromARGB(255, 31, 136, 234), // กำหนดสีพื้นหลังของปุ่ม
          shadowColor: Colors.black, // กำหนดสีเงาของปุ่ม
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // ปรับความโค้งของกรอบปุ่ม
          ),
          side: BorderSide(color: Colors.black), // กำหนดสีขอบปุ่ม
        ),
      ),
    );
  }

  // ฟังก์ชันล็อกอิน facebook
  Future<void> facebookLogin(BuildContext context) async {
    try {
      final result = await FacebookAuth.instance.login(
        permissions: [
          'public_profile',
          'email'
        ], // ขอสิทธิ์การเข้าถึงโปรไฟล์และอีเมล
      );

      if (result.status == LoginStatus.success) {
        // ตรวจสอบว่าการล็อกอินสำเร็จหรือไม่
        final userData = await FacebookAuth.instance
            .getUserData(); // ดึงข้อมูลผู้ใช้จาก Facebook

        print(
            'ข้อมูล facebook : $userData'); // แสดงข้อมูลผู้ใช้ในคอนโซลสำหรับดีบัก

        // แยกเฉพาะ id จาก userData
        String facebookUserId =
            userData['id'] ?? 'Unknown ID'; // ดึง user_id จากข้อมูลผู้ใช้
        String name =
            userData['name'] ?? 'Unknown Name'; // ดึงชื่อผู้ใช้จากข้อมูลผู้ใช้
        String email =
            userData['email'] ?? 'Unknown Email'; // ดึงอีเมลจากข้อมูลผู้ใช้

        // ตรวจสอบว่ามี user_token ใช้อยู่ในฐานข้อมูลหรือไม่
        var response = await http.post(
          Uri.parse(
              'http://10.0.2.2/flutter_webservice/get_ChackToken.php'), // กำหนด URL ของ API ที่ใช้ตรวจสอบ user_token
          headers: {
            "Content-Type": "application/json"
          }, // กำหนด Content-Type เป็น JSON
          body: jsonEncode(
              {"id": facebookUserId}), // ส่ง user_id ที่ได้จาก Facebook
        );

        if (response.statusCode == 200) {
          // ตรวจสอบว่าการตอบกลับจากเซิร์ฟเวอร์สำเร็จหรือไม่
          var jsonResponse =
              jsonDecode(response.body); // แปลงการตอบกลับจาก JSON เป็น Map

          print(
              'ข้อมูลจาก ChackToken : $jsonResponse'); // แสดงข้อมูลจากการตรวจสอบในคอนโซลสำหรับดีบัก

          // ตรวจสอบสถานะก่อน
          if (jsonResponse['status'] == 'inactive') {
            _showErrorDialog(
                "บัญชีของคุณถูกระงับ"); // แสดงกล่องข้อความแจ้งเตือนว่าบัญชีถูกระงับ
            return;
          }

          if (jsonResponse['exists']) {
            // ตรวจสอบว่ามี user_token อยู่ในฐานข้อมูลหรือไม่
            // ตรวจสอบว่า jwt ไม่มีค่า
            if (jsonResponse['jwt'] == null || jsonResponse['jwt'].isEmpty) {
              print("เข้าเงื่อนไขไม่มี jwt");

              // ถ้ามี user_token แต่ไม่มี user_jwt ให้สร้าง jwt ก่อนและบันทึกลง database แล้วส่งไปหน้า home
              String jwt =
                  generateJwt(jsonResponse['user_id']); // สร้าง JWT จาก user_id

              // เก็บ JWT ลงในฐานข้อมูล
              var saveJwtResponse = await http.post(
                Uri.parse(
                    'http://10.0.2.2/flutter_webservice/get_Savejwt.php'), // กำหนด URL ของ API ที่ใช้เก็บ JWT
                headers: {
                  "Content-Type": "application/json"
                }, // กำหนด Content-Type เป็น JSON
                body: jsonEncode({
                  "user_id": jsonResponse[
                      'user_id'], // ส่ง user_id ที่ได้รับจากการตรวจสอบ
                  "jwt": jwt, // ส่ง JWT ที่สร้างขึ้น
                }),
              );

              print('ข้อมูล saveJwt : $saveJwtResponse[result]');

              if (jwt.isNotEmpty) {
                var saveJwtJsonResponse = jsonDecode(
                    saveJwtResponse.body); // แปลงการตอบกลับจาก JSON เป็น Map

                if (saveJwtJsonResponse['result'] == "1") {
                  // แสดงป๊อปอัพเพื่อแจ้งให้ผู้ใช้เข้าสู่ระบบอีกครั้ง
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("บันทึกข้อมูลสำเร็จ"), // หัวข้อของป๊อปอัพ
                        content: Text(
                            "กรุณาเข้าสู่ระบบอีกครั้ง"), // ข้อความในป๊อปอัพ
                        actions: [
                          TextButton(
                            child: Text("ตกลง"), // ข้อความบนปุ่ม
                            onPressed: () {
                              Navigator.of(context)
                                  .pop(); // ปิดป๊อปอัพเมื่อกดปุ่ม "ตกลง"
                              // ส่งผู้ใช้กลับไปหน้า login
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      LoginPage(), // นำทางไปยังหน้า LoginPage
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  _showErrorDialog(
                      "การเก็บ JWT ล้มเหลว"); // แสดงกล่องข้อความแจ้งเตือนว่าการเก็บ JWT ล้มเหลว
                }
              } else {
                _showErrorDialog(
                    "การเก็บ JWT ล้มเหลว"); // แสดงกล่องข้อความแจ้งเตือนว่าการเก็บ JWT ล้มเหลว
              }
            } else {
              print("เข้าเงื่อนไขมี jwt");

              // ถ้ามี user_token และ user_jwt อยู่ในฐานข้อมูล
              String jwt = jsonResponse['jwt']; // ดึง JWT จากการตอบกลับ

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => Homepage(
                      jwt: jwt), // นำทางไปยังหน้า Homepage พร้อมส่ง JWT
                ),
              );
            }
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => editinformation(
                  six_value:
                      facebookUserId, // ส่ง user_id ของ Facebook ไปยังหน้า editinformation
                  name: name, // ส่งชื่อไปยังหน้า editinformation
                  email: email, // ส่งอีเมลไปยังหน้า editinformation
                ),
              ),
            );
          }
        } else {
          // จัดการข้อผิดพลาดของเซิร์ฟเวอร์
          print(
              'Server error: ${response.statusCode}'); // แสดงรหัสสถานะที่ล้มเหลวในคอนโซล
        }
      }
    } catch (error) {
      print(error); // แสดงข้อผิดพลาดในคอนโซลสำหรับดีบัก
    }
  }

  // ฟังก์ชันสร้าง JWT
  String generateJwt(String userId) {
    final jwt = JWT(
      {
        'user_id': userId, // กำหนดข้อมูลผู้ใช้ภายใน JWT
      },
    );

    final secretKey = 'your_secret_key'; // กำหนดคีย์ลับสำหรับการเซ็น JWT
    final token = jwt.sign(SecretKey(secretKey),
        algorithm: JWTAlgorithm
            .HS256); // สร้างและเซ็น JWT ด้วยคีย์ลับและอัลกอริธึม HS256

    print("Generated JWT: $token"); // แสดง JWT ที่สร้างขึ้นในคอนโซลสำหรับดีบัก

    return token; // ส่ง JWT กลับ
  }

  // วิดเจ็ตปุ่มสมัครสมาชิก
  Widget buttonregister() {
    return Container(
      margin: EdgeInsets.fromLTRB(
          0, 15, 0, 0), // กำหนดระยะห่างจากขอบ (ซ้าย, บน, ขวา, ล่าง)
      child: ElevatedButton.icon(
        icon: Icon(
          Icons.people,
          color: const Color.fromARGB(255, 0, 0, 0), // กำหนดสีไอคอนเป็นสีดำ
        ),
        label: Text(
          "สมัครสมาชิก", // ข้อความบนปุ่ม
          style: TextStyle(
            color: Color.fromARGB(255, 0, 0, 0), // กำหนดสีข้อความเป็นสีดำ
          ),
        ),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => editinformation(
                        name: '', // ส่งชื่อว่างไปยังหน้า editinformation
                        six_value:
                            '', // ส่ง user_id ว่างไปยังหน้า editinformation
                        email: '', // ส่งอีเมลว่างไปยังหน้า editinformation
                      ))); // ไปยังหน้าสมัครสมาชิกเมื่อกดปุ่ม
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.fromLTRB(
              10, 10, 20, 8), // กำหนดระยะห่างภายในปุ่ม (ซ้าย, บน, ขวา, ล่าง)
          backgroundColor: Color.fromARGB(
              255, 255, 255, 255), // กำหนดสีพื้นหลังของปุ่มเป็นสีขาว
          shadowColor: Colors.black, // กำหนดสีเงาของปุ่ม
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // ปรับความโค้งของกรอบปุ่ม
          ),
          side: BorderSide(color: Colors.black), // กำหนดสีขอบปุ่ม
        ),
      ),
    );
  }

  // วิดเจ็ตปุ่มลืมรหัสผ่าน
  Widget buttonforget() {
    return Container(
      margin: EdgeInsets.fromLTRB(
          0, 15, 0, 0), // กำหนดระยะห่างจากขอบ (ซ้าย, บน, ขวา, ล่าง)
      child: ElevatedButton.icon(
        icon: Icon(
          Icons.lock_open,
          color: const Color.fromARGB(255, 0, 0, 0), // กำหนดสีไอคอนเป็นสีดำ
        ),
        label: Text(
          "ลืมรหัสผ่าน", // ข้อความบนปุ่ม
          style: TextStyle(
            color: Color.fromARGB(255, 0, 0, 0), // กำหนดสีข้อความเป็นสีดำ
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
          padding: EdgeInsets.fromLTRB(
              10, 10, 20, 8), // กำหนดระยะห่างภายในปุ่ม (ซ้าย, บน, ขวา, ล่าง)
          backgroundColor: Color.fromARGB(
              255, 255, 255, 255), // กำหนดสีพื้นหลังของปุ่มเป็นสีขาว
          shadowColor: Colors.black, // กำหนดสีเงาของปุ่ม
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // ปรับความโค้งของกรอบปุ่ม
          ),
          side: BorderSide(color: Colors.black), // กำหนดสีขอบปุ่ม
        ),
      ),
    );
  }

  // การสร้าง UI ของหน้าจอล็อกอิน
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Stack(
        children: [
          Scaffold(
            backgroundColor:
                Color.fromARGB(255, 255, 255, 255), // กำหนดสีพื้นหลังเป็นสีขาว
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
