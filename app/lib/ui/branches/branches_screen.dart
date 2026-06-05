import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../data/providers/branch_providers.dart';
import '../../domain/models/branch.dart';
import '../../navigation/app_session.dart';

class BranchesScreen extends ConsumerWidget {
  const BranchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncResult = ref.watch(branchesProvider);
    final selectedBranch = ref.watch(selectedBranchProvider);
    final session = ref.watch(appSessionProvider);

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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _BranchesHeader(showAdminActions: session.canViewAdminEntries),
              Expanded(
                child: asyncResult.when(
                  loading: () => const _LoadingView(),
                  error: (error, stackTrace) => _ErrorView(
                    message: 'No se pudieron cargar las sucursales.',
                    detail: error.toString(),
                    onRetry: () => ref.invalidate(branchesProvider),
                  ),
                  data: (result) => result.when(
                    success: (branches) {
                      if (branches.isEmpty) {
                        return const _EmptyView();
                      }

                      return _BranchesList(
                        branches: branches,
                        selectedBranch: selectedBranch,
                        onSelected: (branch) {
                          ref
                              .read(selectedBranchProvider.notifier)
                              .select(branch);
                        },
                      );
                    },
                    failure: (exception) => _ErrorView(
                      message: 'No se pudieron cargar las sucursales.',
                      detail: _formatException(exception),
                      onRetry: () => ref.invalidate(branchesProvider),
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

  String _formatException(AppException exception) =>
      '${exception.code.value}: ${exception.message}';
}

class _BranchesHeader extends StatelessWidget {
  const _BranchesHeader({required this.showAdminActions});

  final bool showAdminActions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      decoration: const BoxDecoration(
        color: Color(0xFF12181C),
        border: Border(bottom: BorderSide(color: Color(0x0FFFFFFF))),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sucursales',
                  style: TextStyle(
                    color: Color(0xFFF8FAFC),
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Seleccionar sucursal activa',
                  style: TextStyle(color: Color(0xFFA9B4BE), fontSize: 13),
                ),
              ],
            ),
          ),
          if (showAdminActions)
            Tooltip(
              message: 'La creación se implementará en otra tarea',
              child: IconButton(
                onPressed: null,
                icon: const Icon(Icons.add),
                color: const Color(0xFF14B8A6),
              ),
            ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Cargando sucursales...'),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StateIcon(icon: Icons.location_off_outlined),
            SizedBox(height: 16),
            Text(
              'No hay sucursales activas disponibles.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFF8FAFC),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.detail,
    required this.onRetry,
  });

  final String message;
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
            const _StateIcon(icon: Icons.error_outline),
            const SizedBox(height: 16),
            Text(
              message,
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
              style: const TextStyle(color: Color(0xFFA9B4BE), fontSize: 12),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Intentar de nuevo'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BranchesList extends StatelessWidget {
  const _BranchesList({
    required this.branches,
    required this.selectedBranch,
    required this.onSelected,
  });

  final List<Branch> branches;
  final Branch? selectedBranch;
  final ValueChanged<Branch> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: branches.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final branch = branches[index];
        return _BranchTile(
          branch: branch,
          selected: selectedBranch?.id == branch.id,
          onTap: () => onSelected(branch),
        );
      },
    );
  }
}

class _BranchTile extends StatelessWidget {
  const _BranchTile({
    required this.branch,
    required this.selected,
    required this.onTap,
  });

  final Branch branch;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? const Color(0xFF14B8A6)
        : const Color(0x0FFFFFFF);
    final backgroundColor = selected
        ? const Color(0xFF123B38)
        : const Color(0xFF12181C);

    return Semantics(
      button: true,
      selected: selected,
      label: branch.name,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2A30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: Color(0xFF14B8A6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            branch.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFF8FAFC),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusBadge(selected: selected),
                      ],
                    ),
                    if (branch.address?.trim().isNotEmpty ?? false) ...[
                      const SizedBox(height: 6),
                      Text(
                        branch.address!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFA9B4BE),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final text = selected ? 'Seleccionada' : 'Activa';
    final textColor = selected
        ? const Color(0xFF14B8A6)
        : const Color(0xFF22C55E);
    final backgroundColor = selected
        ? const Color(0x2414B8A6)
        : const Color(0x2422C55E);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StateIcon extends StatelessWidget {
  const _StateIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFF1F2A30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x0FFFFFFF)),
      ),
      child: Icon(icon, color: const Color(0xFF6F7C86), size: 30),
    );
  }
}
