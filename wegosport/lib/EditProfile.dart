import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wegosport/Profile.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key, required this.jwt});

  final String jwt;

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  Map<String, dynamic>? userData;

  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _userTextController = TextEditingController();

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

    try {
      var response = await http.post(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List<dynamic> &&
            data.isNotEmpty &&
            data[0] is Map<String, dynamic> &&
            data[0].containsKey('user_id')) {
          setState(() {
            userData = data[0];
            _userIdController.text = userData!['user_id'];
            _userNameController.text = userData!['user_name'];
            _userTextController.text = userData!['user_text'];
          });
        } else {
          throw Exception('Failed to load user data');
        }
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (error) {
      throw Exception('Failed to load user data');
    }
  }

  Future<void> updateUserProfile() async {
    var url =
        Uri.parse('http://10.0.2.2/flutter_webservice/get_UpdateProfile.php');

    Map<String, String> headers = {
      'Authorization': 'Bearer ${widget.jwt}',
    };

    Map<String, String> body = {
      'jwt': widget.jwt,
      'user_id': _userIdController.text,
      'user_name': _userNameController.text,
      'user_text': _userTextController.text,
    };

    print(headers);
    print(body);

    try {
      var response = await http.post(
        url,
        headers: headers,
        body: body,
      );
    print(response);
      if (response.statusCode == 200) {
        // อัปเดตสำเร็จ
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(jwt: widget.jwt),
          ),
        );
      } else {
        throw Exception('Failed to update user data');
      }
    } catch (error) {
      throw Exception('Failed to update user data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 255, 0, 0),
          title: Text(
            "หน้าแก้ไขข้อมูล",
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: Color.fromARGB(255, 255, 255, 255)),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(jwt: widget.jwt),
                ),
              );
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _userIdController,
                decoration: InputDecoration(labelText: 'ชื่อผู้ใช้'),
              ),
              TextField(
                controller: _userNameController,
                decoration: InputDecoration(labelText: 'ชื่อ'),
              ),
              TextField(
                controller: _userTextController,
                decoration: InputDecoration(labelText: 'ข้อความขังเขป'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: updateUserProfile,
                child: Text('อัปเดตข้อมูล'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
