import 'package:flutter/material.dart'; // นำเข้าไลบรารีสำหรับการสร้าง UI ด้วย Flutter
import 'package:http/http.dart'
    as http; // นำเข้าไลบรารีสำหรับการทำ HTTP requests
import 'package:image_picker/image_picker.dart'; // นำเข้าไลบรารีสำหรับการเลือกรูปภาพจากแกลเลอรี่หรือกล้อง
import 'package:google_maps_flutter/google_maps_flutter.dart'; // นำเข้าไลบรารีสำหรับใช้งาน Google Maps ใน Flutter
import 'package:flutter_google_places/flutter_google_places.dart'; // นำเข้าไลบรารีสำหรับการค้นหาสถานที่ด้วย Google Places
import 'package:google_maps_webservice/places.dart'; // นำเข้าไลบรารีสำหรับการใช้งาน Google Places API
import 'package:permission_handler/permission_handler.dart'; // นำเข้าไลบรารีสำหรับการขออนุญาตการเข้าถึงทรัพยากรของอุปกรณ์
import 'dart:async'; // นำเข้าไลบรารีสำหรับการทำงานแบบอะซิงโครนัส (asynchronous)
import 'dart:convert'; // นำเข้าไลบรารีสำหรับการแปลงข้อมูล JSON
import 'dart:io'; // นำเข้าไลบรารีสำหรับการทำงานกับไฟล์
import 'package:image_cropper/image_cropper.dart'; // นำเข้าไลบรารีสำหรับการครอปรูปภาพ
import 'package:image/image.dart'
    as img; // นำเข้าไลบรารีสำหรับการจัดการรูปภาพในรูปแบบที่ต่างกัน
import 'package:wegosport/Homepage.dart'; // นำเข้าหน้าหลักของแอปพลิเคชัน

const kGoogleApiKey =
    "AIzaSyA0fREem2DS-afsu3zFC-yH6a7sz4B7Z3Y"; // แทนที่ด้วย API Key ของคุณ

class AddLocationPage extends StatefulWidget {
  const AddLocationPage({Key? key, required this.jwt})
      : super(key: key); // กำหนดคอนสตรัคเตอร์และกำหนดค่า JWT

  final String jwt; // กำหนดตัวแปร jwt เพื่อใช้งานในการพิสูจน์ตัวตน

  @override
  State<AddLocationPage> createState() =>
      _AddLocationState(); // สร้าง State สำหรับ AddLocationPage
}

class _AddLocationState extends State<AddLocationPage> {
  TextEditingController input1 =
      TextEditingController(); // ตัวควบคุมสำหรับชื่อสถานที่
  TextEditingController input2 =
      TextEditingController(); // ตัวควบคุมสำหรับเวลาเปิด-ปิด
  TextEditingController searchController =
      TextEditingController(); // ตัวควบคุมสำหรับค้นหาสถานที่
  TextEditingController typeController =
      TextEditingController(); // ตัวควบคุมสำหรับประเภทสนาม
  List<String> selectedTypes = []; // ประเภทสนามที่เลือก
  List<Map<String, dynamic>> fieldTypes = []; // ประเภทสนามทั้งหมด
  File? _imageFile; // ไฟล์รูปภาพที่เลือก
  LatLng? _selectedLocation; // ตำแหน่งที่เลือกบนแผนที่
  final ImagePicker _picker = ImagePicker(); // ตัวเลือกภาพ
  GoogleMapController? _mapController; // ควบคุมแผนที่

  @override
  void initState() {
    super.initState();
    fetchType(); // เรียกใช้งานฟังก์ชัน fetchType เพื่อดึงข้อมูลประเภทสนาม
    _requestLocationPermission(); // ขออนุญาตการเข้าถึงตำแหน่ง
  }

