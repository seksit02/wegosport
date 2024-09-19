import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatPage extends StatefulWidget {
  final WebSocketChannel channel;
  final dynamic activity;
  final String jwt;

  const ChatPage({
    super.key,
    required this.channel,
    required this.activity,
    required this.jwt,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];

  Map<String, dynamic>? userData;
  List<dynamic> activities = [];

  @override
  void initState() {
    super.initState();
    fetchActivities();
    fetchUserData(widget.jwt);

    // ตรวจสอบค่าของตัวแปรที่ส่งมาจาก ActivityPage
    print("chat Activity data: ${widget.activity}");
    print("chat JWT: ${widget.jwt}");
    print("chat Activity data 1: ${activities}");
    print("chat JWT 1: ${userData}");

    widget.channel.stream.listen((message) {
      setState(() {
        _messages.add(message);
      });
    });
  }

  // ฟังก์ชันดึงข้อมูลกิจกรรมจากเซิร์ฟเวอร์
  Future<void> fetchActivities() async {
    final response = await http.get(Uri.parse(
        'http://10.0.2.2/flutter_webservice/get_ShowDataActivity.php'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // ดึงเฉพาะ user_id ของสมาชิกในกิจกรรม
      List<dynamic> members = widget.activity['members'];
      List<String> memberIds =
          members.map((member) => member['user_id'].toString()).toList();

      // เก็บเฉพาะกิจกรรมที่สมาชิกเป็น user_id
      setState(() {
        activities = data.where((activity) {
          List<dynamic> activityMembers = activity['members'];
          return activityMembers
              .any((member) => memberIds.contains(member['user_id']));
        }).toList();
      });

      print("Filtered Activities: $activities");
    } else {
      throw Exception('Failed to load activities');
    }
  }

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
            userData = data[0]; // เก็บข้อมูลทั้งหมดใน userData
          });
          print('User ID: ${userData!['user_id']}');
        } else {
          print("No user data found");
        }
      } else {
        print("Failed to load user data: ${response.body}");
      }
    } catch (error) {
      print("Error: $error");
    }
  }

  Future<void> sendMessageToDatabase(String message) async {
    if (userData == null) {
      print("User data not ready yet");
      return;
    }

    // ดึง user_id ของผู้ใช้จาก userData
    String userId = userData!['user_id'];

    // ดึงเฉพาะสมาชิกจาก `members` ใน `widget.activity`
    List<String> memberIds = widget.activity['members']
        .map<String>((member) => member['user_id'].toString())
        .toList();

    // แสดงข้อมูลที่กำลังจะถูกส่งไปในคอนโซล
    print("Preparing to send the following data to the database:");
    print("user_id : $userId");
    print("member_id : $memberIds"); // ส่งข้อความให้สมาชิกทั้งหมดใน activity นี้
    print("message : $message");

    try {
      // วนลูปเพื่อส่งข้อความไปยังสมาชิกแต่ละคน
      for (String memberId in memberIds) {
        final response = await http.post(
          Uri.parse(
              'http://10.0.2.2/flutter_webservice/message.php'), // เปลี่ยน URL ของคุณ
          body: {
            'user_id': userId, // ส่ง user_id ของผู้ส่ง
            'member_id': memberId, // ส่ง member_id ของผู้รับแต่ละคน
            'message': message, // ส่งข้อความ
          },
        );

        if (response.body == 'Message sent successfully') {
          print('Message saved to database for member: $memberId');
        } else {
          print(
              'Failed to save message for member: $memberId. Status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // ฟังก์ชันส่งข้อความผ่าน WebSocket และบันทึกในฐานข้อมูล
  void sendMessage(String message) {
    if (message.isNotEmpty) {
      // ส่งข้อมูลในรูปแบบ JSON
      widget.channel.sink.add(jsonEncode(
          {'user_id': 'admin', 'member_id': 'beem21', 'message': message}));
    }
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      // เรียกใช้ฟังก์ชัน sendMessage โดยส่งข้อความจาก TextField
      sendMessage(_controller.text);

      // ล้างข้อความใน TextField หลังจากส่ง
      _controller.clear();
    }
  }

  @override
  void dispose() {
    widget.channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("หน้าแชท",
          style: TextStyle(
            color: Colors.white
          ),
        ),
        backgroundColor:Color.fromARGB(255, 255, 0, 0), // กำหนดสีพื้นหลัง AppBar
        leading: IconButton(
          icon: Icon(Icons.arrow_back,color: const Color.fromARGB(255, 255, 255, 255)), // กำหนดสีของไอคอน,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_messages[index]),
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: 'Aa'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
