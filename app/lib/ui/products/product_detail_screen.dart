import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/errors/app_exception.dart';
import '../../core/result/app_result.dart';
import '../../data/providers/product_providers.dart';
import '../../domain/models/product.dart';
import '../../navigation/routes.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({required this.productId, super.key});

  final String productId;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  Product? _product;
  AppException? _error;
  bool _isLoading = true;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final result = await ref
        .read(productRepositoryProvider)
        .getProduct(widget.productId);
    if (!mounted) return;
    result.when(
      success: (product) => setState(() {
        _product = product;
        _isLoading = false;
      }),
      failure: (error) => setState(() {
        _error = error;
        _isLoading = false;
      }),
    );
  }

  void _pop() => context.pop(_changed);

  Future<void> _edit() async {
    final saved = await context.push<bool>(
      AppRoutes.productEdit(widget.productId),
    );
    if (saved != true) return;
    _changed = true;
    await _load();
  }

  Future<void> _deactivate() async {
    final product = _product;
    if (product == null || !product.isActive) return;

    final deactivated = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _DeactivateProductDialog(
        productName: product.name,
        onDeactivate: () =>
            ref.read(productRepositoryProvider).deactivateProduct(product.id),
      ),
    );
    if (!mounted || deactivated != true) return;

    setState(() {
      _product = _inactiveCopy(product);
      _changed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _pop();
      },
      child: Scaffold(
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
                _DetailHeader(
                  onBack: _pop,
                  onEdit: _product == null ? null : _edit,
                ),
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _Colors.accent),
      );
    }
    if (_error != null || _product == null) {
      return _DetailError(message: _error?.message, onRetry: _load);
    }

    return _DetailContent(product: _product!, onDeactivate: _deactivate);
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.onBack, required this.onEdit});

  final VoidCallback onBack;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      decoration: const BoxDecoration(
        color: _Colors.surface,
        border: Border(bottom: BorderSide(color: _Colors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            key: const Key('product-detail-back-button'),
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: _Colors.textPrimary),
          ),
          const Expanded(
            child: Text(
              'Detalle de producto',
              style: TextStyle(
                color: _Colors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            key: const Key('edit-product-button'),
            onPressed: onEdit,
            style: IconButton.styleFrom(backgroundColor: _Colors.surfaceSoft),
            icon: const Icon(
              Icons.edit_outlined,
              color: _Colors.textPrimary,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailContent extends ConsumerWidget {
  const _DetailContent({required this.product, required this.onDeactivate});

  final Product product;
  final VoidCallback onDeactivate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl = ref
        .watch(publicAssetUrlResolverProvider)
        .resolve(product.imageUrl);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MainImage(productName: product.name, imageUrl: imageUrl),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        color: _Colors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.sku,
                      style: const TextStyle(
                        color: _Colors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(isActive: product.isActive),
            ],
          ),
          const SizedBox(height: 16),
          _InfoCard(product: product),
          const SizedBox(height: 20),
          const _PendingSection(
            title: 'Stock por sucursal',
            message: 'Stock por sucursal pendiente de integración',
          ),
          const SizedBox(height: 20),
          const _PendingSection(
            title: 'Últimos movimientos',
            message: 'Movimientos pendientes de integración',
          ),
          if (product.isActive) ...[
            const SizedBox(height: 24),
            OutlinedButton(
              key: const Key('deactivate-product-button'),
              onPressed: onDeactivate,
              style: OutlinedButton.styleFrom(
                foregroundColor: _Colors.danger,
                side: const BorderSide(color: _Colors.danger),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Desactivar producto'),
            ),
          ],
        ],
      ),
    );
  }
}

class _DeactivateProductDialog extends StatefulWidget {
  const _DeactivateProductDialog({
    required this.productName,
    required this.onDeactivate,
  });

  final String productName;
  final Future<AppResult<void>> Function() onDeactivate;

  @override
  State<_DeactivateProductDialog> createState() =>
      _DeactivateProductDialogState();
}

class _DeactivateProductDialogState extends State<_DeactivateProductDialog> {
  bool _isSubmitting = false;
  String? _error;

  Future<void> _submit() async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final result = await widget.onDeactivate();
    if (!mounted) return;
    final exception = result.exceptionOrNull;
    if (exception == null) {
      Navigator.pop(context, true);
      return;
    }

    setState(() {
      _isSubmitting = false;
      _error = exception.message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: const Key('deactivate-product-dialog'),
      backgroundColor: _Colors.surface,
      title: const Text(
        'Desactivar producto',
        style: TextStyle(color: _Colors.textPrimary),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.productName} quedará inactivo, pero no será eliminado.',
            style: const TextStyle(color: _Colors.textSecondary),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              'No se pudo desactivar: $_error',
              key: const Key('deactivate-product-error'),
              style: const TextStyle(color: _Colors.danger, fontSize: 12),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          key: const Key('cancel-deactivate-product'),
          onPressed: _isSubmitting ? null : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          key: const Key('confirm-deactivate-product'),
          onPressed: _isSubmitting ? null : _submit,
          style: FilledButton.styleFrom(backgroundColor: _Colors.danger),
          child: _isSubmitting
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _Colors.textPrimary,
                  ),
                )
              : const Text('Confirmar'),
        ),
      ],
    );
  }
}

