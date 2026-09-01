// Smoke test for RuralCare app infrastructure.
// NOTE: Full widget tests that exercise Firebase auth require a real device or
// integration test environment where Firebase.initializeApp() has been called.
// This test verifies the theme and Material app structure without Firebase.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruralcare/core/theme/app_theme.dart';
import 'package:ruralcare/core/theme/app_colors.dart';

void main() {
  testWidgets('RuralCare theme smoke test', (WidgetTester tester) async {
    // Pump a standalone MaterialApp using the RuralCare theme —
    // verifies theme tokens load without crashing.
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          backgroundColor: AppColors.surface,
          body: const Center(child: Text('RuralCare')),
        ),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('RuralCare'), findsOneWidget);
  });

  testWidgets('ProviderScope wraps correctly', (WidgetTester tester) async {
    // Verify Riverpod ProviderScope integrates without errors.
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: Center(child: Text('OK'))),
        ),
      ),
    );

    expect(find.byType(ProviderScope), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);
  });
}
