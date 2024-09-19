import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // นำเข้าไลบรารี Google Maps
import 'package:url_launcher/url_launcher.dart'; // นำเข้าไลบรารีสำหรับเปิดลิงก์ในเบราว์เซอร์
import 'package:http/http.dart' as http; // นำเข้าไลบรารีสำหรับ HTTP requests
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:wegosport/Homepage.dart';
import 'package:wegosport/chat.dart'; // นำเข้าหน้า Homepage


// หน้ากิจกรรม
class ActivityPage extends StatelessWidget {
  final dynamic activity;
  final String jwt;
  final String userId; // รับค่าจากหน้า Home

  ActivityPage({
    super.key,
    required this.activity,
    required this.jwt,
    required this.userId, // กำหนดให้รับ userId จาก Home
  });

  @override
  Widget build(BuildContext context) {
    print('userId ที่ได้รับใน ActivityPage: $userId'); // พิมพ์ค่า userId เพื่อตรวจสอบ
    print('JWT ที่ได้รับใน ActivityPage: $jwt');


    // แปลงค่าจาก String เป็น double สำหรับพิกัดแผนที่
    double latitude = double.tryParse(activity['latitude'] ?? '0.0') ?? 0.0;
    double longitude = double.tryParse(activity['longitude'] ?? '0.0') ?? 0.0;

    // ฟังก์ชันเปิดแผนที่ใน Google Maps
    void _openMap() async {
      String googleUrl =
          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude'; // URL สำหรับเปิดแผนที่
      if (await canLaunch(googleUrl)) {
        await launch(googleUrl); // เปิดลิงก์ถ้าทำได้
      } else {
        throw 'Could not open the map.'; // แสดงข้อผิดพลาดหากเปิดไม่ได้
      }
    }

    void _joinActivity() async {
      // แปลง activity_id จาก String เป็น int
      int activityId = int.tryParse(activity['activity_id'] ?? '0') ?? 0;

      // URL สำหรับส่งข้อมูลไปยังเซิร์ฟเวอร์
      String url = 'http://10.0.2.2/flutter_webservice/addmember.php';

      print('ข้อมูล user_id : $userId');
      print('ข้อมูล activity_id : $activityId');

      // ข้อมูลที่จะส่งไป
      Map<String, dynamic> body = {
        'user_id': userId,
        'activity_id': activityId.toString(), // ส่งเป็น String ใน HTTP POST
      };

      // ส่งข้อมูลด้วย HTTP POST
      var response = await http.post(Uri.parse(url), body: body);

      if (response.statusCode == 200) {
        print('เข้าร่วมกิจกรรมสำเร็จ');
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
                  Navigator.of(context).pop(); // ปิดป๊อปอัป
                },
              ),
              TextButton(
                child: Text('ตกลง'),
                onPressed: () {
                  // เรียกใช้ฟังก์ชันในการเพิ่มสมาชิก
                  _joinActivity();
                  Navigator.of(context).pop(); // ปิดป๊อปอัป
                },
              ),
            ],
          );
        },
      );
    }

    // ดึงชื่อผู้ใช้จาก members
    String userName = (activity['members'] != null &&
            activity['members'].isNotEmpty)
        ? activity['members'][0]['user_name']
        : 'ไม่ระบุชื่อ'; // ถ้ามีสมาชิกให้แสดงชื่อ ถ้าไม่มีก็แสดงว่า "ไม่ระบุชื่อ"

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color:
                  const Color.fromARGB(255, 255, 255, 255)), // ไอคอนลูกศรกลับ
          onPressed: () => Navigator.of(context).pop(), // กลับไปหน้าที่แล้ว
        ),
        title: Text('หน้ากิจกรรมที่เข้าร่วม',
            style: TextStyle(
                color:
                    const Color.fromARGB(255, 255, 255, 255))), // หัวข้อของหน้า
        backgroundColor:
            const Color.fromARGB(255, 255, 0, 0), // กำหนดสีพื้นหลังของ AppBar
        elevation: 0, // กำหนดความสูงของเงา AppBar
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0), // กำหนด padding ของหน้า
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // จัดตำแหน่งเนื้อหาไปทางซ้าย
          children: [
            // แท็ก
            Wrap(
              runSpacing: 5.0, // ระยะห่างระหว่างแท็ก
              children: (activity['hashtags'] as List<dynamic>? ?? [])
                  .map((tag) => TagWidget(
                      text: tag['hashtag_message'])) // สร้างวิดเจ็ตแท็ก
                  .toList(),
            ),
            SizedBox(height: 8),
            // วันที่นัดหมาย
            Text(
              'วันที่นัดหมาย ${activity['activity_date'] + " น." ?? 'ไม่ระบุวันที่'}',
              style: TextStyle(color: Colors.grey), // ข้อความสีเทา
            ),
            SizedBox(height: 8),
            // ชื่อกิจกรรม
            Text(
              activity['activity_name'] ?? 'ไม่ระบุชื่อกิจกรรม',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24), // ข้อความชื่อกิจกรรม
            ),
            SizedBox(height: 8),
            // สถานที่
            Text(activity['location_name'] ??
                'ไม่ระบุสถานที่'), // แสดงชื่อสถานที่
            SizedBox(height: 8),
            // ผู้ใช้
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: activity['members'] != null &&
                          activity['members'].isNotEmpty &&
                          (activity['members'] as List).any((member) =>
                              member['user_id'] == activity['creator'])
                      ? NetworkImage(
                          (activity['members'] as List).firstWhere((member) =>
                              member['user_id'] ==
                              activity['creator'])['user_photo'],
                        )
                      : AssetImage('images/logo.png')
                          as ImageProvider, // ถ้าไม่พบรูปให้แสดงโลโก้
                  radius: 16, // ขนาดของ Avatar
                ),
                SizedBox(width: 8),
                Text(activity['creator'] ??
                    'ไม่ระบุชื่อ'), // แสดงชื่อผู้สร้างกิจกรรม
              ],
            ),
            SizedBox(height: 16),
            // แผนที่
            Center(
              child: GestureDetector(
                onTap: _openMap, // เมื่อคลิกแผนที่ให้เปิด Google Maps
                child: Container(
                  padding: EdgeInsets.all(16), // padding ของแผนที่
                  decoration: BoxDecoration(
                    color: Colors.grey[300], // สีพื้นหลังของ Container
                    borderRadius: BorderRadius.circular(16), // ความโค้งของขอบ
                  ),
                  child: Column(
                    children: [
                      Text('แผนที่',
                          style: TextStyle(
                              color: Colors.black)), // ข้อความหัวข้อแผนที่
                      SizedBox(height: 8),
                      Container(
                        height: 200, // ความสูงของแผนที่
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(latitude,
                                longitude), // กำหนดตำแหน่งเริ่มต้นของกล้อง
                            zoom: 14, // ระดับการซูมของกล้อง
                          ),
                          markers: {
                            Marker(
                              markerId:
                                  MarkerId('activityLocation'), // ID ของ Marker
                              position: LatLng(
                                  latitude, longitude), // ตำแหน่งของ Marker
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
            // สมาชิกในกลุ่ม
            Text('สมาชิกในกลุ่ม',
                style: TextStyle(
                    fontWeight: FontWeight.bold)), // ข้อความหัวข้อสมาชิกในกลุ่ม
            SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.add_circle,
                      color: Color.fromARGB(
                          255, 156, 156, 156)), // ไอคอนสำหรับเพิ่มสมาชิก
                  onPressed: () {
                    // Add action for adding member
                  },
                ),
                ...List<Widget>.from(
                  (activity['members'] as List<dynamic>).map(
                    (member) => CircleAvatar(
                      backgroundImage: member['user_photo'] != null &&
                              member['user_photo'].isNotEmpty
                          ? NetworkImage(member[
                              'user_photo']) // แสดงรูปภาพจาก URL ของสมาชิก
                          : AssetImage('images/logo.png')
                              as ImageProvider, // ใช้โลโก้ถ้าไม่มีรูป
                      radius: 16, // ขนาดของ Avatar
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // ปุ่มเข้าร่วมกิจกรรม
            Center(
              child: (activity['members'] as List<dynamic>)
                      .any((member) => member['user_id'] == userId)
                  ? ElevatedButton(
                      onPressed: () {
                        // ไปยังหน้าห้องแชท
                        var channel = WebSocketChannel.connect(
                          Uri.parse('ws://10.0.2.2:8080'),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              channel: channel,
                              activity: activity,
                              jwt: jwt, // ส่งค่า jwt ไปด้วย
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: const Color.fromARGB(
                            255, 255, 255, 255), // สีข้อความในปุ่ม
                        backgroundColor: Color.fromARGB(255, 44, 177, 0), // สีพื้นหลังของปุ่มแชท (สีฟ้า)
                        minimumSize: Size(double.infinity, 50), // ขนาดของปุ่ม
                      ),
                      child: Text('แชท'), // ข้อความในปุ่มสำหรับแชท
                    )
                  : ElevatedButton(
                      onPressed: () {
                        _confirmJoinActivity(
                            context); // แสดงป๊อปอัปเมื่อกดปุ่มเข้าร่วมกิจกรรม
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: const Color.fromARGB(
                            255, 255, 255, 255), // สีข้อความในปุ่ม
                        backgroundColor: Color.fromARGB(255, 255, 0,
                            0), // สีพื้นหลังของปุ่มเข้าร่วมกิจกรรม (สีแดง)
                        minimumSize: Size(double.infinity, 50), // ขนาดของปุ่ม
                      ),
                      child: Text(
                          'เข้าร่วมกิจกรรม'), // ข้อความในปุ่มเข้าร่วมกิจกรรม
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
  final String text; // ข้อความแท็ก

  TagWidget({required this.text}); // Constructor รับข้อความแท็ก

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 8), // ระยะห่างด้านขวาของแท็ก
      padding:
          EdgeInsets.symmetric(horizontal: 12, vertical: 4), // padding ของแท็ก
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 175, 175, 175), // สีพื้นหลังของแท็ก
        borderRadius: BorderRadius.circular(20), // ความโค้งของขอบแท็ก
      ),
      child: Text(
        text, // ข้อความแท็ก
        style: TextStyle(
          color: const Color.fromARGB(255, 0, 0, 0), // สีข้อความในแท็ก
        ),
      ),
    );
  }
}
