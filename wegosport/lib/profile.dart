import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _image;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
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
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 50), // ระยะห่างจากด้านบน
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
                        'images/logo.png',
                        height: 120.0,
                        width: 120.0,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'เต้ สุดหล่อ',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text('@Amaegmee', style: TextStyle(color: Colors.grey[700])),
            SizedBox(height: 8),
            Text('เพื่อน 0'),
            SizedBox(height: 8),
            Text('เต้ สุดหล่อ ยังไม่ได้เขียนอะไรเล้ยยย'),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.white,
                onPrimary: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  side: BorderSide(color: Colors.black),
                ),
              ),
              onPressed: () {},
              child: Text('แก้ไขข้อมูล'),
            ),
          ],
        ),
      ),
    );
  }
}
