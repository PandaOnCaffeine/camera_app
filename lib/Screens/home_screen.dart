// Flutter Imports
import 'package:camera_app/Services/api_service.dart';
import 'package:flutter/material.dart';

/// My Home screen
/// The first thing you on the app
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.apiService});

  final ApiService apiService;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const Text('This is the HomeScreen'),
            FloatingActionButton(
              child: const Icon(Icons.login),
              onPressed: () {
                apiService.login();
                print("Login Clicked");
              },
            )
          ],
        ),
      ),
    );
  }
}
