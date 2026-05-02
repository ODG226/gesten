// lib/presentation/views/products/products_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../controllers/product_controller.dart';
import '../../widgets/product_form_dialog.dart';
import '../../../data/models/product.dart';

class ProductsView extends ConsumerWidget {
  const ProductsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(productNotifierProvider.notifier).loadProducts(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: productsAsync.when(
        data: (products) => _ProductsTable(products: products),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Erreur: $error')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Nouveau produit'),
      ),
    );
  }

  void _showProductDialog(BuildContext context, WidgetRef ref, [Product? product]) {
    showDialog(
      context: context,
      builder: (context) => ProductFormDialog(
        product: product,
        onSave: (product) async {
          if (product.id == null) {
            await ref.read(productNotifierProvider.notifier).addProduct(product);
          } else {
            await ref.read(productNotifierProvider.notifier).updateProduct(product);
          }
        },
      ),
    );
  }
}

class _ProductsTable extends ConsumerWidget {
  final List<Product> products;

  const _ProductsTable({required this.products});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: DataTable2(
        columnSpacing: 12,
        horizontalMargin: 12,
        minWidth: 900,
        columns: const [
          DataColumn2(label: Text('Référence'), size: ColumnSize.S),
          DataColumn2(label: Text('Nom'), size: ColumnSize.L),
          DataColumn2(label: Text('Prix achat'), size: ColumnSize.S),
          DataColumn2(label: Text('Prix vente'), size: ColumnSize.S),
          DataColumn2(label: Text('Stock'), size: ColumnSize.S),
          DataColumn2(label: Text('Actions'), size: ColumnSize.S, numeric: true),
        ],
        rows: products.map((product) {
          return DataRow2(
            cells: [
              DataCell(Text(product.reference)),
              DataCell(Text(product.nom)),
              DataCell(Text('${product.prixAchat.toStringAsFixed(2)} €')),
              DataCell(Text('${product.prixVente.toStringAsFixed(2)} €')),
              DataCell(
                Row(
                  children: [
                    Text('${product.stockActuel}'),
                    if (product.stockActuel <= product.stockMin)
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(Icons.warning, color: Colors.orange, size: 16),
                      ),
                  ],
                ),
              ),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _showProductDialog(context, ref, product),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: () => _deleteProduct(context, ref, product),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showProductDialog(BuildContext context, WidgetRef ref, Product product) {
    showDialog(
      context: context,
      builder: (context) => ProductFormDialog(
        product: product,
        onSave: (updatedProduct) async {
          await ref.read(productNotifierProvider.notifier).updateProduct(updatedProduct);
        },
      ),
    );
  }

  void _deleteProduct(BuildContext context, WidgetRef ref, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer ${product.nom} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(productNotifierProvider.notifier).deleteProduct(product.id!);
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}