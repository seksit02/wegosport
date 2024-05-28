import 'package:flutter/material.dart';

class createactivitypage extends StatefulWidget {
  const createactivitypage({super.key});

  @override
  State<createactivitypage> createState() => _createactivitypageState();
}

class _createactivitypageState extends State<createactivitypage> {
  TextEditingController input1 = TextEditingController();
  TextEditingController input2 = TextEditingController();
  TextEditingController input3 = TextEditingController();
  TextEditingController input4 = TextEditingController();
  TextEditingController input5 = TextEditingController();
  TextEditingController input6 = TextEditingController();

  Widget appLogo() {
    return Container(
      width: 300,
      height: 250,
      margin: EdgeInsets.fromLTRB(0, 50, 0, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50), // กำหนดรูปร่างของกรอบ
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(10), // ให้ Clip รูปภาพตามรูปร่างของกรอบ
        child: Image.asset(
          "images/login.png",
          fit: BoxFit.cover, // ให้รูปภาพปรับตามขนาดของ Container
        ),
      ),
    );
  }

  Widget nameactivity() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
      child: TextFormField(
        controller: input1,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
          hintText: 'ชื่อกิจกรรม',
          fillColor: Color.fromARGB(255, 255, 255, 255),
          filled: true,
          prefixIcon: Icon(
            Icons.add,
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

  Widget location() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
      child: TextFormField(
        controller: input1,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
          hintText: 'สถานที่',
          fillColor: Color.fromARGB(255, 255, 255, 255),
          filled: true,
          prefixIcon: Icon(
            Icons.add,
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

  Widget date() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
      child: TextFormField(
        controller: input1,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
          hintText: 'วันที่',
          fillColor: Color.fromARGB(255, 255, 255, 255),
          filled: true,
          prefixIcon: Icon(
            Icons.add,
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

  Widget hashtag() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
      child: TextFormField(
        controller: input1,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
          hintText: 'แฮชแท็ก',
          fillColor: Color.fromARGB(255, 255, 255, 255),
          filled: true,
          prefixIcon: Icon(
            Icons.add,
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

  Widget buttonblack() {
    return ButtonTheme(
      minWidth: double.infinity,
      child: Container(
        margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
        child: ElevatedButton(
          child: Text(
            "ปุ่มย้อนกลับ",
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

  Widget message() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
      child: TextFormField(
        controller: input1,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
          hintText: 'ข้อความขังเขป',
          fillColor: Color.fromARGB(255, 255, 255, 255),
          filled: true,
          prefixIcon: Icon(
            Icons.add,
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

  Widget picture() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
      child: TextFormField(
        controller: input1,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
          hintText: 'แนปรูป',
          fillColor: Color.fromARGB(255, 255, 255, 255),
          filled: true,
          prefixIcon: Icon(
            Icons.add,
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

  Widget Creategroup() {
    return ButtonTheme(
      minWidth: double.infinity,
      child: Container(
        margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
        child: ElevatedButton(
          child: Text(
            "สร้างกิจกรรม",
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Stack(
        children: [
          Scaffold(
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
            appBar: AppBar(
              title: Text("หน้าสร้างกิจกรรม"),
            ),
            body: SafeArea(
              child: ListView(
                children: [
                  Center(
                      child:
                          Column(mainAxisSize: MainAxisSize.max, children: [])),
                  buttonblack(),
                  appLogo(),
                  nameactivity(),
                  location(),
                  date(),
                  hashtag(),
                  message(),
                  picture(),
                  Creategroup()
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
