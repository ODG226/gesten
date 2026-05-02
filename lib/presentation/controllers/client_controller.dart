// lib/presentation/controllers/client_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/client.dart';
import '../../data/repositories/client_repository.dart';
import 'auth_controller.dart';

final clientRepositoryProvider = Provider((ref) {
  return ClientRepository(ref.watch(localDatabaseProvider));
});

final clientsProvider = FutureProvider<List<Client>>((ref) async {
  return ref.watch(clientRepositoryProvider).getClients();
});

class ClientNotifier extends StateNotifier<AsyncValue<List<Client>>> {
  final ClientRepository _repository;

  ClientNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadClients();
  }

  Future<void> loadClients() async {
    state = const AsyncValue.loading();
    try {
      final clients = await _repository.getClients();
      state = AsyncValue.data(clients);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addClient(Client client) async {
    await _repository.createClient(client);
    await loadClients();
  }

  Future<void> updateClient(Client client) async {
    await _repository.updateClient(client);
    await loadClients();
  }

  Future<void> deleteClient(int id) async {
    await _repository.deleteClient(id);
    await loadClients();
  }
}

final clientNotifierProvider = StateNotifierProvider<ClientNotifier, AsyncValue<List<Client>>>((ref) {
  return ClientNotifier(ref.watch(clientRepositoryProvider));
});