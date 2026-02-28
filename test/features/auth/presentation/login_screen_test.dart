import 'package:assessment_flutter_interview/features/auth/auth_notifier.dart';
import 'package:assessment_flutter_interview/features/auth/presentation/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class MockAuthNotifier extends AsyncNotifier<void> implements AuthNotifier {
  @override
  Future<void> build() async {}

  @override
  Future<User?> login(String email, String password) async => null;

  @override
  Future<User?> signUp(String email, String password) async => null;

  @override
  Future<void> logout() async {}

  @override
  Future<void> updateDisplayName(String displayName) async {}
}

void main() {
  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        authNotifierProvider.overrideWith(() => MockAuthNotifier()),
      ],
      child: const MaterialApp(
        home: LoginScreen(),
      ),
    );
  }

  testWidgets('LoginScreen shows validation errors for empty fields',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(); // Start the microtask cycle
    await tester.pumpAndSettle(); // Settle the AsyncNotifier

    // Find and tap the Log In button without entering any text
    final loginButton = find.descendant(
        of: find.byType(FilledButton), matching: find.text('Log In'));
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    // Verify that the error messages appear
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
  });

  testWidgets(
      'LoginScreen shows validation errors for invalid email and short password',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();
    await tester.pumpAndSettle();

    // Find input fields
    final emailField = find.widgetWithText(TextFormField, 'Email Address');
    final passwordField = find.widgetWithText(TextFormField, 'Password');

    // Enter invalid formatted email and short password
    await tester.enterText(emailField, 'invalid-email');
    await tester.enterText(passwordField, '12345');

    // Tap the login button
    final loginButton = find.descendant(
        of: find.byType(FilledButton), matching: find.text('Log In'));
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    // Verify specific error messages for invalid formats
    expect(find.text('Please enter a valid email'), findsOneWidget);
    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
  });

  testWidgets('LoginScreen toggles between Login and Sign Up',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();
    await tester.pumpAndSettle();

    // Starts in Log In mode
    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(
        find.descendant(
            of: find.byType(FilledButton), matching: find.text('Log In')),
        findsOneWidget);

    // Tap the toggle button at the bottom
    final toggleButton = find.byType(TextButton);
    await tester.tap(toggleButton);
    await tester.pumpAndSettle();

    // Verify it switches to Sign Up mode
    expect(find.text('Create an Account'), findsOneWidget);
    expect(
        find.descendant(
            of: find.byType(FilledButton), matching: find.text('Sign Up')),
        findsOneWidget);
  });
}
