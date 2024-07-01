import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wegosport/addlocation.dart';
import 'package:wegosport/createactivity.dart';
import 'package:wegosport/groupchat.dart'; // นำเข้าไฟล์ groupchat.dart
import 'dart:convert';
import 'package:wegosport/login.dart';

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
        filteredActivities = activities; // ตั้งค่ารายการที่กรองเป็นรายการทั้งหมดเมื่อเริ่มต้น
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        toolbarHeight: 56.0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('images/logo.png', height: 30), // ปรับขนาดของโลโก้
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CircleAvatar(
              backgroundImage: AssetImage('images/logo.png'), // รูปโปรไฟล์
              radius: 16, // ปรับขนาดของรูปโปรไฟล์
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
              onChanged: _filterActivities, // เรียกฟังก์ชันกรองเมื่อมีการเปลี่ยนแปลงข้อความ
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
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => createactivitypage()));
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
                        builder: (context) => addlocationpage()));
                    
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
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // แถวของแท็ก
            Row(
              children: [
                TagWidget(text: 'ตีกัน'),
                TagWidget(text: 'สนามกลาง'),
                TagWidget(text: 'ก๊วน'),
              ],
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
                MemberAvatar(imageUrl: 'https://via.placeholder.com/50'),
                MemberAvatar(imageUrl: 'https://via.placeholder.com/50'),
                MemberAvatar(imageUrl: 'https://via.placeholder.com/50'),
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
            // รูปภาพกิจกรรม
            Image.network('https://via.placeholder.com/150'),
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
        backgroundImage: NetworkImage(imageUrl),
        radius: 16, // ปรับขนาดของรูปโปรไฟล์ในสมาชิก
      ),
    );
  }
}
