import 'package:flutter/material.dart'; // นำเข้าชุดคำสั่งที่ใช้สร้าง UI ใน Flutter
import 'package:http/http.dart'
    as http; // นำเข้าแพ็กเกจ HTTP สำหรับเรียกใช้งาน API
import 'dart:convert'; // นำเข้าแพ็กเกจสำหรับแปลงข้อมูล JSON
import 'package:web_socket_channel/web_socket_channel.dart'; // นำเข้าชุดคำสั่งที่ใช้ในการเชื่อมต่อ WebSocket
import 'package:intl/intl.dart'; // นำเข้าไลบรารีที่จำเป็นสำหรับการทำงาน

// คลาส ChatPage ซึ่งเป็นหน้าจอสำหรับการแชท โดยมีการรับ WebSocket channel, activity, และ JWT เพื่อใช้ในหน้าจอนี้
class ChatPage extends StatefulWidget {
  final WebSocketChannel
      channel; // กำหนดตัวแปร WebSocket channel ที่ใช้สำหรับเชื่อมต่อ WebSocket
  final dynamic activity; // ตัวแปรที่เก็บข้อมูลกิจกรรม (activity) ที่ถูกส่งผ่าน
  final String jwt; // ตัวแปร JWT (JSON Web Token) สำหรับตรวจสอบตัวตนผู้ใช้

  const ChatPage({
    super.key,
    required this.channel, // channel ที่จำเป็นต้องส่งเข้ามา
    required this.activity, // activity ที่จำเป็นต้องส่งเข้ามา
    required this.jwt, // JWT ที่จำเป็นต้องส่งเข้ามา
  });

  @override
  _ChatPageState createState() =>
      _ChatPageState(); // สร้างสถานะ (State) สำหรับ ChatPage
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller =
      TextEditingController(); // ควบคุมการพิมพ์ข้อความ
  final List<Map<String, dynamic>> _messages =
      []; // เก็บข้อความทั้งหมดในรูปแบบของ List
  final ScrollController _scrollController =
      ScrollController(); // ใช้ควบคุมการเลื่อนของ ScrollView
  Map<String, dynamic>?
      userData; // เก็บข้อมูลผู้ใช้หลังจากเรียกใช้ API เพื่อดึงข้อมูล

  @override
  void initState() {
    super.initState();
    fetchUserData(widget.jwt).then((_) {
      // ดึงข้อมูลผู้ใช้จาก JWT และเชื่อมต่อ WebSocket
      connectToWebSocket(); // เรียกฟังก์ชันเชื่อมต่อ WebSocket
      widget.channel.sink.add(jsonEncode({
        // ส่งคำสั่งไปยัง WebSocket เพื่อดึงข้อความของกิจกรรม
        'action': 'get_messages',
        'activity_id': widget.activity['activity_id'],
        'user_id': userData?['user_id'],
      }));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // หลังจากการโหลดหน้าเสร็จ จะเรียกฟังก์ชันเลื่อนลงล่าง
      _scrollToBottom();
    });

    widget.channel.stream.listen((message) {
      // ฟังข้อความจาก WebSocket
      var decodedMessage = jsonDecode(message); // แปลงข้อมูลจาก JSON เป็น Map

      if (decodedMessage['action'] == 'messages') {
        // ถ้า action เป็น 'messages' แสดงว่าดึงข้อความทั้งหมดได้แล้ว
        setState(() {
          _messages.clear(); // ล้างข้อความก่อนหน้า
          _messages.addAll(List<Map<String, dynamic>>.from(
              decodedMessage['messages'])); // เพิ่มข้อความใหม่
          _scrollToBottom(); // เลื่อนข้อความไปที่ข้อความล่าสุด
        });
      } else if (decodedMessage['action'] == 'new_message') {
        // ถ้ามีข้อความใหม่
        setState(() {
          Map<String, dynamic> newMessage = Map<String, dynamic>.from(
              decodedMessage['message']); // เพิ่มข้อความใหม่
          if (!newMessage
                  .containsKey('timestamp') || // ตรวจสอบว่ามี timestamp หรือไม่
              newMessage['timestamp'] == null) {
            newMessage['timestamp'] =
                DateTime.now().toIso8601String(); // ถ้าไม่มี ให้ใช้เวลาปัจจุบัน
          }
          _messages.add(newMessage); // เพิ่มข้อความใหม่
          _scrollToBottom(); // เลื่อนข้อความไปที่ข้อความล่าสุด
        });
      }
    });
  }

