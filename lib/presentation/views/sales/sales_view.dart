// lib/presentation/views/sales/sales_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../controllers/sale_controller.dart';

class SalesView extends ConsumerWidget {
  const SalesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesAsync = ref.watch(saleNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ventes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () => salesAsync.whenData((sales) => _exportToXl(sales)),
            tooltip: 'Exporter les ventes',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(salesProvider),
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: salesAsync.when(
        data: (sales) => Padding(
          padding: const EdgeInsets.all(16),
          child: DataTable2(
            columnSpacing: 12,
            horizontalMargin: 12,
            minWidth: 900,
            columns: const [
              DataColumn2(label: Text('N°'), size: ColumnSize.S),
              DataColumn2(label: Text('Date'), size: ColumnSize.M),
              DataColumn2(label: Text('Client'), size: ColumnSize.L),
              DataColumn2(label: Text('Montant'), size: ColumnSize.S),
              DataColumn2(label: Text('Paiement'), size: ColumnSize.S),
              DataColumn2(label: Text('Actions'), size: ColumnSize.S),
            ],
            rows: sales.map((sale) {
              return DataRow2(
                cells: [
                  DataCell(Text(sale.numero)),
                  DataCell(Text(DateFormat('dd/MM/yyyy HH:mm').format(sale.createdAt))),
                  DataCell(Text(sale.clientId?.toString() ?? 'Anonyme')),
                  DataCell(Text('${sale.montantTtc.toStringAsFixed(2)} €', style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(sale.modePaiement.toUpperCase())),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.print, size: 18),
                          onPressed: () => _printSale(context, sale),
                          tooltip: 'Imprimer',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 18),
                          onPressed: () => _showDeleteDialog(context, ref, sale.id!),
                          tooltip: 'Supprimer',
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Erreur: $error')),
      ),
    );
  }

  void _exportToXl(List<dynamic> sales) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Rapport des Ventes',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Généré le: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
            style: pw.TextStyle(fontSize: 10, color: PdfColor.fromHex('#666666')),
          ),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: ['N°', 'Date', 'Client', 'Montant', 'Paiement'],
            data: sales.map((sale) => [
              sale.numero,
              DateFormat('dd/MM/yyyy HH:mm').format(sale.createdAt),
              sale.clientId?.toString() ?? 'Anonyme',
              '${sale.montantTtc.toStringAsFixed(2)} €',
              sale.modePaiement,
            ]).toList(),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerStyle: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(color: PdfColor(0, 0, 0.5)),
          ),
          pw.SizedBox(height: 20),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Total: ${sales.fold<double>(0.0, (sum, sale) => sum + sale.montantTtc).toStringAsFixed(2)} €',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
    );
  }

  void _printSale(BuildContext context, dynamic sale) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Facture de Vente',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text('N° Facture: ${sale.numero}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.Text('Date: ${DateFormat('dd/MM/yyyy HH:mm').format(sale.createdAt)}'),
            pw.SizedBox(height: 20),
            pw.Text('Client: ${sale.clientId ?? "Anonyme"}'),
            pw.Text('Mode de paiement: ${sale.modePaiement}'),
            pw.SizedBox(height: 30),
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Montant HT', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('${sale.montantTtc.toStringAsFixed(2)} €', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.SizedBox(height: 5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Montant TTC', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                pw.Text('${sale.montantTtc.toStringAsFixed(2)} €', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
              ],
            ),
            pw.SizedBox(height: 5),
            if (sale.montantRendu > 0) pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Monnaie rendue: ${sale.montantRendu.toStringAsFixed(2)} €'),
              ],
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la vente'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette vente?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              ref.read(saleNotifierProvider.notifier).deleteSale(id);
              Navigator.pop(context);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}