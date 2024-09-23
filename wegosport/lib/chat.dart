import 'package:flutter/material.dart'; // นำเข้าชุดคำสั่งที่ใช้สร้าง UI ใน Flutter
import 'package:http/http.dart'
    as http; // นำเข้าแพ็กเกจ HTTP สำหรับเรียกใช้งาน API
import 'dart:convert'; // นำเข้าแพ็กเกจสำหรับแปลงข้อมูล JSON
import 'package:web_socket_channel/web_socket_channel.dart'; // นำเข้าชุดคำสั่งที่ใช้ในการเชื่อมต่อ WebSocket

class ChatPage extends StatefulWidget {
  final WebSocketChannel
      channel; // กำหนดตัวแปร WebSocket channel ที่ใช้สำหรับเชื่อมต่อ WebSocket
  final dynamic activity; // ตัวแปรที่เก็บข้อมูลกิจกรรม (activity) ที่ถูกส่งผ่าน
  final String jwt; // ตัวแปร JWT (JSON Web Token) สำหรับตรวจสอบตัวตนผู้ใช้

  const ChatPage({
    super.key,
    required this.channel,
    required this.activity,
    required this.jwt,
  });

  @override
  _ChatPageState createState() =>
      _ChatPageState(); // สร้างสถานะ (State) สำหรับ ChatPage
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller =
      TextEditingController(); // สร้าง controller สำหรับ TextField เพื่อจัดการข้อความที่พิมพ์
  final List<String> _messages = []; // กำหนด list เพื่อเก็บข้อความแชทที่ได้รับ
  final ScrollController _scrollController =
      ScrollController(); // สร้าง ScrollController สำหรับควบคุมการเลื่อน

  Map<String, dynamic>? userData; // ตัวแปรเก็บข้อมูลผู้ใช้ที่ได้จาก JWT

