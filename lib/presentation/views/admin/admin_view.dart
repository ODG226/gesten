// lib/presentation/views/admin/admin_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/user_controller.dart';

class AdminView extends ConsumerWidget {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);

    // Si l'utilisateur n'est pas admin, afficher une erreur
    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Administration')),
        body: const Center(
          child: Text('Accès refusé. Vous devez être administrateur.'),
        ),
      );
    }

    final usersAsync = ref.watch(usersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showUserDialog(context, ref),
            tooltip: 'Ajouter un utilisateur',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(usersProvider),
          ),
        ],
      ),
      body: usersAsync.when(
        data: (users) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gestion des utilisateurs',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: DataTable2(
                  columnSpacing: 12,
                  horizontalMargin: 12,
                  minWidth: 900,
                  columns: const [
                    DataColumn2(label: Text('Email'), size: ColumnSize.M),
                    DataColumn2(label: Text('Nom'), size: ColumnSize.L),
                    DataColumn2(label: Text('Rôle'), size: ColumnSize.S),
                    DataColumn2(label: Text('Actions'), size: ColumnSize.S),
                  ],
                  rows: const [],
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Erreur: $error')),
      ),
    );
  }

  void _showUserDialog(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final nomController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = 'user';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un utilisateur'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButton<String>(
                value: selectedRole,
                items: const [
                  DropdownMenuItem(value: 'user', child: Text('Utilisateur')),
                  DropdownMenuItem(value: 'admin', child: Text('Administrateur')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    selectedRole = value;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              if (emailController.text.isNotEmpty &&
                  nomController.text.isNotEmpty &&
                  passwordController.text.isNotEmpty) {
                ref.read(userRepositoryProvider).createUser(
                  emailController.text,
                  passwordController.text,
                  nomController.text,
                  selectedRole,
                );
                ref.invalidate(usersProvider);
                Navigator.pop(context);
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }
}
