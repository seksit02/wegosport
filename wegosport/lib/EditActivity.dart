import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'dart:convert';

class EditActivity extends StatefulWidget {
  const EditActivity({Key? key, required this.activityId, required this.jwt})
      : super(key: key);

  final String activityId;
  final String jwt;

  @override
  State<EditActivity> createState() => _EditActivityState();
}

class _EditActivityState extends State<EditActivity> {
  TextEditingController nameController = TextEditingController();
  TextEditingController detailsController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController hashtagController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController sportController = TextEditingController();

  List<String> _selectedTags = [];
  List<String> _allHashtags = [];
  String? selectedLocation;
  String? selectedSport;
  List<String> locations = [];
  List<String> sport = [];
  List<Map<String, dynamic>> locationData = [];
  List<String> availableDays = [];
  String? locationTime;

  @override
  void initState() {
    super.initState();
    fetchLocations();
    fetchHashtags();
    fetchActivityDetails();
  }

  // Map เพื่อจัดเก็บสถานะของวันที่เลือก
  Map<String, bool> selectedDays = {
    'จันทร์': false,
    'อังคาร': false,
    'พุธ': false,
    'พฤหัสบดี': false,
    'ศุกร์': false,
    'เสาร์': false,
    'อาทิตย์': false,
  };

  // ฟังก์ชันแปลงวันที่ที่เลือกเป็น String
  String getSelectedDays() {
    List<String> days = [];
    selectedDays.forEach((key, value) {
      if (value) {
        switch (key) {
          case 'จันทร์':
            days.add('1');
            break;
          case 'อังคาร':
            days.add('2');
            break;
          case 'พุธ':
            days.add('3');
            break;
          case 'พฤหัสบดี':
            days.add('4');
            break;
          case 'ศุกร์':
            days.add('5');
            break;
          case 'เสาร์':
            days.add('6');
            break;
          case 'อาทิตย์':
            days.add('7'); // เปลี่ยนจาก '0' เป็น '7'
            break;
        }
      }
    });
    return days.join(','); // แปลง List เป็น String โดยแยกด้วย ','
  }
  
  Future<void> fetchLocations() async {
    final response = await http.get(Uri.parse(
        'http://10.0.2.2/flutter_webservice/get_ShowDataLocation.php'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('ข้อมูลดิบจาก API get_ShowDataLocation : $data');

      setState(() {
        locationData = List<Map<String, dynamic>>.from(
            data.where((item) => item['status'] == 'approved'));
        locations = locationData
            .map((item) => item['location_name'].toString())
            .toList();
            print('รายชื่อสถานที่: $locations'); // พิมพ์รายการสถานที่ที่ดึงมาได้
      });
    } else {
      print('Failed to load locations.');
      throw Exception('Failed to load locations');
    }
  }

  // ฟังก์ชันกรองกีฬาเมื่อเลือกสถานที่
  void updateSportsForLocation(String locationName) {
    // ดึงข้อมูลสถานที่ที่เลือกจาก locationData
    final selectedLocation = locationData.firstWhere(
      (location) => location['location_name'] == locationName,
      orElse: () => {},
    );

    setState(() {
      // ถ้าสถานที่ถูกต้องและมี sport_types ให้ดึง sport_name ออกมา
      if (selectedLocation.isNotEmpty &&
          selectedLocation['sport_types'] != null) {
        sport = selectedLocation['sport_types']
            .expand((type) =>
                type['sports'] as List) // ดึงรายการกีฬาออกมาจากแต่ละประเภท
            .map<String>((sport) =>
                sport['sport_name'].toString()) // ทำให้แน่ใจว่าเป็น String
            .toList();

        // เก็บข้อมูล location_day และ location_time
        availableDays = selectedLocation['location_day'].split(',');
        locationTime = selectedLocation['location_time'];
      } else {
        sport = [];
        availableDays = [];
        locationTime = null;
      }
    });
  }

  Future<void> fetchHashtags() async {
    final response = await http.get(Uri.parse(
        'http://10.0.2.2/flutter_webservice/get_ShowDataHashtag.php'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _allHashtags = List<String>.from(data
            .map((item) => item['hashtag_message'])
            .where((item) => item != null)
            .toSet());
      });
    } else {
      print('Failed to load hashtags.');
      throw Exception('Failed to load hashtags');
    }
  }