  @override
  void initState() {
    super.initState(); // เรียกใช้ initState ของ class พื้นฐาน
    fetchUserData(widget.jwt).then((_) {
      // เมื่อดึงข้อมูลผู้ใช้สำเร็จ
      connectToWebSocket(); // เรียกฟังก์ชัน connectToWebSocket เพื่อส่ง user_id และ activity_id ไปยังเซิร์ฟเวอร์

      // ส่ง activity_id ไปยังเซิร์ฟเวอร์เพื่อดึงข้อความที่เกี่ยวข้อง
      widget.channel.sink.add(jsonEncode({
        'action': 'get_messages', // บอกว่าเราต้องการดึงข้อความ
        'activity_id': widget.activity['activity_id'], // ส่ง activity_id
        'user_id':
            userData?['user_id'], // ส่ง user_id เพื่อกรองข้อความตามผู้ใช้
      }));
    });

    // เลื่อนไปที่ข้อความล่างสุดเมื่อโหลดเสร็จ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    widget.channel.stream.listen((message) {
      if (!_messages.contains(message)) {
        // เพิ่มเงื่อนไขนี้เพื่อตรวจสอบว่าข้อความยังไม่ถูกเพิ่มใน _messages
        setState(() {
          _messages.add(message); // เพิ่มข้อความใหม่ที่ได้รับ
          _scrollToBottom(); // เลื่อนข้อความไปที่ข้อความล่าสุด
        });
      }
    });
  }

  /// ฟังก์ชันเพื่อเลื่อนไปที่ข้อความล่าสุด
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController
            .position.maxScrollExtent, // เลื่อนลงไปที่ข้อความล่างสุด
        duration: Duration(milliseconds: 500), // กำหนดความเร็วในการเลื่อน
        curve: Curves.easeOut, // ใช้เอฟเฟกต์การเลื่อนแบบนุ่มนวล
      );
    }
  }

  // ฟังก์ชันส่ง user_id และ activity_id ไปยัง WebSocket Server
  void connectToWebSocket() {
    widget.channel.sink.add(jsonEncode({
      'action': 'get_messages',
      'user_id': userData?['user_id'], // user_id ของผู้ใช้
      'activity_id': widget.activity['activity_id'], // activity_id ของกิจกรรม
    }));
  }

  // ฟังก์ชันดึงข้อมูลผู้ใช้จาก JWT
  Future<void> fetchUserData(String jwt) async {
    final response = await http.post(
      // เรียกใช้ API เพื่อตรวจสอบ JWT และดึงข้อมูลผู้ใช้
      Uri.parse('http://10.0.2.2/flutter_webservice/get_ShowDataUser.php'),
      headers: {
        'Authorization': 'Bearer $jwt', // ส่ง JWT เพื่อเป็นการยืนยันตัวตน
      },
    );

    if (response.statusCode == 200) {
      // ตรวจสอบว่าคำขอสำเร็จหรือไม่
      final data = json.decode(
          response.body); // แปลงข้อมูล JSON ที่ได้รับจาก API เป็น Map หรือ List
      if (data is List && data.isNotEmpty) {
        // ตรวจสอบว่าข้อมูลที่ได้เป็น List และไม่ว่างเปล่า
        setState(() {
          userData = data[
              0]; // ดึงข้อมูลผู้ใช้ที่ index 0 (ในกรณีที่ List มีหลายรายการ)
          print('User data: $userData'); // แสดงข้อมูลผู้ใช้ที่ได้รับ
        });
      } else {
        print('No user data found'); // แสดงข้อความถ้าไม่พบข้อมูลผู้ใช้
      }
    } else {
      print('Failed to fetch user data'); // แสดงข้อผิดพลาดถ้าคำขอไม่สำเร็จ
    }
  }

  // ฟังก์ชันส่งข้อความผ่าน WebSocket
  void sendMessage(String message) {
    if (message.isNotEmpty && userData != null) {
      // ตรวจสอบว่าข้อความไม่ว่างและมีข้อมูลผู้ใช้
      widget.channel.sink.add(jsonEncode({
        // ส่งข้อมูลผ่าน WebSocket ในรูปแบบ JSON
        'action': 'send_message',
        'user_id': userData?['user_id'], // ส่ง user_id ของผู้ส่ง
        'user_name': userData?['user_name'], // ส่งชื่อผู้ใช้
        'user_photo': userData?['user_photo'], // ส่งรูปผู้ใช้
        'activity_id':
            widget.activity['activity_id'], // ส่ง activity_id ของกิจกรรมนี้
        'message': message // ส่งข้อความที่ผู้ใช้พิมพ์
      }));
    }
  }

  // ฟังก์ชันเพื่อเรียกใช้การส่งข้อความ
  void _sendMessage() {
    if (_controller.text.isNotEmpty && userData != null) {
      sendMessage(_controller.text); // เรียกใช้ฟังก์ชันส่งข้อความ
      _controller.clear(); // ล้างข้อความใน TextField หลังจากส่ง
      _scrollToBottom(); // เลื่อนข้อความไปที่ข้อความล่าสุด
    }
  }

  @override
  void dispose() {
    widget.channel.sink
        .close(); // ปิด WebSocket เมื่อ widget ถูกทำลาย (เพื่อป้องกัน memory leak)
    super.dispose(); // เรียก dispose ของ class พื้นฐาน
  }

  @override
  Widget build(BuildContext context) {
    print(
        'ข้อมูลของ _messages : ${_messages}'); // พิมพ์ข้อมูล _messages เพื่อตรวจสอบ
    return Scaffold(
      resizeToAvoidBottomInset: true, // ช่วยให้หน้าจอเลื่อนตามแป้นพิมพ์
      appBar: AppBar(
        title: Text(
          'แชทของ : ${widget.activity['activity_name']}',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  // แยก user_id และ message จาก _messages[index]
                  String rawMessage = _messages[index];
                  List<String> splitMessage = rawMessage
                      .split(': '); // แยกข้อความโดยใช้ ": " เป็นตัวคั่น

                  if (splitMessage.length < 2) {
                    return ListTile(
                      title: Text(rawMessage),
                    );
                  }

                  String sender =
                      splitMessage[0]; // ส่วนที่เป็น user_id หรือชื่อผู้ส่ง
                  String message = splitMessage[1]; // ส่วนที่เป็นข้อความจริง

                  // ตรวจสอบว่า user_id ตรงกับผู้ใช้ที่ล็อกอินอยู่หรือไม่
                  bool isLoggedInUser = sender == userData?['user_id'];

                  return Align(
                    alignment: isLoggedInUser
                        ? Alignment
                            .centerRight // จัดข้อความของผู้ที่ล็อกอินทางขวา
                        : Alignment.centerLeft, // จัดข้อความของคนอื่นทางซ้าย
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isLoggedInUser)
                          CircleAvatar(
                            backgroundImage:
                                NetworkImage(userData?['user_photo'] ?? ''),
                            radius: 20,
                          ), // แสดงรูปภาพของผู้ใช้ฝั่งซ้าย (เฉพาะคนอื่น)
                        Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                          padding: EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: isLoggedInUser
                                ? Colors.lightGreen[
                                    100] // สีข้อความของผู้ที่ล็อกอิน
                                : Colors.grey[300], // สีข้อความของคนอื่น
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isLoggedInUser)
                                Text(
                                  userData?['user_name'] ??
                                      'Unknown', // ชื่อผู้ใช้ (คนอื่น)
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              Text(
                                message, // แสดงข้อความจริง
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
