import 'dart:async';
import 'package:assessment_flutter_interview/features/auth/auth_notifier.dart';
import 'package:assessment_flutter_interview/features/projects/data/repositories/project_repository_impl.dart';
import 'package:assessment_flutter_interview/features/task/data/repositories/task_repository_impl.dart';
import 'package:assessment_flutter_interview/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUser extends Mock implements User {
  @override
  String get uid => 'test_uid';
  @override
  String? get displayName => 'Test User';
}

final authStateController = StreamController<User?>.broadcast();

class MockAuthNotifier extends AsyncNotifier<void> implements AuthNotifier {
  @override
  Future<void> build() async {}

  @override
  Future<User?> login(String email, String password) async {
    final user = MockUser();
    authStateController.add(user);
    return user;
  }

  @override
  Future<User?> signUp(String email, String password) async {
    final user = MockUser();
    authStateController.add(user);
    return user;
  }

  @override
  Future<void> logout() async {
    authStateController.add(null);
  }

  @override
  Future<void> updateDisplayName(String displayName) async {}
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    authStateController.add(null); // start logged out
  });

  testWidgets('app end-to-end flow: login, create project',
      (WidgetTester tester) async {
    // We launch the app with mocked Auth providers. We let Projects/Tasks
    // use Hive (local) and Mock the Remote part by throwing or returning empty
    // but the simplest is just let it throw and fallback to offline cache!

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => authStateController.stream),
          authNotifierProvider.overrideWith(() => MockAuthNotifier()),
        ],
        child: const MyApp(),
      ),
    );

    // Initial load: settle animations
    await tester.pumpAndSettle();
    // Verify we are on Login Screen
    expect(find.text('Welcome Back!'), findsOneWidget);

    // Enter email and password
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email Address'), 'test@test.com');
    await tester.pump();
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), '123456');
    await tester.pump();

    // Tap "Log In" button
    await tester.tap(find.descendant(
        of: find.byType(FilledButton), matching: find.text('Log In')));

    // Settling triggers the AuthNotifier login, which adds to stream, triggering AuthChecker navigation!
    await tester.pumpAndSettle();

    // Wait and verify we landed on the Projects screen
    expect(find.text('Projects'), findsOneWidget);

    // Tap on 'New Project' FAB
    final newProjectFab =
        find.widgetWithText(FloatingActionButton, 'New Project');
    expect(newProjectFab, findsOneWidget);
    await tester.tap(newProjectFab);
    await tester.pumpAndSettle();

    // Create a new project filling the BottomSheet
    expect(find.text('New Project'),
        findsWidgets); // Contains title of bottom sheet
    await tester.enterText(
        find.widgetWithText(TextField, 'Project Name'), 'Integration Project');
    await tester.pump();
    await tester.enterText(find.widgetWithText(TextField, 'Description'),
        'Integration Description');
    await tester.pump();

    // Save project
    await tester.tap(find.widgetWithText(FilledButton, 'Create Project'));
    await tester.pumpAndSettle();

    // Verify project appears in the ListView
    expect(find.text('Integration Project'), findsOneWidget);
    expect(find.text('Integration Description'), findsOneWidget);
  });
}
