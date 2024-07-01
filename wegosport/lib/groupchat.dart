import 'package:flutter/material.dart';

class groupchat extends StatefulWidget {
  const groupchat({super.key});

  @override
  State<groupchat> createState() => _groupchatState();
}

class _groupchatState extends State<groupchat> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Stack(
        children: [
          Scaffold(
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
            appBar: AppBar(
              title: Text("หน้ากลุ่มแชท"),
            ),
            body: SafeArea(
              child: ListView(
                children: [
                  Center(
                      child:
                          Column(mainAxisSize: MainAxisSize.max, children: [])),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
