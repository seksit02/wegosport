import 'package:flutter/material.dart';
import 'package:wegosport/hompage.dart';
import 'package:wegosport/login.dart';
import 'package:wegosport/loginpage.dart';
import 'package:wegosport/hompage.dart';

void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:LoginFacebook(),
    );
  }
}