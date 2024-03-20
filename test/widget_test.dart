import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:camera_app/main.dart';

// import 'package:camera_app/Screens/view_picture_screen.dart';

void main() {
  testWidgets('Burger menu test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Open the drawer
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    // Verify that the drawer contains the header with the text 'Drawer Header'
    expect(find.text('BurgerMenu:'), findsOneWidget);
  });
}
