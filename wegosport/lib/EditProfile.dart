import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController userIdController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController userTextController = TextEditingController();
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    //fetchUserData();
    fetchUserData1(); // เรียกใช้ฟังก์ชันดึงข้อมูลผู้ใช้เมื่อเริ่มต้นหน้าจอ
  }

  Future<void> updateUser() async {
    print('Updating user with ID: ${userIdController.text}');
    print('New user name: ${userNameController.text}');
    print('New user text: ${userTextController.text}');

    final response = await http.post(
      Uri.parse(
          'http://10.0.2.2/flutter_webservice/get_UpdateProfile.php'), // แก้ไข URL ให้ถูกต้อง
      body: {
        'user_id': userIdController.text,
        'user_name': userNameController.text,
        'user_text': userTextController.text,
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Profile updated successfully'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to update profile'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  /*Future<void> fetchUserData() async {
    const String jwt =
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoiYmVlbTIxIn0.xD71Fhfq_3oadz8XmiyJbwEv9676HQnPNiouwiMloXc";

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2/flutter_webservice/get_ShowDataUser.php'),
        body: {
          'jwt': jwt,
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          userData =
              data.isNotEmpty && data[0]['user_jwt'] != null ? data[0] : null;
          if (userData != null) {
            userIdController.text = userData!['user_id'];
            userNameController.text = userData!['user_name'];
            userTextController.text = userData!['user_text'];
          }
        });

        print(data);
      } else {
        print("Failed to load user data: ${response.body}");
        throw Exception('Failed to load user data');
      }
    } catch (error) {
      print("Error: $error");
      throw Exception('Failed to load user data');
    }
  }*/

  Future<void> fetchUserData1() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2/flutter_webservice/get_ShowDataUser1.php'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          userData = data.isNotEmpty ? data[0] : null;
          if (userData != null) {
            userIdController.text = userData!['user_id'];
            userNameController.text = userData!['user_name'];
            userTextController.text = userData!['user_text'];
          }
        });

        print(data);
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
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 255, 0, 0),
          title: Text("หน้าแก้ไขโปรไฟล์"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: Color.fromARGB(255, 255, 255, 255)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SafeArea(
          child: ListView(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        TextFormField(
                          controller: userIdController,
                          decoration: InputDecoration(
                            labelText: 'รหัสผู้ใช้',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'กรุณากรอกรหัสผู้ใช้';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: userNameController,
                          decoration: InputDecoration(
                            labelText: 'ชื่อผู้ใช้',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'กรุณากรอกชื่อผู้ใช้';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: userTextController,
                          decoration: InputDecoration(
                            labelText: 'ข้อความสังเขป',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'กรุณากรอกข้อความสังเขป';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              updateUser();
                            }
                          },
                          child: Text('แก้ไขข้อมูล'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
