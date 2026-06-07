import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers/product_providers.dart';
import '../../domain/models/product.dart';
import '../../navigation/routes.dart';
import 'product_catalog_controller.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productCatalogProvider.notifier).loadInitial();
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 240) {
      ref.read(productCatalogProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productCatalogProvider);

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
              _CatalogHeader(state: state),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: ref.read(productCatalogProvider.notifier).reload,
                  color: _Colors.accent,
                  backgroundColor: _Colors.surfaceElevated,
                  child: _CatalogContent(
                    state: state,
                    scrollController: _scrollController,
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

class _CatalogHeader extends ConsumerWidget {
  const _CatalogHeader({required this.state});

  final ProductCatalogState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(productCatalogProvider.notifier);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      decoration: const BoxDecoration(
        color: _Colors.surface,
        border: Border(bottom: BorderSide(color: _Colors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Productos',
                style: TextStyle(
                  color: _Colors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              InkWell(
                key: const Key('add-product-button'),
                onTap: () async {
                  final saved = await context.push<bool>(AppRoutes.productNew);
                  if (saved == true) controller.reload();
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _Colors.accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: _Colors.background,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _BranchSelector(),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: TextField(
              key: const Key('product-search-field'),
              onChanged: controller.setSearchQuery,
              style: const TextStyle(color: _Colors.textPrimary, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, SKU o código...',
                hintStyle: const TextStyle(
                  color: _Colors.textMuted,
                  fontSize: 15,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: _Colors.textMuted,
                  size: 18,
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 40),
                filled: true,
                fillColor: _Colors.surfaceSoft,
                contentPadding: const EdgeInsets.only(right: 16),
                enabledBorder: _inputBorder,
                focusedBorder: _inputBorder.copyWith(
                  borderSide: const BorderSide(color: _Colors.accent),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  text: 'Todos',
                  selected: state.filter == ProductCatalogFilter.all,
                  onTap: () => controller.setFilter(ProductCatalogFilter.all),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  text: 'Activos',
                  selected: state.filter == ProductCatalogFilter.active,
                  onTap: () =>
                      controller.setFilter(ProductCatalogFilter.active),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  text: 'Stock bajo',
                  selected: state.filter == ProductCatalogFilter.lowStock,
                  onTap: () =>
                      controller.setFilter(ProductCatalogFilter.lowStock),
                ),
                const SizedBox(width: 8),
                const _FilterChip(text: 'Agotados'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BranchSelector extends StatelessWidget {
  const _BranchSelector();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        key: const Key('branch-selector'),
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: _Colors.surfaceSoft,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _Colors.border),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tienda Central',
              style: TextStyle(color: _Colors.textPrimary, fontSize: 14),
            ),
            SizedBox(width: 8),
            Icon(Icons.keyboard_arrow_down, color: _Colors.textMuted, size: 16),
          ],
        ),
      ),
    );
  }
}

class _CatalogContent extends ConsumerWidget {
  const _CatalogContent({required this.state, required this.scrollController});

  final ProductCatalogState state;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isLoading) {
      return const _ScrollableCentered(
        child: CircularProgressIndicator(color: _Colors.accent),
      );
    }
    if (state.error != null) {
      return _ScrollableCentered(
        child: _ErrorView(
          message: state.error!.message,
          onRetry: ref.read(productCatalogProvider.notifier).reload,
        ),
      );
    }
    if (state.isEmpty) {
      return const _ScrollableCentered(
        child: Text(
          'No se encontraron productos',
          style: TextStyle(color: _Colors.textMuted, fontSize: 14),
        ),
      );
    }

    return ListView.separated(
      key: const Key('product-list'),
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: state.products.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index < state.products.length) {
          final product = state.products[index];
          return _ProductCard(product: product);
        }
        if (state.isLoadingMore) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: CircularProgressIndicator(color: _Colors.accent),
            ),
          );
        }
        if (state.loadMoreError != null) {
          return TextButton(
            onPressed: ref.read(productCatalogProvider.notifier).loadMore,
            child: const Text('No se pudo cargar más. Reintentar'),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _ProductCard extends ConsumerWidget {
  const _ProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resolver = ref.watch(publicAssetUrlResolverProvider);
    return InkWell(
      onTap: () async {
        final changed = await context.push<bool>(
          AppRoutes.productDetail(product.id),
        );
        if (changed == true) {
          ref.read(productCatalogProvider.notifier).reload();
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        key: Key('product-card-${product.id}'),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _Colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _Colors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProductImage(
              productId: product.id,
              imageUrl: resolver.resolve(product.imageUrl),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _Colors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        key: Key('product-chevron-${product.id}'),
                        Icons.chevron_right,
                        color: _Colors.textMuted,
                        size: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          product.sku,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _Colors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '·',
                          style: TextStyle(
                            color: _Colors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          product.category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _Colors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [_StatusBadge(isActive: product.isActive)],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.productId, this.imageUrl});

  final String productId;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    Widget placeholder() => Center(
      key: Key('product-image-placeholder-$productId'),
      child: const Icon(
        Icons.inventory_2_outlined,
        color: _Colors.accent,
        size: 24,
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: ColoredBox(
        color: _Colors.surfaceSoft,
        child: SizedBox(
          width: 64,
          height: 72,
          child: imageUrl == null
              ? placeholder()
              : Image.network(
                  key: Key('product-image-$productId'),
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => placeholder(),
                ),
        ),
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
          letterSpacing: 0.25,
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.text, this.selected = false, this.onTap});

  final String text;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? _Colors.accentSoft : _Colors.surfaceSoft,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? _Colors.accentBorder : _Colors.border,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: onTap == null
                ? _Colors.textMuted
                : selected
                ? _Colors.accent
                : _Colors.textSecondary,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _ScrollableCentered extends StatelessWidget {
  const _ScrollableCentered({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: constraints.maxHeight,
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: _Colors.danger, size: 36),
          const SizedBox(height: 12),
          const Text(
            'No se pudieron cargar los productos',
            textAlign: TextAlign.center,
            style: TextStyle(color: _Colors.textPrimary, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _Colors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

const _inputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(8)),
  borderSide: BorderSide(color: _Colors.border),
);

abstract final class _Colors {
  static const background = Color(0xFF0C1013);
  static const surface = Color(0xFF12181C);
  static const surfaceElevated = Color(0xFF182126);
  static const surfaceSoft = Color(0xFF1F2A30);
  static const textPrimary = Color(0xFFF8FAFC);
  static const textSecondary = Color(0xFFA9B4BE);
  static const textMuted = Color(0xFF6F7C86);
  static const border = Color(0x0FFFFFFF);
  static const accent = Color(0xFF14B8A6);
  static const accentSoft = Color(0x2414B8A6);
  static const accentBorder = Color(0x5214B8A6);
  static const success = Color(0xFF22C55E);
  static const danger = Color(0xFFEF4444);
}
