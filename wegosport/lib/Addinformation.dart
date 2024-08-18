import 'package:flutter/services.dart'; // นำเข้าไลบรารีสำหรับจัดการระบบบริการ เช่น การจัดการรูปแบบการป้อนข้อมูล
import 'package:flutter/material.dart'; // นำเข้าไลบรารีสำหรับสร้าง UI ใน Flutter
import 'package:http/http.dart'
    as http; // นำเข้าไลบรารีสำหรับการทำ HTTP requests
import 'dart:async'; // นำเข้าไลบรารีสำหรับการทำงานแบบอะซิงโครนัส
import 'dart:convert'; // นำเข้าไลบรารีสำหรับการแปลงข้อมูล JSON
import 'package:wegosport/Login.dart'; // นำเข้าหน้า Login

// หน้าแก้ไขข้อมูลผู้ใช้
class editinformation extends StatefulWidget {
  const editinformation(
      {Key? key,
      required this.name,
      required this.email,
      required this.six_value})
      : super(key: key);

  @override
  State<editinformation> createState() =>
      _editinformationState(); // สร้าง State สำหรับหน้าแก้ไขข้อมูลผู้ใช้

  final String name; // กำหนดตัวแปรสำหรับเก็บชื่อผู้ใช้
  final String email; // กำหนดตัวแปรสำหรับเก็บอีเมลผู้ใช้
  final String six_value; // กำหนดตัวแปรสำหรับเก็บค่าเพิ่มเติมที่ผู้ใช้ส่งเข้ามา
}

class _editinformationState extends State<editinformation> {
  TextEditingController one_value =
      TextEditingController(); // ตัวควบคุมสำหรับชื่อผู้ใช้
  TextEditingController two_value =
      TextEditingController(); // ตัวควบคุมสำหรับอีเมล
  TextEditingController three_value =
      TextEditingController(); // ตัวควบคุมสำหรับรหัสผ่าน
  TextEditingController four_value =
      TextEditingController(); // ตัวควบคุมสำหรับชื่อ-สกุล
  TextEditingController five_value =
      TextEditingController(); // ตัวควบคุมสำหรับอายุ
  String? six_value; // ตัวแปรสำหรับเก็บค่าเพิ่มเติมที่ส่งเข้ามา

  @override
  void initState() {
    super.initState();
    setState(() {
      one_value.text = widget.name; // กำหนดค่าเริ่มต้นของชื่อผู้ใช้
      two_value.text = widget.email; // กำหนดค่าเริ่มต้นของอีเมลผู้ใช้
      six_value = widget.six_value; // กำหนดค่าเริ่มต้นของค่าพิเศษที่ผู้ใช้ส่งมา
    });
  }