  // ฟังก์ชันเลื่อน ScrollView ไปที่ข้อความล่าสุด
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      // ถ้ามี ScrollController อยู่
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent, // เลื่อนไปที่ข้อความสุดท้าย
        duration: Duration(milliseconds: 1), // ตั้งเวลาในการเลื่อน
        curve: Curves.easeOut, // ใช้ curve แบบ easeOut ในการเลื่อน
      );
    }
  }

  // ฟังก์ชันส่ง user_id และ activity_id ไปยัง WebSocket Server
  void connectToWebSocket() {
    widget.channel.sink.add(jsonEncode({
      // ส่งข้อมูลไปยัง WebSocket ในรูปแบบ JSON
      'action': 'get_messages',
      'user_id': userData?['user_id'], // user_id ของผู้ใช้
      'activity_id': widget.activity['activity_id'], // activity_id ของกิจกรรม
    }));
  }

  // ฟังก์ชันดึงข้อมูลผู้ใช้จาก JWT
  Future<void> fetchUserData(String jwt) async {
    final response = await http.post(
      // เรียก API เพื่อตรวจสอบ JWT และดึงข้อมูลผู้ใช้
      Uri.parse(
          'http://10.0.2.2/flutter_webservice/get_ShowDataUser.php'), // URL ของ API
      headers: {
        'Authorization': 'Bearer $jwt', // ส่ง JWT เพื่อยืนยันตัวตน
      },
    );

    if (response.statusCode == 200) {
      // ตรวจสอบว่าสำเร็จหรือไม่
      final data = json
          .decode(response.body); // แปลงข้อมูล JSON ที่ได้เป็น Map หรือ List
      if (data is List && data.isNotEmpty) {
        // ตรวจสอบว่ามีข้อมูลผู้ใช้หรือไม่
        setState(() {
          userData = data[0]; // เก็บข้อมูลผู้ใช้
          print('User data: $userData'); // พิมพ์ข้อมูลผู้ใช้ที่ได้รับ
        });
      } else {
        print('No user data found'); // ถ้าไม่พบข้อมูลผู้ใช้
      }
    } else {
      print('Failed to fetch user data'); // ถ้าคำขอไม่สำเร็จ
    }
  }

  // ฟังก์ชันส่งข้อความผ่าน WebSocket
  void sendMessage(String message) {
    if (message.isNotEmpty && userData != null) {
      // ตรวจสอบว่าข้อความไม่ว่างและมีข้อมูลผู้ใช้
      widget.channel.sink.add(jsonEncode({
        // ส่งข้อมูลไปยัง WebSocket
        'action': 'send_message',
        'user_id': userData?['user_id'], // ส่ง user_id ของผู้ส่ง
        'user_name': userData?['user_name'], // ส่งชื่อผู้ใช้
        'user_photo': userData?['user_photo'], // ส่งรูปผู้ใช้
        'activity_id':
            widget.activity['activity_id'], // ส่ง activity_id ของกิจกรรม
        'message': message // ส่งข้อความ
      }));
    }
  }

  // ฟังก์ชันเพื่อเรียกใช้การส่งข้อความ
  void _sendMessage() {
    if (_controller.text.isNotEmpty && userData != null) {
      // ตรวจสอบว่ามีข้อความใน TextField และข้อมูลผู้ใช้
      sendMessage(_controller.text); // เรียกฟังก์ชันส่งข้อความ
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
          'แชทของ : ${widget.activity['activity_name']}', // ชื่อกิจกรรมในแถบหัว
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              // ส่วนของการแสดงข้อความ
              child: ListView.builder(
                controller: _scrollController, // ใช้ scrollController
                itemCount: _messages.length, // จำนวนข้อความ
                itemBuilder: (context, index) {
                  // ดึงข้อมูลจาก _messages
                  var messageData = _messages[index];

                  // ดึงข้อมูลจาก userData
                  String currentUserId =
                      userData?['user_id'] ?? ''; // user_id ของผู้ใช้ที่ล็อกอิน
                  String currentUserName =
                      userData?['user_name'] ?? ''; // ชื่อผู้ใช้ที่ล็อกอิน
                  String currentUserPhoto =
                      userData?['user_photo'] ?? ''; // รูปผู้ใช้ที่ล็อกอิน

                  // แยกข้อมูลผู้ส่งและข้อความ
                  String senderId =
                      messageData['user_id']; // รับ user_id ของผู้ส่ง
                  String message = messageData['message']; // รับข้อความ
                  String senderName = messageData['user_name']; // รับชื่อผู้ส่ง
                  String senderPhoto =
                      messageData['user_photo']; // รับรูปผู้ส่ง

                  // ตรวจสอบว่า user_id ของผู้ส่งตรงกับ userData หรือไม่
                  bool isLoggedInUser = senderId ==
                      currentUserId; // ตรวจสอบว่าข้อความมาจากผู้ใช้ที่ล็อกอินอยู่หรือไม่

                  String? messageTime =
                      messageData['timestamp']; // เวลาของข้อความ

                  // ส่วนของการสร้าง UI สำหรับข้อความ
                  String formattedTime;
                  if (messageTime != null) {
                    DateTime dateTime =
                        DateTime.parse(messageTime); // แปลงเวลาเป็น DateTime
                    formattedTime = DateFormat('HH.mm น.', 'th')
                        .format(dateTime); // แปลงเวลาเป็นรูปแบบที่ต้องการ
                  } else {
                    formattedTime = "เวลาไม่ระบุ"; // ถ้าไม่มีข้อมูลเวลา
                  }

                  return Align(
                    alignment: isLoggedInUser
                        ? Alignment
                            .centerRight // จัดข้อความไปทางขวาถ้าเป็นผู้ใช้ปัจจุบัน
                        : Alignment
                            .centerLeft, // จัดข้อความไปทางซ้ายถ้าไม่ใช่ผู้ใช้ปัจจุบัน
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment:
                          CrossAxisAlignment.end, // จัดข้อความให้อยู่ล่างสุด
                      children: [
                        if (!isLoggedInUser) // แสดงรูปผู้ส่ง ถ้าไม่ใช่ผู้ใช้ปัจจุบัน
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(
                                  'http://10.0.2.2/flutter_webservice/upload/$senderPhoto'), // รูปของผู้รับ
                              radius: 20,
                            ),
                          ),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: isLoggedInUser
                                ? CrossAxisAlignment
                                    .end // จัดข้อความไปทางขวาถ้าเป็นผู้ใช้ปัจจุบัน
                                : CrossAxisAlignment
                                    .start, // จัดข้อความไปทางซ้ายถ้าไม่ใช่ผู้ใช้ปัจจุบัน
                            children: [
                              if (!isLoggedInUser)
                                Text(
                                  senderName, // แสดงชื่อของผู้ส่ง
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 4.0),
                                padding: EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: isLoggedInUser
                                      ? Colors.lightGreen[
                                          100] // สีสำหรับข้อความที่ส่ง
                                      : Colors
                                          .grey[300], // สีสำหรับข้อความที่รับ
                                  borderRadius:
                                      BorderRadius.circular(15.0), // มุมโค้งมน
                                ),
                                child: Text(
                                  message, // ข้อความ
                                  style: TextStyle(fontSize: 16.0),
                                  softWrap: true, // ทำให้ข้อความยาวๆย่อได้
                                ),
                              ),
                              // แสดงเวลา
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  formattedTime, // เวลาของข้อความ
                                  style: TextStyle(
                                      fontSize: 12.0, color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isLoggedInUser) // แสดงรูปของผู้ใช้ที่ล็อกอินอยู่
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(
                                  currentUserPhoto), // รูปของผู้ใช้
                              radius: 20,
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
                    controller: _controller, // ควบคุมการพิมพ์ข้อความ
                    decoration: InputDecoration(
                        hintText: 'Aa'), // ข้อความแนะนำใน TextField
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send), // ไอคอนสำหรับส่งข้อความ
                  onPressed: _sendMessage, // เมื่อกดจะเรียกฟังก์ชันส่งข้อความ
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
