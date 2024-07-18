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


  @override
  void initState() {
    super.initState();
    fetchLocations();
    fetchSport();
  }

  Widget nameActivity() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
      child: TextFormField(
        controller: nameController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
          hintText: 'ชื่อกิจกรรม',
          fillColor: Color.fromARGB(255, 255, 255, 255),
          filled: true,
          prefixIcon: Icon(
            Icons.add,
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

  Widget location() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
      child: TypeAheadFormField(
        textFieldConfiguration: TextFieldConfiguration(
          controller: locationController,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
            hintText: 'สถานที่',
            hintStyle: TextStyle(fontFamily: 'THSarabunNew'),
            fillColor: Color.fromARGB(255, 255, 255, 255),
            filled: true,
            prefixIcon: Icon(
              Icons.add,
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
            hintText: 'กีฬา',
            hintStyle: TextStyle(fontFamily: 'THSarabunNew'),
            fillColor: Color.fromARGB(255, 255, 255, 255),
            filled: true,
            prefixIcon: Icon(
              Icons.add,
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
          hintText: 'วันที่และเวลา',
          fillColor: Color.fromARGB(255, 255, 255, 255),
          filled: true,
          prefixIcon: Icon(
            Icons.add,
            color: Colors.red,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        readOnly: true,
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
          );

          if (pickedDate != null) {
            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );

            if (pickedTime != null) {
              DateTime finalDateTime = DateTime(
                pickedDate.year,
                pickedDate.month,
                pickedDate.day,
                pickedTime.hour,
                pickedTime.minute,
              );

              setState(() {
                dateController.text = finalDateTime.toString();
              });
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
          Text(
            'ทดสอบ hashtag',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          SizedBox(height: 10),
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
          TextField(
            controller: hashtagController,
            decoration: InputDecoration(
              hintText: 'พิมพ์แฮชแท็กที่นี่',
              suffixIcon: IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  if (hashtagController.text.isNotEmpty &&
                      hashtagController.text.length <= 20 &&
                      _selectedTags.length < 3) {
                    setState(() {
                      _selectedTags.add(hashtagController.text);
                      hashtagController.clear();
                    });
                  }
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
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
          hintText: 'ข้อความขังเขป',
          fillColor: Color.fromARGB(255, 255, 255, 255),
          filled: true,
          prefixIcon: Icon(
            Icons.add,
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

  Widget picture() {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
      child: TextFormField(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
          hintText: 'แนปรูปสถานที่',
          fillColor: Color.fromARGB(255, 255, 255, 255),
          filled: true,
          prefixIcon: Icon(
            Icons.add,
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
      icon: Icon(Icons.arrow_back, color: Colors.black),
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
                  picture(),
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
