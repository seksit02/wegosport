import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<Activity> activities = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchActivities();
  }

  Future<void> fetchActivities() async {
    final response = await http.get(Uri.parse(
        'http://10.0.2.2/flutter_webservice/get_ShowDataActivity.php'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        activities =
            data.map((activity) => Activity.fromJson(activity)).toList();
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load activities');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: activities.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: Image.network(
                      'http://10.0.2.2/flutter_webservice/upload/d5b3dcd9e9770986d05f2d78c0d22479.jpg',
                      fit: BoxFit.cover,
                    ),
                    title: Text(activities[index].activityName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(activities[index].activityDetails),
                        Text('Date: ${activities[index].activityDate}'),
                        Text('Location: ${activities[index].locationName}'),
                        Text('Time: ${activities[index].locationTime}'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class Activity {
  final String activityId;
  final String activityName;
  final String activityDetails;
  final String activityDate;
  final String locationName;
  final String locationTime;
  final String location_photo;
  final List<Member> members;
  final List<SportType> sportTypes;

  Activity({
    required this.activityId,
    required this.activityName,
    required this.activityDetails,
    required this.activityDate,
    required this.locationName,
    required this.locationTime,
    required this.location_photo,
    required this.members,
    required this.sportTypes,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    var membersList = json['members'] as List;
    List<Member> members = membersList.map((i) => Member.fromJson(i)).toList();

    var sportTypesList = json['sport_types'] as List;
    List<SportType> sportTypes =
        sportTypesList.map((i) => SportType.fromJson(i)).toList();

    return Activity(
      activityId: json['activity_id'],
      activityName: json['activity_name'],
      activityDetails: json['activity_details'],
      activityDate: json['activity_date'],
      locationName: json['location_name'],
      locationTime: json['location_time'],
      location_photo: json['location_photo'],
      members: members,
      sportTypes: sportTypes,
    );
  }
}

class Member {
  final String userId;
  final String userName;
  final String userEmail;
  final int userAge;

  Member({
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userAge,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      userId: json['user_id'],
      userName: json['user_name'],
      userEmail: json['user_email'],
      userAge: json['user_age'],
    );
  }
}

class SportType {
  dynamic typeId;
  dynamic typeName;

  SportType({
    required this.typeId,
    required this.typeName,
  });

  factory SportType.fromJson(Map<String, dynamic> json) {
    return SportType(
      typeId: json['type_id'],
      typeName: json['type_name'],
    );
  }
}
