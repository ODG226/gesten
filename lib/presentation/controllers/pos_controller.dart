// lib/presentation/controllers/pos_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product.dart';

class CartItemModel {
  final Product product;
  final int quantity;
  double get total => product.prixVente * quantity;

  CartItemModel({required this.product, required this.quantity});
}

class CartNotifier extends StateNotifier<List<CartItemModel>> {
  CartNotifier() : super([]);

  void addItem(Product product) {
    final index = state.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      state = [
        ...state.sublist(0, index),
        CartItemModel(product: product, quantity: state[index].quantity + 1),
        ...state.sublist(index + 1),
      ];
    } else {
      state = [...state, CartItemModel(product: product, quantity: 1)];
    }
  }

  void incrementItem(Product product) {
    final index = state.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      state = [
        ...state.sublist(0, index),
        CartItemModel(product: product, quantity: state[index].quantity + 1),
        ...state.sublist(index + 1),
      ];
    }
  }

  void decrementItem(Product product) {
    final index = state.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      if (state[index].quantity > 1) {
        state = [
          ...state.sublist(0, index),
          CartItemModel(product: product, quantity: state[index].quantity - 1),
          ...state.sublist(index + 1),
        ];
      } else {
        removeItem(product);
      }
    }
  }

  void removeItem(Product product) {
    state = state.where((item) => item.product.id != product.id).toList();
  }

  void clear() {
    state = [];
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItemModel>>((ref) {
  return CartNotifier();
});

final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0.0, (sum, item) => sum + item.total);
});