import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // นำเข้าไลบรารี Google Maps
import 'package:url_launcher/url_launcher.dart'; // นำเข้าไลบรารีสำหรับเปิดลิงก์ในเบราว์เซอร์
import 'package:wegosport/Homepage.dart'; // นำเข้าหน้า Homepage

// หน้ากิจกรรม
class ActivityPage extends StatelessWidget {
  final dynamic activity; // ตัวแปรเก็บข้อมูลกิจกรรมที่ส่งเข้ามา

  ActivityPage(
      {super.key, required this.activity}); // Constructor รับข้อมูลกิจกรรม

  @override
  Widget build(BuildContext context) {
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
                  backgroundImage:
                      AssetImage('images/logo.png'), // แสดงรูปภาพผู้ใช้ (โลโก้)
                  radius: 16, // ขนาดของ Avatar
                ),
                SizedBox(width: 8),
                Text(activity['members'] != null &&
                        activity['members'].isNotEmpty
                    ? (activity['members'] as List)
                        .map((member) => member['user_name'])
                        .join(', ') // รวมชื่อสมาชิกด้วยเครื่องหมายคอมมา
                    : 'ไม่ระบุชื่อ'), // แสดงชื่อสมาชิก
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
                      backgroundImage: AssetImage(
                          'images/logo.png'), // แทนที่ด้วย URL รูปภาพจริงของสมาชิกถ้ามี
                      radius: 16, // ขนาดของ Avatar
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // ปุ่มเข้าร่วมกิจกรรม
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Add action for joining chat
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color.fromARGB(
                      255, 255, 255, 255), // สีข้อความในปุ่ม
                  backgroundColor:
                      Color.fromARGB(255, 255, 0, 0), // สีพื้นหลังของปุ่ม
                  minimumSize: Size(double.infinity, 50), // ขนาดของปุ่ม
                ),
                child: Text('เข้าร่วมกิจกรรม'), // ข้อความในปุ่ม
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
