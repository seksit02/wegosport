import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // ใช้สำหรับการเรียก HTTP
import 'dart:convert'; // ใช้สำหรับการแปลง JSON
import 'package:wegosport/Homepage.dart'; // นำเข้า Homepage
import 'package:wegosport/EditProfile.dart'; // นำเข้า EditProfile
import 'package:image_picker/image_picker.dart'; // ใช้สำหรับการเลือกภาพจากแกลเลอรี
import 'package:image_cropper/image_cropper.dart'; // ใช้สำหรับการครอบภาพ
import 'dart:io'; // ใช้สำหรับการจัดการไฟล์
import 'package:image/image.dart' as img; // ใช้สำหรับการจัดการภาพ

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.jwt});

  final String jwt; // รับค่า JWT สำหรับการตรวจสอบสิทธิ์

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData; // เก็บข้อมูลผู้ใช้

  @override
  void initState() {
    super.initState();
    fetchUserData(widget.jwt); // เรียกใช้ฟังก์ชัน fetchUserData เมื่อเริ่มต้น
  }

  // ฟังก์ชันดึงข้อมูลผู้ใช้จากเซิร์ฟเวอร์
  Future<void> fetchUserData(String jwt) async {
    var url =
        Uri.parse('http://10.0.2.2/flutter_webservice/get_ShowDataUser.php');

    Map<String, String> headers = {
      'Authorization': 'Bearer $jwt',
    };

    print('Headers profile : $headers');

    try {
      var response = await http.post(
        url,
        headers: headers,
      );

      print('Response status profile : ${response.statusCode}');
      print('Response body profile : ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List<dynamic> &&
            data.isNotEmpty &&
            data[0] is Map<String, dynamic> &&
            data[0].containsKey('user_id')) {
          setState(() {
            userData = data[0]; // เก็บข้อมูลผู้ใช้ในตัวแปร userData
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

  // ฟังชั่นแปลงสตริงวันที่เป็น DateTime object
  String formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);

    // แปลง DateTime object เป็นสตริงในรูปแบบ DD/MM/YYYY
    String formattedDate = "${parsedDate.day.toString().padLeft(2, '0')}/"
        "${parsedDate.month.toString().padLeft(2, '0')}/"
        "${parsedDate.year}";

    return formattedDate;
  }

  // ฟังก์ชันเลือกภาพจากแกลเลอรี
  Future<void> _pickImage() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('แก้ไขรูปโปรไฟล์'),
          content: Text('คุณต้องการแก้ไขรูปโปรไฟล์หรือไม่?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // ยกเลิกการเลือกภาพ
              },
              child: Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // ยืนยันการเลือกภาพ
              },
              child: Text('ตกลง'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final pickedFile = await ImagePicker()
          .pickImage(source: ImageSource.gallery); // เลือกภาพจากแกลเลอรี
      if (pickedFile != null) {
        File? croppedFile = await _cropImage(File(pickedFile.path)); // ครอบภาพ
        if (croppedFile != null) {
          _compressAndUploadImage(croppedFile); // บีบอัดและอัปโหลดภาพ
        }
      }
    }
  }

  // ฟังก์ชันครอบภาพ
  Future<File?> _cropImage(File imageFile) async {
    File? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square, // ตั้งค่าอัตราส่วนภาพเป็นสี่เหลี่ยมจตุรัส
      ],
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'Crop Image',
        toolbarColor: Colors.deepOrange,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.square,
        lockAspectRatio: true,
      ),
      iosUiSettings: IOSUiSettings(
        minimumAspectRatio: 1.0,
      ),
    );
    return croppedFile;
  }

  // ฟังก์ชันบีบอัดและอัปโหลดภาพ
  Future<void> _compressAndUploadImage(File imageFile) async {
    // โหลดไฟล์ภาพ
    img.Image? image = img.decodeImage(await imageFile.readAsBytes());

    // ปรับขนาดภาพให้เล็กลง
    img.Image resizedImage = img.copyResize(image!, width: 600);

    // บีบอัดภาพให้มีขนาดไฟล์เล็กลง
    List<int> compressedImageBytes = img.encodeJpg(resizedImage, quality: 85);

    // สร้างไฟล์ใหม่จากข้อมูลภาพที่ถูกบีบอัด
    File compressedImageFile = File(imageFile.path)
      ..writeAsBytesSync(compressedImageBytes);

    _uploadImage(compressedImageFile); // อัปโหลดภาพ
  }

  // ฟังก์ชันอัปโหลดภาพไปยังเซิร์ฟเวอร์
  Future<void> _uploadImage(File image) async {
    var url =
        Uri.parse('http://10.0.2.2/flutter_webservice/savephotoprofile.php');

    var request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath(
        'image', image.path)); // เพิ่มไฟล์ภาพในคำขอ
    request.fields['user_id'] = userData!['user_id']; // เพิ่ม user_id ในคำขอ

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await http.Response.fromStream(response);
        var data = json.decode(responseData.body);
        if (data['status'] == 'success') {
          setState(() {
            userData!['user_photo'] =
                data['image_url']; // อัปเดต URL ของภาพโปรไฟล์
          });
          fetchUserData(
              widget.jwt); // เรียกใช้ fetchUserData เพื่อรีเฟรชหน้าทันที
        } else {
          print('Failed to upload image: ${data['message']}');
        }
      } else {
        var responseData = await http.Response.fromStream(response);
        print('Failed to upload image: ${responseData.body}');
      }
    } catch (error) {
      print('Error uploading image: $error');
    }
  }

  // การสร้าง UI ของหน้าจอโปรไฟล์
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
                builder: (context) => Homepage(jwt: widget.jwt),
              ),
            );
          },
        ),
      ),
      body: userData == null
          ? Center(
              child:
                  CircularProgressIndicator()) // แสดงตัวโหลดข้อมูลขณะรอข้อมูลผู้ใช้
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap:
                        _pickImage, // เรียกใช้ฟังก์ชัน _pickImage เมื่อกดที่ภาพโปรไฟล์
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: userData!['user_photo'] != null
                          ? NetworkImage(
                              userData!['user_photo']) // แสดงภาพโปรไฟล์จาก URL
                          : AssetImage("images/P001.jpg")
                              as ImageProvider, // แสดงภาพดีฟอลต์ถ้าไม่มีภาพโปรไฟล์
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    userData!['user_name'] ?? 'ไม่มีข้อมูล', // แสดงชื่อผู้ใช้
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '@${userData!['user_id'] ?? 'ไม่มีข้อมูล'}', // แสดง user_id
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color.fromARGB(255, 18, 18, 18),
                    ),
                  ),
                  SizedBox(height: 16),
                  userData!['user_text']?.isNotEmpty == true
                      ? Text(
                          userData!['user_text'],
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color.fromARGB(255, 0, 0, 0),
                          ),
                        )
                      : Text(
                          'ใส่ข้อความสังเขป', // ข้อความที่จะแสดงแทนในกรณีที่ไม่มีข้อมูล
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                  SizedBox(height: 16),
                  Text(
                    formatDate(userData!['user_age'] ??
                        'ไม่มีข้อมูล'), // แสดงผลวันที่ในรูปแบบ DD/MM/YYYY
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
                          builder: (context) => EditProfile(
                              jwt: widget.jwt), // ไปที่หน้า EditProfile
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
