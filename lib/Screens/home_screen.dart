import 'package:flutter/material.dart';

/// The home screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('This is the HomeScreen'),
      ),
    );
  }
}