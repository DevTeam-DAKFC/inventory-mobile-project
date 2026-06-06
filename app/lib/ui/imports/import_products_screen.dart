import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/result/app_result.dart';
import '../../domain/models/import_batch.dart';
import '../../domain/models/paginated_result.dart';
import '../../domain/models/product_import_file.dart';
import 'import_flow_state.dart';
import 'import_flow_view_model.dart';
import 'import_providers.dart';

class ImportProductsScreen extends ConsumerWidget {
  const ImportProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(importFlowViewModelProvider);
    final recentImports = ref.watch(
      importBatchListProvider((page: 1, pageSize: 5)),
    );

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
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const _ImportHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _UploadCard(state: state),
                    const SizedBox(height: 16),
                    _CsvFormatCard(),
                    if (state.createdBatch != null) ...[
                      const SizedBox(height: 16),
                      _BatchSummaryCard(batch: state.createdBatch!),
                    ],
                    if (state.isLoadingErrors) ...[
                      const SizedBox(height: 16),
                      const _StatusPanel(message: 'Loading row errors...'),
                    ] else if (state.batchErrors.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _ImportErrorsCard(errors: state.batchErrors),
                    ],
                    if (state.errorMessage != null) ...[
                      const SizedBox(height: 16),
                      _ErrorPanel(message: state.errorMessage!),
                    ],
                    if (state.successMessage != null) ...[
                      const SizedBox(height: 16),
                      _SuccessPanel(message: state.successMessage!),
                    ],
                    const SizedBox(height: 16),
                    _RecentImportsSection(recentImports: recentImports),
                    const SizedBox(height: 20),
                    _PrimaryButton(
                      label: state.isUploading ? 'Uploading...' : 'Subir CSV',
                      icon: Icons.upload_file,
                      onPressed: state.canUpload
                          ? ref
                                .read(importFlowViewModelProvider.notifier)
                                .submit
                          : null,
                    ),
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

class _RecentImportsSection extends StatelessWidget {
  const _RecentImportsSection({required this.recentImports});

  final AsyncValue<AppResult<PaginatedResult<ImportBatch>>> recentImports;

  @override
  Widget build(BuildContext context) {
    return _PrototypeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Importaciones recientes',
            style: TextStyle(color: Color(0xFFF8FAFC), fontSize: 14),
          ),
          const SizedBox(height: 12),
          recentImports.when(
            data: (result) => result.when(
              success: (page) {
                if (page.isEmpty) {
                  return const _MutedText('No hay importaciones recientes.');
                }
                return Column(
                  children: [
                    for (final batch in page.items.take(5)) ...[
                      _RecentImportRow(batch: batch),
                      if (batch != page.items.take(5).last)
                        const SizedBox(height: 10),
                    ],
                  ],
                );
              },
              failure: (exception) => _MutedText(exception.message),
            ),
            error: (error, stackTrace) =>
                const _MutedText('No se pudo cargar el historial.'),
            loading: () =>
                const _MutedText('Cargando importaciones recientes...'),
          ),
        ],
      ),
    );
  }
}

class _RecentImportRow extends StatelessWidget {
  const _RecentImportRow({required this.batch});

  final ImportBatch batch;

  @override
  Widget build(BuildContext context) {
    final color = batch.hasErrors
        ? const Color(0xFFF59E0B)
        : const Color(0xFF22C55E);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2A30),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x0FFFFFFF)),
      ),
      child: Row(
        children: [
          Icon(Icons.description_outlined, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  batch.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFF8FAFC),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${batch.importedRows} imported - ${batch.failedRows} failed',
                  style: const TextStyle(
                    color: Color(0xFF6F7C86),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          _Badge(text: _statusLabel(batch.status), color: color),
        ],
      ),
    );
  }
}

