import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noty_app/main.dart';
import 'package:noty_app/screens/splash.dart';


void main() {
  testWidgets('SplashScreen displays correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that SplashScreen is displayed.
    expect(find.byType(SplashScreen), findsOneWidget);
  });
}