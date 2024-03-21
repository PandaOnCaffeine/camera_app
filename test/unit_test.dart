import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:camera_app/Services/api_auth_service.dart';
import 'package:localstorage/localstorage.dart';
import 'package:camera_app/main.dart';

// Mock ApiService
class MockApiAuthService extends Mock implements ApiAuthService {}

void main() {
  group('Api Auth', () {
    late ApiAuthService mockApiAuthService;
    final storage = LocalStorage('my_jwt_data.json');


    setUp(() {
      mockApiAuthService = MockApiAuthService();
    });

    testWidgets('Test Saving a JWT Token', (WidgetTester tester) async {

      // Call ApiAuth Login Method
      mockApiAuthService.login();

      // Verify that ApiAuth.Login Method is called once
      verify(mockApiAuthService.login()).called(1);

      // Get Jwt Token
      await storage.ready;
      final String jwt = await storage.getItem('jwt_key');

      // Expect jwt token is not null
      expect(jwt, isNotNull);
    });
  });
}
