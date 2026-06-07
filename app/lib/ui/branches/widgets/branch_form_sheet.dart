import 'package:flutter/material.dart';

import '../../../domain/models/branch.dart';

class BranchFormSheet extends StatefulWidget {
  const BranchFormSheet({required this.onSubmit, this.branch, super.key});

  final Branch? branch;
  final Future<String?> Function(String name, String? address) onSubmit;

  @override
  State<BranchFormSheet> createState() => _BranchFormSheetState();
}

class _BranchFormSheetState extends State<BranchFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  bool _isSubmitting = false;
  String? _submitError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.branch?.name ?? '');
    _addressController = TextEditingController(
      text: widget.branch?.address ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.branch == null
                        ? 'Nueva sucursal'
                        : 'Editar sucursal',
                    style: const TextStyle(
                      color: Color(0xFFF8FAFC),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _isSubmitting
                      ? null
                      : () => Navigator.of(context).pop(false),
                  icon: const Icon(Icons.close),
                  color: const Color(0xFFA9B4BE),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              enabled: !_isSubmitting,
              decoration: const InputDecoration(
                labelText: 'Nombre de la sucursal',
                hintText: 'Sucursal Central',
              ),
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre de la sucursal es requerido.';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _addressController,
              enabled: !_isSubmitting,
              decoration: const InputDecoration(
                labelText: 'Dirección',
                hintText: 'Dirección',
              ),
              minLines: 2,
              maxLines: 4,
            ),
            if (_submitError != null) ...[
              const SizedBox(height: 14),
              Text(
                _submitError!,
                style: const TextStyle(color: Color(0xFFF87171)),
              ),
            ],
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_isSubmitting ? 'Guardando...' : 'Guardar sucursal'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    final error = await widget.onSubmit(
      _nameController.text,
      _addressController.text,
    );

    if (!mounted) return;

    if (error == null) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _isSubmitting = false;
      _submitError = error;
    });
  }
}
