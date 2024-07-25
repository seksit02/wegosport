import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('หน้ากิจกรรมที่เข้าร่วม'),
        backgroundColor: const Color.fromARGB(255, 255, 0, 0),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8.0,
              children: [
                Chip(label: Text('ตีแบด')),
                Chip(label: Text('สนามกลาง')),
                Chip(label: Text('คิวบ์')),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'วันที่, ${activity['activity_date'] ?? 'ไม่ระบุวันที่'}',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              activity['activity_name'] ?? 'ไม่ระบุชื่อกิจกรรม',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            SizedBox(height: 8),
            Text(activity['location_name'] ?? 'ไม่ระบุสถานที่'),
            SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage('images/P001.jpg'),
                  radius: 16,
                ),
                SizedBox(width: 8),
                Text(activity['members'] != null &&
                        activity['members'].isNotEmpty
                    ? (activity['members'] as List)
                        .map((member) => member['user_id'])
                        .join(', ')
                    : 'ไม่ระบุชื่อ'),

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
                        color: Colors.white,
                        child: Center(
                          child:Image.asset("images/logo.png", height: 200),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text('สมัครเข้ากลุ่ม',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.add_circle, color: Colors.grey),
                  onPressed: () {
                    // Add action for adding member
                  },
                ),
                ...List<Widget>.from(
                  (activity['members'] as List<dynamic>).map(
                    (member) => CircleAvatar(
                      backgroundImage: AssetImage(
                          'images/P001.jpg'), // Replace with member's actual image URL if available
                      radius: 16,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Add action for joining chat
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.yellow,
                  onPrimary: Colors.black,
                  minimumSize: Size(double.infinity, 50), // ปรับขนาดของปุ่ม
                ),
                child: Text('แชท'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
