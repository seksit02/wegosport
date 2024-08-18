import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wegosport/Login.dart'; // นำเข้าไลบรารีที่จำเป็นและหน้า Login

// หน้าจอลืมรหัสผ่าน
class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() =>
      _ForgotPasswordPageState(); // สร้างสถานะของ ForgotPasswordPage
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController =
      TextEditingController(); // ตัวควบคุมสำหรับฟิลด์อีเมล
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // กุญแจสำหรับฟอร์ม

  // ฟังก์ชันส่งลิ้งก์รีเซ็ตรหัสผ่าน
  Future<void> _sendResetLink() async {
    final email =
        _emailController.text.trim(); // รับค่าจากฟิลด์อีเมลและตัดช่องว่างออก

    if (_formKey.currentState!.validate()) {
      // ตรวจสอบความถูกต้องของฟอร์ม
      final response = await http.post(
        Uri.parse(
            'http://10.0.2.2/flutter_webservice/send_reset_link.php'), // ส่งคำขอ POST ไปยัง URL ที่ระบุ
        body: {'email': email}, // ส่งข้อมูลอีเมลในส่วนของคำขอ
      );

      if (response.statusCode == 200) {
        // แสดงป๊อปอัพเมื่อส่งลิ้งก์สำเร็จ
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('สำเร็จ'),
              content: Text(
                  'ลิ้งก์รีเซ็ตรหัสผ่านได้ถูกส่งไปที่อีเมลของคุณแล้ว รีเซ็ตรหัสผ่านได้ที่อีเมล'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // ปิดป๊อปอัพ
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(), // กลับไปหน้า Login
                      ),
                    );
                  },
                  child: Text('ตกลง'),
                ),
              ],
            );
          },
        );
      } else {
        // แสดงข้อความเมื่อเกิดข้อผิดพลาด
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Color.fromARGB(255, 255, 255, 255), // กำหนดสีพื้นหลังของหน้าจอ
      appBar: AppBar(
        backgroundColor:
            Color.fromARGB(255, 255, 0, 0), // กำหนดสีพื้นหลังของ AppBar
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back, color: Color.fromARGB(255, 255, 255, 255)),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(), // กลับไปยังหน้า Login
              ),
            );
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: 32.0), // กำหนดขนาด padding ของฟอร์ม
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'images/logo.png', // ใส่ URL โลโก้ของคุณ
                  height: 100,
                ),
                SizedBox(height: 20), // ระยะห่างระหว่างโลโก้กับข้อความ
                Text(
                  'ลืมรหัสผ่าน',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold), // ข้อความลืมรหัสผ่าน
                ),
                SizedBox(height: 10), // ระยะห่างระหว่างข้อความ
                Text(
                  'กรุณากรอกอีเมลเพื่อยืนยันรหัสผ่านใหม่',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center, // จัดข้อความให้อยู่กึ่งกลาง
                ),
                SizedBox(height: 30), // ระยะห่างระหว่างข้อความกับฟิลด์อีเมล
                TextFormField(
                  controller: _emailController, // ตัวควบคุมฟิลด์อีเมล
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email,
                        color: Colors.red), // ไอคอนด้านหน้าฟิลด์
                    labelText: 'กรอกอีเมล', // ข้อความแนะนำในฟิลด์
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          30.0), // ปรับความโค้งของขอบฟิลด์
                    ),
                  ),
                  keyboardType: TextInputType
                      .emailAddress, // กำหนดประเภทคีย์บอร์ดเป็นอีเมล
                  validator: (value) {
                    // ตรวจสอบความถูกต้องของอีเมล
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกอีเมล'; // ข้อความแสดงเมื่อไม่ได้กรอกอีเมล
                    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                        .hasMatch(value)) {
                      return 'กรุณากรอกอีเมลให้ถูกต้อง'; // ข้อความแสดงเมื่ออีเมลไม่ถูกต้อง
                    }
                    return null; // อีเมลถูกต้อง
                  },
                ),
                SizedBox(height: 20), // ระยะห่างระหว่างฟิลด์อีเมลกับปุ่ม
                ElevatedButton(
                  onPressed:
                      _sendResetLink, // เรียกใช้ฟังก์ชัน _sendResetLink เมื่อกดปุ่ม
                  child: Text(
                    'ยืนยัน',
                    style: TextStyle(
                        color: const Color.fromARGB(255, 255, 255, 255)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Color.fromARGB(255, 255, 0, 0), // กำหนดสีพื้นหลังปุ่ม
                    padding: EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15), // ขนาด padding ของปุ่ม
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(30.0), // ปรับความโค้งของปุ่ม
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
