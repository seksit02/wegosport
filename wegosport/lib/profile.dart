import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:wegosport/Homepage.dart';
import 'package:wegosport/EditProfile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.jwt});

  final String jwt;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    fetchUserData(widget.jwt);
  }

  Future<void> fetchUserData(String jwt) async {
    var url =
        Uri.parse('http://10.0.2.2/flutter_webservice/get_ShowDataUser.php');

    Map<String, String> headers = {
      'Authorization': 'Bearer $jwt',
    };

    print('Headers: $headers'); // พิมพ์ headers เพื่อการตรวจสอบ

    try {
      var response = await http.post(
        url,
        headers: headers,
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
            userData = data[0];
          });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 0, 0),
        title: Text(
          "หน้าโปรไฟล์",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: const Color.fromARGB(255, 255, 255, 255)),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    Homepage(jwt: widget.jwt), // ส่ง jwt กลับไปยัง Homepage
              ),
            );
          },
        ),
      ),
      body: userData == null
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: userData!['user_photo'] != null
                        ? NetworkImage(userData!['user_photo'])
                        : AssetImage("images/P001.jpg") as ImageProvider,
                  ),
                  SizedBox(height: 16),
                  Text(
                    userData!['user_name'] ?? 'ไม่มีข้อมูล',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '@${userData!['user_id'] ?? 'ไม่มีข้อมูล'}',
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color.fromARGB(255, 18, 18, 18),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    userData!['user_text'] ?? 'ไม่มีข้อมูล',
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfile(jwt: widget.jwt),
                        ),
                      );
                    },
                    child: Text('แก้ไขข้อมูล'),
                  ),
                ],
              ),
            ),
    );
  }
}
