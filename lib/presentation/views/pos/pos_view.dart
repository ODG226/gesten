// lib/presentation/views/pos/pos_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../controllers/product_controller.dart';
import '../../controllers/pos_controller.dart';
import '../../controllers/sale_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../../data/models/product.dart';
import '../../../data/models/sale.dart';

class PosView extends ConsumerStatefulWidget {
  const PosView({super.key});

  @override
  ConsumerState<PosView> createState() => _PosViewState();
}

class _PosViewState extends ConsumerState<PosView> {
  final _searchController = TextEditingController();
  String _paymentMethod = 'especes';
  final _receivedController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    final cart = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Point de Vente')),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Rechercher un produit',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      ),
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                Expanded(
                  child: productsAsync.when(
                    data: (products) {
                      final filtered = products.where((p) =>
                        p.nom.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                        p.reference.toLowerCase().contains(_searchController.text.toLowerCase())
                      ).toList();
                      
                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.5,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final product = filtered[index];
                          return _ProductCard(
                            product: product,
                            onTap: () => ref.read(cartProvider.notifier).addItem(product),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const Center(child: Text('Erreur')),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 400,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(left: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue,
                  child: const Row(
                    children: [
                      Icon(Icons.shopping_cart, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Panier', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Expanded(
                  child: cart.isEmpty
                      ? const Center(child: Text('Panier vide'))
                      : ListView.builder(
                          itemCount: cart.length,
                          itemBuilder: (context, index) {
                            final item = cart[index];
                            return _CartItem(
                              item: item,
                              onIncrement: () => ref.read(cartProvider.notifier).incrementItem(item.product),
                              onDecrement: () => ref.read(cartProvider.notifier).decrementItem(item.product),
                              onRemove: () => ref.read(cartProvider.notifier).removeItem(item.product),
                            );
                          },
                        ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Colors.grey[300]!)),
                  ),
                  child: Column(
                    children: [
                      const Divider(height: 0),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('${total.toStringAsFixed(2)} €', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _paymentMethod,
                        decoration: const InputDecoration(
                          labelText: 'Mode de paiement',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'especes', child: Text('Espèces')),
                          DropdownMenuItem(value: 'carte', child: Text('Carte bancaire')),
                          DropdownMenuItem(value: 'cheque', child: Text('Chèque')),
                        ],
                        onChanged: (value) => setState(() => _paymentMethod = value!),
                      ),
                      const SizedBox(height: 16),
                      if (_paymentMethod == 'especes')
                        TextField(
                          controller: _receivedController,
                          decoration: const InputDecoration(
                            labelText: 'Montant reçu',
                            border: OutlineInputBorder(),
                            suffixText: '€',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: cart.isEmpty ? null : () => _processSale(context, ref, total),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('VALIDER LA VENTE', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: cart.isEmpty ? null : () => ref.read(cartProvider.notifier).clear(),
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
                          child: const Text('ANNULER'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _processSale(BuildContext context, WidgetRef ref, double total) async {
    final received = _paymentMethod == 'especes' ? double.tryParse(_receivedController.text) ?? 0 : total;
    
    if (_paymentMethod == 'especes' && received < total) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Montant insuffisant')),
      );
      return;
    }

    final change = received - total;
    final cart = ref.read(cartProvider);
    final currentUser = ref.read(currentUserProvider);
    
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur: Utilisateur non authentifié')),
      );
      return;
    }

    // Créer les lignes de vente
    final saleLines = cart.map((item) {
      return SaleLine(
        productId: item.product.id!,
        quantite: item.quantity,
        prixUnitaire: item.product.prixVente,
        montant: item.total,
      );
    }).toList();

    // Créer la vente
    final sale = Sale(
      numero: 'V${DateTime.now().millisecondsSinceEpoch}',
      clientId: null,
      montantTtc: total,
      montantRecu: received,
      montantRendu: change,
      modePaiement: _paymentMethod.toUpperCase(),
      userId: currentUser.id,
      createdAt: DateTime.now(),
      lignes: saleLines,
    );

    // Sauvegarder la vente
    try {
      await ref.read(saleNotifierProvider.notifier).addSale(sale);
      
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('✅ Vente enregistrée'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('N° Vente: ${sale.numero}'),
                const SizedBox(height: 12),
                Text('Total: ${total.toStringAsFixed(2)} €', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                if (_paymentMethod == 'especes') ...[
                  const SizedBox(height: 8),
                  Text('Reçu: ${received.toStringAsFixed(2)} €'),
                  Text('Rendu: ${change.toStringAsFixed(2)} €', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ref.read(cartProvider.notifier).clear();
                  _receivedController.clear();
                },
                child: const Text('Non'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _printReceipt(sale);
                },
                icon: const Icon(Icons.print),
                label: const Text('Oui, imprimer'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la sauvegarde: $e')),
        );
      }
    }
  }

  void _printReceipt(Sale sale) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(16),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    'gESTeN',
                    style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text('Reçu de Vente', style: pw.TextStyle(fontSize: 14)),
                ],
              ),
            ),
            pw.SizedBox(height: 16),
            pw.Divider(),
            pw.SizedBox(height: 12),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('N° Vente: ${sale.numero}'),
                pw.Text(DateFormat('dd/MM/yyyy HH:mm').format(sale.createdAt)),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Text('Mode paiement: ${sale.modePaiement}'),
            pw.SizedBox(height: 16),
            pw.Divider(),
            pw.SizedBox(height: 12),
            pw.TableHelper.fromTextArray(
              headers: ['Article', 'Qté', 'Prix', 'Total'],
              data: sale.lignes.map((line) => [
                'Produit ${line.productId}',
                line.quantite.toString(),
                '${line.prixUnitaire.toStringAsFixed(2)} €',
                '${line.montant.toStringAsFixed(2)} €',
              ]).toList(),
              cellStyle: pw.TextStyle(fontSize: 9),
              headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 16),
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Total:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                pw.Text('${sale.montantTtc.toStringAsFixed(2)} €', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
              ],
            ),
            if (sale.montantRendu > 0) ...[
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Monnaie rendue:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  pw.Text('${sale.montantRendu.toStringAsFixed(2)} €', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.green)),
                ],
              ),
            ],
            pw.SizedBox(height: 16),
            pw.Divider(),
            pw.SizedBox(height: 16),
            pw.Center(
              child: pw.Text(
                'Merci de votre achat!',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
            ),
            pw.Center(
              child: pw.Text(
                DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()),
                style: pw.TextStyle(fontSize: 8, color: PdfColors.grey),
              ),
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(product.nom, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${product.prixVente.toStringAsFixed(2)} €', style: const TextStyle(fontSize: 18, color: Colors.blue)),
                  Text('Stock: ${product.stockActuel}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartItem extends StatelessWidget {
  final CartItemModel item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const _CartItem({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.product.nom, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('${item.product.prixVente.toStringAsFixed(2)} €', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: onDecrement,
                  iconSize: 20,
                ),
                Text('${item.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: onIncrement,
                  iconSize: 20,
                ),
              ],
            ),
            SizedBox(
              width: 80,
              child: Text('${item.total.toStringAsFixed(2)} €', style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onRemove,
              iconSize: 20,
            ),
          ],
        ),
      ),
    );
  }
}