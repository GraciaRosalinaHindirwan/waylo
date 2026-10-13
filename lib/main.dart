import 'package:flutter/material.dart';
import 'package:waylo/models/user.dart';
import 'package:waylo/pages/home.dart';
import 'package:waylo/repositories/user_repository_impl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<User?>(
        future: UserRepositoryImpl().getUserByUsername('test'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text('Error: ${snapshot.error}'),
              ),
            );
          }

          final user = snapshot.data;

          if (user == null) {
            return const Scaffold(
              body: Center(child: Text('User tidak ditemukan')),
            );
          }

          return HomePage(user: user);
        },
      ),
    );
  }
}