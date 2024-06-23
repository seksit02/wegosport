import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:wegosport/login.dart';

class homepage extends StatefulWidget {
  const homepage({super.key});

  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  String activityDate = '';

  @override
  void initState() {
    super.initState();
    fetchActivityDate();
  }

  Future<void> fetchActivityDate() async {
    final response = await http.get(Uri.parse('http://10.0.2.2/flutter_webservice/get_ShowDataActivity.php'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        activityDate = data['activity_date']; // ปรับตามโครงสร้าง JSON ที่ได้รับ
      });
    } else {
      throw Exception('Failed to load activity date');
    }
  }

  Widget showData1() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
      child: TextFormField(
        readOnly: true,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20, 15, 0, 0),
          hintText:
              activityDate.isNotEmpty ? activityDate : 'กำลังโหลดข้อมูล...',
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(0),
          ),
        ),
      ),
    );
  }

  Widget showData2() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
      child: TextFormField(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20, 15, 0, 0),
          hintText: 'แสดงผลข้อมูล ชื่อกิจกรรม',
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(0),
          ),
        ),
      ),
    );
  }

  Widget showData3() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
      child: TextFormField(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20, 15, 0, 0),
          hintText: 'แสดงผลข้อมูล สถานที่เล่นกีฬา',
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(0),
          ),
        ),
      ),
    );
  }

  Widget showData4() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
      child: TextFormField(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20, 15, 0, 0),
          hintText: 'แสดงผลข้อมูล รายละเอียดกิจกรรม',
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(0),
          ),
        ),
      ),
    );
  }

  Widget search() {
    return Container(
      margin: EdgeInsets.fromLTRB(40, 25, 25, 30),
      child: TextFormField(
        decoration: InputDecoration(
          contentPadding:
              EdgeInsets.fromLTRB(10, 5, 10, 5), // ปรับขนาดช่องให้เล็กลง
          hintText: 'ค้นหา',
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

  Widget logo() {
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Stack(
        children: [
          Scaffold(
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
            appBar: AppBar(
              title: Text("หน้าหลัก แสดงกิจกรรมต่างๆ"),
            ),
            body: SafeArea(
              child: ListView(
                children: [
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        logo(),
                        twoButtons(),
                        search(),
                        showData1(),
                        showData2(),
                        showData3(),
                        showData4(),
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
