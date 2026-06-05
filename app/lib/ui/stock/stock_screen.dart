import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/stock_overview_item.dart';
import 'stock_state.dart';
import 'stock_view_model.dart';

class StockScreen extends ConsumerStatefulWidget {
  const StockScreen({super.key});

  @override
  ConsumerState<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends ConsumerState<StockScreen> {
  final _searchController = TextEditingController();
  _StockFilter _activeFilter = _StockFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(stockViewModelProvider);

    return DecoratedBox(
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
            _Header(
              branchName: _branchName(asyncState),
              controller: _searchController,
              activeFilter: _activeFilter,
              onSearchChanged: (_) => setState(() {}),
              onFilterChanged: (filter) {
                setState(() => _activeFilter = filter);
              },
            ),
            Expanded(
              child: asyncState.when(
                loading: () => const _LoadingState(),
                error: (error, _) => _ErrorState(
                  title: 'No se pudieron cargar las existencias',
                  detail: error.toString(),
                  onRetry: () =>
                      ref.read(stockViewModelProvider.notifier).refresh(),
                ),
                data: (state) => _buildDataState(state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataState(StockState state) {
    return switch (state) {
      StockLoaded(:final items) => _StockList(
        items: _filteredItems(items),
        onRefresh: () => ref.read(stockViewModelProvider.notifier).refresh(),
      ),
      StockEmpty() => _EmptyState(
        message: 'No se encontraron existencias',
        onRefresh: () => ref.read(stockViewModelProvider.notifier).refresh(),
      ),
      StockError(:final code, :final message) => _ErrorState(
        title: 'No se pudieron cargar las existencias',
        detail: '$code: $message',
        onRetry: () => ref.read(stockViewModelProvider.notifier).refresh(),
      ),
    };
  }

  List<StockOverviewItem> _filteredItems(List<StockOverviewItem> items) {
    final query = _searchController.text.trim().toLowerCase();

    return items
        .where((item) {
          final matchesSearch =
              query.isEmpty ||
              item.productName.toLowerCase().contains(query) ||
              (item.sku?.toLowerCase().contains(query) ?? false);

          if (!matchesSearch) {
            return false;
          }

          return switch (_activeFilter) {
            _StockFilter.all => true,
            _StockFilter.available => !item.isLowStock && !item.isOutOfStock,
            _StockFilter.low => item.isLowStock && !item.isOutOfStock,
            _StockFilter.empty => item.isOutOfStock,
          };
        })
        .toList(growable: false);
  }

  String _branchName(AsyncValue<StockState> asyncState) {
    final value = asyncState.asData?.value;
    return switch (value) {
      StockLoaded(:final branchName) => branchName,
      StockEmpty(:final branchName) => branchName,
      StockError(:final branchName) => branchName,
      _ => 'Sucursal Central',
    };
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.branchName,
    required this.controller,
    required this.activeFilter,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  final String branchName;
  final TextEditingController controller;
  final _StockFilter activeFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<_StockFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      decoration: const BoxDecoration(
        color: Color(0xFF12181C),
        border: Border(bottom: BorderSide(color: Color(0x0FFFFFFF))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Existencias',
            style: TextStyle(
              color: Color(0xFFF8FAFC),
              fontSize: 24,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          _BranchButton(branchName: branchName),
          const SizedBox(height: 12),
          _SearchField(controller: controller, onChanged: onSearchChanged),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final filter in _StockFilter.values) ...[
                  _FilterChip(
                    filter: filter,
                    selected: filter == activeFilter,
                    onTap: () => onFilterChanged(filter),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BranchButton extends StatelessWidget {
  const _BranchButton({required this.branchName});

  final String branchName;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2A30),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x0FFFFFFF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            branchName,
            style: const TextStyle(color: Color(0xFFF8FAFC), fontSize: 14),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF6F7C86),
            size: 18,
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: Color(0xFFF8FAFC), fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Buscar producto...',
          hintStyle: const TextStyle(color: Color(0xFF6F7C86)),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF6F7C86),
            size: 20,
          ),
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: const Color(0xFF1F2A30),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0x0FFFFFFF)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0x5214B8A6)),
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.filter,
    required this.selected,
    required this.onTap,
  });

  final _StockFilter filter;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? const Color(0x2414B8A6) : const Color(0xFF1F2A30),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? const Color(0x5214B8A6) : const Color(0x0FFFFFFF),
          ),
        ),
        child: Text(
          filter.label,
          style: TextStyle(
            color: selected ? const Color(0xFF14B8A6) : const Color(0xFFA9B4BE),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _StockList extends StatelessWidget {
  const _StockList({required this.items, required this.onRefresh});

  final List<StockOverviewItem> items;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _EmptyState(
        message: 'No se encontraron existencias',
        onRefresh: onRefresh,
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        itemBuilder: (context, index) => _StockCard(item: items[index]),
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemCount: items.length,
      ),
    );
  }
}

class _StockCard extends StatelessWidget {
  const _StockCard({required this.item});

