import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage1 extends StatefulWidget {
  @override
  _ProfilePage1State createState() => _ProfilePage1State();
}

class _ProfilePage1State extends State<ProfilePage1> {

  File? _image;
  Map<String, dynamic>? profileData;

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    final response = await http.get(
      Uri.parse(
          'http://10.0.2.2/flutter_webservice/get_ShowDataUser.php'), // เปลี่ยนเป็นที่อยู่เซิร์ฟเวอร์ของคุณ
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data is List) {
        // สมมติว่าคุณต้องการข้อมูลตัวแรกใน List
        data = data.isNotEmpty ? data[0] : null;
      }
      if (data is Map<String, dynamic>) {
        setState(() {
          profileData = data;
        });
      } else {
        throw Exception('Unexpected data format');
      }
    } else {
      throw Exception('Failed to load profile data');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _navigateAndEditProfile(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditProfilePage(profileData: profileData!)),
    );

    if (result == true) {
      fetchProfileData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color.fromARGB(255, 0, 0, 0)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: profileData == null
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 50),
                  GestureDetector(
                    onTap: _pickImage,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: _image != null
                          ? Image.file(
                              _image!,
                              height: 120.0,
                              width: 120.0,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              'images/P001.jpg',
                              height: 200.0,
                              width: 120.0,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    profileData!['user_name'] ?? 'Unknown',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text('@${profileData!['user_id']}',
                      style: TextStyle(color: Colors.grey[700])),
                  SizedBox(height: 8),
                  Text(profileData!['user_text'] ?? 'ยังไม่ได้เขียนอะไรเลย'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black, backgroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                        side: BorderSide(color: Colors.black),
                      ),
                    ),
                    onPressed: () => _navigateAndEditProfile(context),
                    child: Text('แก้ไขข้อมูล'),
                  ),
                ],
              ),
      ),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> profileData;

  EditProfilePage({required this.profileData});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _idController;
  late TextEditingController _nameController;
  late TextEditingController _briefController;

  @override
  void initState() {
    super.initState();
    _idController =
        TextEditingController(text: widget.profileData['user_id'] ?? '');
    _nameController =
        TextEditingController(text: widget.profileData['user_name'] ?? '');
    _briefController =
        TextEditingController(text: widget.profileData['user_text'] ?? '');
  }

  Future<void> _saveProfile() async {
    final response = await http.post(
      Uri.parse(
          'http://10.0.2.2/flutter_webservice/get_UpdateProfile.php'), // เปลี่ยนเป็นที่อยู่เซิร์ฟเวอร์ของคุณ
      body: {
        'user_id': _idController.text,
        'user_name': _nameController.text,
        'user_text': _briefController.text,
      },
    );

    if (response.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      throw Exception('Failed to update profile data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('แก้ไขข้อมูลโปรไฟล์'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Text(
                  '',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _idController,
                decoration: InputDecoration(
                  labelText: 'รหัสผู้ใช้',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.perm_identity),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'ชื่อ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _briefController,
                decoration: InputDecoration(
                  labelText: 'ข้อมูลพอสังเขป',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.info),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  child: Text('บันทึก'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
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



