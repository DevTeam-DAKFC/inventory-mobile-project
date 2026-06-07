import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_error_code.dart';
import '../../core/result/app_result.dart';
import '../../domain/models/branch.dart';
import '../../domain/models/inventory_movement.dart';
import '../../domain/models/inventory_movement_filters.dart';
import '../../domain/models/product.dart';
import 'movement_form_state.dart';
import 'movement_form_view_model.dart';
import 'movement_history_state.dart';
import 'movement_history_view_model.dart';
import 'movement_providers.dart';
import 'movement_reference_resolver.dart';

class MovementFormScreen extends ConsumerStatefulWidget {
  const MovementFormScreen({super.key});

  @override
  ConsumerState<MovementFormScreen> createState() => _MovementFormScreenState();
}

class _MovementFormScreenState extends ConsumerState<MovementFormScreen> {
  bool _showForm = false;
  String _activeFilter = 'all';
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(movementHistoryViewModelProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _quantityController.dispose();
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(movementFormViewModelProvider);
    final historyState = ref.watch(movementHistoryViewModelProvider);
    final resolver = ref.watch(movementReferenceResolverProvider);
    final products = ref.watch(activeProductCatalogProvider);
    final branches = ref.watch(activeBranchCatalogProvider);

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
          child: _showForm
              ? _MovementFormView(
                  state: formState,
                  quantityController: _quantityController,
                  reasonController: _reasonController,
                  notesController: _notesController,
                  products: products,
                  branches: branches,
                  onBack: () => setState(() => _showForm = false),
                  onSubmitSuccess: () {
                    setState(() => _showForm = false);
                    ref.read(movementHistoryViewModelProvider.notifier).load();
                  },
                )
              : _MovementHistoryView(
                  state: historyState,
                  resolver: resolver,
                  activeFilter: _activeFilter,
                  searchController: _searchController,
                  onSearchChanged: () => setState(() {}),
                  onFilterChanged: _applyFilter,
                  onOpenForm: () => setState(() => _showForm = true),
                  onLoadMore: ref
                      .read(movementHistoryViewModelProvider.notifier)
                      .loadNextPage,
                ),
        ),
      ),
    );
  }

  void _applyFilter(String filter) {
    setState(() => _activeFilter = filter);
    final type = switch (filter) {
      'incoming' => MovementType.incoming,
      'outgoing' => MovementType.outgoing,
      _ => null,
    };
    ref
        .read(movementHistoryViewModelProvider.notifier)
        .applyFilters(InventoryMovementFilters(type: type));
  }
}

class _MovementHistoryView extends StatelessWidget {
  const _MovementHistoryView({
    required this.state,
    required this.resolver,
    required this.activeFilter,
    required this.searchController,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.onOpenForm,
    required this.onLoadMore,
  });

  final MovementHistoryState state;
  final MovementReferenceResolver resolver;
  final String activeFilter;
  final TextEditingController searchController;
  final VoidCallback onSearchChanged;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback onOpenForm;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    final query = searchController.text.trim().toLowerCase();
    final visibleMovements = state.movements.where((movement) {
      if (query.isEmpty) return true;
      return resolver
              .productLabel(movement.productId)
              .toLowerCase()
              .contains(query) ||
          resolver
              .branchLabel(movement.branchId)
              .toLowerCase()
              .contains(query) ||
          resolver.userLabel(movement.userId).toLowerCase().contains(query);
    }).toList();

