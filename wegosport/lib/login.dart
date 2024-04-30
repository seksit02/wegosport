import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController inputone = TextEditingController();
  TextEditingController inputtwo = TextEditingController();


Widget appLogo() {
  return Container(
    width: 300,
    height: 250,
    margin: EdgeInsets.fromLTRB(0, 50, 0, 0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(50), // กำหนดรูปร่างของกรอบ
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(10), // ให้ Clip รูปภาพตามรูปร่างของกรอบ
      child: Image.asset(
        "images/login.png",
        fit: BoxFit.cover, // ให้รูปภาพปรับตามขนาดของ Container
      ),
    ),
  );
}

  Widget inputOne() {
  return Container(
    margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
    child: TextFormField(
      controller: inputone,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
        hintText: 'ชื่อผู้ใช้',
        fillColor: Colors.white, // กำหนดสีพื้นหลังเป็นสีขาว
        filled: true,
        prefixIcon: Icon(
          Icons.person,
          color: Colors.red, // ตั้งค่าสีของไอคอนเป็นสีแดง
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(30), // ปรับความโค้งของกรอบ
        ),
      ),
    ),
  );
}

Widget inputTwo() {
  return Container(
    margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
    child: TextFormField(
      controller: inputtwo,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
        hintText: 'รหัสผ่าน',
        fillColor: Color.fromARGB(255, 255, 255, 255),
        filled: true,
        prefixIcon: Icon(
          Icons.lock,
          color: Colors.red, // ตั้งค่าสีของไอคอนเป็นสีแดง
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(30), // ปรับความโค้งของกรอบ
        ),
      ),
    ),
  );
}


Widget buttonProcesslogin() {
  return ButtonTheme(
    minWidth: double.infinity,
    child: Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
      child: ElevatedButton(
        child: Text(
          "เข้าสู่ระบบ",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
          backgroundColor: Color.fromARGB(249, 255, 4, 4),
          shadowColor: Color.fromARGB(255, 255, 255, 255),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // ปรับความโค้งของกรอบ
            side: BorderSide(color: Colors.black),
          ),
        ),
        onPressed: () {
          // โค้ดการเข้าสู่ระบบ
        },
      ),
    ),
  );
}

Widget buttonfacebook() {
  return Container(
    margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
    child: ElevatedButton.icon(
      icon: Icon(
        Icons.facebook,
        color: Colors.white,
      ),
      label: Text(
        "Sign up with Facebook",
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      onPressed: () {
        // โค้ดที่ต้องการทำเมื่อกดปุ่ม Facebook
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.fromLTRB(15, 10, 20, 8),
        backgroundColor: Color.fromARGB(255, 31, 136, 234),
        shadowColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // ปรับความโค้งของกรอบ
        ),
        side: BorderSide(color: Colors.black),
      ),
    ),
  );
}



  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Stack(
        children: [
          Scaffold(
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
            body: SafeArea(
              child: ListView(
                children: [
                  Center(
                      child: Column(mainAxisSize: MainAxisSize.max, children: [
                    appLogo(),
                    inputOne(),
                    inputTwo(),
                    buttonProcesslogin(),
                    buttonfacebook()

                  ])),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
