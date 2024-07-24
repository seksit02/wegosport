import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  String? photoUrl;

  @override
  void initState() {
    super.initState();
    fetchPhoto("admin"); // เปลี่ยนเป็น user_id ที่คุณต้องการ
  }

  Future<void> fetchPhoto(String userId) async {
    final response = await http.get(
      Uri.parse(
          'http://10.0.2.2/flutter_webservice/get_TestAPI.php?user_id=$userId'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data); // พิมพ์ข้อมูลที่ได้รับเพื่อตรวจสอบ

      setState(() {
        // สมมุติว่า data เป็น Map และมี key 'photo_url'
        if (data is Map<String, dynamic> && data.containsKey('photo_url')) {
          photoUrl = 'http://10.0.2.2/flutter_webservice/' + data['photo_url'];
        } else {
          throw Exception('Photo URL not found in response');
        }
      });
    } else {
      throw Exception('Failed to load photo');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ทดสอบดึงรูปด้วย API'),
      ),
      body: Center(
        child: photoUrl == null
            ? CircularProgressIndicator()
            : Image.network(photoUrl!),
      ),
    );
  }
}