    return Column(
      children: [
        _MovementHeader(
          searchController: searchController,
          onSearchChanged: onSearchChanged,
          activeFilter: activeFilter,
          onFilterChanged: onFilterChanged,
          onOpenForm: onOpenForm,
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              if (state.isLoading && !state.hasLoaded)
                const _CenteredStatus(message: 'Loading movement history...')
              else if (state.errorMessage != null)
                _ErrorPanel(message: state.errorMessage!)
              else if (state.isEmpty || visibleMovements.isEmpty)
                const _CenteredStatus(message: 'No movements found')
              else ...[
                for (final movement in visibleMovements) ...[
                  _MovementCard(movement: movement, resolver: resolver),
                  const SizedBox(height: 12),
                ],
                if (state.hasNextPage)
                  _PrimaryButton(
                    label: state.isLoading ? 'Loading...' : 'Load more',
                    onPressed: state.isLoading ? null : onLoadMore,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MovementHeader extends StatelessWidget {
  const _MovementHeader({
    required this.searchController,
    required this.onSearchChanged,
    required this.activeFilter,
    required this.onFilterChanged,
    required this.onOpenForm,
  });

  final TextEditingController searchController;
  final VoidCallback onSearchChanged;
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback onOpenForm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      decoration: const BoxDecoration(
        color: Color(0xFF12181C),
        border: Border(bottom: BorderSide(color: Color(0x0FFFFFFF))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Historial',
                  style: TextStyle(
                    color: Color(0xFFF8FAFC),
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              _IconActionButton(icon: Icons.add, onPressed: onOpenForm),
            ],
          ),
          const SizedBox(height: 16),
          const _BranchChip(),
          const SizedBox(height: 12),
          _SearchField(
            controller: searchController,
            onChanged: onSearchChanged,
          ),
          const SizedBox(height: 12),
          _FilterRow(activeFilter: activeFilter, onChanged: onFilterChanged),
        ],
      ),
    );
  }
}

class _MovementFormView extends ConsumerWidget {
  const _MovementFormView({
    required this.state,
    required this.quantityController,
    required this.reasonController,
    required this.notesController,
    required this.products,
    required this.branches,
    required this.onBack,
    required this.onSubmitSuccess,
  });

  final MovementFormState state;
  final TextEditingController quantityController;
  final TextEditingController reasonController;
  final TextEditingController notesController;
  final AsyncValue<AppResult<List<Product>>> products;
  final AsyncValue<AppResult<List<Branch>>> branches;
  final VoidCallback onBack;
  final VoidCallback onSubmitSuccess;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productOptions = _productOptions(products);
    final branchOptions = _branchOptions(branches);
    final productLoadMessage = _catalogLoadMessage(
      products,
      loading: 'Loading active products...',
      failurePrefix: 'Using fallback products.',
    );
    final branchLoadMessage = _catalogLoadMessage(
      branches,
      loading: 'Loading active branches...',
      failurePrefix: 'Using fallback branches.',
    );

    ref.listen<MovementFormState>(movementFormViewModelProvider, (
      previous,
      next,
    ) {
      if (previous?.createdMovement == null && next.createdMovement != null) {
        onSubmitSuccess();
      }
    });

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          decoration: const BoxDecoration(
            color: Color(0xFF12181C),
            border: Border(bottom: BorderSide(color: Color(0x0FFFFFFF))),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back, color: Color(0xFFF8FAFC)),
              ),
              const SizedBox(width: 4),
              const Text(
                'Registrar movimiento',
                style: TextStyle(
                  color: Color(0xFFF8FAFC),
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _MovementTypeSelector(state: state),
              const SizedBox(height: 20),
              _SelectField(
                label: 'Producto *',
                value: state.productId,
                hint: 'Seleccionar producto',
                options: productOptions,
                errorText:
                    state.fieldErrors[MovementFormViewModel.productField],
                onChanged: (value) {
                  ref
                      .read(movementFormViewModelProvider.notifier)
                      .setProductId(value);
                  ref
                      .read(movementFormViewModelProvider.notifier)
                      .loadCurrentStock();
                },
              ),
              if (productLoadMessage != null) ...[
                const SizedBox(height: 8),
                _InlineStatus(message: productLoadMessage),
              ],
              const SizedBox(height: 20),
              _SelectField(
                label: 'Sucursal *',
                value: state.branchId,
                hint: 'Seleccionar sucursal',
                options: branchOptions,
                errorText: state.fieldErrors[MovementFormViewModel.branchField],
                onChanged: (value) {
                  ref
                      .read(movementFormViewModelProvider.notifier)
                      .setBranchId(value);
                  ref
                      .read(movementFormViewModelProvider.notifier)
                      .loadCurrentStock();
                },
              ),
              if (branchLoadMessage != null) ...[
                const SizedBox(height: 8),
                _InlineStatus(message: branchLoadMessage),
              ],
              const SizedBox(height: 20),
              _TextInput(
                label: 'Cantidad *',
                controller: quantityController,
                keyboardType: TextInputType.number,
                errorText:
                    state.fieldErrors[MovementFormViewModel.quantityField],
                onChanged: (value) {
                  ref
                      .read(movementFormViewModelProvider.notifier)
                      .setQuantity(int.tryParse(value));
                },
              ),
              const SizedBox(height: 20),
              _TextInput(
                label: 'Motivo *',
                controller: reasonController,
                errorText: state.fieldErrors[MovementFormViewModel.reasonField],
                onChanged: ref
                    .read(movementFormViewModelProvider.notifier)
                    .setReason,
              ),
              const SizedBox(height: 20),
              _TextInput(
                label: 'Notas (opcional)',
                controller: notesController,
                maxLines: 3,
                onChanged: ref
                    .read(movementFormViewModelProvider.notifier)
                    .setNotes,
              ),
              const SizedBox(height: 20),
              if (state.currentStock != null)
                _MovementSummary(state: state)
              else
                const _InfoPanel(
                  message: 'Select a product and branch to load current stock.',
                ),
              if (state.errorMessage != null) ...[
                const SizedBox(height: 16),
                _ErrorPanel(
                  message: state.errorMessage!,
                  danger: state.errorCode == AppErrorCode.insufficientStock,
                ),
              ],
              const SizedBox(height: 24),
              _PrimaryButton(
                label: state.isSubmitting
                    ? 'Registering...'
                    : 'Registrar movimiento',
                onPressed: state.canSubmit
                    ? ref.read(movementFormViewModelProvider.notifier).submit
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<MovementSelectOption> _productOptions(
    AsyncValue<AppResult<List<Product>>> catalog,
  ) {
    return catalog.when(
      data: (result) => result.when(
        success: (products) => products
            .map(
              (product) =>
                  MovementSelectOption(id: product.id, label: product.name),
            )
            .toList(),
        failure: (_) => const [],
      ),
      error: (_, _) => const [],
      loading: () => const [],
    );
  }

  List<MovementSelectOption> _branchOptions(
    AsyncValue<AppResult<List<Branch>>> catalog,
  ) {
    return catalog.when(
      data: (result) => result.when(
        success: (branches) => branches
            .map(
              (branch) =>
                  MovementSelectOption(id: branch.id, label: branch.name),
            )
            .toList(),
        failure: (_) => const [],
      ),
      error: (_, _) => const [],
      loading: () => const [],
    );
  }

  String? _catalogLoadMessage<T>(
    AsyncValue<AppResult<List<T>>> catalog, {
    required String loading,
    required String failurePrefix,
  }) {
    return catalog.when(
      data: (result) => result.when(
        success: (_) => null,
        failure: (exception) => '$failurePrefix ${exception.message}',
      ),
      error: (_, _) => failurePrefix,
      loading: () => loading,
    );
  }
}

final class MovementSelectOption {
  const MovementSelectOption({required this.id, required this.label});

  final String id;
  final String label;
}

class _MovementTypeSelector extends ConsumerWidget {
  const _MovementTypeSelector({required this.state});

  final MovementFormState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('Tipo de movimiento *'),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _TypeButton(
                label: 'Entrada',
                selected: state.type == MovementType.incoming,
                color: const Color(0xFF22C55E),
                onTap: () => ref
                    .read(movementFormViewModelProvider.notifier)
                    .setType(MovementType.incoming),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _TypeButton(
                label: 'Salida',
                selected: state.type == MovementType.outgoing,
                color: const Color(0xFF3B82F6),
                onTap: () => ref
                    .read(movementFormViewModelProvider.notifier)
                    .setType(MovementType.outgoing),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MovementSummary extends StatelessWidget {
  const _MovementSummary({required this.state});

  final MovementFormState state;

  @override
  Widget build(BuildContext context) {
    final stock = state.currentStock!;
    final quantity = state.quantity ?? 0;
    final resultingStock = state.type == MovementType.incoming
        ? stock.availableQuantity + quantity
        : stock.availableQuantity - quantity;
    final sign = state.type == MovementType.incoming ? '+' : '-';
    final color = state.type == MovementType.incoming
        ? const Color(0xFF22C55E)
        : const Color(0xFF3B82F6);

    return _PrototypeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen del movimiento',
            style: TextStyle(color: Color(0xFFF8FAFC), fontSize: 14),
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            label: 'Stock actual en ${stock.branch.name}',
            value: '${stock.availableQuantity}',
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'Cantidad a mover',
            value: '$sign$quantity',
            valueColor: color,
          ),
          const SizedBox(height: 8),
          const Divider(color: Color(0x0FFFFFFF)),
          _SummaryRow(
            label: 'Stock resultante',
            value: '$resultingStock',
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _MovementCard extends StatelessWidget {
  const _MovementCard({required this.movement, required this.resolver});

  final InventoryMovement movement;
  final MovementReferenceResolver resolver;

  @override
  Widget build(BuildContext context) {
    final isIncoming = movement.type == MovementType.incoming;
    final typeLabel = isIncoming ? 'Entrada' : 'Salida';
    final quantity = isIncoming
        ? '+${movement.quantity}'
        : '-${movement.quantity}';

    return _PrototypeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _Badge(
                text: typeLabel,
                color: isIncoming
                    ? const Color(0xFF22C55E)
                    : const Color(0xFF3B82F6),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  resolver.productLabel(movement.productId),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFF8FAFC),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                resolver.branchLabel(movement.branchId),
                style: const TextStyle(color: Color(0xFFA9B4BE), fontSize: 12),
              ),
              Text(
                '$quantity → Stock: ${movement.resultingStock}',
                style: const TextStyle(color: Color(0xFF6F7C86), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Color(0x0FFFFFFF)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                resolver.userLabel(movement.userId),
                style: const TextStyle(color: Color(0xFF6F7C86), fontSize: 12),
              ),
              Text(
                _formatDate(movement.createdAt),
                style: const TextStyle(color: Color(0xFF6F7C86), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Motivo: ${movement.reason}',
            style: const TextStyle(color: Color(0xFFA9B4BE), fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.activeFilter, required this.onChanged});

  final String activeFilter;
  final ValueChanged<String> onChanged;

  static const _filters = [
    ('all', 'Todos'),
    ('incoming', 'Entrada'),
    ('outgoing', 'Salida'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in _filters) ...[
            _FilterChipButton(
              label: filter.$2,
              selected: activeFilter == filter.$1,
              onTap: () => onChanged(filter.$1),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0x2414B8A6) : const Color(0xFF1F2A30),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? const Color(0x5214B8A6) : const Color(0x0FFFFFFF),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF14B8A6) : const Color(0xFFA9B4BE),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: (_) => onChanged(),
      style: const TextStyle(color: Color(0xFFF8FAFC), fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Buscar movimiento...',
        hintStyle: const TextStyle(color: Color(0xFF6F7C86)),
        prefixIcon: const Icon(
          Icons.search,
          color: Color(0xFF6F7C86),
          size: 18,
        ),
        filled: true,
        fillColor: const Color(0xFF1F2A30),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0x0FFFFFFF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0x0FFFFFFF)),
        ),
      ),
    );
  }
}

class _SelectField extends StatelessWidget {
  const _SelectField({
    required this.label,
    required this.value,
    required this.hint,
    required this.options,
    required this.onChanged,
    this.errorText,
  });

  final String label;
  final String? value;
  final String hint;
  final List<MovementSelectOption> options;
  final ValueChanged<String?> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          dropdownColor: const Color(0xFF1F2A30),
          decoration: _inputDecoration(errorText: errorText),
          hint: Text(hint, style: const TextStyle(color: Color(0xFF6F7C86))),
          items: [
            for (final option in options)
              DropdownMenuItem(value: option.id, child: Text(option.label)),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _TextInput extends StatelessWidget {
  const _TextInput({
    required this.label,
    required this.controller,
    required this.onChanged,
    this.keyboardType,
    this.maxLines = 1,
    this.errorText,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(color: Color(0xFFF8FAFC)),
          decoration: _inputDecoration(errorText: errorText),
        ),
      ],
    );
  }
}

InputDecoration _inputDecoration({String? errorText}) {
  return InputDecoration(
    errorText: errorText,
    filled: true,
    fillColor: const Color(0xFF1F2A30),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0x0FFFFFFF)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0x0FFFFFFF)),
    ),
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(color: Color(0xFFA9B4BE), fontSize: 14),
    );
  }
}

class _TypeButton extends StatelessWidget {
  const _TypeButton({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.14)
              : const Color(0xFF12181C),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? color.withValues(alpha: 0.3)
                : const Color(0x0FFFFFFF),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? color : const Color(0xFFF8FAFC),
              fontSize: 14,
            ),
          ),
        ),
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

class _IconActionButton extends StatelessWidget {
  const _IconActionButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF14B8A6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF0C1013), size: 20),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF14B8A6),
        foregroundColor: const Color(0xFF0C1013),
        minimumSize: const Size.fromHeight(48),
      ),
      child: Text(label),
    );
  }
}

class _BranchChip extends StatelessWidget {
  const _BranchChip();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2A30),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0x0FFFFFFF)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Central Branch',
              style: TextStyle(color: Color(0xFFF8FAFC), fontSize: 14),
            ),
            SizedBox(width: 8),
            Icon(Icons.keyboard_arrow_down, color: Color(0xFF6F7C86), size: 16),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor = const Color(0xFFF8FAFC),
    this.bold = false,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFFA9B4BE), fontSize: 14),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 14,
            fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return _PrototypeCard(
      child: Text(
        message,
        style: const TextStyle(color: Color(0xFFA9B4BE), fontSize: 13),
      ),
    );
  }
}

class _InlineStatus extends StatelessWidget {
  const _InlineStatus({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: const TextStyle(color: Color(0xFF6F7C86), fontSize: 12),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, this.danger = false});

  final String message;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? const Color(0xFFEF4444) : const Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(message, style: TextStyle(color: color, fontSize: 13)),
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
