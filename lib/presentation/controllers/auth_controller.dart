// lib/presentation/controllers/auth_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user.dart';
import '../../data/repositories/user_repository.dart';
import '../../core/database/local_database.dart';

// Provider pour LocalDatabase
final localDatabaseProvider = Provider<LocalDatabase>((ref) {
  return LocalDatabase.instance;
});

// Provider pour UserRepository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final localDatabase = ref.watch(localDatabaseProvider);
  return UserRepository(localDatabase);
});

// Provider pour l'utilisateur actuellement connecté
final currentUserProvider = StateProvider<User?>((ref) => null);

// Future Provider pour la connexion
final loginProvider = FutureProvider.family<User?, (String, String)>((ref, params) async {
  final userRepository = ref.watch(userRepositoryProvider);
  final email = params.$1;
  final password = params.$2;
  
  final user = await userRepository.login(email, password);
  if (user != null) {
    ref.read(currentUserProvider.notifier).state = user;
  }
  return user;
});

// Provider pour la déconnexion
final logoutProvider = Provider<void Function()>((ref) {
  return () {
    ref.read(currentUserProvider.notifier).state = null;
  };
});

// Provider pour vérifier si l'utilisateur est admin
final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.isAdmin ?? false;
});
