import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Network Image Example'),
        ),
        body: Center(
          child: Image.network(
            'http://10.0.2.2/flutter_webservice/upload/d5b3dcd9e9770986d05f2d78c0d22479.jpg',
            errorBuilder: (BuildContext context, Object exception,
                StackTrace? stackTrace) {
              return Text('Failed to load image');
            },
          ),
        ),
      ),
    );
  }
}
