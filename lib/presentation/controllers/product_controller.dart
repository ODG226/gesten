// lib/presentation/controllers/product_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';
import 'auth_controller.dart';

final productRepositoryProvider = Provider((ref) {
  return ProductRepository(ref.watch(localDatabaseProvider));
});

final productsProvider = FutureProvider<List<Product>>((ref) async {
  return ref.watch(productRepositoryProvider).getProducts();
});

class ProductNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final ProductRepository _repository;

  ProductNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadProducts();
  }

  Future<void> loadProducts() async {
    state = const AsyncValue.loading();
    try {
      final products = await _repository.getProducts();
      state = AsyncValue.data(products);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addProduct(Product product) async {
    await _repository.createProduct(product);
    await loadProducts();
  }

  Future<void> updateProduct(Product product) async {
    await _repository.updateProduct(product);
    await loadProducts();
  }

  Future<void> deleteProduct(int id) async {
    await _repository.deleteProduct(id);
    await loadProducts();
  }
}

final productNotifierProvider = StateNotifierProvider<ProductNotifier, AsyncValue<List<Product>>>((ref) {
  return ProductNotifier(ref.watch(productRepositoryProvider));
});