// lib/presentation/views/clients/clients_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../controllers/client_controller.dart';
import '../../widgets/client_form_dialog.dart';
import '../../../data/models/client.dart';

class ClientsView extends ConsumerWidget {
  const ClientsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsAsync = ref.watch(clientNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(clientNotifierProvider.notifier).loadClients(),
          ),
        ],
      ),
      body: clientsAsync.when(
        data: (clients) => _ClientsTable(clients: clients),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Erreur: $error')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showClientDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Nouveau client'),
      ),
    );
  }

  void _showClientDialog(BuildContext context, WidgetRef ref, [Client? client]) {
    showDialog(
      context: context,
      builder: (context) => ClientFormDialog(
        client: client,
        onSave: (client) async {
          if (client.id == null) {
            await ref.read(clientNotifierProvider.notifier).addClient(client);
          } else {
            await ref.read(clientNotifierProvider.notifier).updateClient(client);
          }
        },
      ),
    );
  }
}

class _ClientsTable extends ConsumerWidget {
  final List<Client> clients;

  const _ClientsTable({required this.clients});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: DataTable2(
        columnSpacing: 12,
        horizontalMargin: 12,
        minWidth: 800,
        columns: const [
          DataColumn2(label: Text('Nom'), size: ColumnSize.L),
          DataColumn2(label: Text('Email'), size: ColumnSize.L),
          DataColumn2(label: Text('Téléphone'), size: ColumnSize.M),
          DataColumn2(label: Text('Ville'), size: ColumnSize.M),
          DataColumn2(label: Text('Actions'), size: ColumnSize.S, numeric: true),
        ],
        rows: clients.map((client) {
          return DataRow2(
            cells: [
              DataCell(Text(client.nom)),
              DataCell(Text(client.email ?? '-')),
              DataCell(Text(client.telephone ?? '-')),
              DataCell(Text(client.ville ?? '-')),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _showClientDialog(context, ref, client),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: () => _deleteClient(context, ref, client),
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

  void _showClientDialog(BuildContext context, WidgetRef ref, Client client) {
    showDialog(
      context: context,
      builder: (context) => ClientFormDialog(
        client: client,
        onSave: (updatedClient) async {
          await ref.read(clientNotifierProvider.notifier).updateClient(updatedClient);
        },
      ),
    );
  }

  void _deleteClient(BuildContext context, WidgetRef ref, Client client) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer ${client.nom} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(clientNotifierProvider.notifier).deleteClient(client.id!);
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