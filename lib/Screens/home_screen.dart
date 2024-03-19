// Flutter Imports
import 'package:flutter/material.dart';

// My Services
import '../Services/api_auth_service.dart';

/// My Home screen
/// The first thing you on the app
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.apiAuth});

  // Repository
  final ApiAuthService apiAuth;
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
                apiAuth.login();
                debugPrint("Login Clicked");
              },
            )
          ],
        ),
      ),
    );
  }
}
