import 'package:flutter/material.dart';
import 'package:wegosport/Login.dart';

void main() {
  runApp(MyApp()); // ฟังก์ชันหลักของแอป เริ่มต้นการทำงานของแอป
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // คอนสตรักเตอร์สำหรับ MyApp
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(), // กำหนดหน้าหลักเมื่อเปิดแอปคือ LoginPage
    );
  }
}
