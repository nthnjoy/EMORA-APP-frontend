
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:emolens_app/screens/login_page.dart';

void main() {
  testWidgets('Login page shows validation when fields are empty', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginPage(),
      ),
    );

    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    expect(find.text('Username & Password wajib diisi'), findsOneWidget);
  });
}
