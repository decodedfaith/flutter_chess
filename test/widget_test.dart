import 'package:flutter/material.dart';
import 'package:flutter_chess/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Test case 1: Check if the app builds without errors
  testWidgets('App builds without errors', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(ChessGameApp());

    // Check if the app's basic components are displayed
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  // Test case 2: Check if the chessboard grid is displayed correctly
  testWidgets('Chessboard grid displays 8x8 squares', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(ChessGameApp());

    // Verify that the grid has 64 squares (8x8)
    expect(find.byType(Container), findsAtLeastNWidgets(64));

    // Verify that the chessboard square colors alternate
    final firstSquare = tester.widget<Container>(find.byType(Container).first);
    final lastSquare = tester.widget<Container>(find.byType(Container).last);

    // Checking the color (this is just a basic check for alternating color logic)
    expect(firstSquare.color, isNot(equals(lastSquare.color)));
  });

  // Test case 3: Check if tapping the floating action button (reset) works
  testWidgets('FloatingActionButton triggers reset', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(ChessGameApp());

    // Tap the floating action button
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();

    // Check if a reset-related change happens (e.g., printing reset, state change)
    // You can replace this with actual logic if needed, for example:
    // expect(someStateVar, equals(expectedValue));
  });
}
