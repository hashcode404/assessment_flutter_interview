import 'package:assessment_flutter_interview/features/auth/presentation/login_screen.dart';
import 'package:assessment_flutter_interview/features/home/presentation/main_navigation_screen.dart';
import 'package:assessment_flutter_interview/features/auth/auth_notifier.dart';
import 'package:assessment_flutter_interview/firebase_options.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:assessment_flutter_interview/core/constants/enums.dart';
import 'package:assessment_flutter_interview/features/projects/domain/project_data_model.dart';
import 'package:assessment_flutter_interview/features/task/domain/task_data_model.dart';
import 'package:assessment_flutter_interview/core/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(TaskTypeAdapter());
  Hive.registerAdapter(ProjectDataModelAdapter());
  Hive.registerAdapter(TaskDataModelAdapter());

  // Initialize Notifications safely via globally registered handler
  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const AuthChecker(),
      ),
    );
  }
}

class AuthChecker extends ConsumerWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return const MainNavigationScreen();
        }
        return const LoginScreen();
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, trace) => Scaffold(
        body: Center(
          child: Text('Error: $e'),
        ),
      ),
    );
  }
}