  // ดึงข้อมูลประเภทสนามจากเซิร์ฟเวอร์
  Future<void> fetchType() async {
    final response = await http.get(Uri.parse(
        'http://10.0.2.2/flutter_webservice/get_ShowDataType.php')); // ส่งคำขอ HTTP เพื่อดึงข้อมูลประเภทสนาม

    if (response.statusCode == 200) {
      final data = json.decode(response.body); // ถอดรหัส JSON จากการตอบกลับ
      setState(() {
        fieldTypes = List<Map<String, dynamic>>.from(
            data); // เก็บข้อมูลประเภทสนามในตัวแปร fieldTypes
      });
    } else {
      print(
          'Failed to load field types. Status code: ${response.statusCode}'); // แสดงข้อผิดพลาดถ้าดึงข้อมูลล้มเหลว
      throw Exception(
          'Failed to load field types'); // โยนข้อยกเว้นเมื่อเกิดข้อผิดพลาด
    }
  }

  bool _isPickingImage = false; // ตัวแปรตรวจสอบสถานะการเลือกภาพ

  Future<void> _pickImage() async {
    if (_isPickingImage) {
      return; // หยุดการทำงานถ้ามีการเลือกภาพอยู่แล้ว
    }

    _isPickingImage = true; // กำหนดสถานะว่ากำลังเลือกภาพ
    try {
      final pickedFile = await _picker.pickImage(
          source: ImageSource.gallery); // เลือกรูปภาพจากแกลเลอรี

      if (pickedFile != null) {
        File? croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path, // เส้นทางของรูปภาพที่เลือก
          aspectRatio:
              CropAspectRatio(ratioX: 1.0, ratioY: 1.0), // อัตราส่วนครอป
          androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.red,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          iosUiSettings: IOSUiSettings(
            minimumAspectRatio: 1.0,
          ),
        );

        if (croppedFile != null) {
          setState(() {
            _imageFile =
                croppedFile; // เก็บไฟล์ที่ครอปแล้วไว้ในตัวแปร _imageFile
          });
        }
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('Error picking image: $e'); // จัดการข้อผิดพลาด
    } finally {
      _isPickingImage = false; // ปรับสถานะเมื่อกระบวนการเสร็จสิ้น
    }
  }
 
  // ขออนุญาตการเข้าถึงตำแหน่ง
  Future<void> _requestLocationPermission() async {
      var status =
          await Permission.locationWhenInUse.status; // ตรวจสอบสถานะการอนุญาต
      if (!status.isGranted) {
        status = await Permission.locationWhenInUse.request(); // ขออนุญาตถ้ายังไม่ได้รับ
            
        if (!status.isGranted) {
          // จัดการกรณีที่ผู้ใช้ปฏิเสธการอนุญาต
          print('ไม่ได้รับอนุญาติให้ระบุตำแหน่ง');
          return;
        }
      }
      print('ได้รับอนุญาติให้จัดสถานที่แล้ว');
    }

