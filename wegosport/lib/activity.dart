import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:wegosport/Homepage.dart';
import 'package:wegosport/chat.dart';

import 'package:intl/intl.dart';


// หน้ากิจกรรม
class ActivityPage extends StatefulWidget {
  final dynamic activity;
  final String jwt;
  final String userId;

  ActivityPage({
    super.key,
    required this.activity,
    required this.jwt,
    required this.userId,
  });

  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  @override
  Widget build(BuildContext context) {
    print('userId ที่ได้รับใน ActivityPage: ${widget.userId}');
    print('JWT ที่ได้รับใน ActivityPage: ${widget.jwt}');

    // แปลงวันเวลาเป็น DateTime
    DateTime activityDate;

    try {
      activityDate = DateFormat('yyyy-MM-dd HH:mm:ss')
          .parse(widget.activity['activity_date']);
    } catch (e) {
      activityDate = DateTime.now(); // ถ้ามีปัญหาในการแปลงจะใช้วันเวลาปัจจุบัน
    }

    // จัดรูปแบบวันเวลาเป็นภาษาไทย
    String formattedDate =
        DateFormat('HH:mm น. d MMMM ', 'th_TH').format(activityDate);

    // แปลงปีเป็นพุทธศักราช
    int buddhistYear = activityDate.year + 543;
    formattedDate += buddhistYear.toString();

    // แปลงค่าจาก String เป็น double สำหรับพิกัดแผนที่
    double latitude =
        double.tryParse(widget.activity['latitude'] ?? '0.0') ?? 0.0;
    double longitude =
        double.tryParse(widget.activity['longitude'] ?? '0.0') ?? 0.0;

    // ฟังก์ชันเปิดแผนที่ใน Google Maps
    void _openMap() async {
      String googleUrl =
          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
      if (await canLaunch(googleUrl)) {
        await launch(googleUrl);
      } else {
        throw 'Could not open the map.';
      }
    }

    // ฟังก์ชันเข้าร่วมกิจกรรม
    void _joinActivity() async {
      int activityId = int.tryParse(widget.activity['activity_id'] ?? '0') ?? 0;

      String url = 'http://10.0.2.2/flutter_webservice/addmember.php';
      print('ข้อมูล user_id : ${widget.userId}');
      print('ข้อมูล activity_id : $activityId');

      Map<String, dynamic> body = {
        'user_id': widget.userId,
        'activity_id': activityId.toString(),
      };

      var response = await http.post(Uri.parse(url), body: body);

      if (response.statusCode == 200) {
        print('เข้าร่วมกิจกรรมสำเร็จ');

        // เมื่อเข้าร่วมกิจกรรมสำเร็จ ให้เพิ่มผู้ใช้ลงใน members ของ activity
        setState(() {
          widget.activity['members'].add({
            'user_id': widget.userId,
            'user_name': 'ชื่อผู้ใช้ที่เข้าร่วม',
            'user_photo': 'url รูปผู้ใช้'
          });
        });
      } else {
        print('เกิดข้อผิดพลาดในการเข้าร่วมกิจกรรม');
      }
    }

    // ฟังก์ชันป๊อปอัปยืนยันการเข้าร่วมกิจกรรม
    void _confirmJoinActivity(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('ยืนยันการเข้าร่วมกิจกรรม'),
            content: Text('คุณต้องการเข้าร่วมกิจกรรมนี้หรือไม่?'),
            actions: <Widget>[
              TextButton(
                child: Text('ยกเลิก'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('ตกลง'),
                onPressed: () {
                  _joinActivity();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    // ดึงชื่อผู้ใช้จาก members
    String userName = (widget.activity['members'] != null &&
            widget.activity['members'].isNotEmpty)
        ? widget.activity['members'][0]['user_name']
        : 'ไม่ระบุชื่อ';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: const Color.fromARGB(255, 255, 255, 255)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('หน้ากิจกรรมที่เข้าร่วม',
            style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255))),
        backgroundColor: const Color.fromARGB(255, 255, 0, 0),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              runSpacing: 5.0,
              children: (widget.activity['hashtags'] as List<dynamic>? ?? [])
                  .map((tag) => TagWidget(text: tag['hashtag_message']))
                  .toList(),
            ),
            SizedBox(height: 8),
            Text(
              'วันที่นัดหมาย $formattedDate',
              style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
            ),
            SizedBox(height: 8),
            Text(
              widget.activity['activity_name'] ?? 'ไม่ระบุชื่อกิจกรรม',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            SizedBox(height: 8),
            Text(widget.activity['location_name'] ?? 'ไม่ระบุสถานที่'),
            SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: widget.activity['members'] != null &&
                          widget.activity['members'].isNotEmpty &&
                          (widget.activity['members'] as List).any((member) =>
                              member['user_id'] == widget.activity['creator'])
                      ? NetworkImage(
                          (widget.activity['members'] as List).firstWhere(
                              (member) =>
                                  member['user_id'] ==
                                  widget.activity['creator'])['user_photo'],
                        )
                      : AssetImage('images/logo.png') as ImageProvider,
                  radius: 16,
                ),
                SizedBox(width: 8),
                Text(widget.activity['creator'] ?? 'ไม่ระบุชื่อ'),
              ],
            ),
            SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: _openMap,
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text('แผนที่', style: TextStyle(color: Colors.black)),
                      SizedBox(height: 8),
                      Container(
                        height: 200,
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(latitude, longitude),
                            zoom: 14,
                          ),
                          markers: {
                            Marker(
                              markerId: MarkerId('activityLocation'),
                              position: LatLng(latitude, longitude),
                            ),
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text('สมาชิกในกลุ่ม',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.add_circle,
                      color: Color.fromARGB(255, 156, 156, 156)),
                  onPressed: () {
                    // Add action for adding member
                  },
                ),
                ...List<Widget>.from(
                  (widget.activity['members'] as List<dynamic>).map(
                    (member) => CircleAvatar(
                      backgroundImage: member['user_photo'] != null &&
                              member['user_photo'].isNotEmpty
                          ? NetworkImage(member['user_photo'])
                          : AssetImage('images/logo.png') as ImageProvider,
                      radius: 16,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Center(
              child: (widget.activity['members'] as List<dynamic>)
                      .any((member) => member['user_id'] == widget.userId)
                  ? ElevatedButton(
                      onPressed: () {
                        var channel = WebSocketChannel.connect(
                          Uri.parse('ws://10.0.2.2:8080'),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              channel: channel,
                              activity: widget.activity,
                              jwt: widget.jwt,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            const Color.fromARGB(255, 255, 255, 255),
                        backgroundColor: Color.fromARGB(255, 255, 0, 0),
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text(
                        'แชท',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        _confirmJoinActivity(context);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            const Color.fromARGB(255, 255, 255, 255),
                        backgroundColor: Color.fromARGB(255, 255, 0, 0),
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text(
                        'เข้าร่วมกิจกรรม',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// วิดเจ็ตแสดงแท็ก
class TagWidget extends StatelessWidget {
  final String text;

  TagWidget({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 175, 175, 175),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: const Color.fromARGB(255, 0, 0, 0),
        ),
      ),
    );
  }
}