  Future<void> fetchActivityDetails() async {
    final response = await http.get(Uri.parse(
        'http://10.0.2.2/flutter_webservice/get_ShowDataActivity.php?id=${widget.activityId}'));

    if (response.statusCode == 200) {
      final List<dynamic> activities = json.decode(response.body);
      final activity = activities.firstWhere(
          (activity) => activity['activity_id'] == widget.activityId);

      setState(() {
        nameController.text = activity['activity_name'];
        dateController.text = activity['activity_date'];
        detailsController.text = activity['activity_details'];
        _selectedTags.addAll((activity['hashtags'] as List<dynamic>?)
                ?.map((hashtag) => "${hashtag['hashtag_message']}")
                .toList() ??
            []);
        selectedLocation = activity['location_name'];
        selectedSport = activity['sport_name'];

        locationController.text = selectedLocation!;

        if (selectedSport != null) {
          sportController.text = selectedSport!;
        }

        updateSportsForLocation(selectedLocation!);

      });
    } else {
      print('Failed to load activity details');
    }
  }
  
  Future<void> updateActivity() async {
    String hashtags = _selectedTags.join(" ");
    List<String> hashtagList =
        hashtags.split(RegExp(r'\s+')).where((tag) => tag.isNotEmpty).toList();

    if (hashtagList.length > 3 || hashtagList.any((tag) => tag.length > 20)) {
      print("Invalid hashtag input");
      return;
    }

    Map<String, dynamic> dataPost = {
      "activity_id": widget.activityId,
      "activity_name": nameController.text,
      "activity_details": detailsController.text,
      "activity_date": dateController.text,
      "location_name": selectedLocation ?? '',
      "sport_name": sport.firstWhere((element) => element == selectedSport,
          orElse: () => '1' // ระบุค่าเริ่มต้นในกรณีที่ไม่มีองค์ประกอบตรงกัน
          ),
      "hashtags": hashtagList,
    };

    print("DataPost: $dataPost");

    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer ${widget.jwt}"
    };

    var url =
        Uri.parse("http://10.0.2.2/flutter_webservice/get_UpdateActivity.php");

