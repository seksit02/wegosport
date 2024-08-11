import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditActivity extends StatefulWidget {
  final String
      activityId; // รับค่า activityId เพื่อระบุว่ากิจกรรมใดที่ต้องแก้ไข

  const EditActivity({Key? key, required this.activityId}) : super(key: key);

  @override
  State<EditActivity> createState() => _EditActivityState();
}

class _EditActivityState extends State<EditActivity> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _hashtagController = TextEditingController();
  TextEditingController _detailsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchActivityDetails(); // ดึงข้อมูลกิจกรรมเพื่อตั้งค่าเริ่มต้นในฟอร์ม
  }

  // ฟังก์ชันสำหรับดึงข้อมูลกิจกรรมเพื่อแสดงในฟอร์ม
  Future<void> _fetchActivityDetails() async {
    final response = await http.get(
      Uri.parse(
          'http://10.0.2.2/flutter_webservice/get_ActivityDetails.php?id=${widget.activityId}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _nameController.text = data['activity_name'];
        _dateController.text = data['activity_date'];
        _locationController.text = data['location_name'];
        _hashtagController.text =
            data['hashtags'].join(', '); // สมมติว่า hashtags เป็นลิสต์
        _detailsController.text = data['activity_details'];
      });
    } else {
      // จัดการกรณีที่ไม่สามารถดึงข้อมูลได้
      print('Failed to load activity details');
    }
  }

  // ฟังก์ชันสำหรับอัปเดตกิจกรรม
  Future<void> _updateActivity() async {
    if (_formKey.currentState?.validate() ?? false) {
      // ส่งข้อมูลไปยัง API เพื่อทำการอัปเดต
      final response = await http.post(
        Uri.parse('http://10.0.2.2/flutter_webservice/UpdateActivity.php'),
        body: {
          'activity_id': widget.activityId,
          'activity_name': _nameController.text,
          'activity_date': _dateController.text,
          'location_name': _locationController.text,
          'hashtags': _hashtagController.text,
          'activity_details': _detailsController.text,
        },
      );

      if (response.statusCode == 200) {
        // แสดงป๊อปอัพเมื่อการอัปเดตสำเร็จ
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('สำเร็จ'),
              content: Text('แก้ไขกิจกรรมสำเร็จ'),
              actions: [
                TextButton(
                  child: Text('ตกลง'),
                  onPressed: () {
                    Navigator.of(context).pop(); // ปิดป๊อปอัพ
                  },
                ),
              ],
            );
          },
        );
      } else {
        // แสดงป๊อปอัพเมื่อการอัปเดตล้มเหลว
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('ล้มเหลว'),
              content: Text('การแก้ไขกิจกรรมล้มเหลว'),
              actions: [
                TextButton(
                  child: Text('ตกลง'),
                  onPressed: () {
                    Navigator.of(context).pop(); // ปิดป๊อปอัพ
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('แก้ไขกิจกรรม'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'ชื่อกิจกรรม'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกชื่อกิจกรรม';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(labelText: 'วันที่'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกวันที่';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'สถานที่'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกสถานที่';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _hashtagController,
                decoration: InputDecoration(labelText: 'แฮชแท็ก'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกแฮชแท็ก';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _detailsController,
                decoration: InputDecoration(labelText: 'ข้อความสังเขป'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกข้อความสังเขป';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateActivity,
                child: Text('บันทึกการเปลี่ยนแปลง'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
