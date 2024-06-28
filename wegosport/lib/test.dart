import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ActivityCard extends StatefulWidget {
  @override
  _ActivityCardState createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard> {
  List<dynamic> activities = [];

  @override
  void initState() {
    super.initState();
    fetchActivities();
  }

  Future<void> fetchActivities() async {
    final response = await http.get(Uri.parse(
        'http://10.0.2.2/flutter_webservice/get_ShowDataActivity.php'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        activities = data;
      });
    } else {
      throw Exception('Failed to load activities');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activities'),
      ),
      body: activities.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                return ActivityCardItem(activity: activity);
              },
            ),
    );
  }
}

class ActivityCardItem extends StatelessWidget {
  final dynamic activity;

  ActivityCardItem({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tag Row
            Row(
              children: [
                TagWidget(text: 'ตีกัน'),
                TagWidget(text: 'สนามกลาง'),
                TagWidget(text: 'ก๊วน'),
              ],
            ),
            SizedBox(height: 8),
            // Date and Time
            Text(
              activity['activity_date'] ?? '',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            // Activity Title
            Text(
              activity['activity_name'] ?? '',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 4),
            // Location
            Text(
              activity['location_name'] ?? '',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            // Members Row
            Row(
              children: [
                MemberAvatar(imageUrl: 'https://via.placeholder.com/50'),
                MemberAvatar(imageUrl: 'https://via.placeholder.com/50'),
                MemberAvatar(imageUrl: 'https://via.placeholder.com/50'),
                Spacer(),
                // Member Count
                Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 4),
                    Text('${activity['members'].length}'),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            // Attendance
            Text(
              '${activity['members'].length}/99 จะไป',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text('วันและเวลาสะดวกวันไหนคุยได้ครับ'),
            SizedBox(height: 8),
            // Activity Image
            Image.network('https://via.placeholder.com/150'),
          ],
        ),
      ),
    );
  }
}

class TagWidget extends StatelessWidget {
  final String text;

  TagWidget({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.yellow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text),
    );
  }
}

class MemberAvatar extends StatelessWidget {
  final String imageUrl;

  MemberAvatar({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      child: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
    );
  }
}
