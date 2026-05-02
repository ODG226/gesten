// lib/presentation/controllers/sale_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/sale.dart';
import '../../data/repositories/sale_repository.dart';
import 'auth_controller.dart';

final saleRepositoryProvider = Provider((ref) {
  return SaleRepository(ref.watch(localDatabaseProvider));
});

final salesProvider = FutureProvider<List<Sale>>((ref) async {
  return ref.watch(saleRepositoryProvider).getSales();
});

class SaleNotifier extends StateNotifier<AsyncValue<List<Sale>>> {
  final SaleRepository _repository;

  SaleNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadSales();
  }

  Future<void> loadSales() async {
    state = const AsyncValue.loading();
    try {
      final sales = await _repository.getSales();
      state = AsyncValue.data(sales);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addSale(Sale sale) async {
    await _repository.createSale(sale);
    await loadSales();
  }

  Future<void> updateSale(Sale sale) async {
    await _repository.updateSale(sale);
    await loadSales();
  }

  Future<void> deleteSale(int id) async {
    await _repository.deleteSale(id);
    await loadSales();
  }
}

final saleNotifierProvider = StateNotifierProvider<SaleNotifier, AsyncValue<List<Sale>>>((ref) {
  return SaleNotifier(ref.watch(saleRepositoryProvider));
});