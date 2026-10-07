import 'package:flutter/material.dart';
import 'package:waylo/components/inputField.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo', 
      home: Scaffold(
        body: Center(
          child: Inputfield(
            label: 'Username',
            controller: TextEditingController(),
          ),
        ),
      )
    );
  } 
}
