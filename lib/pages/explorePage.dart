import 'package:flutter/material.dart';
import 'package:waylo/layouts/homeLayout.dart';

class Explorepage extends StatelessWidget {
  const Explorepage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Homelayout(
      greeting:  "Let's Find a Place", 
      title: "Explore",
      subtitle: "Discover your next destination", 
    );
  }
}