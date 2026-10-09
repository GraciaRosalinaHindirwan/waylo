import 'package:flutter/material.dart';
import 'package:waylo/components/favoriteCard.dart';
import 'package:waylo/dummy/favoriteDummy.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFFFF8E8),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: favoriteDummy.map((destination) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: FavoriteCard(
                    destination: destination,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}