import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/public_asset_url_resolver.dart';
import '../../data/providers/product_providers.dart';
import '../../domain/models/product.dart';
import 'product_form_controller.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({this.productId, this.product, super.key});

  final String? productId;
  final Product? product;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  late final ProductFormController _controller;
  final _name = TextEditingController();
  final _sku = TextEditingController();
  final _barcode = TextEditingController();
  final _category = TextEditingController();
  final _description = TextEditingController();
  final _minStock = TextEditingController();
  Product? _syncedProduct;

  @override
  void initState() {
    super.initState();
    _controller = ProductFormController(
      ref.read(productRepositoryProvider),
      ref.read(productLookupRepositoryProvider),
      ref.read(productImagePickerProvider),
      productId: widget.productId,
      product: widget.product,
    )..addListener(_onStateChanged);
    _syncProduct();
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onStateChanged)
      ..dispose();
    _name.dispose();
    _sku.dispose();
    _barcode.dispose();
    _category.dispose();
    _description.dispose();
    _minStock.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (!mounted) return;
    _syncFormValues();
    setState(() {});
  }

  void _syncProduct() {
    final product = _controller.state.originalProduct;
    if (product == null || identical(product, _syncedProduct)) return;
    _syncedProduct = product;
    _name.text = product.name;
    _sku.text = product.sku;
    _barcode.text = product.barcode ?? '';
    _category.text = product.category;
    _description.text = product.description ?? '';
    _minStock.text = product.minStock.toString();
  }

  void _syncFormValues() {
    _syncProduct();
    final state = _controller.state;
    _syncText(_name, state.name);
    _syncText(_sku, state.sku);
    _syncText(_barcode, state.barcode);
    _syncText(_category, state.category);
    _syncText(_description, state.description);
    _syncText(_minStock, state.minStock);
  }

  void _syncText(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    final outcome = await _controller.save();
    if (!mounted || outcome != ProductFormSaveOutcome.success) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_Colors.gradientStart, _Colors.gradientEnd],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _FormHeader(
                title: state.isEditing ? 'Editar producto' : 'Nuevo producto',
                onBack: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: state.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: _Colors.accent),
                      )
                    : state.isEditing && state.originalProduct == null
                    ? _LoadError(
                        message:
                            state.generalError ??
                            'No se pudo cargar el producto.',
                        onRetry: _controller.initialize,
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (!state.isEditing) ...[
                              _LookupSection(
                                state: state,
                                barcodeController: _barcode,
                                onBarcodeChanged: _controller.setBarcode,
                                onLookup: _controller.lookupByBarcode,
                              ),
                              const SizedBox(height: 24),
                            ],
                            _ImageField(
                              state: state,
                              resolver: ref.watch(
                                publicAssetUrlResolverProvider,
                              ),
                              onSelect: _controller.selectImage,
                              onRemove: _controller.removeImage,
                            ),
                            const SizedBox(height: 24),
                            if (state.generalError != null) ...[
                              _FormMessage(
                                message: state.generalError!,
                                danger: !state.imageUploadFailed,
                              ),
                              const SizedBox(height: 16),
                            ],
                            _FormField(
                              fieldKey: const Key('product-name-field'),
                              label: 'Nombre del producto *',
                              placeholder: 'Ej: Arroz 1kg',
                              controller: _name,
                              error: state.fieldErrors['name'],
                              onChanged: _controller.setName,
                            ),
                            const SizedBox(height: 24),
                            _FormField(
                              fieldKey: const Key('product-sku-field'),
                              label: 'SKU *',
                              placeholder: 'Ej: ARR-001',
                              controller: _sku,
                              error: state.fieldErrors['sku'],
                              onChanged: _controller.setSku,
                            ),
                            const SizedBox(height: 24),
                            if (state.isEditing) ...[
                              _FormField(
                                fieldKey: const Key('product-barcode-field'),
                                label: 'Código de barras',
                                placeholder: 'Ej: 744100100001',
                                controller: _barcode,
                                error: state.fieldErrors['barcode'],
                                keyboardType: TextInputType.number,
                                onChanged: _controller.setBarcode,
                              ),
                              const SizedBox(height: 24),
                            ],
                            _FormField(
                              fieldKey: const Key('product-category-field'),
                              label: 'Categoría *',
                              placeholder: 'Ej: Granos básicos',
                              controller: _category,
                              error: state.fieldErrors['category'],
                              onChanged: _controller.setCategory,
                            ),
                            const SizedBox(height: 24),
                            _FormField(
                              fieldKey: const Key('product-description-field'),
                              label: 'Descripción',
                              placeholder: 'Descripción del producto',
                              controller: _description,
                              error: state.fieldErrors['description'],
                              maxLines: 3,
                              onChanged: _controller.setDescription,
                            ),
                            const SizedBox(height: 24),
                            _FormField(
                              fieldKey: const Key('product-min-stock-field'),
                              label: 'Stock mínimo *',
                              placeholder: '10',
                              controller: _minStock,
                              error: state.fieldErrors['minStock'],
                              keyboardType: TextInputType.number,
                              onChanged: _controller.setMinStock,
                            ),
                            const SizedBox(height: 24),
                            const _StockNote(),
                            const SizedBox(height: 24),
                            _SaveButton(
                              editing: state.isEditing,
                              saving: state.isSaving,
                              uploading: state.isUploadingImage,
                              retryingUpload: state.imageUploadFailed,
                              onPressed: state.isBusy ? null : _save,
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LookupSection extends StatelessWidget {
  const _LookupSection({
    required this.state,
    required this.barcodeController,
    required this.onBarcodeChanged,
    required this.onLookup,
  });

  final ProductFormState state;
  final TextEditingController barcodeController;
  final ValueChanged<String> onBarcodeChanged;
  final VoidCallback onLookup;

  @override
  Widget build(BuildContext context) {
    final status = state.lookupStatus;
    final isSuccess = status == ProductLookupStatus.found;
    final isError =
        status == ProductLookupStatus.notFound ||
        status == ProductLookupStatus.error;
    final color = isSuccess
        ? _Colors.success
        : isError
        ? _Colors.warning
        : _Colors.accent;

    return Container(
      key: const Key('product-lookup-section'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _Colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _Colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Buscar por código de barras',
            style: TextStyle(
              color: _Colors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          _FormField(
            fieldKey: const Key('product-barcode-field'),
            label: 'Código de barras',
            placeholder: 'Ej: 3017624010701',
            controller: barcodeController,
            error: state.fieldErrors['barcode'],
            keyboardType: TextInputType.number,
            onChanged: onBarcodeChanged,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: OutlinedButton.icon(
              key: const Key('lookup-product-button'),
              onPressed: state.isLookingUp ? null : onLookup,
              icon: state.isLookingUp
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _Colors.textMuted,
                      ),
                    )
                  : const Icon(Icons.search, size: 18),
              label: Text(
                state.isLookingUp ? 'Buscando producto...' : 'Buscar producto',
              ),
            ),
          ),
          if (state.lookupMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              key: const Key('product-lookup-message'),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    state.lookupMessage!,
                    style: TextStyle(color: color, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FormHeader extends StatelessWidget {
  const _FormHeader({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      decoration: const BoxDecoration(
        color: _Colors.surface,
        border: Border(bottom: BorderSide(color: _Colors.border)),
      ),
      child: Row(
        children: [
          InkWell(
            key: const Key('product-form-back-button'),
            onTap: onBack,
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.arrow_back,
                color: _Colors.textPrimary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              color: _Colors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: _Colors.danger, size: 36),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _Colors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const Key('retry-load-product-button'),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageField extends StatelessWidget {
  const _ImageField({
    required this.state,
    required this.resolver,
    required this.onSelect,
    required this.onRemove,
  });

  final ProductFormState state;
  final PublicAssetUrlResolver resolver;
  final VoidCallback onSelect;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final selected = state.selectedImage;
    final existingUrl = resolver.resolve(state.existingImageUrl);
    final hasImage = selected != null || existingUrl != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Imagen del producto',
          style: TextStyle(color: _Colors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 8),
        InkWell(
          key: const Key('product-image-picker'),
          onTap: state.isBusy ? null : onSelect,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _Colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _Colors.border,
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (selected != null)
                  Image.memory(
                    selected.bytes,
                    key: const Key('selected-product-image-preview'),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const _ImagePlaceholder(),
                  )
                else if (existingUrl != null)
                  Image.network(
                    existingUrl,
                    key: const Key('existing-product-image-preview'),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const _ImagePlaceholder(),
                  )
                else
                  const _ImagePlaceholder(),
                if (hasImage)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: InkWell(
                      key: const Key('remove-product-image-button'),
                      onTap: state.isBusy ? null : onRemove,
                      borderRadius: BorderRadius.circular(8),
                      child: const ColoredBox(
                        color: _Colors.surface,
                        child: Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(
                            Icons.close,
                            color: _Colors.textPrimary,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.file_upload_outlined, color: _Colors.textMuted, size: 32),
        SizedBox(height: 8),
        Text(
          'Toca para seleccionar imagen',
          style: TextStyle(color: _Colors.textSecondary, fontSize: 14),
        ),
      ],
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.fieldKey,
    required this.label,
    required this.placeholder,
    required this.controller,
    required this.onChanged,
    this.error,
    this.keyboardType,
    this.maxLines = 1,
  });

  final Key fieldKey;
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? error;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _Colors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          key: fieldKey,
          controller: controller,
          onChanged: onChanged,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(color: _Colors.textPrimary, fontSize: 15),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(color: _Colors.textMuted, fontSize: 15),
            filled: true,
            fillColor: _Colors.surfaceSoft,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: maxLines == 1 ? 0 : 12,
            ),
            constraints: maxLines == 1
                ? const BoxConstraints(minHeight: 44, maxHeight: 44)
                : null,
            enabledBorder: _border(error),
            focusedBorder: _border(error, focused: true),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 6),
          Text(
            error!,
            key: Key('${fieldKey.toString()}-error'),
            style: const TextStyle(color: _Colors.danger, fontSize: 12),
          ),
        ],
      ],
    );
  }

  OutlineInputBorder _border(String? error, {bool focused = false}) {
    final color = error != null
        ? _Colors.danger
        : focused
        ? _Colors.accent
        : _Colors.border;
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color),
    );
  }
}

class _StockNote extends StatelessWidget {
  const _StockNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _Colors.accentSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _Colors.accentBorder),
      ),
      child: const Text.rich(
        TextSpan(
          style: TextStyle(color: _Colors.textSecondary, fontSize: 12),
          children: [
            TextSpan(
              text: 'Nota: ',
              style: TextStyle(
                color: _Colors.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text:
                  'El stock se actualiza únicamente mediante movimientos de '
                  'inventario. No se puede editar directamente.',
            ),
          ],
        ),
      ),
    );
  }
}

class _FormMessage extends StatelessWidget {
  const _FormMessage({required this.message, required this.danger});

  final String message;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? _Colors.danger : _Colors.warning;
    return Container(
      key: const Key('product-form-general-error'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      child: Text(message, style: TextStyle(color: color, fontSize: 12)),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.editing,
    required this.saving,
    required this.uploading,
    required this.retryingUpload,
    required this.onPressed,
  });

  final bool editing;
  final bool saving;
  final bool uploading;
  final bool retryingUpload;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final loading = saving || uploading;
    final label = uploading
        ? 'Subiendo imagen...'
        : saving
        ? 'Guardando...'
        : retryingUpload
        ? 'Reintentar subida de imagen'
        : editing
        ? 'Guardar cambios'
        : 'Crear producto';
    return SizedBox(
      height: 44,
      child: FilledButton(
        key: const Key('save-product-button'),
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: _Colors.accent,
          disabledBackgroundColor: _Colors.surfaceSoft,
          foregroundColor: _Colors.background,
          disabledForegroundColor: _Colors.textMuted,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading) ...[
              const SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _Colors.textMuted,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(label),
          ],
        ),
      ),
    );
  }
}

abstract final class _Colors {
  static const gradientStart = Color(0xFF0A0D0F);
  static const gradientEnd = Color(0xFF111A20);
  static const background = Color(0xFF0C1013);
  static const surface = Color(0xFF12181C);
  static const surfaceSoft = Color(0xFF1F2A30);
  static const textPrimary = Color(0xFFF8FAFC);
  static const textSecondary = Color(0xFFA9B4BE);
  static const textMuted = Color(0xFF6F7C86);
  static const border = Color(0x0FFFFFFF);
  static const accent = Color(0xFF14B8A6);
  static const accentSoft = Color(0x2414B8A6);
  static const accentBorder = Color(0x5214B8A6);
  static const danger = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);
  static const success = Color(0xFF22C55E);
}
