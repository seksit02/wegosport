import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // ใช้สำหรับจัดการวันที่
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

  // ฟังก์ชันสำหรับการแปลงวันที่เป็นรูปแบบไทย
  String formatThaiDate(String dateString) {
    DateTime date = DateTime.parse(dateString);
    String formattedTime = DateFormat('HH:mm น.', 'th_TH').format(date);
    String formattedDate = DateFormat('d MMMM ', 'th_TH').format(date);
    int buddhistYear = date.year + 543;
    return '$formattedTime $formattedDate $buddhistYear';
  }

  // ฟังก์ชันสร้างรายการกิจกรรมที่ผู้ใช้เข้าร่วม
  Widget _buildActivityList() {

    if (userActivities.isEmpty) {
      return const Center(child: Text('ไม่มีกิจกรรมที่คุณเข้าร่วม'));
    }

    return ListView.builder(
      shrinkWrap: true, // เพื่อให้สามารถทำงานได้ใน Column
      itemCount: userActivities.length,
      itemBuilder: (context, index) {
        final activity = userActivities[index];

        // แปลงวันที่เป็นรูปแบบที่ต้องการ
        String formattedDate = formatThaiDate(activity['activity_date']);

        // ดึงรูปภาพสถานที่จาก activity
        String? locationPhoto = activity['location_photo'];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 5, // เพิ่มเงาให้การ์ด
          child: InkWell(
            borderRadius: BorderRadius.circular(15.0),
            onTap: () {
              // เมื่อกดเข้ากิจกรรม
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ActivityPage(
                    activity: activity,
                    jwt: widget.jwt,
                    userId:
                        userData?['user_id'] ?? '', // ส่ง userId ที่เป็น String
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0), // เพิ่ม Padding รอบการ์ด
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // รูปภาพสถานที่
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: locationPhoto != null && locationPhoto.isNotEmpty
                        ? Image.network(
                            locationPhoto,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'images/default_location.png', // รูปภาพ default หากไม่มีรูป
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                  ),
                  const SizedBox(
                      width: 16.0), // ระยะห่างระหว่างรูปภาพกับข้อความ
                  // ข้อมูลกิจกรรม
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity['activity_name'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                          overflow: TextOverflow.ellipsis, // ตัดข้อความยาวเกิน
                        ),
                        const SizedBox(height: 8.0), // ระยะห่างระหว่างข้อความ
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 16.0, color: Colors.grey),
                            const SizedBox(width: 5.0),
                            Text(
                              'วันที่ : $formattedDate',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // ไอคอนลูกศรแสดงการเข้ากิจกรรม
                  const Icon(Icons.arrow_forward_ios,
                      color: Colors.grey, size: 16.0),
                ],
              ),
            ),
          ),
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
        padding: const EdgeInsets.all(1.0),
        child: _buildActivityList(),
      ),
    );
  }
}