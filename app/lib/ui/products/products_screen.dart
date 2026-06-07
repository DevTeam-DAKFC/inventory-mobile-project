import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/product.dart';
import 'product_catalog_state.dart';
import 'product_catalog_view_model.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(productCatalogViewModelProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productCatalogViewModelProvider);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0D0F), Color(0xFF111A20)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const _ProductsHeader(),
              Expanded(child: _ProductsContent(state: state)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductsHeader extends StatelessWidget {
  const _ProductsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      decoration: const BoxDecoration(
        color: Color(0xFF12181C),
        border: Border(bottom: BorderSide(color: Color(0x0FFFFFFF))),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Text(
              'Productos',
              style: TextStyle(
                color: Color(0xFFF8FAFC),
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductsContent extends ConsumerWidget {
  const _ProductsContent({required this.state});

  final ProductCatalogState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        if (state.isLoading && !state.hasLoaded)
          const _CenteredStatus(message: 'Loading products...')
        else if (state.errorMessage != null)
          _ErrorPanel(message: state.errorMessage!)
        else if (state.isEmpty)
          const _CenteredStatus(message: 'No products found')
        else ...[
          if (state.successMessage != null) ...[
            _SuccessPanel(message: state.successMessage!),
            const SizedBox(height: 12),
          ],
          for (final product in state.products) ...[
            _ProductCard(product: product, disabled: state.isChangingState),
            const SizedBox(height: 12),
          ],
        ],
      ],
    );
  }
}

class _ProductCard extends ConsumerWidget {
  const _ProductCard({required this.product, required this.disabled});

  final Product product;
  final bool disabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = product.isActive
        ? const Color(0xFF22C55E)
        : const Color(0xFFF59E0B);
    final actionLabel = product.isActive ? 'Deactivate' : 'Activate';

    return _PrototypeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _Badge(
                text: product.isActive ? 'Activo' : 'Inactivo',
                color: color,
              ),
              const Spacer(),
              Text(
                product.sku,
                style: const TextStyle(color: Color(0xFF6F7C86), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFFF8FAFC), fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            product.category,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFFA9B4BE), fontSize: 12),
          ),
          const SizedBox(height: 14),
          _SecondaryButton(
            label: disabled ? 'Updating...' : actionLabel,
            icon: product.isActive
                ? Icons.block_outlined
                : Icons.check_circle_outline,
            onPressed: disabled
                ? null
                : () {
                    final viewModel = ref.read(
                      productCatalogViewModelProvider.notifier,
                    );
                    if (product.isActive) {
                      viewModel.deactivateProduct(product.id);
                    } else {
                      viewModel.activateProduct(product.id);
                    }
                  },
          ),
        ],
      ),
    );
  }
}

class _PrototypeCard extends StatelessWidget {
  const _PrototypeCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF12181C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x0FFFFFFF)),
      ),
      child: child,
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFF8FAFC),
        minimumSize: const Size.fromHeight(44),
        side: const BorderSide(color: Color(0x0FFFFFFF)),
      ),
    );
  }
}

class _SuccessPanel extends StatelessWidget {
  const _SuccessPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF22C55E).withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF22C55E).withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Color(0xFF22C55E), fontSize: 13),
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFEF4444).withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13),
      ),
    );
  }
}

class _CenteredStatus extends StatelessWidget {
  const _CenteredStatus({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Text(message, style: const TextStyle(color: Color(0xFF6F7C86))),
      ),
    );
  }
}