  final StockOverviewItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF12181C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x0FFFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      style: const TextStyle(
                        color: Color(0xFFF8FAFC),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _ProductMeta(item: item),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _StatusBadge(item: item),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0x0FFFFFFF), height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  label: 'Disponible',
                  value: item.availableQuantity.toString(),
                ),
              ),
              Expanded(
                child: _Metric(
                  label: 'Mínimo',
                  value: item.minStock.toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0x0FFFFFFF), height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Última actualización',
                style: TextStyle(color: Color(0xFF6F7C86), fontSize: 12),
              ),
              Text(
                _formatDate(item.updatedAt ?? item.lastMovementAt),
                style: const TextStyle(color: Color(0xFFA9B4BE), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Sin movimientos';
    }
    const months = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    final local = date.toLocal();
    final month = months[local.month - 1];
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.day} $month, $hour:$minute';
  }
}

class _ProductMeta extends StatelessWidget {
  const _ProductMeta({required this.item});

  final StockOverviewItem item;

  @override
  Widget build(BuildContext context) {
    final sku = item.sku?.isEmpty ?? true ? 'Sin SKU' : item.sku!;

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          sku,
          style: const TextStyle(color: Color(0xFFA9B4BE), fontSize: 12),
        ),
        const Text(
          '·',
          style: TextStyle(color: Color(0xFF6F7C86), fontSize: 12),
        ),
        Text(
          item.branchName,
          style: const TextStyle(color: Color(0xFF6F7C86), fontSize: 12),
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF6F7C86), fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFF8FAFC),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.item});

  final StockOverviewItem item;

  @override
  Widget build(BuildContext context) {
    final status = _StockStatus.fromItem(item);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: status.border),
      ),
      child: Text(
        status.label.toUpperCase(),
        style: TextStyle(
          color: status.foreground,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Color(0xFF14B8A6)),
          SizedBox(height: 16),
          Text(
            'Cargando existencias...',
            style: TextStyle(color: Color(0xFFA9B4BE)),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message, required this.onRefresh});

  final String message;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 72, 20, 24),
        children: [
          Center(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFF6F7C86), fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.title,
    required this.detail,
    required this.onRetry,
  });

  final String title;
  final String detail;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFEF4444),
              size: 36,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFF8FAFC),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              detail,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFA9B4BE), fontSize: 13),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}

enum _StockFilter {
  all('Todos'),
  available('Disponible'),
  low('Stock bajo'),
  empty('Agotado');

  const _StockFilter(this.label);

  final String label;
}

enum _StockStatus {
  available(
    'Disponible',
    Color(0x2422C55E),
    Color(0xFF22C55E),
    Color(0x3322C55E),
  ),
  low('Stock bajo', Color(0x24F59E0B), Color(0xFFF59E0B), Color(0x33F59E0B)),
  empty('Agotado', Color(0x24EF4444), Color(0xFFEF4444), Color(0x33EF4444));

  const _StockStatus(this.label, this.background, this.foreground, this.border);

  final String label;
  final Color background;
  final Color foreground;
  final Color border;

  static _StockStatus fromItem(StockOverviewItem item) {
    if (item.isOutOfStock) {
      return _StockStatus.empty;
    }
    if (item.isLowStock) {
      return _StockStatus.low;
    }
    return _StockStatus.available;
  }
}
