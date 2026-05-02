// lib/presentation/widgets/product_form_dialog.dart
import 'package:flutter/material.dart';
import '../../data/models/product.dart';

class ProductFormDialog extends StatefulWidget {
  final Product? product;
  final Function(Product) onSave;

  const ProductFormDialog({super.key, this.product, required this.onSave});

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _referenceController;
  late TextEditingController _nomController;
  late TextEditingController _descriptionController;
  late TextEditingController _prixAchatController;
  late TextEditingController _prixVenteController;
  late TextEditingController _stockActuelController;
  late TextEditingController _stockMinController;

  @override
  void initState() {
    super.initState();
    _referenceController = TextEditingController(text: widget.product?.reference ?? '');
    _nomController = TextEditingController(text: widget.product?.nom ?? '');
    _descriptionController = TextEditingController(text: widget.product?.description ?? '');
    _prixAchatController = TextEditingController(text: widget.product?.prixAchat.toString() ?? '0');
    _prixVenteController = TextEditingController(text: widget.product?.prixVente.toString() ?? '0');
    _stockActuelController = TextEditingController(text: widget.product?.stockActuel.toString() ?? '0');
    _stockMinController = TextEditingController(text: widget.product?.stockMin.toString() ?? '0');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product == null ? 'Nouveau produit' : 'Modifier produit'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _referenceController,
                  decoration: const InputDecoration(labelText: 'Référence *', border: OutlineInputBorder()),
                  validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nomController,
                  decoration: const InputDecoration(labelText: 'Nom *', border: OutlineInputBorder()),
                  validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _prixAchatController,
                        decoration: const InputDecoration(labelText: 'Prix achat *', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _prixVenteController,
                        decoration: const InputDecoration(labelText: 'Prix vente *', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _stockActuelController,
                        decoration: const InputDecoration(labelText: 'Stock actuel', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _stockMinController,
                        decoration: const InputDecoration(labelText: 'Stock minimum', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
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
      final product = Product(
        id: widget.product?.id,
        reference: _referenceController.text,
        nom: _nomController.text,
        description: _descriptionController.text,
        prixAchat: double.parse(_prixAchatController.text),
        prixVente: double.parse(_prixVenteController.text),
        stockActuel: int.parse(_stockActuelController.text),
        stockMin: int.parse(_stockMinController.text),
      );
      widget.onSave(product);
      Navigator.pop(context);
    }
  }
}