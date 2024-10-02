import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wegosport/Addlocation.dart';
import 'package:wegosport/Createactivity.dart';
import 'package:wegosport/EditActivity.dart';
import 'package:wegosport/MyActivity.dart';
import 'package:wegosport/Profile.dart';
import 'package:wegosport/Activity.dart';
import 'package:wegosport/Groupchat.dart';
import 'dart:convert';
import 'package:wegosport/Login.dart';
import 'dart:ui';
import 'package:intl/intl.dart'; // นำเข้าไลบรารีที่จำเป็นสำหรับการทำงาน
import 'package:web_socket_channel/web_socket_channel.dart'; // สำหรับ WebSocket

import 'package:intl/intl_standalone.dart';
import 'package:intl/date_symbol_data_local.dart';

// หน้าจอ Homepage
class Homepage extends StatefulWidget {
  final String jwt; // รับค่า JWT สำหรับการตรวจสอบสิทธิ์

  const Homepage({Key? key, required this.jwt}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState(); // สร้างสถานะของ Homepage
}

class _HomepageState extends State<Homepage> {
  List<dynamic> activities = []; // เก็บข้อมูลกิจกรรมทั้งหมด
  List<dynamic> filteredActivities = []; // เก็บข้อมูลกิจกรรมที่กรองแล้ว
  int _selectedIndex = 0; // เก็บค่าดัชนีของแท็บที่เลือก
  String searchQuery = ""; // เก็บข้อความที่ค้นหา
  Map<String, dynamic>? userData; // เก็บข้อมูลผู้ใช้

  @override
  void initState() {
    super.initState();
    _initializeLocaleAndFetchData();
  }

  Future<void> _initializeLocaleAndFetchData() async {
    await initializeDateFormatting(
        'th_TH', null); // เรียก initializeDateFormatting
    fetchActivities(); // เรียกใช้ fetchActivities หลังจากที่ข้อมูล locale ถูกตั้งค่า
    fetchUserData(widget.jwt); // เรียกดึงข้อมูลผู้ใช้
  }

  // ฟังก์ชันดึงข้อมูลกิจกรรมจากเซิร์ฟเวอร์
  Future<void> fetchActivities() async {
    final response = await http.get(Uri.parse(
        'http://10.0.2.2/flutter_webservice/get_ShowDataActivity.php'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // กรองกิจกรรมที่ยังไม่หมดเวลา
      final currentDate = DateTime.now();
      final upcomingActivities = data.where((activity) {
        final activityDate = DateTime.parse(activity['activity_date']);
        return activityDate
            .isAfter(currentDate); // กรองเฉพาะกิจกรรมที่ยังไม่หมดเวลา
      }).toList();

      // จัดเรียงกิจกรรมตามวันที่สร้าง
      upcomingActivities.sort((a, b) {
        final dateA = DateTime.parse(a['activity_date']);
        final dateB = DateTime.parse(b['activity_date']);
        return dateB.compareTo(dateA); // จัดเรียงตามลำดับวันที่
      });

      setState(() {
        activities = upcomingActivities; // เก็บเฉพาะกิจกรรมที่ยังไม่หมดเวลา
        filteredActivities =
            activities; // ตั้งค่ารายการที่กรองเป็นรายการทั้งหมดเมื่อเริ่มต้น
      });
    } else {
      throw Exception('Failed to load activities');
    }
  }

  // ฟังก์ชันดึงข้อมูลผู้ใช้จากเซิร์ฟเวอร์
  Future<void> fetchUserData(String jwt) async {
    var url =
        Uri.parse('http://10.0.2.2/flutter_webservice/get_ShowDataUser.php');

    Map<String, String> headers = {
      'Authorization': 'Bearer $jwt', // ใส่ JWT ในส่วนของ Authorization Header
    };

    print('Headers Homepage : $headers'); // พิมพ์ headers เพื่อการตรวจสอบ

    try {
      var response = await http.post(
        url,
        headers: headers, // ส่งค่า JWT ไปพร้อมกับคำขอ
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List<dynamic> &&
            data.isNotEmpty &&
            data[0] is Map<String, dynamic> &&
            data[0].containsKey('user_id')) {
          setState(() {
            userData = data[0]; // เก็บข้อมูลผู้ใช้ในตัวแปร userData
          });
          print('User data: $userData');
        } else {
          print("No user data found");
          throw Exception('Failed to load user data');
        }
      } else {
        print("Failed to load user data: ${response.body}");
        throw Exception('Failed to load user data');
      }
    } catch (error) {
      print("Error: $error");
      throw Exception('Failed to load user data');
    }
  }

