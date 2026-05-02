// lib/presentation/views/invoices/invoices_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
// ignore: unused_import
import 'package:intl/intl.dart';

class InvoicesView extends ConsumerWidget {
  const InvoicesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Factures'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: DataTable2(
          columnSpacing: 12,
          horizontalMargin: 12,
          minWidth: 1000,
          columns: const [
            DataColumn2(label: Text('N°'), size: ColumnSize.S),
            DataColumn2(label: Text('Date'), size: ColumnSize.M),
            DataColumn2(label: Text('Client'), size: ColumnSize.L),
            DataColumn2(label: Text('Montant TTC'), size: ColumnSize.S),
            DataColumn2(label: Text('Payé'), size: ColumnSize.S),
            DataColumn2(label: Text('Statut'), size: ColumnSize.S),
            DataColumn2(label: Text('Actions'), size: ColumnSize.S, numeric: true),
          ],
          rows: const [],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle facture'),
      ),
    );
  }
}