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

  Future<void> updateUser() async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2/flutter_webservice/get_UpdateProfile.php'), // แก้ไข URL ให้ถูกต้อง
      body: {
        'user_id': userIdController.text,
        'user_name': userNameController.text,
        'user_text': userTextController.text,
      },
    );

    if (response.statusCode == 200) {
      final snackBar = SnackBar(content: Text('Profile updated successfully'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      final snackBar = SnackBar(content: Text('Failed to update profile'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Stack(
        children: [
          Scaffold(
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
                                labelText: 'User ID',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter user ID';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              controller: userNameController,
                              decoration: InputDecoration(
                                labelText: 'User Name',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter user name';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              controller: userTextController,
                              decoration: InputDecoration(
                                labelText: 'User Text',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter user text';
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
                              child: Text('Update Profile'),
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
        ],
      ),
    );
  }
}
