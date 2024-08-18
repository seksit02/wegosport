import 'package:flutter/material.dart';
import 'package:wegosport/Activity.dart';
import 'package:wegosport/Addlocation.dart';
import 'package:wegosport/EditProfile.dart';
import 'package:wegosport/chat.dart';
import 'package:wegosport/Createactivity.dart';
import 'package:wegosport/Addinformation.dart';
import 'package:wegosport/forgetpassword.dart';
import 'package:wegosport/groupchat.dart';
import 'package:wegosport/Homepage.dart';
import 'package:wegosport/Login.dart';
import 'package:wegosport/Profile.dart'; // นำเข้าไฟล์และไลบรารีที่จำเป็นสำหรับแอป

void main() {
  runApp(MyApp()); // ฟังก์ชันหลักของแอป เริ่มต้นการทำงานของแอป
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // คอนสตรักเตอร์สำหรับ MyApp
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(), // กำหนดหน้าหลักเมื่อเปิดแอปคือ LoginPage
      routes: {
        '/Profile': (context) => ProfilePage(
              jwt: '',
            ), // เส้นทางสำหรับไปยังหน้า ProfilePage พร้อมส่งค่า jwt
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
            builder: (context) =>
                UnknownPage()); // กำหนดหน้าสำรองเมื่อเส้นทางไม่ถูกต้อง
      },
    );
  }
}

class UnknownPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Unknown Page'), // กำหนดชื่อหน้าสำรอง
      ),
      body: Center(
        child: Text(
            'This page does not exist!'), // ข้อความที่จะแสดงเมื่อเส้นทางไม่ถูกต้อง
      ),
    );
  }
}
