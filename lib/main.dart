import 'package:flutter/material.dart';
import 'package:waylo/components/selectionButton.dart';

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
          child: SelectionButton(
              options: [
              'Japan',
              'Indonesia',
              'South Korea',
              'Thailand',
              'China',
            ],
            onChanged: (value) {
              print(value);
            },
          ),
        ),
      )
    );
  } 
}
