import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/auth_repository.dart';
import '../data_sources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User?> login(String email, String password) {
    return remoteDataSource.login(email, password);
  }

  @override
  Future<User?> signUp(String email, String password) {
    return remoteDataSource.signUp(email, password);
  }

  @override
  Future<void> logout() {
    return remoteDataSource.logout();
  }

  @override
  Future<void> updateDisplayName(String name) {
    return remoteDataSource.updateDisplayName(name);
  }

  @override
  Stream<User?> get authStateChanges => remoteDataSource.authStateChanges;

  @override
  User? get currentUser => remoteDataSource.currentUser;
}
