import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'package:wegosport/Chat.dart'; // นำเข้าไลบรารีที่จำเป็นและหน้า Profile

class GroupChatListPage extends StatefulWidget {
  final WebSocketChannel channel;
  final dynamic activity; // ตัวแปรที่เก็บข้อมูลกิจกรรม (activity) ที่ถูกส่งผ่าน
  final String jwt;

  const GroupChatListPage({
    super.key,
    required this.channel,
    required this.jwt,
    required this.activity,
  });

  @override
  State<GroupChatListPage> createState() => _GroupChatListPageState();
}

class _GroupChatListPageState extends State<GroupChatListPage> {
  List<Map<String, dynamic>> chatList = []; // เก็บรายการแชท
  Map<String, dynamic>? userData;
  bool isLoading = true; // สถานะการโหลด
  bool hasError = false; // สถานะหากเกิดข้อผิดพลาด

  @override
  void initState() {
    super.initState();
    fetchUserData(widget.jwt).then((_) {
      // ส่งคำสั่งดึงรายการแชทของผู้ใช้
      widget.channel.sink.add(jsonEncode({
        'action': 'get_group_chats',
        'user_id': userData?['user_id'],
      }));
    }).catchError((error) {
      setState(() {
        hasError = true; // กำหนดสถานะเป็นข้อผิดพลาด
      });
    });

    // รับข้อมูลจาก WebSocket และอัปเดตรายการแชท
    widget.channel.stream.listen((message) {
      final data = jsonDecode(message);
      if (data['action'] == 'group_chats') {
        setState(() {
          chatList = List<Map<String, dynamic>>.from(data['chats']);
          isLoading = false; // ปิดสถานะการโหลด
        });
      }
    }, onError: (error) {
      setState(() {
        hasError = true; // กำหนดสถานะเป็นข้อผิดพลาด
      });
    });
  }

  // ฟังก์ชันดึงข้อมูลผู้ใช้จาก JWT
  Future<void> fetchUserData(String jwt) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2/flutter_webservice/get_ShowDataUser.php'),
      headers: {
        'Authorization': 'Bearer $jwt',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List && data.isNotEmpty) {
        setState(() {
          userData = data[0];
        });
      } else {
        throw Exception('No user data found');
      }
    } else {
      throw Exception('Failed to fetch user data');
    }
  }

  @override
  Widget build(BuildContext context) {
    print(
        'ข้อมูลของ _messages : ${chatList}'); // พิมพ์ข้อมูล _messages เพื่อตรวจสอบ
    return Scaffold(
      appBar: AppBar(
        title: Text('รวมแชทกิจกรรม'),
        backgroundColor: Colors.red,
      ),
      body: hasError
          ? Center(
              child: Text(
                  'เกิดข้อผิดพลาดในการโหลดข้อมูล')) // แสดงข้อความเมื่อมีข้อผิดพลาด
          : isLoading
              ? Center(child: CircularProgressIndicator()) // แสดงสถานะการโหลด
              : chatList.isEmpty
                  ? Center(
                      child: Text('ไม่มีแชทในกิจกรรม')) // เมื่อไม่มีข้อมูลแชท
                  : ListView.builder(
                      itemCount: chatList.length,
                      itemBuilder: (context, index) {
                        final chat = chatList[index];

                        return Card(
                          margin:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 25,
                              backgroundImage: NetworkImage(
                                'http://10.0.2.2/flutter_webservice/upload/${chat['user_photo'] ?? ''}',
                              ),
                            ),
                            title: Text(
                              chat['activity_name'] ?? 'ไม่มีข้อมูล',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text(
                              chat['last_message'] ?? 'ไม่มีข้อความ',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                            onTap: () {
                              // เมื่อคลิกที่รายการ ให้ไปที่หน้า ChatPage พร้อมส่งข้อมูล activity
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatPage(
                                    channel: widget.channel,
                                    activity: widget.activity, // ส่งข้อมูล activity ให้ ChatPage
                                    jwt: widget.jwt,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
    );
  }

  @override
  void dispose() {
    widget.channel.sink.close(); // ปิด WebSocket เมื่อหน้าออกจากหน้าจอ
    super.dispose();
  }
}
