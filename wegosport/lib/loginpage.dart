import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:wegosport/hompage.dart';

class LoginFacebook extends StatefulWidget {
  const LoginFacebook({Key? key}) : super(key: key);
  

  @override
  State<LoginFacebook> createState() => _LoginFacebookState();
}

class _LoginFacebookState extends State<LoginFacebook> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ElevatedButton(
            onPressed: () {
              facebookLogin();
            },
            child: Text('Login With Facebook'),),
        ),
      ),
    );
  }



  facebookLogin() async {
    try {
      final result =
      await FacebookAuth.i.login(permissions: ['public_profile', 'email']);
      if (result.status == LoginStatus.success) {
        final userData = await FacebookAuth.i.getUserData();
        print('facebook_login_data:-');
        print(userData);
        Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage(image: userData['picture']['data']['url'],
          name: userData['name'], email: userData['email'])));
      }
    } catch (error) {
      print(error);
    }
  }

}