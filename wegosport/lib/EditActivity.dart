import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditActivity extends StatefulWidget {
  final String activityId;
  final String jwt;

  const EditActivity({Key? key, required this.activityId, required this.jwt})
      : super(key: key);

  @override
  State<EditActivity> createState() => _EditActivityState();
}

class _EditActivityState extends State<EditActivity> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController detailsController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController hashtagController = TextEditingController();

  List<Map<String, dynamic>> locations = [];
  List<Map<String, dynamic>> sports = [];

  String? selectedLocation;
  String? selectedSport;
  List<String> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    fetchLocations();
    fetchSports();
    fetchActivityDetails();
  }

  Future<void> fetchLocations() async {
    final response = await http.get(Uri.parse(
        'http://10.0.2.2/flutter_webservice/get_ShowDataLocation.php'));

    if (response.statusCode == 200) {
      final List<Map<String, dynamic>> data =
          List<Map<String, dynamic>>.from(json.decode(response.body));
      setState(() {
        locations = data;
      });
    } else {
      print('Failed to load locations');
    }
  }

  Future<void> fetchSports() async {
    final response = await http.get(
        Uri.parse('http://10.0.2.2/flutter_webservice/get_ShowDataSport.php'));

    if (response.statusCode == 200) {
      final List<Map<String, dynamic>> data =
          List<Map<String, dynamic>>.from(json.decode(response.body));
      setState(() {
        sports = data;
      });
    } else {
      print('Failed to load sports');
    }
  }

  Future<void> fetchActivityDetails() async {
    final response = await http.get(
      Uri.parse(
          'http://10.0.2.2/flutter_webservice/get_ShowDataActivity.php?id=${widget.activityId}'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> activities = json.decode(response.body);
      final activity = activities.firstWhere(
          (activity) => activity['activity_id'] == widget.activityId);

      setState(() {
        nameController.text = activity['activity_name'];
        dateController.text = activity['activity_date'];
        detailsController.text = activity['activity_details'];
        selectedLocation = activity['location_name'];
        selectedSport = activity['sport_name'];
        _selectedTags.addAll((activity['hashtags'] as List<dynamic>?)
                ?.map((hashtag) => "${hashtag['hashtag_message']}")
                .toList() ??
            []);
      });
    } else {
      print('Failed to load activity details');
    }
  }

  int? getLocationIdByName(String locationName) {
    print('Looking for location: $locationName');
    final loc = locations
        .firstWhere((loc) => loc['location_name'] == locationName, orElse: () {
      print('Location not found');
      return {};
    });
    return loc.isNotEmpty ? loc['location_id'] : null;
  }

  int? getSportIdByName(String sportName) {
    print('Looking for sport: $sportName');
    final sport = sports.firstWhere((sport) => sport['sport_name'] == sportName,
        orElse: () {
      print('Sport not found');
      return {};
    });
    return sport.isNotEmpty ? sport['sport_id'] : null;
  }


  Future<void> updateActivity() async {
    print('ข้อมูล ไอดีกิจกรรม : ${widget.activityId}');
    print('ข้อมูล ชื่อกิจกรรม : ${nameController.text}');
    print('ข้อมูล ข้อความสังเขปกิจกรรม : ${detailsController.text}');
    print('ข้อมูล วันที่ : ${dateController.text}');
    print('ข้อมูล สถานที่ : ${selectedLocation}');
    print('ข้อมูล กีฬา : ${selectedSport}');
    print('ข้อมูล hashtag : ${_selectedTags}');
    
    final locationId = getLocationIdByName(selectedLocation ?? '');
    final sportId = getSportIdByName(selectedSport ?? '');

    print('ข้อมูล สถานที่แปลงแล้ว : ${locationId}');
    print('ข้อมูล กีฬาแปลงแล้ว : ${sportId}');

    if (locationId == null || sportId == null) {
      print('เลือกสถานที่หรือกีฬาไม่ถูกต้อง');
      return;
    }

    String hashtags = _selectedTags.join(" ");
    List<String> hashtagList =
        hashtags.split(RegExp(r'\s+')).where((tag) => tag.isNotEmpty).toList();

    Map<String, dynamic> dataPost = {
      "activity_id": widget.activityId,
      "activity_name": nameController.text,
      "activity_details": detailsController.text,
      "activity_date": dateController.text,
      "location_id": locationId,
      "sport_id": sportId,
      "hashtags": hashtagList,
    };

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
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("ล้มเหลว"),
            content: Text("การแก้ไขกิจกรรมล้มเหลว"),
            actions: <Widget>[
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'ชื่อกิจกรรม'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกชื่อกิจกรรม';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: dateController,
                decoration: InputDecoration(labelText: 'วันที่'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกวันที่';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: selectedLocation,
                decoration: InputDecoration(labelText: 'สถานที่'),
                onChanged: (value) {
                  setState(() {
                    selectedLocation = value;
                  });
                },
                items: locations
                    .map((location) => DropdownMenuItem<String>(
                          value: location['location_name'],
                          child: Text(location['location_name']),
                        ))
                    .toList(),
              ),
              DropdownButtonFormField<String>(
                value: selectedSport,
                decoration: InputDecoration(labelText: 'กีฬา'),
                onChanged: (value) {
                  setState(() {
                    selectedSport = value;
                  });
                },
                items: sports
                    .map((sport) => DropdownMenuItem<String>(
                          value: sport['sport_name'],
                          child: Text(sport['sport_name']),
                        ))
                    .toList(),
              ),
              TextFormField(
                controller: detailsController,
                decoration: InputDecoration(labelText: 'รายละเอียดกิจกรรม'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกรายละเอียดกิจกรรม';
                  }
                  return null;
                },
              ),
              // Add more fields as needed
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: updateActivity,
                child: Text('บันทึกการเปลี่ยนแปลง'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