    var response = await http.post(
      url,
      headers: headers,
      body: json.encode(dataPost),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      if (responseData["message"] == "Activity updated successfully") {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("สำเร็จ"),
              content: Text("แก้ไขกิจกรรมสำเร็จ"),
              actions: <Widget>[
                TextButton(
                  child: Text("ตกลง"),
                  onPressed: () {
                    Navigator.of(context).pop(); // ปิด AlertDialog
                    Navigator.of(context).pop(
                        true); // กลับไปยังหน้าหลักพร้อมแจ้งว่าให้รีเฟรชข้อมูล
                  },
                ),
              ],
            );
          },
        );
      } else {
        print("Update failed: ${responseData['message']}");
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("ล้มเหลว"),
              content: Text("การแก้ไขกิจกรรมล้มเหลว"),
              actions: [
                TextButton(
                  child: Text("ตกลง"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("ล้มเหลว"),
            content: Text("การแก้ไขกิจกรรมล้มเหลว"),
            actions: [
              TextButton(
                child: Text("ตกลง"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> deleteActivity() async {
    Map<String, dynamic> dataPost = {
      "activity_id": widget.activityId,
    };

    print("DataPost for Delete: $dataPost");

    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer ${widget.jwt}"
    };

    var url =
        Uri.parse("http://10.0.2.2/flutter_webservice/get_DeleteActivity.php");

    var response = await http.post(
      url,
      headers: headers,
      body: json.encode(dataPost),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      if (responseData["result"] == "success") {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("สำเร็จ"),
              content: Text("ลบกิจกรรมสำเร็จ"),
              actions: <Widget>[
                TextButton(
                  child: Text("ตกลง"),
                  onPressed: () {
                    Navigator.of(context).pop(); // ปิด AlertDialog
                    Navigator.of(context).pop(
                        true); // กลับไปยังหน้าหลักพร้อมแจ้งว่าให้รีเฟรชข้อมูล
                  },
                ),
              ],
            );
          },
        );
      } else {
        print("Delete failed: ${responseData['message']}");
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("ล้มเหลว"),
              content: Text("การลบกิจกรรมล้มเหลว"),
              actions: [
                TextButton(
                  child: Text("ตกลง"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("ล้มเหลว"),
            content: Text("การลบกิจกรรมล้มเหลว"),
            actions: [
              TextButton(
                child: Text("ตกลง"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('แก้ไขกิจกรรม'),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            nameActivity(),
            location(),
            sportDropdown(),
            dateField(),
            hashtagField(),
            detailsField(),
            saveButton(),
            deleteButton()
          ],
        ),
      ),
    );
  }

  Widget deleteButton() {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 20, 10, 0),
      child: SizedBox(
        width: 200,
        child: ElevatedButton(
          child: Text(
            "ลบกิจกรรม",
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: BorderSide(color: Colors.black),
            ),
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("ยืนยันการลบ"),
                  content: Text("คุณต้องการลบกิจกรรมนี้หรือไม่?"),
                  actions: <Widget>[
                    TextButton(
                      child: Text("ยกเลิก"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text("ยืนยัน"),
                      onPressed: () {
                        Navigator.of(context).pop(); // ปิด dialog
                        deleteActivity();
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget nameActivity() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
      child: TextFormField(
        controller: nameController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
          hintText: 'ชื่อกิจกรรม',
          fillColor: Colors.white,
          filled: true,
          prefixIcon: Icon(Icons.event, color: Colors.red),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  Widget location() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
      child: TypeAheadFormField(
        textFieldConfiguration: TextFieldConfiguration(
          controller: locationController,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
            hintText: 'สถานที่',
            fillColor: Colors.white,
            filled: true,
            prefixIcon: Icon(Icons.location_on, color: Colors.red),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        suggestionsCallback: (pattern) {
          return locations.where((location) =>
              location.toLowerCase().contains(pattern.toLowerCase()));
        },
        itemBuilder: (context, suggestion) {
          return ListTile(
            title: Text(suggestion),
          );
        },
        onSuggestionSelected: (suggestion) {
          setState(() {
            locationController.text = suggestion;
            selectedLocation = suggestion;
            updateSportsForLocation(suggestion);
          });
        },
        noItemsFoundBuilder: (context) {
          return Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'ไม่พบสถานที่',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 18.0),
            ),
          );
        },
      ),
    );
  }

  Widget sportDropdown() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
      child: TypeAheadFormField(
        textFieldConfiguration: TextFieldConfiguration(
          controller: sportController,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
            hintText: 'กีฬา',
            fillColor: Colors.white,
            filled: true,
            prefixIcon: Icon(Icons.sports_soccer, color: Colors.red),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        suggestionsCallback: (pattern) {
          return sport.where(
              (sport) => sport.toLowerCase().contains(pattern.toLowerCase()));
        },
        itemBuilder: (context, suggestion) {
          return ListTile(
            title: Text(suggestion),
          );
        },
        onSuggestionSelected: (suggestion) {
          setState(() {
            sportController.text = suggestion;
            selectedSport = suggestion;
          });
        },
        noItemsFoundBuilder: (context) {
          return Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'ไม่พบกีฬา',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 18.0),
            ),
          );
        },
      ),
    );
  }

  Widget dateField() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0), // กำหนด margin รอบฟิลด์
      child: TextFormField(
        controller: dateController,
        decoration: InputDecoration(
          contentPadding:
              EdgeInsets.fromLTRB(0, 15, 0, 0), // กำหนด padding ภายในฟิลด์
          hintText: 'เพิ่มวันที่และเวลา', // ข้อความแนะนำในฟิลด์
          fillColor: Color.fromARGB(255, 255, 255, 255), // สีพื้นหลังของฟิลด์
          filled: true,
          prefixIcon: Icon(
            Icons.calendar_today, // ไอคอนวันที่และเวลา
            color: Colors.red, // กำหนดสีของไอคอน
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black), // กำหนดสีของขอบฟิลด์
            borderRadius: BorderRadius.circular(30), // ปรับความโค้งของขอบฟิลด์
          ),
        ),
        readOnly: true, // ปิดการแก้ไขฟิลด์โดยตรง
        onTap: () async {
          DateTime now = DateTime.now();

          // กำหนดวันใน location_day ที่ให้เลือกได้เท่านั้น
          List<int> allowedDays =
              availableDays.map((day) => int.parse(day)).toList();

          // ให้เลือกได้เฉพาะวันที่เปิดตาม availableDays
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: now,
            firstDate: now,
            lastDate: DateTime(2101),
            selectableDayPredicate: (DateTime date) {
              return allowedDays
                  .contains(date.weekday); // กรองวันที่อนุญาตให้เลือก
            },
          );

          if (pickedDate != null) {
            // แสดงเวลาที่อนุญาตตาม location_time
            if (locationTime != null) {
              List<String> timeRange = locationTime!.split(' - ');
              int startHour = int.parse(timeRange[0].split(':')[0]);
              int startMinute = int.parse(timeRange[0].split(':')[1]);
              int endHour = int.parse(timeRange[1].split(':')[0]);
              int endMinute = int.parse(timeRange[1].split(':')[1]);

              TimeOfDay initialTime =
                  TimeOfDay(hour: startHour, minute: startMinute);

              TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: initialTime,
                builder: (context, child) {
                  return MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      alwaysUse24HourFormat: true, // ใช้รูปแบบเวลา 24 ชั่วโมง
                    ),
                    child: child!,
                  );
                },
              );

              if (pickedTime != null) {
                DateTime finalDateTime = DateTime(
                  pickedDate.year,
                  pickedDate.month,
                  pickedDate.day,
                  pickedTime.hour,
                  pickedTime.minute,
                );

                // ตรวจสอบว่าเวลาที่เลือกอยู่ในช่วงเวลาที่กำหนด
                if (pickedTime.hour >= startHour &&
                    pickedTime.minute >= startMinute &&
                    (pickedTime.hour < endHour ||
                        (pickedTime.hour == endHour &&
                            pickedTime.minute <= endMinute))) {
                  setState(() {
                    dateController.text = finalDateTime
                        .toString(); // แสดงวันที่และเวลาที่เลือกในฟิลด์
                  });
                } else {
                  // แสดงการแจ้งเตือนถ้าเวลาที่เลือกไม่อยู่ในช่วงที่กำหนด
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('ข้อผิดพลาด'),
                        content: Text('กรุณาเลือกเวลาที่อยู่ในช่วงที่กำหนด'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('ตกลง'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              }
            }
          }
        },
      ),
    );
  }

  Widget hashtagField() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8.0,
            children: _selectedTags
                .map((tag) => Chip(
                      label: Text(tag),
                      onDeleted: () {
                        setState(() {
                          _selectedTags.remove(tag);
                        });
                      },
                    ))
                .toList(),
          ),
          TypeAheadFormField<String>(
            textFieldConfiguration: TextFieldConfiguration(
              controller: hashtagController,
              decoration: InputDecoration(
                hintText: 'แฮชแท็ก',
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: TextButton(
                    onPressed: () {
                      String newTag = hashtagController.text.trim();
                      if (newTag.isNotEmpty &&
                          newTag.length <= 20 &&
                          _selectedTags.length < 3 &&
                          !_selectedTags.contains('#$newTag')) {
                        setState(() {
                          _selectedTags.add('#$newTag');
                          hashtagController.clear();
                        });
                      }
                    },
                    child: Text('เพิ่ม'),
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            suggestionsCallback: (pattern) {
              return _allHashtags.where((hashtag) =>
                  hashtag.toLowerCase().contains(pattern.toLowerCase()));
            },
            itemBuilder: (context, suggestion) {
              return ListTile(
                title: Text(suggestion),
              );
            },
            onSuggestionSelected: (suggestion) {
              if (_selectedTags.length < 3 &&
                  !_selectedTags.contains(suggestion)) {
                setState(() {
                  _selectedTags.add(suggestion);
                  hashtagController.clear();
                });
              }
            },
            noItemsFoundBuilder: (context) {
              return Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'ไม่พบแฮชแท็ก',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 18.0),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget detailsField() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
      child: TextFormField(
        controller: detailsController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
          hintText: 'รายละเอียดกิจกรรม',
          fillColor: Colors.white,
          filled: true,
          prefixIcon: Icon(Icons.description, color: Colors.red),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  Widget saveButton() {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 20, 10, 0),
      child: SizedBox(
        width: 200,
        child: ElevatedButton(
          child: Text(
            "บันทึกการเปลี่ยนแปลง",
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: BorderSide(color: Colors.black),
            ),
          ),
          onPressed: updateActivity,
        ),
      ),
    );
  }

}
