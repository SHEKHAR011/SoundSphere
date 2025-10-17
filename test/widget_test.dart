// SoundSphere Music App Widget Test
//
// Tests the basic functionality of the music app interface

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soundsphere/main.dart';

void main() {
  testWidgets('SoundSphere app launches and shows splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app shows SoundSphere title
    expect(find.text('SoundSphere'), findsOneWidget);

    // Verify splash screen elements are present
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    
    // Wait for splash screen animation
    await tester.pumpAndSettle(const Duration(seconds: 4));
    
    // After splash, should navigate to login/home
    // (Note: Exact navigation depends on user session state)
  });

  testWidgets('App has proper theme and styling', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MyApp());

    // Verify MaterialApp is properly configured
    final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
    expect(materialApp.title, 'SoundSphere');
    expect(materialApp.debugShowCheckedModeBanner, false);
  });
}
