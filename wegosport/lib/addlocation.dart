import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:wegosport/Homepage.dart';

class AddLocationPage extends StatefulWidget {
  const AddLocationPage({super.key});

  @override
  State<AddLocationPage> createState() => _AddLocationState();
}

class _AddLocationState extends State<AddLocationPage> {
  TextEditingController input1 = TextEditingController();
  TextEditingController input2 = TextEditingController();
  TextEditingController input3 = TextEditingController();
  File? _imageFile;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Widget backButton() {
    return IconButton(
      icon: Icon(Icons.arrow_back, color: Colors.black),
      onPressed: () {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => Homepage()));
      },
    );
  }

  Widget namelocation() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: TextFormField(
        controller: input1,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(15, 10, 15, 10),
          hintText: 'ชื่อสถานที่',
          fillColor: Colors.black,
          filled: true,
          hintStyle: TextStyle(color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget time() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: TextFormField(
        controller: input2,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(15, 10, 15, 10),
          hintText: 'เวลาเปิด - ปิด',
          fillColor: Colors.black,
          filled: true,
          hintStyle: TextStyle(color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        style: TextStyle(color: Colors.white),
      ),
    );
  }


  Widget addImage() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: ElevatedButton.icon(
        icon: Icon(Icons.image, color: Colors.white),
        label: Text("แบบรูป", style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          primary: Colors.black,
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: _pickImage,
      ),
    );
  }

  Widget mapImage() {
    return _imageFile == null
        ? Container(
            margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'images/logo.png', // เปลี่ยนเป็นรูปภาพของแผนที่
                fit: BoxFit.cover,
              ),
            ),
          )
        : Container(
            margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                _imageFile!,
                fit: BoxFit.cover,
              ),
            ),
          );
  }

  Widget buttonAddLocation() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: ElevatedButton(
        child: Text("เพิ่มสถานที่", style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          primary: Colors.yellow[700],
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          functionAddLocation();
        },
      ),
    );
  }

  Future<void> functionAddLocation() async {
    if (_imageFile == null) {
      print("No image selected.");
      return;
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("http://10.0.2.2/flutter_webservice/get_AddLocation.php"),
    );

    request.fields['location_name'] = input1.text;
    request.fields['location_time'] = input2.text;
    
    request.files
        .add(await http.MultipartFile.fromPath('image', _imageFile!.path));

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        print(responseData);
      } else {
        print("Request failed with status: ${response.statusCode}");
      }
    } catch (error) {
      print("Error: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text("เพิ่มสถานที่"),
        leading: backButton(),
        backgroundColor: Colors.grey[800],
      ),
      body: SafeArea(
        child: ListView(
          children: [
            namelocation(),
            time(),
            addImage(),
            mapImage(),
            buttonAddLocation(),
          ],
        ),
      ),
    );
  }
}