Product _inactiveCopy(Product product) {
  return Product(
    id: product.id,
    name: product.name,
    sku: product.sku,
    barcode: product.barcode,
    category: product.category,
    description: product.description,
    imageUrl: product.imageUrl,
    minStock: product.minStock,
    isActive: false,
    createdAt: product.createdAt,
    updatedAt: product.updatedAt,
  );
}

class _MainImage extends StatelessWidget {
  const _MainImage({required this.productName, required this.imageUrl});

  final String productName;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    Widget placeholder() => const Center(
      key: Key('product-detail-image-placeholder'),
      child: Icon(Icons.inventory_2_outlined, color: _Colors.accent, size: 54),
    );

    return GestureDetector(
      key: const Key('product-detail-image-tap'),
      onTap: imageUrl == null
          ? null
          : () => _showImagePreview(context, productName, imageUrl!),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: ColoredBox(
          color: _Colors.surfaceSoft,
          child: SizedBox(
            height: 220,
            child: imageUrl == null
                ? placeholder()
                : Image.network(
                    key: const Key('product-detail-image'),
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => placeholder(),
                  ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Información del producto',
            style: TextStyle(
              color: _Colors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          _InfoRow(label: 'Categoría', value: product.category),
          _InfoRow(
            label: 'Código de barras',
            value: product.barcode ?? 'No disponible',
          ),
          _InfoRow(label: 'Stock mínimo', value: product.minStock.toString()),
          _InfoRow(
            label: 'Descripción',
            value: product.description ?? 'Sin descripción',
            last: true,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.last = false});

  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: last ? 0 : 12),
      margin: EdgeInsets.only(bottom: last ? 0 : 12),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: _Colors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(
              label,
              style: const TextStyle(color: _Colors.textMuted, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: _Colors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingSection extends StatelessWidget {
  const _PendingSection({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _Colors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        _Card(
          child: Row(
            children: [
              const Icon(
                Icons.schedule_outlined,
                color: _Colors.accent,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: _Colors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _Colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _Colors.border),
      ),
      child: child,
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? _Colors.success : _Colors.danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        isActive ? 'ACTIVO' : 'INACTIVO',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _DetailError extends StatelessWidget {
  const _DetailError({required this.message, required this.onRetry});

  final String? message;
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
            const Text(
              'No se pudo cargar el producto',
              style: TextStyle(color: _Colors.textPrimary),
            ),
            if (message != null) ...[
              const SizedBox(height: 4),
              Text(message!, style: const TextStyle(color: _Colors.textMuted)),
            ],
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}

Future<void> _showImagePreview(
  BuildContext context,
  String productName,
  String imageUrl,
) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black87,
    builder: (context) => Dialog(
      key: const Key('product-image-preview-dialog'),
      backgroundColor: _Colors.surface,
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    productName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _Colors.textPrimary),
                  ),
                ),
                IconButton(
                  key: const Key('close-product-image-preview'),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: _Colors.textSecondary),
                ),
              ],
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 480),
              child: Image.network(
                key: const Key('product-image-preview'),
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const SizedBox(
                  height: 240,
                  child: Center(
                    child: Text(
                      'No se pudo cargar la imagen',
                      style: TextStyle(color: _Colors.textMuted),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

abstract final class _Colors {
  static const gradientStart = Color(0xFF0A0D0F);
  static const gradientEnd = Color(0xFF111A20);
  static const surface = Color(0xFF12181C);
  static const surfaceSoft = Color(0xFF1F2A30);
  static const textPrimary = Color(0xFFF8FAFC);
  static const textSecondary = Color(0xFFA9B4BE);
  static const textMuted = Color(0xFF6F7C86);
  static const border = Color(0x0FFFFFFF);
  static const accent = Color(0xFF14B8A6);
  static const success = Color(0xFF22C55E);
  static const danger = Color(0xFFEF4444);
}
