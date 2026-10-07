import 'package:flutter/material.dart';
import 'package:waylo/components/favoriteButton.dart';
import 'package:waylo/theme/appColors.dart';

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
          child: FavoriteButton(
  onChanged: (isFavorite) {
    print('Favorite: $isFavorite');
  },
),
        ),
      )
    );
  } 
}
