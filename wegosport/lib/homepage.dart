import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wegosport/Addlocation.dart';
import 'package:wegosport/Createactivity.dart';
import 'package:wegosport/Profile.dart';
import 'package:wegosport/groupchat.dart'; // นำเข้าไฟล์ groupchat.dart
import 'dart:convert';
import 'package:wegosport/Login.dart';

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
    final filtered = activities.where((activity) {
      final activityName = activity['activity_name'].toLowerCase();
      final searchLower = query.toLowerCase();
      return activityName.contains(searchLower);
    }).toList();

    setState(() {
      searchQuery = query;
      filteredActivities = filtered;
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
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        toolbarHeight: 56.0,
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
                      builder: (context) => ProfilePage()), // โปรไฟล์เพจ
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
          preferredSize: Size.fromHeight(36.0),
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
              VerticalDivider(thickness: 1, color: Colors.grey),
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
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredActivities.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredActivities.length,
                    itemBuilder: (context, index) {
                      final activity = filteredActivities[index];
                      return ActivityCardItem(activity: activity);
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0), // ปรับขนาด padding ของปุ่ม
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => CreateActivityPage()));
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.yellow,
                    onPrimary: Colors.black,
                    minimumSize: Size(double.infinity, 40), // ปรับขนาดของปุ่ม
                  ),
                  child: Text('สร้างกิจกรรม'),
                ),
                SizedBox(height: 8), // ปรับขนาดของช่องว่างระหว่างปุ่ม
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => AddLocationPage()));
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.yellow,
                    onPrimary: Colors.black,
                    minimumSize: Size(double.infinity, 40), // ปรับขนาดของปุ่ม
                  ),
                  child: Text('เพิ่มสถานที่'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityCardItem extends StatelessWidget {
  final dynamic activity;

  ActivityCardItem({required this.activity});

  @override
  Widget build(BuildContext context) {
    // Debug: พิมพ์ URL ของรูปภาพเพื่อตรวจสอบ
    print('Location photo URL: ${activity['location_photo']}');

    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // แถวของแท็ก
            Wrap(
              children: (activity['hashtags'] as List<dynamic>)
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
                    Text('${activity['members'].length}'),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            // ข้อความเข้าร่วม
            Text(
              '${activity['members'].length}/99 จะไป',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            // รายละเอียดกิจกรรม
            Text(activity['activity_details'] ?? ''),
            SizedBox(height: 8),
            // รูปภาพสถานที่
            // รูปภาพสถานที่
            activity['location_photo'] != null
                ? Image.network(
                    "https://media.istockphoto.com/id/1011241694/th/%E0%B8%A3%E0%B8%B9%E0%B8%9B%E0%B8%96%E0%B9%88%E0%B8%B2%E0%B8%A2/%E0%B9%80%E0%B8%A3%E0%B8%B7%E0%B8%AD%E0%B8%AB%E0%B8%B2%E0%B8%87%E0%B8%A2%E0%B8%B2%E0%B8%A7%E0%B9%84%E0%B8%A1%E0%B9%89%E0%B9%84%E0%B8%97%E0%B8%A2%E0%B9%81%E0%B8%A5%E0%B8%B0%E0%B8%AB%E0%B8%B2%E0%B8%94%E0%B8%97%E0%B8%A3%E0%B8%B2%E0%B8%A2%E0%B8%97%E0%B8%B5%E0%B9%88%E0%B8%AA%E0%B8%A7%E0%B8%A2%E0%B8%87%E0%B8%B2%E0%B8%A1.jpg?s=612x612&w=0&k=20&c=q7qz0uFc4Zkf5tGxFLNFyg82k_l9YS06nUQ9Ny-RIOo=",
                    height: 200)
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
        color: Colors.yellow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text),
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
        backgroundImage: NetworkImage(imageUrl), // ใช้รูปจาก URL
        radius: 16, // ปรับขนาดของรูปโปรไฟล์ในสมาชิก
      ),
    );
  }
}
