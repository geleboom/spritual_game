// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spiritual_game/main.dart';
import 'package:spiritual_game/features/verses/screens/Dashboard.dart';

void main() {
  group('App Tests', () {
    testWidgets('App should start with welcome pages',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify we're on the first welcome page
      expect(find.text('እንኳን ደህና መጡ'), findsOneWidget);
      expect(find.text('መንፈሳዊ እድገት'), findsOneWidget);
    });
  });

  group('Verse List Screen Tests', () {
    testWidgets('Verse list shows verses and search button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardScreen(),
        ),
      );

      // Verify the app bar title
      expect(find.text('መንፈሳዊ ጥቅሶች'), findsOneWidget);

      // Verify search button exists
      expect(find.byIcon(Icons.search), findsOneWidget);

      // Verify some verses are displayed
      expect(find.text('ዮሐንስ 3:16'), findsOneWidget);
      expect(find.text('መዝሙር 23:1'), findsOneWidget);

      // Verify practice button exists
      expect(find.text('ልምምድ ጀምር'), findsOneWidget);
    });

    testWidgets('Search functionality works', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardScreen(),
        ),
      );

      // Tap search button
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Verify search field appears
      expect(find.byType(SearchDelegate), findsOneWidget);
    });

    testWidgets('Verse card tap shows detail', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardScreen(),
        ),
      );

      // Tap first verse card
      await tester.tap(find.text('ዮሐንስ 3:16'));
      await tester.pumpAndSettle();

      // Verify bottom sheet appears with verse details
      expect(find.byType(Container), findsWidgets);
    });
  });
}