  // วิดเจ็ตแสดงโลโก้
  Widget appLogo() {
    return Container(
      width: 100, // กำหนดความกว้างของโลโก้
      height: 100, // กำหนดความสูงของโลโก้
      margin: EdgeInsets.fromLTRB(0, 50, 0, 0), // กำหนดระยะขอบด้านบน
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50), // กำหนดความโค้งของขอบโลโก้
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10), // กำหนดความโค้งของขอบภาพโลโก้
        child: Image.asset(
          "images/logo.png", // แสดงโลโก้จาก assets
          fit: BoxFit.cover, // ปรับขนาดรูปภาพให้พอดีกับ Container
        ),
      ),
    );
  }

  // วิดเจ็ตฟิลด์ชื่อผู้ใช้งาน
  Widget inputOne() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0), // กำหนดระยะขอบของฟิลด์
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // จัดแนวเนื้อหาไปทางด้านซ้าย
        children: [
          TextFormField(
            controller: one_value, // กำหนดตัวควบคุมสำหรับฟิลด์นี้
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(
                  0, 15, 0, 0), // กำหนด padding ของเนื้อหาภายในฟิลด์
              hintText: 'ชื่อผู้ใช้งาน "มากกว่า 6 ตัว"', // ข้อความแนะนำในฟิลด์
              fillColor: Colors.white, // กำหนดสีพื้นหลังของฟิลด์
              filled: true, // กำหนดให้ฟิลด์มีสีพื้นหลัง
              prefixIcon: Icon(
                Icons.create, // กำหนดไอคอนด้านหน้า
                color: Colors.red, // กำหนดสีของไอคอน
              ),
              border: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Colors.black), // กำหนดสีของขอบฟิลด์
                borderRadius:
                    BorderRadius.circular(30), // กำหนดความโค้งของขอบฟิลด์
              ),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'กรุณากรอกชื่อผู้ใช้งาน'; // ตรวจสอบว่าช่องว่างหรือไม่
              }
              if (value.length <= 6) {
                return 'ชื่อผู้ใช้งานควรมีมากกว่า 6 ตัวอักษร'; // ตรวจสอบความยาวของชื่อผู้ใช้งาน
              }
              if (!value.contains(RegExp(r'[a-zA-Z]'))) {
                return 'ชื่อผู้ใช้งานควรมีตัวอักษรประกอบด้วยอย่างน้อย 1 ตัว'; // ตรวจสอบว่าชื่อมีตัวอักษรหรือไม่
              }
              return null; // ถ้าถูกต้องไม่คืนค่าอะไรเลย
            },
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(
                RegExp(
                    r'[a-zA-Z0-9]'), // อนุญาตให้กรอกได้เฉพาะตัวเลขและตัวอักษรภาษาอังกฤษพิมพ์เล็ก-ใหญ่
              ),
            ],
          ),
          SizedBox(height: 5), // ระยะห่างระหว่างฟิลด์และข้อความตัวอย่าง
          Padding(
            padding: EdgeInsets.only(left: 16.0), // เพิ่มระยะทางซ้ายของข้อความ
            child: Text(
              'ตัวอย่าง: user1234', // ข้อความตัวอย่าง
              style: TextStyle(color: Colors.grey), // กำหนดสีข้อความเป็นสีเทา
            ),
          ),
        ],
      ),
    );
  }

  // วิดเจ็ตฟิลด์อีเมล
  Widget inputTwo() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0), // กำหนดระยะขอบของฟิลด์
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // จัดแนวเนื้อหาไปทางด้านซ้าย
        children: [
          TextFormField(
            controller: two_value, // กำหนดตัวควบคุมสำหรับฟิลด์นี้
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(
                  0, 15, 0, 0), // กำหนด padding ของเนื้อหาภายในฟิลด์
              hintText:
                  'อีเมล "ใช้อีเมลที่ติดต่อได้เท่านั้น"', // ข้อความแนะนำในฟิลด์
              fillColor: Colors.white, // กำหนดสีพื้นหลังของฟิลด์
              filled: true, // กำหนดให้ฟิลด์มีสีพื้นหลัง
              prefixIcon: Icon(
                Icons.edit, // กำหนดไอคอนด้านหน้า
                color: Colors.red, // กำหนดสีของไอคอน
              ),
              border: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Colors.black), // กำหนดสีของขอบฟิลด์
                borderRadius:
                    BorderRadius.circular(30), // กำหนดความโค้งของขอบฟิลด์
              ),
            ),
          ),
          SizedBox(height: 5), // ระยะห่างระหว่างฟิลด์และข้อความตัวอย่าง
          Padding(
            padding: EdgeInsets.only(left: 20.0), // เพิ่มระยะทางซ้ายของข้อความ
            child: Text(
              'ตัวอย่าง: example@example.com', // ข้อความตัวอย่าง
              style: TextStyle(color: Colors.grey), // กำหนดสีข้อความเป็นสีเทา
            ),
          ),
        ],
      ),
    );
  }

  // วิดเจ็ตฟิลด์รหัสผ่าน
  Widget inputthree() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0), // กำหนดระยะขอบของฟิลด์
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // จัดแนวเนื้อหาไปทางด้านซ้าย
        children: [
          TextFormField(
            controller: three_value, // กำหนดตัวควบคุมสำหรับฟิลด์นี้
            keyboardType:
                TextInputType.text, // กำหนดประเภทของแป้นพิมพ์ให้เป็นข้อความ
            obscureText: true, // ทำเป็นรหัสผ่านที่ถูกซ่อนไว้
            validator: (value) {
              if (value!.isEmpty) {
                return 'กรุณากรอกรหัสผ่าน'; // ตรวจสอบว่าช่องว่างหรือไม่
              }
              if (value.length <= 6) {
                return 'รหัสผ่านควรมีอย่างน้อย 6 ตัว'; // ตรวจสอบความยาวของรหัสผ่าน
              }
              bool hasDigits = value
                  .contains(RegExp(r'\d')); // ตรวจสอบว่ารหัสผ่านมีตัวเลขหรือไม่
              bool hasLetters = value.contains(
                  RegExp(r'[a-zA-Z]')); // ตรวจสอบว่ารหัสผ่านมีตัวอักษรหรือไม่
              if (!hasDigits || !hasLetters) {
                return 'รหัสผ่านควรประกอบด้วยตัวเลขและตัวอักษร'; // ตรวจสอบว่ารหัสผ่านมีทั้งตัวเลขและตัวอักษรหรือไม่
              }
              return null; // ถ้าถูกต้องไม่คืนค่าอะไรเลย
            },
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(
                  0, 15, 0, 0), // กำหนด padding ของเนื้อหาภายในฟิลด์
              hintText: 'รหัสผ่าน "มากกว่า 6 ตัว"', // ข้อความแนะนำในฟิลด์
              fillColor: Colors.white, // กำหนดสีพื้นหลังของฟิลด์
              filled: true, // กำหนดให้ฟิลด์มีสีพื้นหลัง
              prefixIcon: Icon(
                Icons.edit, // กำหนดไอคอนด้านหน้า
                color: Colors.red, // กำหนดสีของไอคอน
              ),
              border: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Colors.black), // กำหนดสีของขอบฟิลด์
                borderRadius:
                    BorderRadius.circular(30), // กำหนดความโค้งของขอบฟิลด์
              ),
            ),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(
                RegExp(
                    r'[a-zA-Z0-9._]'), // อนุญาตให้กรอกได้เฉพาะตัวเลขและตัวอักษร
              ),
            ],
          ),
          SizedBox(height: 5), // ระยะห่างระหว่างฟิลด์และข้อความตัวอย่าง
          Padding(
            padding: EdgeInsets.only(left: 20.0), // เพิ่มระยะทางซ้ายของข้อความ
            child: Text(
              'ตัวอย่าง: Pass1234', // ข้อความตัวอย่าง
              style: TextStyle(color: Colors.grey), // กำหนดสีข้อความเป็นสีเทา
            ),
          ),
        ],
      ),
    );
  }

  // วิดเจ็ตฟิลด์ชื่อ-สกุล
  Widget inputfour() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0), // กำหนดระยะขอบของฟิลด์
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // จัดแนวเนื้อหาไปทางด้านซ้าย
        children: [
          TextFormField(
            controller: four_value, // กำหนดตัวควบคุมสำหรับฟิลด์นี้
            keyboardType:
                TextInputType.text, // กำหนดประเภทของแป้นพิมพ์ให้เป็นข้อความ
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(
                RegExp(
                    r'[a-zA-Zก-๏เ-๙]'), // อนุญาตให้กรอกเฉพาะตัวอักษรภาษาไทยและอักษรภาษาอังกฤษ
              ),
            ],
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(
                  0, 15, 0, 0), // กำหนด padding ของเนื้อหาภายในฟิลด์
              hintText: 'ชื่อ-สกุล', // ข้อความแนะนำในฟิลด์
              fillColor: Colors.white, // กำหนดสีพื้นหลังของฟิลด์
              filled: true, // กำหนดให้ฟิลด์มีสีพื้นหลัง
              prefixIcon: Icon(
                Icons.edit, // กำหนดไอคอนด้านหน้า
                color: Colors.red, // กำหนดสีของไอคอน
              ),
              border: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Colors.black), // กำหนดสีของขอบฟิลด์
                borderRadius:
                    BorderRadius.circular(30), // กำหนดความโค้งของขอบฟิลด์
              ),
            ),
          ),
          SizedBox(height: 5), // ระยะห่างระหว่างฟิลด์และข้อความตัวอย่าง
          Padding(
            padding: EdgeInsets.only(left: 20.0), // เพิ่มระยะทางซ้ายของข้อความ
            child: Text(
              'ตัวอย่าง: John Doe หรือ สมชาย ใจดี', // ข้อความตัวอย่าง
              style: TextStyle(color: Colors.grey), // กำหนดสีข้อความเป็นสีเทา
            ),
          ),
        ],
      ),
    );
  }

  // วิดเจ็ตฟิลด์วัน/เดือน/ปีเกิด
  Widget inputfive() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0), // กำหนดระยะขอบของฟิลด์
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // จัดแนวเนื้อหาไปทางด้านซ้าย
        children: [
          TextFormField(
            controller: five_value, // กำหนดตัวควบคุมสำหรับฟิลด์นี้
            keyboardType: TextInputType
                .datetime, // กำหนดประเภทของแป้นพิมพ์ให้เป็นวัน/เดือน/ปีเกิด
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(
                RegExp(r'[0-9/]'), // อนุญาตให้กรอกเฉพาะตัวเลขและเครื่องหมาย '/'
              ),
              LengthLimitingTextInputFormatter(
                  10), // จำกัดความยาวสูงสุดของการป้อนข้อมูลเป็น 10 ตัวอักษร
              DateInputFormatter(), // ใช้ตัวจัดรูปแบบวันที่ที่กำหนดเอง
            ],
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(
                  0, 15, 0, 0), // กำหนด padding ของเนื้อหาภายในฟิลด์
              hintText: 'วัน/เดือน/ปีเกิด', // ข้อความแนะนำในฟิลด์
              fillColor: Colors.white, // กำหนดสีพื้นหลังของฟิลด์
              filled: true, // กำหนดให้ฟิลด์มีสีพื้นหลัง
              prefixIcon: Icon(
                Icons.calendar_today, // กำหนดไอคอนด้านหน้า
                color: Colors.red, // กำหนดสีของไอคอน
              ),
              border: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Colors.black), // กำหนดสีของขอบฟิลด์
                borderRadius:
                    BorderRadius.circular(30), // กำหนดความโค้งของขอบฟิลด์
              ),
            ),
          ),
          SizedBox(height: 5), // ระยะห่างระหว่างฟิลด์และข้อความตัวอย่าง
          Padding(
            padding: EdgeInsets.only(left: 20.0), // เพิ่มระยะทางซ้ายของข้อความ
            child: Text(
              'ตัวอย่าง: 01/01/1990', // ข้อความตัวอย่าง
              style: TextStyle(color: Colors.grey), // กำหนดสีข้อความเป็นสีเทา
            ),
          ),
        ],
      ),
    );
  }

  // ฟังก์ชันตรวจสอบข้อมูล
  bool _validateInputs() {
    // ตรวจสอบรูปแบบวันที่
    RegExp dateRegEx = RegExp(
      r'^(\d{2})/(\d{2})/(\d{4})$', // รูปแบบวันที่ในรูปแบบวัน/เดือน/ปี
    );

    return one_value.text.isNotEmpty && // ตรวจสอบว่าฟิลด์ชื่อผู้ใช้ไม่ว่าง
        one_value.text.length >=
            6 && // ตรวจสอบว่าชื่อผู้ใช้มีอย่างน้อย 6 ตัวอักษร
        one_value.text.contains(
            RegExp(r'[a-zA-Z]')) && // ตรวจสอบว่าชื่อผู้ใช้มีตัวอักษรหรือไม่
        two_value.text.isNotEmpty && // ตรวจสอบว่าฟิลด์อีเมลไม่ว่าง
        two_value.text.contains('@') && // ตรวจสอบว่าอีเมลมี '@' หรือไม่
        three_value.text.isNotEmpty && // ตรวจสอบว่าฟิลด์รหัสผ่านไม่ว่าง
        three_value.text.length >=
            6 && // ตรวจสอบว่ารหัสผ่านมีอย่างน้อย 6 ตัวอักษร
        three_value.text
            .contains(RegExp(r'\d')) && // ตรวจสอบว่ารหัสผ่านมีตัวเลขหรือไม่
        three_value.text.contains(
            RegExp(r'[a-zA-Z]')) && // ตรวจสอบว่ารหัสผ่านมีตัวอักษรหรือไม่
        four_value.text.isNotEmpty && // ตรวจสอบว่าฟิลด์ชื่อ-สกุลไม่ว่าง
        five_value.text.isNotEmpty && // ตรวจสอบว่าฟิลด์วัน/เดือน/ปีเกิดไม่ว่าง
        dateRegEx.hasMatch(
            five_value.text); // ตรวจสอบว่าข้อความตรงกับรูปแบบวันที่ที่ถูกต้อง
  }

  // วิดเจ็ตปุ่มยืนยันข้อมูล
  Widget buttonProcesslogin(BuildContext context) {
    return ButtonTheme(
      minWidth: double.infinity, // กำหนดความกว้างขั้นต่ำของปุ่มให้เต็มหน้าจอ
      child: Container(
        margin: EdgeInsets.fromLTRB(50, 20, 50, 0), // กำหนดระยะขอบของปุ่ม
        child: ElevatedButton(
          child: Text(
            "ยืนยัน", // ข้อความของปุ่ม
            style: TextStyle(
              color: Colors.white, // กำหนดสีของข้อความในปุ่ม
            ),
          ),
          style: ElevatedButton.styleFrom(
            padding:
                EdgeInsets.fromLTRB(20, 10, 20, 10), // กำหนด padding ของปุ่ม
            backgroundColor:
                Color.fromARGB(249, 255, 4, 4), // กำหนดสีพื้นหลังของปุ่ม
            shadowColor:
                Color.fromARGB(255, 255, 255, 255), // กำหนดสีของเงาปุ่ม
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(30), // กำหนดความโค้งของขอบปุ่ม
              side: BorderSide(
                  color: const Color.fromARGB(
                      255, 255, 0, 0)), // กำหนดสีของเส้นขอบปุ่ม
            ),
          ),
          onPressed: () {
            if (_validateInputs()) {
              functionregister(
                  context); // ถ้าข้อมูลถูกต้อง เรียกใช้ฟังก์ชัน functionregister
            } else {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title:
                        Text("กรุณากรอกข้อมูลให้ครบถ้วน"), // หัวข้อของ dialog
                    actions: <Widget>[
                      TextButton(
                        child: Text("ตกลง"), // ข้อความของปุ่มตกลงใน dialog
                        onPressed: () {
                          Navigator.of(context)
                              .pop(); // ปิด dialog เมื่อกดปุ่มตกลง
                        },
                      ),
                    ],
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  // แปลงรูปแบบวันที่ให้เป็น YYYY-MM-DD ก่อนส่งไปยัง PHP
  String formatDate(String date) {
    List<String> parts = date.split('/'); // แยกวันที่ตาม '/'
    if (parts.length == 3) {
      return '${parts[2]}-${parts[1]}-${parts[0]}'; // คืนค่าวันที่ในรูปแบบ YYYY-MM-DD
    }
    return date; // คืนค่ากลับถ้ารูปแบบไม่ถูกต้อง
  }

  // ฟังก์ชันสมัครสมาชิก
  Future<void> functionregister(BuildContext context) async {
    print("user_id: ${one_value.text}"); // แสดง user_id ที่กรอก
    print("user_email: ${two_value.text}"); // แสดง user_email ที่กรอก
    print("user_pass: ${three_value.text}"); // แสดง user_pass ที่กรอก
    print("user_name: ${four_value.text}"); // แสดง user_name ที่กรอก
    print("user_age: ${five_value.text}"); // แสดง user_age ที่กรอก
    print("user_token: ${six_value}"); // แสดง user_token ที่ได้รับ

    // แปลงรูปแบบวันที่ให้เป็น YYYY-MM-DD ก่อนส่งไปยัง PHP
    String formattedDob = formatDate(five_value.text);

    // เตรียมข้อมูลที่จะส่ง
    Map<String, String> dataPost = {
      "user_id": one_value.text,
      "user_email": two_value.text,
      "user_pass": three_value.text,
      "user_name": four_value.text,
      "user_age": formattedDob, // ใช้วันที่ที่แปลงแล้ว
      "user_token": six_value.toString()
    };

    // เตรียมหัวเรื่อง
    Map<String, String> headers = {
      "Content-Type": "application/json", // กำหนด Content-Type ของ HTTP request
      "Accept": "application/json" // ยอมรับการตอบกลับในรูปแบบ JSON
    };

    var url = Uri.parse(
        "http://10.0.2.2/flutter_webservice/get_Register.php"); // กำหนด URL สำหรับคำขอ

    try {
      var response = await http.post(
        url,
        headers: headers, // ส่ง header
        body: json.encode(dataPost), // ส่งข้อมูลในรูปแบบ JSON
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse =
            json.decode(response.body); // แปลงข้อมูลการตอบกลับจาก JSON
        print(jsonResponse); // แสดงข้อมูลการตอบกลับ

        // เช็คผลลัพธ์ที่ได้จากเซิร์ฟเวอร์
        if (jsonResponse['result'] == 1) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("กรอกข้อมูลสำเร็จ"), // หัวข้อของ dialog
                actions: <Widget>[
                  TextButton(
                    child: Text("ตกลง"), // ข้อความของปุ่มตกลงใน dialog
                    onPressed: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) =>
                              LoginPage())); // เปลี่ยนหน้าไปยังหน้า Login
                    },
                  ),
                ],
              );
            },
          );
        } else {
          // ตรวจสอบข้อความข้อผิดพลาด
          if (jsonResponse['message'] == "ชื่อผู้ใช้หรืออีเมลนี้มีผู้ใช้แล้ว") {
            _showDialog(context, 'ผิดพลาด',
                'ชื่อผู้ใช้หรืออีเมลนี้มีผู้ใช้แล้ว กรุณากรอกข้อมูลใหม่'); // แสดงข้อความข้อผิดพลาด
          } else {
            _showDialog(
                context,
                'ผิดพลาด',
                jsonResponse['message'] ??
                    'การเพิ่มข้อมูลล้มเหลว'); // แสดงข้อความข้อผิดพลาดทั่วไป
          }
        }
      } else {
        print(
            "Request failed with status: ${response.statusCode}"); // แสดงสถานะการตอบกลับเมื่อคำขอล้มเหลว
        _showDialog(context, 'ผิดพลาด',
            'เกิดข้อผิดพลาดในการเชื่อมต่อกับเซิร์ฟเวอร์'); // แสดงข้อความข้อผิดพลาดในการเชื่อมต่อ
      }
    } catch (error) {
      print(
          "Error: $error"); // แสดงข้อความเมื่อเกิดข้อผิดพลาดในกระบวนการส่งคำขอ
      _showDialog(context, 'ผิดพลาด',
          'เกิดข้อผิดพลาด: $error'); // แสดงข้อความข้อผิดพลาด
    }
  }

  // ฟังก์ชันแสดงข้อความแจ้งเตือน
  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title), // หัวข้อของ dialog
          content: Text(message), // เนื้อหาของ dialog
          actions: <Widget>[
            TextButton(
              child: Text("ปิด"), // ข้อความของปุ่มปิดใน dialog
              onPressed: () {
                Navigator.of(context).pop(); // ปิด dialog เมื่อกดปุ่ม
              },
            ),
          ],
        );
      },
    );
  }

  // วิดเจ็ตข้อความหัวข้อ
  Widget text1() {
    return Container(
      child: Text(
        "สมัครสมาชิก", // ข้อความหัวข้อ
        style: TextStyle(
          fontSize: 24, // ขนาดตัวอักษร
          fontWeight: FontWeight.bold, // ความหนาของตัวอักษร
          fontStyle: FontStyle.italic, // รูปแบบตัวอักษรเป็นตัวเอียง
          fontFamily: 'YourFontFamily', // กำหนดฟอนต์
        ),
      ),
    );
  }

  // วิดเจ็ตปุ่มย้อนกลับ
  Widget backButton() {
    return IconButton(
      icon: Icon(Icons.arrow_back, // ไอคอนลูกศรกลับ
          color: const Color.fromARGB(255, 255, 255, 255)), // กำหนดสีของไอคอน
      onPressed: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => LoginPage())); // กลับไปยังหน้า Login
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Stack(
        children: [
          Scaffold(
            backgroundColor:
                Color.fromARGB(255, 255, 255, 255), // กำหนดสีพื้นหลังของหน้า
            appBar: AppBar(
              backgroundColor:
                  Color.fromARGB(255, 255, 0, 0), // กำหนดสีพื้นหลังของ AppBar
              title: Text("หน้าเพิ่มข้อมูลผู้ใช้",
                  style: TextStyle(color: Colors.white)), // หัวข้อของ AppBar
              leading: backButton(), // ปุ่มย้อนกลับ
            ),
            body: SafeArea(
              child: ListView(
                children: [
                  Center(
                      child: Column(mainAxisSize: MainAxisSize.max, children: [
                    appLogo(), // แสดงโลโก้ของแอป
                    text1(), // ข้อความหัวข้อ
                    inputOne(), // วิดเจ็ตฟิลด์ชื่อผู้ใช้งาน
                    inputTwo(), // วิดเจ็ตฟิลด์อีเมล
                    inputthree(), // วิดเจ็ตฟิลด์รหัสผ่าน
                    inputfour(), // วิดเจ็ตฟิลด์ชื่อ-สกุล
                    inputfive(), // วิดเจ็ตฟิลด์วัน/เดือน/ปีเกิด
                    buttonProcesslogin(context), // ปุ่มยืนยันข้อมูล
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

// Custom Input Formatter สำหรับรูปแบบวัน/เดือน/ปีเกิด
class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Handle backspace
    if (newValue.text.length < oldValue.text.length) {
      return newValue; // คืนค่าใหม่เมื่อกด backspace
    }

    var newText = newValue.text; // ข้อความใหม่ที่ผู้ใช้ป้อน
    if (newText.length == 2 || newText.length == 5) {
      newText += '/'; // เพิ่ม '/' เมื่อข้อความมีความยาวถึง 2 หรือ 5 ตัวอักษร
    } else if (newText.length > 10) {
      newText =
          newText.substring(0, 10); // จำกัดความยาวของข้อความไม่เกิน 10 ตัวอักษร
    }

    return newValue.copyWith(
      text: newText, // คืนค่าข้อความที่ปรับปรุงแล้ว
      selection: TextSelection.collapsed(
          offset: newText.length), // ตั้งตำแหน่งเคอร์เซอร์
    );
  }
}
