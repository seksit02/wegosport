
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:wegosport/loginpage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, this.image, this.name, this.email}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
  final image;
  final name;
  final email;
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login TO Facebook'),
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginFacebook()));
                },
                child: Text('Logout')),
          ],
        ),
      ),
    );
  }
}