import 'package:flutter/material.dart';

import '../../../domain/models/branch.dart';

class BranchesList extends StatelessWidget {
  const BranchesList({
    required this.branches,
    required this.selectedBranch,
    required this.onSelected,
    required this.showAdminActions,
    required this.onEdit,
    required this.onDeactivate,
    required this.onReactivate,
    super.key,
  });

  final List<Branch> branches;
  final Branch? selectedBranch;
  final ValueChanged<Branch> onSelected;
  final bool showAdminActions;
  final ValueChanged<Branch> onEdit;
  final ValueChanged<Branch> onDeactivate;
  final ValueChanged<Branch> onReactivate;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: branches.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final branch = branches[index];
        return BranchTile(
          branch: branch,
          selected: selectedBranch?.id == branch.id,
          onTap: () => onSelected(branch),
          showAdminActions: showAdminActions,
          onEdit: () => onEdit(branch),
          onDeactivate: () => onDeactivate(branch),
          onReactivate: () => onReactivate(branch),
        );
      },
    );
  }
}

class BranchTile extends StatelessWidget {
  const BranchTile({
    required this.branch,
    required this.selected,
    required this.onTap,
    required this.showAdminActions,
    required this.onEdit,
    required this.onDeactivate,
    required this.onReactivate,
    super.key,
  });

  final Branch branch;
  final bool selected;
  final VoidCallback onTap;
  final bool showAdminActions;
  final VoidCallback onEdit;
  final VoidCallback onDeactivate;
  final VoidCallback onReactivate;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? const Color(0xFF14B8A6)
        : const Color(0x0FFFFFFF);
    final backgroundColor = selected
        ? const Color(0xFF123B38)
        : const Color(0xFF12181C);

    return Semantics(
      button: branch.isActive,
      selected: selected,
      label: branch.name,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: branch.isActive ? onTap : null,
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
                child: Icon(
                  branch.isActive
                      ? Icons.location_on_outlined
                      : Icons.location_off_outlined,
                  color: branch.isActive
                      ? const Color(0xFF14B8A6)
                      : const Color(0xFF6F7C86),
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
                        if (showAdminActions)
                          BranchActions(
                            isActive: branch.isActive,
                            onEdit: onEdit,
                            onDeactivate: onDeactivate,
                            onReactivate: onReactivate,
                          )
                        else
                          BranchStatusBadge(
                            selected: selected,
                            isActive: branch.isActive,
                          ),
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
                    if (showAdminActions) ...[
                      const SizedBox(height: 8),
                      BranchStatusBadge(
                        selected: selected,
                        isActive: branch.isActive,
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

class BranchActions extends StatelessWidget {
  const BranchActions({
    required this.isActive,
    required this.onEdit,
    required this.onDeactivate,
    required this.onReactivate,
    super.key,
  });

  final bool isActive;
  final VoidCallback onEdit;
  final VoidCallback onDeactivate;
  final VoidCallback onReactivate;

  @override
  Widget build(BuildContext context) {
    if (!isActive) {
      return Tooltip(
        message: 'Reactivar sucursal',
        child: IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: onReactivate,
          icon: const Icon(Icons.restore),
          color: const Color(0xFF14B8A6),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: 'Editar sucursal',
          child: IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
            color: const Color(0xFFA9B4BE),
          ),
        ),
        Tooltip(
          message: 'Desactivar sucursal',
          child: IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onDeactivate,
            icon: const Icon(Icons.block),
            color: const Color(0xFFF87171),
          ),
        ),
      ],
    );
  }
}

class BranchStatusBadge extends StatelessWidget {
  const BranchStatusBadge({
    required this.selected,
    required this.isActive,
    super.key,
  });

  final bool selected;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final text = !isActive
        ? 'Inactiva'
        : (selected ? 'Seleccionada' : 'Activa');
    final textColor = !isActive
        ? const Color(0xFFF87171)
        : selected
        ? const Color(0xFF14B8A6)
        : const Color(0xFF22C55E);
    final backgroundColor = !isActive
        ? const Color(0x24EF4444)
        : selected
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
