import 'package:flutter/material.dart';

class chat extends StatefulWidget {
  const chat({super.key, required activity});

  @override
  State<chat> createState() => _chatState();
}

class _chatState extends State<chat> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Stack(
        children: [
          Scaffold(
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
            appBar: AppBar(
              title: Text("หน้าแชท"),
              leading: IconButton(
                icon:
                    Icon(Icons.arrow_back, color: Color.fromARGB(255, 0, 0, 0)),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
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
