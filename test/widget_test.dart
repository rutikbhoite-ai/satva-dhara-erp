// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility from the flutter_test package.

import 'package:flutter_test/flutter_test.dart';

import 'package:satva_dhara_erp/main.dart';

void main() {
  testWidgets(
    'shows a startup error when Firebase is not initialized',
    (tester) async {
      await tester.pumpWidget(
        const SatvaDharaApp(
          firebaseInitialized: false,
        ),
      );

      expect(
        find.textContaining(
          'App सुरू करता आली नाही',
        ),
        findsOneWidget,
      );
    },
  );
}