import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:wegosport/Homepage.dart';

const kGoogleApiKey =
    "AIzaSyC_RzmlxLOESG1-JwwSddFSijV11HUVHJk"; // แทนที่ด้วย API Key ของคุณ

class AddLocationPage extends StatefulWidget {
  const AddLocationPage({super.key});

  @override
  State<AddLocationPage> createState() => _AddLocationState();
}

class _AddLocationState extends State<AddLocationPage> {
  TextEditingController input1 = TextEditingController();
  TextEditingController input2 = TextEditingController();

  TextEditingController typeController =
      TextEditingController(); // เพิ่ม TextEditingController สำหรับประเภทสนาม
  List<String> selectedTypes = [];
  List<Map<String, dynamic>> fieldTypes = [];

  File? _imageFile;
  LatLng? _selectedLocation; // Added to store the selected location
  final ImagePicker _picker = ImagePicker();
  GoogleMapController? _mapController;

  Future<void> fetchType() async {
    final response = await http.get(
        Uri.parse('http://10.0.2.2/flutter_webservice/get_ShowDataType.php'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        fieldTypes = List<Map<String, dynamic>>.from(data);
      });
    } else {
      print('Failed to load field types. Status code: ${response.statusCode}');
      throw Exception('Failed to load field types');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchType();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _handlePressButton() async {
    Prediction? p = await PlacesAutocomplete.show(
        context: context,
        apiKey: kGoogleApiKey,
        mode: Mode.overlay, // Mode.fullscreen
        language: "th",
        components: [Component(Component.country, "th")]);
    displayPrediction(p);
  }

  Future<void> displayPrediction(Prediction? p) async {
    if (p != null) {
      // get detail (lat/lng)
      GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId!);
      final lat = detail.result.geometry!.location.lat;
      final lng = detail.result.geometry!.location.lng;

      setState(() {
        _selectedLocation = LatLng(lat, lng);
        _mapController
            ?.animateCamera(CameraUpdate.newLatLng(_selectedLocation!));
      });
    }
  }

