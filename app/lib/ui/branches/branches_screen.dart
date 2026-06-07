import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/errors/app_exception.dart';
import '../../data/providers/branch_providers.dart';
import '../../domain/models/branch.dart';
import '../../navigation/app_session.dart';
import '../../navigation/routes.dart';
import 'branch_error_message.dart';
import 'branches_controller.dart';
import 'widgets/branch_form_sheet.dart';
import 'widgets/branch_state_views.dart';
import 'widgets/branches_header.dart';
import 'widgets/branches_list.dart';

class BranchesScreen extends ConsumerWidget {
  const BranchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(appSessionProvider);
    final filter = ref.watch(branchesControllerProvider);
    final effectiveFilter = session.canViewAdminEntries
        ? filter
        : BranchFilter.active;
    final asyncResult = switch (effectiveFilter) {
      BranchFilter.all => ref.watch(allBranchesProvider),
      BranchFilter.active => ref.watch(branchesProvider),
      BranchFilter.inactive => ref.watch(inactiveBranchesProvider),
    };
    final selectedBranch = ref.watch(selectedBranchProvider);

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
              BranchesHeader(
                showAdminActions: session.canViewAdminEntries,
                onBack: () => context.go(AppRoutes.home),
                onCreate: () => _showBranchForm(context, ref),
                filter: effectiveFilter,
                onFilterChanged: ref
                    .read(branchesControllerProvider.notifier)
                    .selectFilter,
              ),
              Expanded(
                child: asyncResult.when(
                  loading: () => const BranchLoadingView(),
                  error: (error, stackTrace) => BranchErrorView(
                    message: 'No se pudieron cargar las sucursales.',
                    detail:
                        'Ocurrió un error inesperado. Inténtalo nuevamente.',
                    onRetry: ref
                        .read(branchesControllerProvider.notifier)
                        .refreshCurrent,
                  ),
                  data: (result) => result.when(
                    success: (branches) {
                      if (branches.isEmpty) {
                        return BranchEmptyView(filter: effectiveFilter);
                      }

                      return BranchesList(
                        branches: branches,
                        selectedBranch: selectedBranch,
                        onSelected: ref
                            .read(selectedBranchProvider.notifier)
                            .select,
                        showAdminActions: session.canViewAdminEntries,
                        onEdit: (branch) =>
                            _showBranchForm(context, ref, branch: branch),
                        onDeactivate: (branch) =>
                            _confirmDeactivate(context, ref, branch),
                        onReactivate: (branch) =>
                            _confirmReactivate(context, ref, branch),
                      );
                    },
                    failure: (exception) => BranchErrorView(
                      message: 'No se pudieron cargar las sucursales.',
                      detail: branchErrorMessage(exception),
                      onRetry: ref
                          .read(branchesControllerProvider.notifier)
                          .refreshCurrent,
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

  Future<void> _showBranchForm(
    BuildContext context,
    WidgetRef ref, {
    Branch? branch,
  }) async {
    final controller = ref.read(branchesControllerProvider.notifier);
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF12181C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => BranchFormSheet(
        branch: branch,
        onSubmit: (name, address) async {
          final result = await controller.saveBranch(
            branch: branch,
            name: name,
            address: address,
          );
          return result.when(success: (_) => null, failure: branchErrorMessage);
        },
      ),
    );

    if (saved != true || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          branch == null
              ? 'Sucursal creada correctamente.'
              : 'Sucursal actualizada correctamente.',
        ),
      ),
    );
  }

  Future<void> _confirmDeactivate(
    BuildContext context,
    WidgetRef ref,
    Branch branch,
  ) async {
    final confirmed = await _confirmStatusChange(
      context,
      title: 'Desactivar sucursal',
      message:
          'La sucursal "${branch.name}" dejará de aparecer en la lista activa.',
      actionLabel: 'Desactivar',
    );
    if (!confirmed || !context.mounted) return;

    final result = await ref
        .read(branchesControllerProvider.notifier)
        .deactivate(branch);
    if (!context.mounted) return;

    _showMutationResult(
      context,
      result.exceptionOrNull,
      successMessage: 'Sucursal desactivada correctamente.',
    );
  }

  Future<void> _confirmReactivate(
    BuildContext context,
    WidgetRef ref,
    Branch branch,
  ) async {
    final confirmed = await _confirmStatusChange(
      context,
      title: 'Reactivar sucursal',
      message: 'La sucursal "${branch.name}" volverá a estar disponible.',
      actionLabel: 'Reactivar',
    );
    if (!confirmed || !context.mounted) return;

    final result = await ref
        .read(branchesControllerProvider.notifier)
        .reactivate(branch);
    if (!context.mounted) return;

    _showMutationResult(
      context,
      result.exceptionOrNull,
      successMessage: 'Sucursal reactivada correctamente.',
    );
  }

  Future<bool> _confirmStatusChange(
    BuildContext context, {
    required String title,
    required String message,
    required String actionLabel,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(actionLabel),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showMutationResult(
    BuildContext context,
    AppException? exception, {
    required String successMessage,
  }) {
    final message = exception == null
        ? successMessage
        : branchErrorMessage(exception);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
