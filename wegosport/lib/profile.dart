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
  const ProfilePage({super.key, required this.jwt, required this.activity});

  final String jwt; // รับค่า JWT สำหรับการตรวจสอบสิทธิ์
  final dynamic activity;

  @override
  State<ProfilePage> createState() =>
      _ProfilePageState(); // สร้างสถานะของ ProfilePage
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData; // เก็บข้อมูลผู้ใช้
  List<dynamic> createdActivities = []; // เก็บข้อมูลกิจกรรมที่ผู้ใช้สร้าง

  @override
  void initState() {
    super.initState();
    fetchUserData(widget.jwt).then((_) {
      fetchCreatedActivities(); // ดึงกิจกรรมที่ผู้ใช้สร้าง
    });
  }

  // ฟังก์ชันดึงข้อมูลผู้ใช้จากเซิร์ฟเวอร์
  Future<void> fetchUserData(String jwt) async {
    var url =
        Uri.parse('http://10.0.2.2/flutter_webservice/get_ShowDataUser.php');

    Map<String, String> headers = {
      'Authorization': 'Bearer $jwt', // ใส่ JWT ในส่วนของ Authorization Header
    };

    try {
      var response = await http.post(
        url,
        headers: headers, // ส่งค่า JWT ไปพร้อมกับคำขอ
      );

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
        throw Exception('Failed to load user data');
      }
    } catch (error) {
      print("Error: $error");
      throw Exception('Failed to load user data');
    }
  }

  // ฟังก์ชันดึงกิจกรรมจากเซิร์ฟเวอร์แล้วกรองเฉพาะกิจกรรมที่ผู้ใช้สร้าง
  Future<void> fetchCreatedActivities() async {
    final userId = userData?['user_id']; // ดึง user_id จากข้อมูลผู้ใช้
    if (userId == null) {
      print('User ID is null');
      return;
    }

    // เรียก API ดึงข้อมูลกิจกรรมทั้งหมด
    final response = await http.get(
      Uri.parse('http://10.0.2.2/flutter_webservice/get_ShowDataActivity.php'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // จัดเรียงกิจกรรมตามวันที่
      data.sort((a, b) {
        final dateA = DateTime.parse(a['activity_date']);
        final dateB = DateTime.parse(b['activity_date']);
        return dateB.compareTo(dateA); // จัดเรียงตามวันที่ล่าสุด
      });

      // กรองข้อมูลกิจกรรม เฉพาะที่ผู้ใช้เป็น creator
      List<dynamic> filteredActivities = data.where((activity) {
        return activity['creator'] ==
            userId; // ตรวจสอบว่าผู้ใช้เป็น creator หรือไม่
      }).toList();

      setState(() {
        createdActivities = filteredActivities; // เก็บกิจกรรมที่ผู้ใช้สร้าง
      });
    } else {
      throw Exception('Failed to load activities');
    }
  }

  // ฟังก์ชันสร้างรายการกิจกรรมที่ผู้ใช้สร้าง
  Widget _buildCreatedActivityList() {
    if (createdActivities.isEmpty) {
      return Text('คุณยังไม่มีกิจกรรมที่สร้าง');
    }
    return ListView.builder(
      shrinkWrap: true, // เพื่อให้รายการกิจกรรมอยู่ใน Column ได้
      itemCount: createdActivities.length,
      itemBuilder: (context, index) {
        final activity = createdActivities[index];
        return ListTile(
          title: Text(activity['activity_name']),
          subtitle: Text('วันที่: ${activity['activity_date']}'),
        );
      },
    );
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
        lockAspectRatio: true, // ล็อกอัตราส่วนภาพให้เป็นสี่เหลี่ยมจตุรัส
      ),
      iosUiSettings: IOSUiSettings(
        minimumAspectRatio: 1.0, // กำหนดอัตราส่วนขั้นต่ำสำหรับ iOS
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
        backgroundColor: Color.fromARGB(
            255, 255, 0, 0), // กำหนดสีพื้นหลังของ AppBar เป็นสีแดง
        title: Text(
          "หน้าโปรไฟล์", // ชื่อหน้าจอ
          style: TextStyle(color: Colors.white), // กำหนดสีข้อความเป็นสีขาว
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: const Color.fromARGB(
                  255, 255, 255, 255)), // กำหนดสีไอคอนเป็นสีขาว
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    Homepage(jwt: widget.jwt), // กลับไปที่หน้า Homepage
              ),
            );
          },
        ),
      ),
      body: userData == null
          ? Center(
              child:
                  CircularProgressIndicator()) // แสดงตัวโหลดข้อมูลขณะรอข้อมูลผู้ใช้
          : SingleChildScrollView(
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
                          : AssetImage("images/BGProfile.jpg")
                              as ImageProvider, // แสดงภาพดีฟอลต์ถ้าไม่มีภาพโปรไฟล์
                    ),
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
                  userData!['user_text']?.isNotEmpty == true
                      ? Text(
                          userData!['user_text'],
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color.fromARGB(255, 0, 0, 0),
                          ),
                        )
                      : Text(
                          'ใส่ข้อความสังเขป',
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                  SizedBox(height: 16),
                  Text(
                    formatDate(userData!['user_age'] ?? 'ไม่มีข้อมูล'),
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

                  // เส้นกัน
                  Divider(thickness: 2, color: Colors.grey),

                  // ส่วนแสดงกิจกรรมที่ผู้ใช้สร้าง
                  Text(
                    'กิจกรรมที่คุณสร้าง',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  _buildCreatedActivityList(),
                ],
              ),
            ),
    );
  }
}
