import 'package:flutter/material.dart'; // นำเข้าชุดคำสั่งที่ใช้สร้าง UI ใน Flutter
import 'package:http/http.dart'as http; // นำเข้าแพ็กเกจ HTTP สำหรับเรียกใช้งาน API
import 'dart:convert'; // นำเข้าแพ็กเกจสำหรับแปลงข้อมูล JSON
import 'package:web_socket_channel/web_socket_channel.dart'; // นำเข้าชุดคำสั่งที่ใช้ในการเชื่อมต่อ WebSocket
import 'package:intl/intl.dart'; // นำเข้าไลบรารีที่จำเป็นสำหรับการทำงาน

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

  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    fetchUserData(widget.jwt).then((_) {
      connectToWebSocket();
      widget.channel.sink.add(jsonEncode({
        'action': 'get_messages',
        'activity_id': widget.activity['activity_id'],
        'user_id': userData?['user_id'],
      }));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    widget.channel.stream.listen((message) {
      var decodedMessage = jsonDecode(message);

      if (decodedMessage['action'] == 'messages') {
        setState(() {
          _messages.clear();
          _messages.addAll(
              List<Map<String, dynamic>>.from(decodedMessage['messages']));
          _scrollToBottom(); // เลื่อนข้อความไปที่ข้อความล่าสุด
        });
      } else if (decodedMessage['action'] == 'new_message') {
        setState(() {
          Map<String, dynamic> newMessage =
              Map<String, dynamic>.from(decodedMessage['message']);
          // เช็คว่ามี timestamp หรือไม่ ถ้าไม่มีก็ใช้ DateTime.now()
          if (!newMessage.containsKey('timestamp') ||
              newMessage['timestamp'] == null) {
            newMessage['timestamp'] = DateTime.now().toIso8601String();
          }
          _messages.add(newMessage); // เพิ่มข้อความใหม่
          _scrollToBottom(); // เลื่อนข้อความไปที่ข้อความล่าสุด
        });
      }
    });

  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOut,
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

                  String? messageTime = messageData['timestamp'];

                  // ส่วนของการสร้าง UI สำหรับข้อความ
                  String formattedTime;
                  if (messageTime != null) {
                    DateTime dateTime = DateTime.parse(messageTime);
                    formattedTime =
                        DateFormat('HH.mm น.', 'th').format(dateTime);
                  } else {
                    formattedTime = "เวลาไม่ระบุ";
                  }

                  return Align(
                    alignment: isLoggedInUser
                        ? Alignment
                            .centerRight // Align message to the right for logged-in user
                        : Alignment
                            .centerLeft, // Align message to the left for other users
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment:
                          CrossAxisAlignment.end, // Align at the bottom
                      children: [
                        if (!isLoggedInUser) // Display profile picture for other users
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(
                                  'http://10.0.2.2/flutter_webservice/upload/$senderPhoto'),
                              radius: 20,
                            ),
                          ),
                        Column(
                          crossAxisAlignment: isLoggedInUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment
                                  .start, // Align text based on the user
                          children: [
                            if (!isLoggedInUser)
                              Text(
                                senderName, // Display name for other users
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 4.0),
                              padding: EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: isLoggedInUser
                                    ? Colors.lightGreen[
                                        100] // Custom color for sent messages
                                    : Colors.grey[
                                        300], // Light grey for received messages
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Text(
                                message,
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ),
                            // Add timestamp
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                formattedTime, // Example timestamp, you can replace it with actual data
                                style: TextStyle(
                                    fontSize: 12.0, color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                        if (isLoggedInUser) // Display profile picture for logged-in user
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(currentUserPhoto),
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
