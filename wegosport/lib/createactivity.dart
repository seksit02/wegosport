import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';

import 'dart:async';
import 'dart:convert';
import 'package:wegosport/Homepage.dart';

class CreateActivityPage extends StatefulWidget {
  const CreateActivityPage({super.key});

  @override
  State<CreateActivityPage> createState() => _CreateActivityPageState();
}

class _CreateActivityPageState extends State<CreateActivityPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController detailsController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController hashtagController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController sportController = TextEditingController();

  final List<String> _selectedTags = [];
  List<String> _allHashtags = [];

  void _showTagPicker(BuildContext context) {
    showMaterialCheckboxPicker(
      context: context,
      title: 'เลือกแฮชแท็ก',
      items: ['กีฬา', 'ฟิตเนส', 'สุขภาพ', 'วิ่ง', 'ว่ายน้ำ'],
      selectedItems: _selectedTags,
      onChanged: (List<String> value) {
        setState(() {
          _selectedTags.clear();
          _selectedTags.addAll(value);
        });
      },
    );
  }

  String? selectedLocation;
  String? selectedSport;
  List<String> locations = [];
  List<String> sport = [];

  get selectedSportId => 1;

  Future<void> fetchLocations() async {
    final response = await http.get(Uri.parse(
        'http://10.0.2.2/flutter_webservice/get_ShowDataLocation.php'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        locations = List<String>.from(
            data.map((item) => item['location_name']).toSet());
      });
    } else {
      print('Failed to load locations. Status code: ${response.statusCode}');
      throw Exception('Failed to load locations');
    }
  }

  Future<void> fetchSport() async {
    final response = await http.get(
        Uri.parse('http://10.0.2.2/flutter_webservice/get_ShowDataSport.php'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        sport =
            List<String>.from(data.map((item) => item['sport_name']).toSet());
      });
    } else {
      print('Failed to load sport names. Status code: ${response.statusCode}');
      throw Exception('Failed to load sport names');
    }
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
      print('Failed to load hashtags. Status code: ${response.statusCode}');
      throw Exception('Failed to load hashtags');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchLocations();
    fetchSport();
    fetchHashtags();
  }


  Widget nameActivity() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
      child: TextFormField(
        controller: nameController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
          hintText: 'เพิ่มชื่อกิจกรรม',
          fillColor: Color.fromARGB(255, 255, 255, 255),
          filled: true,
          prefixIcon: Padding(
            padding: const EdgeInsets.all(15.0), // เพิ่ม padding ให้ตัวอักษร
            child: Text(
              'A',
              style: TextStyle(
                color: Colors.red,
                fontSize: 18.0, // ขนาดตัวอักษร
                fontWeight: FontWeight.bold, // ทำให้ตัวอักษรหนา
              ),
            ),
          ),
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
            hintText: 'เพิ่มสถานที่',
            hintStyle: TextStyle(fontFamily: 'THSarabunNew'),
            fillColor: Color.fromARGB(255, 255, 255, 255),
            filled: true,
            prefixIcon: Icon(
              Icons.location_on,
              color: Colors.red,
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          style: TextStyle(fontFamily: 'THSarabunNew'),
        ),
        suggestionsCallback: (pattern) {
          return locations.where((location) =>
              location.toLowerCase().contains(pattern.toLowerCase()));
        },
        itemBuilder: (context, suggestion) {
          return ListTile(
            title:
                Text(suggestion, style: TextStyle(fontFamily: 'THSarabunNew')),
          );
        },
        onSuggestionSelected: (suggestion) {
          setState(() {
            locationController.text = suggestion;
            selectedLocation = suggestion;
          });
        },
        noItemsFoundBuilder: (context) {
          return Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'ไม่พบสถานที่',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 18.0,
                fontFamily: 'THSarabunNew',
              ),
            ),
          );
        },
      ),
    );
  }

  Widget field_name() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
      child: TypeAheadFormField(
        textFieldConfiguration: TextFieldConfiguration(
          controller: sportController,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
            hintText: 'เพิ่มกีฬา',
            hintStyle: TextStyle(fontFamily: 'THSarabunNew'),
            fillColor: Color.fromARGB(255, 255, 255, 255),
            filled: true,
            prefixIcon: Icon(
              Icons.sports_soccer,
              color: Colors.red,
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          style: TextStyle(fontFamily: 'THSarabunNew'),
        ),
        suggestionsCallback: (pattern) {
          return sport.where(
              (sport) => sport.toLowerCase().contains(pattern.toLowerCase()));
        },
        itemBuilder: (context, suggestion) {
          return ListTile(
            title:
                Text(suggestion, style: TextStyle(fontFamily: 'THSarabunNew')),
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
              style: TextStyle(
                color: Colors.grey,
                fontSize: 18.0,
                fontFamily: 'THSarabunNew',
              ),
            ),
          );
        },
      ),
    );
  }


  Widget date() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
      child: TextFormField(
        controller: dateController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
          hintText: 'เพิ่มวันที่และเวลา',
          fillColor: Color.fromARGB(255, 255, 255, 255),
          filled: true,
          prefixIcon: Icon(
            Icons.calendar_today,
            color: Colors.red,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        readOnly: true,
        onTap: () async {
          DateTime now = DateTime.now();
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: now,
            firstDate: now,
            lastDate: DateTime(2101),
          );

          if (pickedDate != null) {
            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    alwaysUse24HourFormat: true,
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

              if (finalDateTime.isAfter(now)) {
                setState(() {
                  dateController.text = finalDateTime.toString();
                });
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('ข้อผิดพลาด'),
                      content: Text('ไม่สามารถเลือกเวลาที่ผ่านมาแล้วได้'),
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
        },
      ),
    );
  }





  Widget hashtag() {
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
                hintText: 'เพิ่มแฮชแท็กที่ต้องการ',
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: TextButton(
                    onPressed: () {
                      if (hashtagController.text.isNotEmpty &&
                          hashtagController.text.length <= 20 &&
                          _selectedTags.length < 3 &&
                          !_selectedTags.contains(hashtagController.text)) {
                        setState(() {
                          _selectedTags.add(hashtagController.text);
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
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18.0,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }


  Widget message() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
      child: TextFormField(
        controller: detailsController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
          hintText: 'เพิ่มรายละเอียดกิจกรรม',
          fillColor: Color.fromARGB(255, 255, 255, 255),
          filled: true,
          prefixIcon: Icon(
            Icons.mail,
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


  Widget createGroupButton() {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 20, 10, 0),
      child: SizedBox(
        width: 200, // กำหนดความกว้างของปุ่มตามที่ต้องการ
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
              borderRadius: BorderRadius.circular(30),
              side: BorderSide(color: Colors.black),
            ),
          ),
          onPressed: () {
            functionCreateActivity();
          },
        ),
      ),
    );
  }


  Widget backButton() {
    return IconButton(
      icon: Icon(Icons.arrow_back,
          color: const Color.fromARGB(255, 255, 255, 255)),
      onPressed: () {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => Homepage()));
      },
    );
  }

  Future<void> showSuccessDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("สำเร็จ"),
          content: Text("สร้างกิจกรรมสำเร็จ"),
          actions: <Widget>[
            TextButton(
              child: Text("ตกลง"),
              onPressed: () {
                Navigator.of(context).pop(); // ปิด dialog
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => Homepage()));
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> functionCreateActivity() async {
    String hashtags = _selectedTags.join(" ");
    List<String> hashtagList =
        hashtags.split(RegExp(r'\s+')).where((tag) => tag.isNotEmpty).toList();

    if (hashtagList.length > 3 || hashtagList.any((tag) => tag.length > 20)) {
      print("Invalid hashtag input");
      return;
    }

    print("activity_name: ${nameController.text}");
    print("activity_details: ${detailsController.text}");
    print("activity_date: ${dateController.text}");

    Map<String, dynamic> dataPost = {
      "activity_name": nameController.text,
      "activity_details": detailsController.text,
      "activity_date": dateController.text,
      "location_name": selectedLocation ?? '',
      "sport_id": selectedSportId, // Ensure this value is set appropriately
      "hashtags": hashtagList,
    };

    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json"
    };

    var url =
        Uri.parse("http://10.0.2.2/flutter_webservice/get_CreateActivity.php");

    try {
      var response = await http.post(
        url,
        headers: headers,
        body: json.encode(dataPost),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        print(jsonResponse);
        if (jsonResponse["result"] == 1) {
          showSuccessDialog(); // แสดง dialog เมื่อสร้างกิจกรรมสำเร็จ
        }
      } else {
        print("Request failed with status: ${response.statusCode}");
      }
    } catch (error) {
      print("Error: $error");
    }
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
              leading: backButton(),
              backgroundColor: Color.fromARGB(255, 255, 0, 0),
            ),
            body: SafeArea(
              child: ListView(
                children: [
                  Center(
                      child:
                          Column(mainAxisSize: MainAxisSize.max, children: [])),
                  nameActivity(),
                  location(),
                  field_name(),
                  date(),
                  hashtag(),
                  message(),
                  createGroupButton()
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
