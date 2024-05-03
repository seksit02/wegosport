import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:wegosport/login.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({Key? key, this.image, this.name, this.email})
      : super(key: key);

  @override
  State<ActivityPage> createState() => _ActivityPageState();
  final image;
  final name;
  final email;
}

class _ActivityPageState extends State<ActivityPage> {
  @override
   Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('หน้ากิจกรรม'),
      ),
      body: Center(
        child: Column(
          children: [
            Image.network(widget.image, height: 200, width: 200,),
            Text(widget.name),
            Text(widget.email),
            SizedBox(height: 100),
            ElevatedButton(
                onPressed: (){
                  FacebookAuth.i.logOut();
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                },
                child: Text('Logout')),
          ],
        ),
      ),
    );
  }
}