  // ฟังก์ชันกรองกิจกรรม (ช่องค้นหา)
  void _filterActivities(String query) {
    if (activities == null || query == null) {
      setState(() {
        searchQuery = query ?? '';
        filteredActivities = [
          {'activity_name': 'ไม่มีกิจกรรม'} // กำหนดค่าดีฟอลต์หากไม่มีผลลัพธ์
        ];
      });
      return;
    }

    final searchLower = query.toLowerCase();

    final filtered = activities.where((activity) {
      final activityName = activity['activity_name']?.toLowerCase() ?? '';
      final locationName = activity['location_name']?.toLowerCase() ?? '';
      final sportName = activity['sport_name']?.toLowerCase() ?? '';
      final hashtags = activity['hashtags'] as List<dynamic>? ?? [];
      final hashtagMessages = hashtags
          .map((tag) => tag['hashtag_message']?.toLowerCase() ?? '')
          .toList();

      // เพิ่มเงื่อนไขในการตรวจสอบสถานะว่ากิจกรรมยังไม่ถูกระงับ
      final isActive = activity['status'] == 'active' ||
          activity['status'] == 'มาใหม่' ||
          activity['status'] == 'ยอดฮิต';

      return isActive &&
          (activityName.contains(searchLower) ||
              locationName.contains(searchLower) ||
              sportName.contains(searchLower) ||
              hashtagMessages.any((hashtag) => hashtag.contains(searchLower)));
    }).toList();

    setState(() {
      searchQuery = query;
      if (filtered.isEmpty) {
        filteredActivities = [
          {'activity_name': 'ไม่มีกิจกรรม'} // กำหนดค่าดีฟอลต์หากไม่มีผลลัพธ์
        ];
      } else {
        filteredActivities = filtered.map((activity) {
          final members = activity['members'];
          final status =
              (members != null && members.length > 3) ? "ยอดฮิต" : "มาใหม่";
          return {...activity, 'status': status};
        }).toList();
      }
    });
  }

  // ฟังก์ชันกรองกิจกรรมตามแฮชแท็กที่ถูกกด
  void _filterActivitiesByHashtag(String hashtag) {
    final filtered = activities.where((activity) {
      final hashtags = activity['hashtags'] as List<dynamic>? ?? [];

      // เพิ่มเงื่อนไขในการตรวจสอบสถานะว่ากิจกรรมยังไม่ถูกระงับ
      final isActive = activity['status'] == 'active' ||
          activity['status'] == 'มาใหม่' ||
          activity['status'] == 'ยอดฮิต';

      return isActive &&
          hashtags.any((tag) => tag['hashtag_message'] == hashtag);
    }).toList();

    setState(() {
      filteredActivities = filtered.isEmpty
          ? [
              {'activity_name': 'ไม่มีกิจกรรม'}
            ]
          : filtered.map((activity) {
              final members = activity['members'];
              final status =
                  (members != null && members.length > 3) ? "ยอดฮิต" : "มาใหม่";
              return {...activity, 'status': status};
            }).toList();
    });
  }

