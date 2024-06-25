import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Addinformation extends StatefulWidget {
  @override
  _AddinformationState createState() => _AddinformationState();
}

class _AddinformationState extends State<Addinformation> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController ageController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  void register() async {
    if (_formKey.currentState!.validate()) {
      var response = await http.post(
        Uri.parse('http://yourdomain.com/get_Register.php'),
        body: {
          'username': usernameController.text,
          'email': emailController.text,
          'password': passwordController.text,
          'age': ageController.text,
        },
      );
      if (response.statusCode == 200) {
        // Handle success
      } else {
        // Handle error
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value!.isEmpty ||
                      value.length < 6 ||
                      !RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
                    return 'Please enter a valid username (at least 6 characters, letters and numbers only)';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value!.isEmpty ||
                      !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty ||
                      value.length < 6 ||
                      !RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
                    return 'Please enter a valid password (at least 6 characters, letters and numbers only)';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: ageController,
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty || !RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Please enter a valid age';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: register,
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