  void _showFullScreenMap() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 1.0, // ขนาดเริ่มต้นของแผนที่
          minChildSize: 1.0, // ขนาดขั้นต่ำของแผนที่
          maxChildSize: 1.0, // ขนาดสูงสุดของแผนที่
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              child: map(), // เรียกใช้ฟังก์ชัน map() ที่คุณมี
            );
          },
        );
      },
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

  Widget namelocation() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: TextFormField(
        controller: input1,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(15, 10, 15, 10),
          hintText: 'ชื่อสถานที่',
          fillColor: const Color.fromARGB(255, 255, 255, 255),
          filled: true,
          hintStyle: TextStyle(color: Color.fromARGB(255, 102, 102, 102)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          prefixIcon: Icon(Icons.add, color: Color.fromARGB(255, 255, 0, 0)),
        ),
        style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
      ),
    );
  }

  Widget time() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: TextFormField(
        controller: input2,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(15, 10, 15, 10),
          hintText: 'เวลาเปิด - ปิด',
          fillColor: Color.fromARGB(255, 255, 255, 255),
          filled: true,
          hintStyle: TextStyle(color: Color.fromARGB(255, 102, 102, 102)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          prefixIcon: Icon(Icons.add, color: Color.fromARGB(255, 255, 0, 0)),
        ),
        style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
      ),
    );
  }

  Widget type() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: TextFormField(
        controller: typeController,
        readOnly: true,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(15, 10, 15, 10),
          hintText: 'เลือกประเภทสนาม',
          fillColor: Color.fromARGB(255, 255, 255, 255),
          filled: true,
          hintStyle: TextStyle(color: Color.fromARGB(255, 102, 102, 102)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          prefixIcon: Icon(Icons.add, color: Color.fromARGB(255, 255, 0, 0)),
        ),
        onTap: _showTypeDialog,
        style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
      ),
    );
  }

  Widget addImage() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: ElevatedButton.icon(
        icon: Icon(Icons.image, color: Color.fromARGB(255, 255, 0, 0)),
        label: Text("เลือกรูปภาพ",
            style: TextStyle(color: const Color.fromARGB(255, 29, 29, 29))),
        style: ElevatedButton.styleFrom(
          primary: const Color.fromARGB(255, 255, 255, 255),
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
        ),
        onPressed: _pickImage,
      ),
    );
  }

  Widget searchBar() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: ElevatedButton(
        child: Text("ค้นหาสถานที่", style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          primary: Colors.blue,
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: _handlePressButton,
      ),
    );
  }

  Widget map() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
      width: double.infinity,
      height: 500,
      child: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(13.736717, 100.523186), // Initial position (Bangkok)
          zoom: 10,
        ),
        onTap: (LatLng location) {
          setState(() {
            _selectedLocation = location;
          });
        },
        markers: _selectedLocation != null
            ? {
                Marker(
                  markerId: MarkerId('เลือกสถานที่'),
                  position: _selectedLocation!,
                ),
              }
            : {},
      ),
    );
  }

  Widget mapImage() {
    return _imageFile == null
        ? Container(
            margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
            width: 200, // กำหนดความกว้างที่ต้องการ
            height: 200, // กำหนดความสูงที่ต้องการ
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image.asset(
                'images/logo.png', // เปลี่ยนเป็นรูปภาพของแผนที่
                //fit: BoxFit.cover,
              ),
            ),
          )
        : Container(
            margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
            width: 200, // กำหนดความกว้างที่ต้องการ
            height: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.file(
                _imageFile!,
                //fit: BoxFit.cover,
              ),
            ),
          );
  }

  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ข้อผิดพลาด'),
          content: Text(message),
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

  void _showTypeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('เลือกประเภทสนาม'),
          content: SingleChildScrollView(
            child: ListBody(
              children: fieldTypes.map((type) {
                return CheckboxListTile(
                  title: Text(type['type_name']),
                  value: selectedTypes.contains(type['type_name']),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedTypes.add(type['type_name']);
                      } else {
                        selectedTypes.remove(type['type_name']);
                      }
                    });
                    Navigator.of(context).pop();
                    _showTypeDialog(); // เปิดใหม่เพื่อรีเฟรช
                  },
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('ตกลง'),
              onPressed: () {
                Navigator.of(context).pop();
                typeController.text =
                    selectedTypes.join(', '); // แสดงประเภทที่เลือก
              },
            ),
          ],
        );
      },
    );
  }

  Widget buttonAddLocation(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: ElevatedButton(
        child: Text("เพิ่มสถานที่", style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          primary: Color.fromARGB(255, 255, 0, 0),
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
        ),
        onPressed: () {
          if (input1.text.isEmpty || input2.text.isEmpty) {
            showErrorDialog(context, 'กรุณากรอกข้อมูล');
          } else if (_imageFile == null) {
            showErrorDialog(context, 'กรุณาเลือกรูปภาพ');
          } else if (_selectedLocation == null) {
            showErrorDialog(context, 'กรุณาเลือกสถานที่บนแผนที่');
          } else {
            functionAddLocation();
          }
        },
      ),
    );
  }

  Future<void> functionAddLocation() async {
    if (_imageFile == null || _selectedLocation == null) {
      print("No image or location selected.");
      return;
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("http://10.0.2.2/flutter_webservice/get_AddLocation.php"),
    );

    request.fields['location_name'] = input1.text;
    request.fields['location_time'] = input2.text;

    request.fields['types_id'] = json.encode(selectedTypes.map((type) {
      final typeMap =
          fieldTypes.firstWhere((element) => element['type_name'] == type);
      return typeMap['type_id'];
    }).toList());

    request.fields['latitude'] = _selectedLocation!.latitude.toString();
    request.fields['longitude'] = _selectedLocation!.longitude.toString();

    request.files
        .add(await http.MultipartFile.fromPath('image', _imageFile!.path));
    
    print(request.fields);
    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        print(responseData);
        // Show success dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('สำเร็จ'),
              content: Text('เพิ่มสถานที่สำเร็จแล้ว'),
              actions: <Widget>[
                TextButton(
                  child: Text('ตกลง'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Homepage()),
                    );
                  },
                ),
              ],
            );
          },
        );
      } else {
        print("Request failed with status: ${response.statusCode}");
      }
    } catch (error) {
      print("Error: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 222, 222, 222),
      appBar: AppBar(
        title: Text("เพิ่มสถานที่"),
        leading: backButton(),
        backgroundColor: Color.fromARGB(255, 255, 0, 0),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            namelocation(),
            time(),
            type(),
            addImage(),
            mapImage(),
            map(),
            buttonAddLocation(context),
            SizedBox(height: 20)
          ],
        ),
      ),
    );
  }
}
