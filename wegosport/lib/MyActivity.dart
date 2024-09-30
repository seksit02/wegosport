import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:wegosport/Activity.dart';

class Myactivity extends StatefulWidget {
  final dynamic activity; // ตัวแปรที่เก็บข้อมูลกิจกรรม (activity) ที่ถูกส่งผ่าน
  final String jwt; // ตัวแปร JWT (JSON Web Token) สำหรับตรวจสอบตัวตนผู้ใช้

  const Myactivity({super.key, this.activity, required this.jwt});

  @override
  State<Myactivity> createState() => _MyactivityState();
}

class _MyactivityState extends State<Myactivity> {
  Map<String, dynamic>? userData;
  List<dynamic> activities = []; // เก็บข้อมูลกิจกรรมทั้งหมด
  List<dynamic> userActivities = []; // เก็บข้อมูลกิจกรรมที่ผู้ใช้เข้าร่วม

  @override
  void initState() {
    super.initState();
    fetchUserData(widget.jwt).then((_) {
      fetchActivities(); // ดึงข้อมูลกิจกรรมเมื่อดึงข้อมูลผู้ใช้สำเร็จ
    });
  }

  // ฟังก์ชันดึงข้อมูลผู้ใช้จาก JWT
  Future<void> fetchUserData(String jwt) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2/flutter_webservice/get_ShowDataUser.php'),
      headers: {
        'Authorization': 'Bearer $jwt',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List && data.isNotEmpty) {
        setState(() {
          userData = data[0];
        });
      } else {
        print('No user data found');
      }
    } else {
      print('Failed to fetch user data');
    }
  }

  // ฟังก์ชันดึงข้อมูลกิจกรรมจากเซิร์ฟเวอร์
  Future<void> fetchActivities() async {
    final response = await http.get(Uri.parse(
        'http://10.0.2.2/flutter_webservice/get_ShowDataActivity.php'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // จัดเรียงกิจกรรมตามวันที่สร้าง
      data.sort((a, b) {
        final dateA = DateTime.parse(a['activity_date']);
        final dateB = DateTime.parse(b['activity_date']);
        return dateB.compareTo(dateA); // จัดเรียงตามลำดับวันที่
      });

      // ตรวจสอบว่าผู้ใช้เป็นสมาชิกในกิจกรรมไหนบ้าง
      List<dynamic> filteredActivities = data.where((activity) {
        List<dynamic> members = activity['members'];

        // ตรวจสอบว่า user_id ของผู้ใช้ตรงกับสมาชิกในกิจกรรมหรือไม่
        bool isMember =
            members.any((member) => member['user_id'] == userData?['user_id']);
        return isMember;
      }).toList();

      setState(() {
        activities = data;
        userActivities = filteredActivities; // เก็บกิจกรรมที่ผู้ใช้เข้าร่วม
      });
    } else {
      throw Exception('Failed to load activities');
    }
  }

  // ฟังก์ชันสร้างรายการกิจกรรมที่ผู้ใช้เข้าร่วม
  Widget _buildActivityList() {
    if (userActivities.isEmpty) {
      return const Center(child: Text('ไม่มีกิจกรรมที่คุณเข้าร่วม'));
    }
    return ListView.builder(
      itemCount: userActivities.length,
      itemBuilder: (context, index) {
        final activity = userActivities[index];
        
        return ListTile(
          title: Text(activity['activity_name']),
          subtitle: Text('วันที่: ${activity['activity_date']}'),

          onTap: () {
            // เมื่อกดเข้ากิจกรรม
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ActivityPage(
                  activity: activity,
                  jwt: widget.jwt,
                  userId: userData?[
                      'user_id'], // ส่ง userId ที่เป็น String ไปแทน Map ทั้งหมด
                ),
              ),
            );
          },

        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('กิจกรรมที่ฉันเข้าร่วม'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _buildActivityList(),
      ),
    );
  }
}

class ActivityDetailPage extends StatelessWidget {
  final dynamic activity;

  const ActivityDetailPage({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(activity['activity_name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ชื่อกิจกรรม: ${activity['activity_name']}'),
            SizedBox(height: 8),
            Text('วันที่จัด: ${activity['activity_date']}'),
            SizedBox(height: 8),
            Text('รายละเอียด: ${activity['activity_detail']}'),
            // เพิ่มข้อมูลอื่น ๆ ของกิจกรรมที่ต้องการแสดง
          ],
        ),
      ),
    );
  }
}
