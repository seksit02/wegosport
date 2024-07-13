import 'package:flutter/material.dart';
import 'package:wegosport/activity.dart';
import 'package:wegosport/Addlocation.dart';
import 'package:wegosport/chat.dart';
import 'package:wegosport/Createactivity.dart';
import 'package:wegosport/Addinformation.dart';
import 'package:wegosport/forgetpassword.dart';
import 'package:wegosport/groupchat.dart';
import 'package:wegosport/Homepage.dart';
import 'package:wegosport/Login.dart';
import 'package:wegosport/Profile.dart';
import 'package:wegosport/test.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Homepage(),
      routes: {
        '/homepage': (context) => Homepage(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => UnknownPage());
      },
    );
  }
}

class UnknownPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Unknown Page'),
      ),
      body: Center(
        child: Text('This page does not exist!'),
      ),
    );
  }
}