class _ImportHeader extends StatelessWidget {
  const _ImportHeader();

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
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back, color: Color(0xFFF8FAFC)),
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Text(
              'Importar productos',
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

class _UploadCard extends ConsumerWidget {
  const _UploadCard({required this.state});

  final ImportFlowState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final file = state.selectedFile;

    return _PrototypeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const _IconTile(icon: Icons.description_outlined),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file?.fileName ?? 'Archivo CSV',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFF8FAFC),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      file == null
                          ? 'Selecciona un archivo .csv'
                          : '${file.bytes.length} bytes listos',
                      style: const TextStyle(
                        color: Color(0xFF6F7C86),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SecondaryButton(
            label: 'Seleccionar archivo',
            icon: Icons.folder_open_outlined,
            onPressed: () => _pickCsv(ref),
          ),
        ],
      ),
    );
  }

  Future<void> _pickCsv(WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv'],
      withData: true,
    );
    final picked = result?.files.single;
    final bytes = picked?.bytes;
    if (picked == null || bytes == null) return;

    ref
        .read(importFlowViewModelProvider.notifier)
        .selectFile(ProductImportFile(fileName: picked.name, bytes: bytes));
  }
}

class _CsvFormatCard extends StatelessWidget {
  const _CsvFormatCard();

  @override
  Widget build(BuildContext context) {
    return const _PrototypeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Formato esperado',
            style: TextStyle(color: Color(0xFFF8FAFC), fontSize: 14),
          ),
          SizedBox(height: 10),
          _FormatLine(
            label: 'Requeridos',
            value: 'name, sku, category, minStock',
          ),
          SizedBox(height: 8),
          _FormatLine(
            label: 'Opcionales',
            value: 'barcode, description, imageUrl, isActive',
          ),
        ],
      ),
    );
  }
}

class _BatchSummaryCard extends StatelessWidget {
  const _BatchSummaryCard({required this.batch});

  final ImportBatch batch;

  @override
  Widget build(BuildContext context) {
    final statusColor = batch.hasErrors
        ? const Color(0xFFF59E0B)
        : const Color(0xFF22C55E);

    return _PrototypeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _Badge(text: _statusLabel(batch.status), color: statusColor),
              const Spacer(),
              Text(
                _formatDate(batch.createdAt),
                style: const TextStyle(color: Color(0xFF6F7C86), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            batch.fileName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFFF8FAFC), fontSize: 16),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MetricTile(label: 'Total', value: '${batch.totalRows}'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricTile(
                  label: 'Importadas',
                  value: '${batch.importedRows}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricTile(
                  label: 'Fallidas',
                  value: '${batch.failedRows}',
                  color: batch.hasErrors
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFFF8FAFC),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _statusLabel(ImportStatus status) {
    return switch (status) {
      ImportStatus.pending => 'Pendiente',
      ImportStatus.processing => 'Procesando',
      ImportStatus.completed => 'Completado',
      ImportStatus.failed => 'Fallido',
      ImportStatus.completedWithErrors => 'Con errores',
    };
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}

class _ImportErrorsCard extends StatelessWidget {
  const _ImportErrorsCard({required this.errors});

  final List<ImportBatchError> errors;

  @override
  Widget build(BuildContext context) {
    return _PrototypeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Errores por fila',
            style: TextStyle(color: Color(0xFFF8FAFC), fontSize: 14),
          ),
          const SizedBox(height: 12),
          for (final error in errors.take(5)) ...[
            _ErrorRow(error: error),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _ErrorRow extends StatelessWidget {
  const _ErrorRow({required this.error});

  final ImportBatchError error;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fila ${error.rowNumber} - ${error.field}',
            style: const TextStyle(color: Color(0xFFF8FAFC), fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            error.message,
            style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _FormatLine extends StatelessWidget {
  const _FormatLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(color: Color(0xFFA9B4BE), fontSize: 12),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(color: Color(0xFFF8FAFC), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _MutedText extends StatelessWidget {
  const _MutedText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(color: Color(0xFF6F7C86), fontSize: 12),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    this.color = const Color(0xFFF8FAFC),
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2A30),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x0FFFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF6F7C86), fontSize: 10),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

String _statusLabel(ImportStatus status) {
  return switch (status) {
    ImportStatus.pending => 'Pendiente',
    ImportStatus.processing => 'Procesando',
    ImportStatus.completed => 'Completado',
    ImportStatus.failed => 'Fallido',
    ImportStatus.completedWithErrors => 'Con errores',
  };
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

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF1F2A30),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: const Color(0xFF14B8A6), size: 20),
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

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF14B8A6),
        foregroundColor: const Color(0xFF0C1013),
        minimumSize: const Size.fromHeight(48),
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
  final VoidCallback onPressed;

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

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({required this.message});

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
