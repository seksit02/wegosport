import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wegosport/Homepage.dart';

// หน้ากิจกรรม
class ActivityPage extends StatelessWidget {
  final dynamic activity;

  ActivityPage({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    
    // แปลงค่าจาก String เป็น double
    double latitude = double.tryParse(activity['latitude'] ?? '0.0') ?? 0.0;
    double longitude = double.tryParse(activity['longitude'] ?? '0.0') ?? 0.0;

    void _openMap() async {
      String googleUrl =
          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
      if (await canLaunch(googleUrl)) {
        await launch(googleUrl);
      } else {
        throw 'Could not open the map.';
      }
    }

    // ดึงชื่อผู้ใช้จาก members
    String userName =
        (activity['members'] != null && activity['members'].isNotEmpty)
            ? activity['members'][0]['user_name']
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
            // แท็ก
            Wrap(
              runSpacing: 5.0,
              children: (activity['hashtags'] as List<dynamic>? ?? [])
                  .map((tag) => TagWidget(text: tag['hashtag_message']))
                  .toList(),
            ),
            SizedBox(height: 8),
            // วันที่นัดหมาย
            Text(
              'วันที่นัดหมาย ${activity['activity_date'] + " น." ?? 'ไม่ระบุวันที่'}',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 8),
            // ชื่อกิจกรรม
            Text(
              activity['activity_name'] ?? 'ไม่ระบุชื่อกิจกรรม',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            SizedBox(height: 8),
            // สถานที่
            Text(activity['location_name'] ?? 'ไม่ระบุสถานที่'),
            SizedBox(height: 8),
            // ผู้ใช้
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage('images/logo.png'),
                  radius: 16,
                ),
                SizedBox(width: 8),
                Text(activity['members'] != null &&
                        activity['members'].isNotEmpty
                    ? (activity['members'] as List)
                        .map((member) => member['user_name'])
                        .join(', ')
                    : 'ไม่ระบุชื่อ'),
              ],
            ),
            SizedBox(height: 16),
            // แผนที่
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
            // สมาชิกในกลุ่ม
            Text('สมาชิกในกลุ่ม',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.add_circle, color: Color.fromARGB(255, 156, 156, 156)),
                  onPressed: () {
                    // Add action for adding member
                  },
                ),
                ...List<Widget>.from(
                  (activity['members'] as List<dynamic>).map(
                    (member) => CircleAvatar(
                      backgroundImage: AssetImage(
                          'images/logo.png'), // Replace with member's actual image URL if available
                      radius: 16,
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
                  foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                  backgroundColor: Color.fromARGB(255, 255, 0, 0),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('เข้าร่วมกิจกรรม'),
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
