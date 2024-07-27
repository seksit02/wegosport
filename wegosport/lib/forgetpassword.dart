import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wegosport/Login.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _sendResetLink() async {
    final email = _emailController.text.trim();

    if (_formKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse('http://10.0.2.2/flutter_webservice/send_reset_link.php'),
        body: {'email': email},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('ลิ้งก์รีเซ็ตรหัสผ่านได้ถูกส่งไปที่อีเมลของคุณแล้ว')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: Text(
          'หน้าลืมรหัสผ่าน',
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 255, 0, 0),
        leading: IconButton(
            icon: Icon(Icons.arrow_back,color: Color.fromARGB(255, 255, 255, 255),),
            onPressed: () {
             Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage())); // Handle back navigation
            },
          ),
        ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'images/logo.png', // ใส่ URL โลโก้ของคุณ
                  height: 100,
                ),
                SizedBox(height: 20),
                Text(
                  'ลืมรหัสผ่าน',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'กรุณากรอกอีเมลเพื่อยืนยันรหัสผ่านใหม่',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email, color: Colors.red),
                    labelText: 'กรอกอีเมล',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกอีเมล';
                    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                        .hasMatch(value)) {
                      return 'กรุณากรอกอีเมลให้ถูกต้อง';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _sendResetLink,
                  child: Text('ยืนยัน',
                  style : TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 255, 0, 0),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
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
