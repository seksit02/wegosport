import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:wegosport/login.dart';

class homepage extends StatefulWidget {
  const homepage({super.key});

  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  TextEditingController inputone = TextEditingController();

  Widget inputOne() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
      child: TextFormField(
        controller: inputone,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
          hintText: '',
          fillColor: Colors.white,
          filled: true,
          prefixIcon: Icon(
            Icons.edit,
            color: Colors.red,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  Widget inputTwo() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
      child: TextFormField(
        controller: inputone,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
          hintText: '',
          fillColor: Colors.white,
          filled: true,
          prefixIcon: Icon(
            Icons.person,
            color: Colors.red,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  Widget inputthree() {
    return Container(
      margin: EdgeInsets.fromLTRB(40, 25, 25, 30),
      child: TextFormField(
        controller: inputone,
        decoration: InputDecoration(
          contentPadding:
              EdgeInsets.fromLTRB(10, 5, 10, 5), // ปรับขนาดช่องให้เล็กลง
          hintText: 'ค้นหา...',
          fillColor: Colors.white,
          filled: true,
          prefixIcon: Icon(
            Icons.search,
            color: Colors.red,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  Widget appLogo() {
    return Padding(
      padding: const EdgeInsets.only(top: 50, bottom: 20),
      child: Container(
        width: 50,
        height: 50,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            "images/login.png",
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget twoButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: ElevatedButton(
            onPressed: () {
              // โค้ดที่จะทำงานเมื่อปุ่ม 1 ถูกกด
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.white,
              side: BorderSide(width: 2, color: Colors.black),
            ),
            child: Text(
              'หน้าหลัก',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: ElevatedButton(
            onPressed: () {
              // โค้ดที่จะทำงานเมื่อปุ่ม 2 ถูกกด
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.white,
              side: BorderSide(width: 2, color: Colors.black),
            ),
            child: Text(
              'แชท',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget text1() {
    return Container(
      child: Text(
        "",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
          fontFamily: 'YourFontFamily',
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
              title: Text("หน้าลืมหลัก แสดงกิจกรรมต่างๆ"),
            ),
            body: SafeArea(
              child: ListView(
                children: [
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        appLogo(),
                        twoButtons(),
                        inputthree(),
                        text1(),
                        inputOne(),
                        inputTwo(),
                      ],
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
