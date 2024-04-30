import 'package:flutter/material.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({Key? key}) : super(key: key);

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('หน้าหลักกิจกรรม'),
          backgroundColor: Colors.red, // กำหนดสีพื้นหลังของแถบ App Bar เป็นสีแดง
        ),
        body: Container(
          color: Colors.red, // กำหนดสีพื้นหลังของหน้าจอเป็นสีแดง
          child: Center(
            child: Text(
              'นี่คือหน้าหลักกิจกรรม',
              style: TextStyle(
                fontSize: 24.0,
                color: Colors.white, // กำหนดสีข้อความเป็นสีขาว
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(ActivityPage());
}
