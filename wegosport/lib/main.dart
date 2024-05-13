import 'package:flutter/material.dart';
import 'package:wegosport/editinformation.dart';
import 'package:wegosport/forgetpassword.dart';
import 'package:wegosport/homepage.dart';
import 'package:wegosport/login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: homepage(),
    );
  }
}