  // ฟังก์ชันเปลี่ยนแท็บ
  void _onItemTapped(int index) {
    if (index == 0) {
      setState(() {
        _selectedIndex = 0;
      });
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Myactivity(
            activity: activities,
            jwt: widget.jwt,
          ),
        ),
      );
    }
  }

  // ฟังก์ชันออกจากระบบ
  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ออกจากระบบ'),
          content: Text('คุณต้องการจะออกจากระบบหรือไม่?'),
          actions: [
            TextButton(
              child: Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop(); // ปิดกล่องข้อความ
              },
            ),
            TextButton(
              child: Text('ตกลง'),
              onPressed: () {
                Navigator.of(context).pop(); // ปิดกล่องข้อความ
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (context) => LoginPage()), // กลับไปยังหน้า Login
                );
              },
            ),
          ],
        );
      },
    );
  }

  // ฟังก์ชันไปยังหน้าโปรไฟล์
  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(
          activity: activities,
          jwt: widget.jwt, // ส่งค่า JWT ไปยังหน้า ProfilePage
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Color.fromARGB(255, 255, 255, 255), // กำหนดสีพื้นหลัง AppBar
        iconTheme:
            IconThemeData(color: Colors.black), // กำหนดสีของไอคอนใน AppBar
        toolbarHeight: 45.0, // กำหนดความสูงของ AppBar
        leading: IconButton(
          icon: Icon(Icons.logout),
          onPressed: _logout, // เรียกใช้ฟังก์ชัน _logout เมื่อกดปุ่มออกจากระบบ
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
              onTap:
                  _navigateToProfile, // เรียกใช้ฟังก์ชัน _navigateToProfile เมื่อกดที่รูปโปรไฟล์
              child: CircleAvatar(
                backgroundImage:
                    userData != null && userData!['user_photo'] != null
                        ? NetworkImage(userData!['user_photo'])
                        : AssetImage('images/P001.jpg') as ImageProvider,
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
                  onPressed: () => _onItemTapped(
                      0), // เรียกใช้ฟังก์ชัน _onItemTapped เมื่อกดปุ่มหน้าหลัก
                  child: Text(
                    'หน้าหลัก',
                    style: TextStyle(
                      color: _selectedIndex == 0
                          ? Color.fromARGB(255, 0, 0, 0)
                          : Colors.black,
                    ),
                  ),
                ),
                VerticalDivider(
                    thickness: 1, color: Color.fromARGB(255, 146, 146, 146)),
                TextButton(
                  onPressed: () => _onItemTapped(
                      1), // เรียกใช้ฟังก์ชัน _onItemTapped เมื่อกดปุ่มแชท
                  child: Text(
                    'กิจกรรมของฉัน',
                    style: TextStyle(
                      color: _selectedIndex == 1
                          ? const Color.fromARGB(255, 255, 255, 255)
                          : Colors.black,
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
                  borderRadius:
                      BorderRadius.circular(50.0), // ปรับความโค้งของขอบ
                ),
              ),
            ),
          ),
          Expanded(
            // การ์ดกิจกรรม
            child: filteredActivities.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredActivities.length,
                    itemBuilder: (context, index) {
                      final activity = filteredActivities[index];
                      return InkWell(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ActivityPage(
                                activity: activity,
                                jwt: widget.jwt, // ส่ง JWT ไปยัง ActivityPage
                                userId: userData != null
                                    ? userData!['user_id']
                                    : 'ไม่พบข้อมูล', // ส่ง user_id ไปยัง ActivityPage
                              ),
                            ),
                          );

                          if (result == true) {
                            // ถ้าเข้าร่วมกิจกรรมสำเร็จ ทำการ fetch ข้อมูลกิจกรรมใหม่
                            fetchActivities();
                          }
                        },
                        child: ActivityCardItem(
                          activity: activity,
                          userData: userData,
                          fetchActivities: fetchActivities,
                          jwt: widget.jwt,
                          onHashtagTap:
                              _filterActivitiesByHashtag, // ส่ง callback สำหรับกดแฮชแท็ก
                        ),
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
                    // เมื่อไปยังหน้าสร้างกิจกรรม
                    onPressed: () {
                      Navigator.of(context)
                          .push(
                        MaterialPageRoute(
                          builder: (context) => CreateActivityPage(
                            jwt: widget
                                .jwt, // ส่งค่า jwt ไปยังหน้า CreateActivityPage
                          ),
                        ),
                      )
                          .then((value) {
                        fetchActivities(); // เรียกใช้ fetchActivities เมื่อกลับมาจากหน้า CreateActivityPage
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                      backgroundColor: Color.fromARGB(255, 255, 0, 0),
                      minimumSize: Size(double.infinity, 30), // ปรับขนาดของปุ่ม
                    ),
                    child: Text(
                      'สร้างกิจกรรม',
                      style: TextStyle(
                        fontSize: 18.0, // ปรับขนาดฟอนต์ตามที่ต้องการ
                        fontWeight: FontWeight.bold, // ทำให้ฟอนต์หนา
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AddLocationPage(
                            jwt: widget
                                .jwt, // ส่งค่า jwt ไปยังหน้า AddLocationPage
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Color.fromARGB(255, 255, 255, 255),
                      backgroundColor: Color.fromARGB(255, 255, 0, 0),
                      minimumSize: Size(double.infinity, 30), // ปรับขนาดของปุ่ม
                    ),
                    child: Text(
                      'เพิ่มสถานที่',
                      style: TextStyle(
                        fontSize: 18.0, // ปรับขนาดฟอนต์ตามที่ต้องการ
                        fontWeight: FontWeight.bold, // ทำให้ฟอนต์หนา
                      ),
                    ),
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

// วิดเจ็ตแสดงกิจกรรม
class ActivityCardItem extends StatelessWidget {
  final dynamic activity;
  final dynamic userData;
  final dynamic jwt;
  final Color backgroundColor;
  final Color statusColor;
  final Color textColor;
  final Function fetchActivities; // รับฟังก์ชัน fetchActivities
  final Function(String) onHashtagTap; // เพิ่ม callback สำหรับกดแฮชแท็ก

  ActivityCardItem({
    required this.activity,
    required this.userData,
    required this.jwt,
    required this.fetchActivities,
    required this.onHashtagTap, // เพิ่ม callback
    this.backgroundColor = const Color.fromARGB(255, 255, 255, 255),
    this.statusColor = const Color.fromARGB(255, 255, 225, 1),
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    print('ข้อมูล userData จากการ์ด $userData');
    print('ข้อมูล Activity จากการ์ด $activity');

    // ตรวจสอบสถานะของกิจกรรม
    final isActive = activity['status'] == 'active' ||
        activity['status'] == 'มาใหม่' ||
        activity['status'] == 'ยอดฮิต';
    print('Activity Status: ${activity['status']}'); // พิมพ์สถานะกิจกรรม

    final members = activity['members'];
    bool isPopular = (members != null && members.length > 3);
    String statusText = isPopular ? "ยอดฮิต" : "มาใหม่";
    Icon statusIcon = isPopular
        ? Icon(Icons.star, color: Color.fromARGB(255, 255, 0, 0))
        : Icon(Icons.local_fire_department, color: Colors.red);

    DateTime activityDate;

    try {
      activityDate =
          DateFormat('yyyy-MM-dd HH:mm:ss').parse(activity['activity_date']);
    } catch (e) {
      activityDate = DateTime.now(); // หรือค่าดีฟอลต์หรือจัดการตามที่ต้องการ
    }

    // แปลงรูปแบบวันที่และเวลาเป็นรูปแบบที่คุณต้องการ
    String formattedDate =
        DateFormat('HH.mm น. d MMMM yyyy', 'th_TH').format(activityDate);

    // แปลงปีให้เป็นพุทธศักราช
    int buddhistYear = activityDate.year + 543;
    formattedDate =
        formattedDate.replaceAll('${activityDate.year}', '$buddhistYear');

    bool isPast = DateTime.now().isAfter(activityDate);

    return GestureDetector(
      onTap: () {
        if (isActive) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ActivityPage(
                activity: activity,
                jwt: jwt,
                userId: userData != null
                    ? userData!['user_id']
                    : 'ไม่พบข้อมูล', // ตรวจสอบว่าค่า userData มีข้อมูลจริง
              ),
            ),
          ).then((_) {
            // หลังจากกลับมาจากหน้า ActivityPage รีเฟรชข้อมูลกิจกรรม
            fetchActivities();
          });
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('กิจกรรมถูกระงับ'),
              content: Text('กิจกรรมนี้ถูกระงับและไม่สามารถเข้าถึงได้.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // ปิด popup
                  },
                  child: Text('ตกลง'),
                ),
              ],
            ),
          );
        }
      },
      child: Card(
        color: backgroundColor,
        margin: EdgeInsets.all(10), // กำหนดขอบของการ์ดกิจกรรม
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // แถบแสดงสถานะพร้อมปุ่มแก้ไข
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 108, vertical: 1),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          statusText,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        SizedBox(width: 5),
                        statusIcon,
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.more_vert,
                        color: const Color.fromARGB(255, 0, 0, 0)),
                    onPressed: () async {
                      if (userData != null &&
                          activity['creator'] == userData!['user_id']) {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditActivity(
                              activityId: activity['activity_id'].toString(),
                              jwt: '', // ใช้ JWT ที่ถูกต้องที่คุณต้องการส่งไป
                            ),
                          ),
                        );

                        if (result == true) {
                          // รีเฟรชข้อมูลหลังจากกลับมาจากหน้า EditActivity
                          fetchActivities(); // เรียกใช้ฟังก์ชันที่ส่งมาจาก Homepage
                        }
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('ไม่มีสิทธิ์ในการแก้ไข'),
                              content:
                                  Text('คุณไม่มีสิทธิ์ในการแก้ไขกิจกรรมนี้'),
                              actions: [
                                TextButton(
                                  child: Text('ตกลง'),
                                  onPressed: () {
                                    Navigator.of(context).pop(); // ปิด popup
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 8),
              // แถวของแท็ก
              Wrap(
                runSpacing: 5.0,
                children: (activity['hashtags'] as List<dynamic>? ?? [])
                    .map((tag) => GestureDetector(
                          onTap: () => onHashtagTap(tag[
                              'hashtag_message']), // เพิ่มการทำงานเมื่อกดแฮชแท็ก
                          child: TagWidget(text: tag['hashtag_message']),
                        ))
                    .toList(),
              ),
              SizedBox(height: 8),
              // วันที่และเวลา
              Text(
                formattedDate,
                style: TextStyle(
                  color: isPast
                      ? const Color.fromARGB(255, 180, 180, 180)
                      : Colors.black,
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
              // สถานที่เล่นกีฬาและชื่อกีฬา
              Text(
                '${activity['location_name'] ?? ''} - ${activity['sport_name'] ?? ''}',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8),
              // แถวของสมาชิก
              Row(
                children: [
                  if (members != null && members.isNotEmpty)
                    ...members.map((member) {
                      String imageUrl =
                          member['user_photo'] ?? 'images/logo.png';
                      return MemberAvatar(
                          imageUrl: imageUrl); // แสดงรูปภาพของสมาชิก
                    }).toList()
                  else
                    Text('ไม่มีสมาชิก', style: TextStyle(color: Colors.grey)),
                  Spacer(),
                  // จำนวนสมาชิก
                  Row(
                    children: [
                      Icon(Icons.person),
                      SizedBox(width: 4),
                      Text(
                        '${members != null ? members.length : 0}',
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
                'รายละเอียดเพิ่มเติม',
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
                  ? ClipRRect(
                      borderRadius:
                          BorderRadius.circular(20.0), // กำหนดความโค้งขอบ
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5), // สีเงา
                              spreadRadius: 5, // ขนาดเงา
                              blurRadius: 7, // ความเบลอของเงา
                              offset: Offset(0, 3), // ตำแหน่งเงา
                            ),
                          ],
                        ),
                        child: Image.network(
                          activity['location_photo'],
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (BuildContext context, Object exception,
                              StackTrace? stackTrace) {
                            return Container(
                              height: 200,
                              child: Center(
                                child: Text('เกิดข้อผิดพลาดในการโหลดรูปภาพ'),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 200,
                      child: Center(child: Text('ไม่มีรูปภาพ')),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

// วิดเจ็ตแสดงแท็ก (hashtag)
class TagWidget extends StatelessWidget {
  final String text;

  TagWidget({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 175, 175, 175), // กำหนดสีพื้นหลังของแท็ก
        borderRadius: BorderRadius.circular(20), // ปรับความโค้งของแท็ก
      ),
      child: Text(
        text,
        style: TextStyle(
          color: const Color.fromARGB(255, 0, 0, 0), // กำหนดสีข้อความเป็นสีดำ
        ),
      ),
    );
  }
}

// วิดเจ็ตแสดงรูปภาพของสมาชิก
class MemberAvatar extends StatelessWidget {
  final String imageUrl;

  MemberAvatar({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    bool isNetworkImage =
        imageUrl.startsWith('http'); // ตรวจสอบว่าเป็น URL หรือไม่

    return Container(
      margin: EdgeInsets.only(right: 8),
      child: CircleAvatar(
        backgroundImage: isNetworkImage
            ? NetworkImage(imageUrl) // ถ้าเป็น URL ใช้ NetworkImage
            : AssetImage(imageUrl) as ImageProvider, // ถ้าไม่เป็นใช้ AssetImage
        radius: 16, // ขนาดของรูปภาพ
      ),
    );
  }
}
