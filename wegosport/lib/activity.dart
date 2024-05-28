import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:wegosport/login.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('หน้ากิจกรรมที่เข้าร่วม'),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 100),
            ElevatedButton(
                onPressed: () {
                  FacebookAuth.i.logOut();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginPage()));
                },
                child: Text('Logout')),
          ],
        ),
      ),
    );
  }
}
