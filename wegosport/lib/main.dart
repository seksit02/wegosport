import 'package:flutter/material.dart';
import 'package:wegosport/activity.dart';
import 'package:wegosport/addlocation.dart';
import 'package:wegosport/chat.dart';
import 'package:wegosport/createactivity.dart';
import 'package:wegosport/Addinformation.dart';
import 'package:wegosport/forgetpassword.dart';
import 'package:wegosport/groupchat.dart';
import 'package:wegosport/homepage.dart';
import 'package:wegosport/login.dart';
import 'package:wegosport/profile.dart';
import 'package:wegosport/test.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ActivityCard(),
    );
  }
}
