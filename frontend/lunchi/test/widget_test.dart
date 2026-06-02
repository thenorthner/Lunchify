import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lunchi/login_page.dart';

void main() {
  testWidgets('Login page displays correctly', (WidgetTester tester) async {
    // Load the LoginPage widget.
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    // Check if the title is shown
    expect(find.text('Login to Lunchify'), findsOneWidget);

    // Check if input fields are present
    expect(find.byType(TextField), findsNWidgets(3));

    // Check if Login button is present
    expect(find.text('Login'), findsOneWidget);
  });
}
