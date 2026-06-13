import 'package:flutter/material.dart';

import '../branches_controller.dart';

class BranchesHeader extends StatelessWidget {
  const BranchesHeader({
    required this.showAdminActions,
    required this.onBack,
    required this.onCreate,
    required this.filter,
    required this.onFilterChanged,
    super.key,
  });

  final bool showAdminActions;
  final VoidCallback onBack;
  final VoidCallback onCreate;
  final BranchFilter filter;
  final ValueChanged<BranchFilter> onFilterChanged;

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
              Tooltip(
                message: 'Volver',
                child: IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back),
                  color: const Color(0xFFF8FAFC),
                ),
              ),
              const SizedBox(width: 4),
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
                  message: 'Nueva sucursal',
                  child: IconButton(
                    onPressed: onCreate,
                    icon: const Icon(Icons.add),
                    color: const Color(0xFF14B8A6),
                  ),
                ),
            ],
          ),
          if (showAdminActions) ...[
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  BranchFilterButton(
                    label: 'Todas',
                    selected: filter == BranchFilter.all,
                    onTap: () => onFilterChanged(BranchFilter.all),
                  ),
                  const SizedBox(width: 8),
                  BranchFilterButton(
                    label: 'Activas',
                    selected: filter == BranchFilter.active,
                    onTap: () => onFilterChanged(BranchFilter.active),
                  ),
                  const SizedBox(width: 8),
                  BranchFilterButton(
                    label: 'Inactivas',
                    selected: filter == BranchFilter.inactive,
                    onTap: () => onFilterChanged(BranchFilter.inactive),
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

class BranchFilterButton extends StatelessWidget {
  const BranchFilterButton({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
