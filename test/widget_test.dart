import 'package:assessment_flutter_interview/features/auth/auth_notifier.dart';
import 'package:assessment_flutter_interview/main.dart';
import 'package:assessment_flutter_interview/features/auth/presentation/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  testWidgets('MyApp startup navigates based on mocked unauthenticated state',
      (WidgetTester tester) async {
    // Build our app and trigger a frame, mocking the auth provider
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value(null)),
          authNotifierProvider.overrideWith(() => MockAuthNotifier()),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pump();

    // Verify that without authenticated Stream, it lands back to the Login Screen directly.
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
