// lib/presentation/widgets/client_form_dialog.dart
import 'package:flutter/material.dart';
import '../../data/models/client.dart';

class ClientFormDialog extends StatefulWidget {
  final Client? client;
  final Function(Client) onSave;

  const ClientFormDialog({super.key, this.client, required this.onSave});

  @override
  State<ClientFormDialog> createState() => _ClientFormDialogState();
}

class _ClientFormDialogState extends State<ClientFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController;
  late TextEditingController _emailController;
  late TextEditingController _telephoneController;
  late TextEditingController _adresseController;
  late TextEditingController _villeController;
  late TextEditingController _codePostalController;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.client?.nom ?? '');
    _emailController = TextEditingController(text: widget.client?.email ?? '');
    _telephoneController = TextEditingController(text: widget.client?.telephone ?? '');
    _adresseController = TextEditingController(text: widget.client?.adresse ?? '');
    _villeController = TextEditingController(text: widget.client?.ville ?? '');
    _codePostalController = TextEditingController(text: widget.client?.codePostal ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.client == null ? 'Nouveau client' : 'Modifier client'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nomController,
                  decoration: const InputDecoration(labelText: 'Nom *', border: OutlineInputBorder()),
                  validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _telephoneController,
                  decoration: const InputDecoration(labelText: 'Téléphone', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _adresseController,
                  decoration: const InputDecoration(labelText: 'Adresse', border: OutlineInputBorder()),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _codePostalController,
                        decoration: const InputDecoration(labelText: 'Code postal', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _villeController,
                        decoration: const InputDecoration(labelText: 'Ville', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final client = Client(
        id: widget.client?.id,
        nom: _nomController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        telephone: _telephoneController.text.isEmpty ? null : _telephoneController.text,
        adresse: _adresseController.text.isEmpty ? null : _adresseController.text,
        ville: _villeController.text.isEmpty ? null : _villeController.text,
        codePostal: _codePostalController.text.isEmpty ? null : _codePostalController.text,
      );
      widget.onSave(client);
      Navigator.pop(context);
    }
  }
}