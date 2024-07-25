import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wegosport/Addlocation.dart';
import 'package:wegosport/Createactivity.dart';
import 'package:wegosport/Profile.dart';
import 'package:wegosport/Activity.dart';
import 'package:wegosport/groupchat.dart';
import 'dart:convert';
import 'package:wegosport/Login.dart';
import 'dart:ui';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<dynamic> activities = [];
  List<dynamic> filteredActivities = [];
  int _selectedIndex = 0;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    fetchActivities();
  }

  Future<void> fetchActivities() async {
    final response = await http.get(Uri.parse(
        'http://10.0.2.2/flutter_webservice/get_ShowDataActivity.php'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Sort activities by creation date (assuming 'activity_date' contains the date)
      data.sort((a, b) {
        final dateA = DateTime.parse(a['activity_date']);
        final dateB = DateTime.parse(b['activity_date']);
        return dateB.compareTo(dateA); // Sort in descending order
      });

      setState(() {
        activities = data;
        filteredActivities =
            activities; // ตั้งค่ารายการที่กรองเป็นรายการทั้งหมดเมื่อเริ่มต้น
      });
    } else {
      throw Exception('Failed to load activities');
    }
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      setState(() {
        _selectedIndex = 0;
      });
    } else if (index == 1) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => groupchat()),
      );
    }
  }

  void _filterActivities(String query) {
    if (activities == null || query == null) {
      setState(() {
        searchQuery = query ?? '';
        filteredActivities = [
          {'activity_name': 'ไม่มีกิจกรรม'}
        ];
      });
      return;
    }

    final searchLower = query.toLowerCase();

    final filtered = activities.where((activity) {
      final activityName = activity['activity_name']?.toLowerCase() ?? '';
      final hashtags = activity['hashtags'] as List<dynamic>? ?? [];
      final hashtagMessages = hashtags
          .map((tag) => tag['hashtag_message']?.toLowerCase() ?? '')
          .toList();

      return activityName.contains(searchLower) ||
          hashtagMessages.any((hashtag) => hashtag.contains(searchLower));
    }).toList();

    setState(() {
      searchQuery = query;
      if (filtered.isEmpty) {
        filteredActivities = [
          {'activity_name': 'ไม่มีกิจกรรม'}
        ];
      } else {
        filteredActivities = filtered.map((activity) {
          final members = activity['members'];
          final status =
              (members != null && members.length > 3) ? "ยอดฮิต" : "มาใหม่";
          return {
            ...activity,
            'status': status,
          };
        }).toList();
      }
    });
  }


  void _logout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        iconTheme: IconThemeData(color: Colors.black),
        toolbarHeight: 45.0,
        leading: IconButton(
          icon: Icon(Icons.logout),
          onPressed: _logout,
          tooltip: 'ออกจากระบบ',
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('images/logo.png', height: 30), // ปรับขนาดของโลโก้
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      jwt: '',
                    ), // โปรไฟล์เพจ
                  ),
                );
              },
              child: CircleAvatar(
                backgroundImage: AssetImage('images/P001.jpg'), // รูปโปรไฟล์
                radius: 16, // ปรับขนาดของรูปโปรไฟล์
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: Container(
            color:
                Color.fromARGB(255, 255, 255, 255), // กำหนดสีพื้นหลังที่ต้องการ
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                TextButton(
                  onPressed: () => _onItemTapped(0),
                  child: Text(
                    'หน้าหลัก',
                    style: TextStyle(
                      color: _selectedIndex == 0 ? Colors.blue : Colors.black,
                    ),
                  ),
                ),
                VerticalDivider(
                    thickness: 1, color: Color.fromARGB(255, 50, 50, 50)),
                TextButton(
                  onPressed: () => _onItemTapped(1),
                  child: Text(
                    'แชท',
                    style: TextStyle(
                      color: _selectedIndex == 1 ? Colors.blue : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0), // ปรับขนาด padding ของช่องค้นหา
            child: TextField(
              onChanged:
                  _filterActivities, // เรียกฟังก์ชันกรองเมื่อมีการเปลี่ยนแปลงข้อความ
              decoration: InputDecoration(
                hintText: 'ค้นหา',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
              ),
            ),
          ),
          Expanded(
            // การ์ด
            child: filteredActivities.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredActivities.length,
                    itemBuilder: (context, index) {
                      final activity = filteredActivities[index];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ActivityPage(activity: activity),
                            ),
                          );
                        },
                        child: ActivityCardItem(activity: activity),
                      );
                    },
                  ),
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 100.0, vertical: 0.0), // ปรับขนาด padding ของปุ่ม
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => CreateActivityPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 255, 0, 0),
                      onPrimary: const Color.fromARGB(255, 255, 255, 255),
                      minimumSize: Size(double.infinity, 30), // ปรับขนาดของปุ่ม
                    ),
                    child: Text('สร้างกิจกรรม'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => AddLocationPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 255, 0, 0),
                      onPrimary: Color.fromARGB(255, 255, 255, 255),
                      minimumSize: Size(double.infinity, 30), // ปรับขนาดของปุ่ม
                    ),
                    child: Text('เพิ่มสถานที่'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityCardItem extends StatelessWidget {
  final dynamic activity;
  final Color backgroundColor;
  final Color statusColor;
  final Color textColor;

  ActivityCardItem({
    required this.activity,
    this.backgroundColor = const Color.fromARGB(255, 255, 255, 255),
    this.statusColor = const Color.fromARGB(255, 255, 225, 1),
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    final members = activity['members'];
    String status =
        (members != null && members.length > 3) ? "ยอดฮิต" : "มาใหม่";

    return Card(
      color: backgroundColor,
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // แถบแสดงสถานะ
            Container(
              padding: EdgeInsets.symmetric(horizontal: 155, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            SizedBox(height: 8),
            // แถวของแท็ก
            Wrap(
              children: (activity['hashtags'] as List<dynamic>? ?? [])
                  .map((tag) => TagWidget(text: tag['hashtag_message']))
                  .toList(),
            ),
            SizedBox(height: 8),
            // วันที่และเวลา
            Text(
              activity['activity_date'] ?? '',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            // ชื่อกิจกรรม
            Text(
              activity['activity_name'] ?? '',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: textColor,
              ),
            ),
            SizedBox(height: 4),
            // สถานที่
            Text(
              activity['location_name'] ?? '',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            // แถวของสมาชิก
            Row(
              children: [
                MemberAvatar(
                  imageUrl: '',
                ),
                MemberAvatar(
                  imageUrl: '',
                ),
                MemberAvatar(
                  imageUrl: '',
                ),
                Spacer(),
                // จำนวนสมาชิก
                Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 4),
                    Text(
                      '${activity['members'] != null ? activity['members'].length : 0}',
                      style: TextStyle(
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            // ข้อความเข้าร่วม
            Text(
              '${activity['members'] != null ? activity['members'].length : 0}/${activity['members'] != null ? activity['members'].length : 0} จะไปแน่นอน',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            SizedBox(height: 4),
            // รายละเอียดกิจกรรม
            Text(
              activity['activity_details'] ?? '',
              style: TextStyle(
                color: textColor,
              ),
            ),
            SizedBox(height: 8),
            // รูปภาพสถานที่
            activity['location_photo'] != null
                ? Image.asset("images/logo.png", height: 200)
                : SizedBox(
                    height: 200,
                    child: Center(child: Text('ไม่มีรูปภาพ')),
                  ), // ใช้รูปภาพจาก assets
          ],
        ),
      ),
    );
  }
}

class TagWidget extends StatelessWidget {
  final String text;

  TagWidget({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 168, 168, 168),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color:
              const Color.fromARGB(255, 0, 0, 0), // เปลี่ยนสีข้อความเป็นสีเทา
        ),
      ),
    );
  }
}

class MemberAvatar extends StatelessWidget {
  final String imageUrl;

  MemberAvatar({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      child: CircleAvatar(
        backgroundImage: AssetImage('images/P001.jpg'), // ใช้รูปจาก URL
        radius: 16, // ปรับขนาดของรูปโปรไฟล์ในสมาชิก
      ),
    );
  }
}
