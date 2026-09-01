import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/medical_document.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ruralcare_button.dart';

class DocumentViewerScreen extends ConsumerStatefulWidget {
  const DocumentViewerScreen({
    super.key,
    required this.documentId,
    this.document,
  });

  final String documentId;
  final MedicalDocument? document;

  @override
  ConsumerState<DocumentViewerScreen> createState() =>
      _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends ConsumerState<DocumentViewerScreen> {
  bool _isDeleting = false;
  MedicalDocument? _document;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _document = widget.document;
    if (_document == null) {
      _fetchDocument();
    }
  }

  Future<void> _fetchDocument() async {
    setState(() => _isLoading = true);
    final repo = ref.read(documentRepositoryProvider);
    final docs = await repo.getDocuments();
    final doc = docs.where((d) => d.id == widget.documentId).firstOrNull;
    if (mounted) {
      setState(() {
        _document = doc;
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text(
          'Are you sure you want to delete "${_document?.title ?? 'this document'}"? This action cannot be undone.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.emergency),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isDeleting = true);
      final repo = ref.read(documentRepositoryProvider);
      await repo.deleteDocument(widget.documentId);
      ref.invalidate(patientDocumentsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document deleted successfully.'),
            backgroundColor: AppColors.primary,
          ),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Document Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final doc = _document;
    if (doc == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Document Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.description_outlined,
                  size: 64, color: AppColors.textMuted),
              const SizedBox(height: 16),
              Text('Document not found', style: AppTextStyles.titleMedium),
              const SizedBox(height: 16),
              RuralCareButton(
                label: 'Go Back',
                onPressed: () => context.pop(),
                width: 160,
              ),
            ],
          ),
        ),
      );
    }

    final formattedDate =
        DateFormat('dd MMMM yyyy, h:mm a').format(doc.uploadedAt);

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        title: Text(doc.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.emergency),
            tooltip: 'Delete Document',
            onPressed: _isDeleting ? null : _confirmDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview card
            Container(
              width: double.infinity,
              height: 260,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _buildDocumentPreview(doc),
              ),
            ),
            const SizedBox(height: 20),

            // Metadata card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Document Info',
                          style: AppTextStyles.titleMedium
                              .copyWith(fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          doc.documentType,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _MetaRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Uploaded On',
                    value: formattedDate,
                  ),
                  const SizedBox(height: 12),
                  _MetaRow(
                    icon: Icons.data_usage_outlined,
                    label: 'File Size',
                    value: doc.formattedFileSize,
                  ),
                  const SizedBox(height: 12),
                  _MetaRow(
                    icon: Icons.description_outlined,
                    label: 'MIME Type',
                    value: doc.mimeType ?? 'image/jpeg',
                  ),
                  if (doc.notes != null && doc.notes!.isNotEmpty) ...[
                    const Divider(height: 24),
                    Text('Notes / Description',
                        style: AppTextStyles.labelMedium
                            .copyWith(color: AppColors.textMuted)),
                    const SizedBox(height: 6),
                    Text(
                      doc.notes!,
                      style: AppTextStyles.bodyMedium.copyWith(height: 1.4),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action row
            Row(
              children: [
                Expanded(
                  child: RuralCareButton(
                    label: 'Share with Doctor',
                    icon: Icons.share_outlined,
                    variant: RuralCareButtonVariant.outline,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Document linked to your consultation record.'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentPreview(MedicalDocument doc) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getIconForType(doc.documentType),
            size: 72,
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          Text(
            doc.title,
            style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Securely stored in RuralCare encrypted storage',
            style:
                AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'prescription':
        return Icons.medication_outlined;
      case 'lab report':
        return Icons.biotech_outlined;
      case 'discharge summary':
        return Icons.receipt_long_outlined;
      case 'x-ray / scan':
        return Icons.document_scanner_outlined;
      case 'insurance':
        return Icons.shield_outlined;
      default:
        return Icons.description_outlined;
    }
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Text('$label: ',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textMuted)),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium
                .copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