  // ค้นหาสถานที่โดยใช้ Google Places API
  Future<void> _handlePressButton() async {
    try {
      String searchQuery =
          input1.text; // รับค่าที่ผู้ใช้พิมพ์ในฟิลด์ชื่อสถานที่
      if (searchQuery.isEmpty) {
        print('Search query is empty.'); // แสดงข้อความเมื่อช่องค้นหาว่างเปล่า
        return;
      }

      print('Showing PlacesAutocomplete');
      final response = await http.get(Uri.parse(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$searchQuery&key=$kGoogleApiKey&components=country:th')); // ส่งคำขอไปยัง Google Places API เพื่อค้นหาสถานที่

      if (response.statusCode == 200) {
        final predictions = json.decode(
            response.body)['predictions']; // ถอดรหัสการทำนายผลลัพธ์จาก JSON
        if (predictions.isNotEmpty) {
          final place = predictions[0];
          final placeId =
              place['place_id']; // เก็บ place_id ของสถานที่แรกที่ถูกทำนาย
          final description = place['description']; // เก็บคำอธิบายของสถานที่
          print('Prediction: $description');
          displayPrediction(
              placeId); // เรียกใช้ฟังก์ชันเพื่อแสดงรายละเอียดสถานที่
        } else {
          print(
              'No predictions found.'); // แสดงข้อความเมื่อไม่พบผลลัพธ์จากการค้นหา
        }
      } else {
        print(
            'Failed to load predictions. Status code: ${response.statusCode}'); // แสดงข้อความเมื่อการโหลดการทำนายล้มเหลว
      }
    } catch (error) {
      print(
          'Error in _handlePressButton: $error'); // แสดงข้อความเมื่อเกิดข้อผิดพลาดในฟังก์ชัน
    }
  }

  // แสดงตำแหน่งที่เลือกจาก Google Places API
  Future<void> displayPrediction(String placeId) async {
    try {
      final response = await http.get(Uri.parse(
          'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$kGoogleApiKey')); // ส่งคำขอไปยัง Google Places API เพื่อรับรายละเอียดของสถานที่

      if (response.statusCode == 200) {
        final details =
            json.decode(response.body)['result']; // ถอดรหัสผลลัพธ์จาก JSON
        final lat =
            details['geometry']['location']['lat']; // ดึงละติจูดจากผลลัพธ์
        final lng =
            details['geometry']['location']['lng']; // ดึงลองจิจูดจากผลลัพธ์
        print('Location: ($lat, $lng)');

        setState(() {
          _selectedLocation = LatLng(
              lat, lng); // เก็บตำแหน่งที่เลือกไว้ในตัวแปร _selectedLocation
          if (_selectedLocation != null) {
            _mapController?.animateCamera(CameraUpdate.newLatLng(
                _selectedLocation!)); // ปรับกล้องไปยังตำแหน่งที่เลือก
          }
        });
      } else {
        print(
            'Failed to load place details. Status code: ${response.statusCode}'); // แสดงข้อความเมื่อการโหลดรายละเอียดสถานที่ล้มเหลว
      }
    } catch (error) {
      print(
          'Error in displayPrediction: $error'); // แสดงข้อความเมื่อเกิดข้อผิดพลาดในฟังก์ชัน
    }
  }

  // แสดงแผนที่ในโหมดเต็มหน้าจอ
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

  // วิดเจ็ตปุ่มกลับไปหน้าหลัก
  Widget backButton() {
    return IconButton(
      icon: Icon(Icons.arrow_back,
          color: const Color.fromARGB(
              255, 255, 255, 255)), // กำหนดไอคอนของปุ่มกลับไปหน้าหลัก
      onPressed: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) =>
                  Homepage(jwt: widget.jwt)), // สร้างเส้นทางไปยังหน้า Homepage
        );
      },
    );
  }

  // วิดเจ็ตฟิลด์ชื่อสถานที่
  Widget namelocation() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 20, 20, 0), // กำหนดระยะขอบของฟิลด์
      child: TextFormField(
        controller: input1, // กำหนดตัวควบคุมให้กับฟิลด์ชื่อสถานที่
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(
              15, 10, 15, 10), // กำหนด padding ของเนื้อหาภายในฟิลด์
          hintText: 'ชื่อสถานที่', // ข้อความแนะนำในฟิลด์
          fillColor: const Color.fromARGB(
              255, 255, 255, 255), // กำหนดสีพื้นหลังของฟิลด์
          filled: true, // กำหนดให้ฟิลด์มีสีพื้นหลัง
          hintStyle: TextStyle(
              color:
                  Color.fromARGB(255, 102, 102, 102)), // กำหนดสีของข้อความแนะนำ
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40), // กำหนดความโค้งของขอบฟิลด์
          ),
          prefixIcon: Icon(Icons.abc,
              color: Color.fromARGB(255, 255, 0, 0)), // กำหนดไอคอนของฟิลด์
        ),
        style: TextStyle(
            color: const Color.fromARGB(
                255, 0, 0, 0)), // กำหนดสีของข้อความภายในฟิลด์
      ),
    );
  }

  Map<String, bool> selectedDays = {
    'จันทร์': false,
    'อังคาร': false,
    'พุธ': false,
    'พฤหัสบดี': false,
    'ศุกร์': false,
    'เสาร์': false,
    'อาทิตย์': false,
  };

  Widget daySelection() {
    bool isSelectAll = selectedDays.values.every((value) => value);

    return Container(
      margin: EdgeInsets.all(20), // เพิ่มระยะขอบรอบ ๆ
      padding: EdgeInsets.all(10), // เพิ่ม Padding ภายในกล่อง
      decoration: BoxDecoration(
        color: Colors.white, // สีพื้นหลังของกล่อง
        borderRadius: BorderRadius.circular(15), // ความโค้งของกรอบ
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), // สีของเงา
            spreadRadius: 2, // การกระจายเงา
            blurRadius: 5, // ความเบลอของเงา
            offset: Offset(0, 3), // ตำแหน่งเงา
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...selectedDays.keys.map((String day) {
            return CheckboxListTile(
              title: Text(day),
              value: selectedDays[day],
              onChanged: (bool? value) {
                setState(() {
                  selectedDays[day] = value!;
                });
              },
            );
          }).toList(),
          Align(
            alignment: Alignment.center, // จัดปุ่มให้อยู่ขวา
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  if (isSelectAll) {
                    selectedDays
                        .updateAll((key, value) => false); // ยกเลิกทั้งหมด
                  } else {
                    selectedDays
                        .updateAll((key, value) => true); // เลือกทั้งหมด
                  }
                });
              },
              child: Text(
                isSelectAll ? 'ยกเลิกทั้งหมด' : 'เลือกทั้งหมด',
                style: TextStyle(color: Colors.black), // สีตัวหนังสือ
              ),
            ),
          ),
        ],
      ),
    );
  }

  // วิดเจ็ตฟิลด์เวลาเปิด-ปิด
  Widget time() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 20, 20, 0), // กำหนดระยะขอบของฟิลด์
      child: TextFormField(
        controller: input2, // ตัวควบคุมสำหรับเวลาเปิด-ปิด
        decoration: InputDecoration(
          contentPadding:
              EdgeInsets.fromLTRB(15, 10, 15, 10), // Padding ภายในฟิลด์
          hintText: 'เลือกเวลาเปิด - ปิด', // ข้อความแนะนำ
          fillColor: Color.fromARGB(255, 255, 255, 255), // สีพื้นหลังของฟิลด์
          filled: true, // ให้ฟิลด์มีสีพื้นหลัง
          hintStyle: TextStyle(
              color: Color.fromARGB(255, 102, 102, 102)), // สีของข้อความแนะนำ
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40), // ความโค้งของขอบฟิลด์
          ),
          prefixIcon: Icon(
            Icons.access_time, // ไอคอนเวลา
            color: Color.fromARGB(255, 255, 0, 0), // สีของไอคอน
          ),
        ),
        readOnly: true, // ปิดการแก้ไขฟิลด์โดยตรง
        onTap: () async {
          // แสดงตัวเลือกเวลาเปิด
          TimeOfDay? pickedOpenTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(), // เริ่มต้นด้วยเวลาปัจจุบัน
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  alwaysUse24HourFormat: true, // ใช้เวลาแบบ 24 ชั่วโมง
                ),
                child: child!,
              );
            },
          );

          // ถ้าเลือกเวลาเปิดแล้ว ให้แสดงตัวเลือกเวลาปิด
          if (pickedOpenTime != null) {
            TimeOfDay? pickedCloseTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(), // เริ่มต้นด้วยเวลาปัจจุบัน
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    alwaysUse24HourFormat: true, // ใช้เวลาแบบ 24 ชั่วโมง
                  ),
                  child: child!,
                );
              },
            );

            if (pickedCloseTime != null) {
              setState(() {
                input2.text =
                    '${pickedOpenTime.format(context)} - ${pickedCloseTime.format(context)}'; // แสดงเวลาเปิด-ปิดในฟิลด์
              });
            }
          }
        },
      ),
    );
  }

  // วิดเจ็ตฟิลด์ประเภทสนาม
  Widget type() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 20, 20, 0), // กำหนดระยะขอบของฟิลด์
      child: TextFormField(
        controller: typeController, // กำหนดตัวควบคุมให้กับฟิลด์ประเภทสนาม
        readOnly: true, // ตั้งค่าให้ฟิลด์เป็นแบบอ่านอย่างเดียว
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(
              15, 10, 15, 10), // กำหนด padding ของเนื้อหาภายในฟิลด์
          hintText: 'เลือกประเภทสนาม', // ข้อความแนะนำในฟิลด์
          fillColor:
              Color.fromARGB(255, 255, 255, 255), // กำหนดสีพื้นหลังของฟิลด์
          filled: true, // กำหนดให้ฟิลด์มีสีพื้นหลัง
          hintStyle: TextStyle(
              color:
                  Color.fromARGB(255, 102, 102, 102)), // กำหนดสีของข้อความแนะนำ
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40), // กำหนดความโค้งของขอบฟิลด์
          ),
          prefixIcon: Icon(Icons.add,
              color: Color.fromARGB(255, 255, 0, 0)), // กำหนดไอคอนของฟิลด์
        ),
        onTap: _showTypeDialog, // เรียกฟังก์ชัน _showTypeDialog เมื่อกดที่ฟิลด์
        style: TextStyle(
            color: Color.fromARGB(255, 0, 0, 0)), // กำหนดสีของข้อความภายในฟิลด์
      ),
    );
  }

  // วิดเจ็ตปุ่มเลือกรูปภาพ
  Widget addImage() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 20, 20, 0), // กำหนดระยะขอบของปุ่ม
      child: ElevatedButton.icon(
        icon: Icon(Icons.image,
            color:
                Color.fromARGB(255, 255, 0, 0)), // กำหนดไอคอนของปุ่มเลือกรูปภาพ
        label: Text("เลือกรูปภาพ",
            style: TextStyle(
                color: const Color.fromARGB(
                    255, 29, 29, 29))), // กำหนดข้อความของปุ่ม
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(
              255, 255, 255, 255), // กำหนดสีพื้นหลังของปุ่ม
          padding: EdgeInsets.symmetric(vertical: 15), // กำหนด padding ของปุ่ม
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40), // กำหนดความโค้งของขอบปุ่ม
          ),
        ),
        onPressed: _pickImage, // เรียกฟังก์ชัน _pickImage เมื่อกดปุ่ม
      ),
    );
  }

  // วิดเจ็ตปุ่มค้นหาสถานที่
  Widget searchlocation() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 20, 20, 0), // กำหนดระยะขอบของปุ่ม
      child: ElevatedButton.icon(
        onPressed:
            _handlePressButton, // เรียกฟังก์ชัน _handlePressButton เมื่อกดปุ่ม
        icon: Icon(Icons.search), // กำหนดไอคอนของปุ่มค้นหาสถานที่
        label: Text('ค้นหาสถานที่',
            style: TextStyle(
                color: const Color.fromARGB(
                    255, 29, 29, 29))), // กำหนดข้อความของปุ่ม
        style: ElevatedButton.styleFrom(
          backgroundColor:
              Color.fromARGB(255, 255, 255, 255), // กำหนดสีพื้นหลังของปุ่ม
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40), // กำหนดความโค้งของขอบปุ่ม
          ),
        ),
      ),
    );
  }

  // วิดเจ็ตแผนที่
  Widget map() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 20, 20, 0), // กำหนดระยะขอบของแผนที่
      width: double.infinity, // กำหนดความกว้างของแผนที่
      height: 500, // กำหนดความสูงของแผนที่
      child: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _mapController =
              controller; // กำหนดตัวควบคุมแผนที่เมื่อสร้างแผนที่เสร็จสิ้น
        },
        initialCameraPosition: CameraPosition(
          target:
              LatLng(13.736717, 100.523186), // กำหนดตำแหน่งเริ่มต้น (กรุงเทพฯ)
          zoom: 10, // กำหนดระดับการซูมเริ่มต้น
        ),
        onTap: (LatLng location) {
          setState(() {
            _selectedLocation = location; // กำหนดตำแหน่งที่เลือกเมื่อแตะที่แผนที่
                
          });
        },
        markers: _selectedLocation != null
            ? {
                Marker(
                  markerId: MarkerId('เลือกสถานที่'), // กำหนด ID ของ Marker
                  position: _selectedLocation!, // กำหนดตำแหน่งของ Marker
                ),
              }
            : {},
        myLocationEnabled: true, // แสดงปุ่มตำแหน่งปัจจุบัน
        myLocationButtonEnabled: true, // เปิดใช้งานปุ่มตำแหน่งปัจจุบัน
      ),
    );
  }

  // วิดเจ็ตแสดงรูปภาพที่เลือกหรือโลโก้
  Widget imageDisplay() {
    return _imageFile == null
        ? Container(
            margin: EdgeInsets.fromLTRB(20, 20, 20, 0), // กำหนดระยะขอบของรูปภาพ
            width: 200, // กำหนดความกว้างของรูปภาพ
            height: 200, // กำหนดความสูงของรูปภาพ
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(40), // กำหนดความโค้งของขอบรูปภาพ
              child: Image.asset(
                'images/BGLocation1.jpg', // ใช้โลโก้เป็นรูปภาพเริ่มต้น
              ),
            ),
          )
        : Container(
            margin: EdgeInsets.fromLTRB(20, 20, 20, 0), // กำหนดระยะขอบของรูปภาพ
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                  0), // กำหนดความโค้งของขอบรูปภาพ (0 = ไม่โค้ง)
              child: Image.file(
                _imageFile!, // แสดงรูปภาพที่เลือก
                fit: BoxFit.cover, // กำหนดรูปแบบการแสดงผลของรูปภาพ
              ),
            ),
          );
  }

  // ฟังก์ชันแสดง dialog ข้อผิดพลาด
  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ข้อผิดพลาด'), // กำหนดหัวข้อของ dialog
          content: Text(message), // กำหนดเนื้อหาของ dialog
          actions: <Widget>[
            TextButton(
              child: Text('ตกลง'), // ข้อความของปุ่มตกลง
              onPressed: () {
                Navigator.of(context).pop(); // ปิด dialog เมื่อกดปุ่ม
              },
            ),
          ],
        );
      },
    );
  }

  // ฟังก์ชันแสดง dialog เลือกประเภทสนาม
  void _showTypeDialog() {
    // เลือกประเภทสนาม
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('เลือกประเภทสนาม'), // กำหนดหัวข้อของ dialog
          content: SingleChildScrollView(
            child: ListBody(
              children: fieldTypes.map((type) {
                return CheckboxListTile(
                  title: Text(type['type_name']), // แสดงชื่อประเภทสนาม
                  value: selectedTypes.contains(
                      type['type_name']), // กำหนดสถานะการเลือกของ Checkbox
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedTypes.add(type[
                            'type_name']); // เพิ่มประเภทสนามใน selectedTypes ถ้าเลือก
                      } else {
                        selectedTypes.remove(type[
                            'type_name']); // ลบประเภทสนามจาก selectedTypes ถ้าไม่เลือก
                      }
                    });
                    Navigator.of(context).pop(); // ปิด dialog ปัจจุบัน
                    _showTypeDialog(); // เปิด dialog ใหม่เพื่อรีเฟรช
                  },
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('ตกลง'), // ข้อความของปุ่มตกลง
              onPressed: () {
                Navigator.of(context).pop(); // ปิด dialog เมื่อกดปุ่มตกลง
                typeController.text = selectedTypes
                    .join(', '); // แสดงประเภทที่เลือกในฟิลด์ประเภทสนาม
              },
            ),
          ],
        );
      },
    );
  }

  // วิดเจ็ตปุ่มเพิ่มสถานที่
  Widget buttonAddLocation(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 20, 20, 0), // กำหนดระยะขอบของปุ่ม
      child: ElevatedButton(
        child: Text("เพิ่มสถานที่",
            style: TextStyle(
                color: Colors.white)), // ข้อความของปุ่มและกำหนดสีของข้อความ
        style: ElevatedButton.styleFrom(
          backgroundColor:
              Color.fromARGB(255, 255, 0, 0), // กำหนดสีพื้นหลังของปุ่ม
          padding: EdgeInsets.symmetric(vertical: 15), // กำหนด padding ของปุ่ม
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40), // กำหนดความโค้งของขอบปุ่ม
          ),
        ),
        onPressed: () {
          if (input1.text.isEmpty || input2.text.isEmpty) {
            showErrorDialog(
                context, 'กรุณากรอกข้อมูล'); // แสดงข้อผิดพลาดเมื่อข้อมูลไม่ครบ
          } else if (_imageFile == null) {
            showErrorDialog(context,
                'กรุณาเลือกรูปภาพ'); // แสดงข้อผิดพลาดเมื่อไม่ได้เลือกรูปภาพ
          } else if (_selectedLocation == null) {
            showErrorDialog(context,
                'กรุณาเลือกสถานที่บนแผนที่'); // แสดงข้อผิดพลาดเมื่อไม่ได้เลือกสถานที่บนแผนที่
          } else {
            functionAddLocation(); // เรียกใช้ฟังก์ชัน functionAddLocation เพื่อเพิ่มสถานที่
          }
        },
      ),
    );
  }

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
            days.add('7');
            break;
        }
      }
    });
    return days.join(','); // แปลง List เป็น String โดยแยกด้วย ','
  }

  // ฟังก์ชันเพิ่มสถานที่
  Future<void> functionAddLocation() async {
    if (_imageFile == null || _selectedLocation == null) {
      print(
          "No image or location selected."); // แสดงข้อความเมื่อไม่ได้เลือกรูปภาพหรือสถานที่
      return;
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse(
          "http://10.0.2.2/flutter_webservice/get_AddLocation.php"), // กำหนด URL สำหรับส่งคำขอ POST
    );

    request.fields['location_name'] =
        input1.text; // ใส่ชื่อสถานที่ลงในฟิลด์ 'location_name'
    request.fields['location_time'] =
        input2.text; // ใส่เวลาเปิด-ปิดลงในฟิลด์ 'location_time'

    // เพิ่มฟิลด์สำหรับวันที่ที่เลือก
    request.fields['location_day'] = getSelectedDays(); // ส่งวันที่ที่เลือกไปยังฐานข้อมูล

    request.fields['types_id'] = json.encode(selectedTypes.map((type) {
      final typeMap = fieldTypes.firstWhere((element) =>
          element['type_name'] == type); // ค้นหา type_id ที่ตรงกับ type_name
      return typeMap['type_id']; // ส่งคืน type_id สำหรับแต่ละประเภท
    }).toList());

    request.fields['latitude'] =
        _selectedLocation!.latitude.toString(); // ใส่ค่าละติจูด
    request.fields['longitude'] =
        _selectedLocation!.longitude.toString(); // ใส่ค่าลองจิจูด

    request.files.add(await http.MultipartFile.fromPath(
        'image', _imageFile!.path)); // เพิ่มไฟล์รูปภาพในฟิลด์ 'image'

    print(
        'Fields : ${request.fields}'); // แสดงข้อมูลฟิลด์ทั้งหมดที่ถูกส่งไปในคำขอ HTTP
    print(
        'File : ${_imageFile!.path}'); // แสดง path ของไฟล์รูปภาพที่ถูกส่งไปในคำขอ HTTP

    try {
      var response = await request.send(); // ส่งคำขอไปยังเซิร์ฟเวอร์

      if (response.statusCode == 200) {
        var responseData = await response.stream
            .bytesToString(); // รับข้อมูลการตอบกลับจากเซิร์ฟเวอร์
        var responseDataJson =
            json.decode(responseData); // ถอดรหัสข้อมูลการตอบกลับเป็น JSON
        print(
            'Response Data Addlocation : $responseData'); // แสดงข้อมูลการตอบกลับ

        // รับ location_id จากการตอบกลับ
        String locationId = responseDataJson['location_id']
            .toString(); // แปลงเป็น String ก่อนใช้งาน

        // ส่งคำขอเพื่อรับสถานะของสถานที่ที่เพิ่งเพิ่ม
        var statusResponse = await http.post(
          Uri.parse(
              'http://10.0.2.2/flutter_webservice/get_Chackapprove.php'), // URL สำหรับตรวจสอบสถานะการอนุมัติ
          body: {
            'location_id': locationId, // ส่ง location_id เพื่อเช็คสถานะ
          },
        );

        if (statusResponse.statusCode == 200) {
          var statusData =
              json.decode(statusResponse.body); // ถอดรหัสข้อมูลสถานะจาก JSON
          String status =
              statusData['status'].toString(); // แปลงสถานะเป็น String

          print('สถานะการอนุมัติ: $status'); // แสดงสถานะการอนุมัติ

          // แสดง dialog แจ้งเตือนเมื่อเพิ่มสถานที่สำเร็จ
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('สำเร็จ'), // หัวข้อของ dialog
                content: Text(
                    'เพิ่มสถานที่สำเร็จแล้ว สถานะการอนุมัติ: $status'), // เนื้อหาของ dialog
                actions: <Widget>[
                  TextButton(
                    child: Text('ตกลง'), // ข้อความของปุ่มใน dialog
                    onPressed: () {
                      Navigator.of(context).pop(); // ปิด dialog เมื่อกดปุ่มตกลง
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Homepage(
                                jwt: widget.jwt)), // กลับไปที่หน้า Homepage
                      );
                    },
                  ),
                ],
              );
            },
          );
        } else {
          print(
              "Failed to get status: ${statusResponse.statusCode}"); // แสดงข้อความเมื่อการตรวจสอบสถานะล้มเหลว
        }
      } else {
        print(
            "Request failed with status: ${response.statusCode}"); // แสดงข้อความเมื่อคำขอล้มเหลว
      }
    } catch (error) {
      print(
          "Error: $error"); // แสดงข้อความเมื่อเกิดข้อผิดพลาดในกระบวนการส่งคำขอ
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Color.fromARGB(255, 222, 222, 222), // กำหนดสีพื้นหลังของหน้า
      appBar: AppBar(
        title: Text("เพิ่มสถานที่",
            style: TextStyle(
                color: const Color.fromARGB(
                    255, 255, 255, 255))), // หัวข้อของ AppBar
        leading: backButton(), // ปุ่มกลับไปที่หน้าก่อนหน้า
        backgroundColor:
            Color.fromARGB(255, 255, 0, 0), // กำหนดสีพื้นหลังของ AppBar
      ),
      body: SafeArea(
        child: ListView(
          children: [
            namelocation(), // วิดเจ็ตฟิลด์ชื่อสถานที่
            Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 20), // เพิ่มระยะห่างระหว่างข้อความและขอบ
              child: Center(
                // จัดให้อยู่ตรงกลาง
                child: Text(
                  'กรุณาเลือกวันทำการ',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black), // กำหนดสไตล์ของข้อความ
                ),
              ),
            ),
            daySelection(),
            time(), // วิดเจ็ตฟิลด์เวลาเปิด-ปิด
            type(), // วิดเจ็ตฟิลด์ประเภทสนาม
            addImage(), // วิดเจ็ตปุ่มเลือกรูปภาพ
            imageDisplay(), // วิดเจ็ตแสดงรูปภาพที่เลือกหรือโลโก้
            searchlocation(), // วิดเจ็ตปุ่มค้นหาสถานที่
            map(), // วิดเจ็ตแผนที่
            buttonAddLocation(context), // วิดเจ็ตปุ่มเพิ่มสถานที่
            SizedBox(height: 20) // เพิ่มช่องว่างด้านล่าง
          ],
        ),
      ),
    );
  }
}
