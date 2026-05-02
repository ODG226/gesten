// lib/presentation/controllers/user_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user.dart';
import '../../data/repositories/user_repository.dart';
import 'auth_controller.dart';

final usersProvider = FutureProvider<List<User>>((ref) async {
  return ref.watch(userRepositoryProvider).getAllUsers();
});

class UserNotifier extends StateNotifier<AsyncValue<List<User>>> {
  final UserRepository _repository;

  UserNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadUsers();
  }

  Future<void> loadUsers() async {
    state = const AsyncValue.loading();
    try {
      final users = await _repository.getAllUsers();
      state = AsyncValue.data(users);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addUser(String email, String password, String nom, String role) async {
    await _repository.createUser(email, password, nom, role);
    await loadUsers();
  }

  Future<void> updateUser(int id, String nom, String role) async {
    await _repository.updateUser(id, nom, role);
    await loadUsers();
  }

  Future<void> deleteUser(int id) async {
    await _repository.deleteUser(id);
    await loadUsers();
  }
}

final userNotifierProvider = StateNotifierProvider<UserNotifier, AsyncValue<List<User>>>((ref) {
  return UserNotifier(ref.watch(userRepositoryProvider));
});
