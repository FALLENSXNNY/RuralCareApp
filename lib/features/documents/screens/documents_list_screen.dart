import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/medical_document.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/section_card.dart';

class DocumentsListScreen extends ConsumerStatefulWidget {
  const DocumentsListScreen({super.key});

  @override
  ConsumerState<DocumentsListScreen> createState() =>
      _DocumentsListScreenState();
}

class _DocumentsListScreenState extends ConsumerState<DocumentsListScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Prescription',
    'Lab Report',
    'Discharge Summary',
    'X-Ray / Scan',
    'Insurance',
    'Medical Report',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final docsAsync = ref.watch(patientDocumentsProvider(null));

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        title: const Text('Uploaded Documents'),
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate_outlined),
            tooltip: 'Upload Document',
            onPressed: () => context.push(AppRoutes.documentUpload),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.documentUpload),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.upload_file, color: Colors.white),
        label: const Text('Upload Document',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          // Search & Filter header
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) =>
                      setState(() => _searchQuery = val.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search documents by title or notes...',
                    prefixIcon:
                        const Icon(Icons.search, color: AppColors.textMuted),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (_) =>
                              setState(() => _selectedCategory = cat),
                          selectedColor: AppColors.primaryContainer,
                          labelStyle: AppTextStyles.labelMedium.copyWith(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textMuted,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Documents list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(patientDocumentsProvider(null));
                await ref.read(patientDocumentsProvider(null).future);
              },
              child: docsAsync.when(
                data: (documents) {
                  final filtered = documents.where((doc) {
                    if (_selectedCategory != 'All') {
                      if (!doc.documentType
                          .toLowerCase()
                          .contains(_selectedCategory.toLowerCase())) {
                        return false;
                      }
                    }
                    if (_searchQuery.isNotEmpty) {
                      final matchTitle =
                          doc.title.toLowerCase().contains(_searchQuery);
                      final matchNotes =
                          doc.notes?.toLowerCase().contains(_searchQuery) ?? false;
                      final matchType = doc.documentType
                          .toLowerCase()
                          .contains(_searchQuery);
                      return matchTitle || matchNotes || matchType;
                    }
                    return true;
                  }).toList();

                  if (filtered.isEmpty) {
                    return ListView(
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.2),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF3E0),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.upload_file_outlined,
                                    size: 32, color: Color(0xFFE65100)),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isEmpty &&
                                        _selectedCategory == 'All'
                                    ? 'No Documents Uploaded'
                                    : 'No matching documents',
                                style: AppTextStyles.titleMedium,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _searchQuery.isEmpty &&
                                        _selectedCategory == 'All'
                                    ? 'Tap below to upload prescriptions, lab reports or scans'
                                    : 'Try searching with another keyword or category',
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: AppColors.textMuted),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () =>
                                    context.push(AppRoutes.documentUpload),
                                icon: const Icon(Icons.add_a_photo_outlined),
                                label: const Text('Upload First Document'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                        AppConstants.screenPadding,
                        AppConstants.screenPadding,
                        AppConstants.screenPadding,
                        80),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final doc = filtered[index];
                      return _DocumentCard(doc: doc);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 44, color: AppColors.emergency),
                        const SizedBox(height: 12),
                        Text('Failed to load documents',
                            style: AppTextStyles.titleMedium),
                        const SizedBox(height: 4),
                        Text('$err',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.textMuted),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              ref.invalidate(patientDocumentsProvider(null)),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.doc});
  final MedicalDocument doc;

  @override
  Widget build(BuildContext context) {
    final typeLower = doc.documentType.toLowerCase();
    IconData iconData = Icons.description_outlined;
    Color iconColor = AppColors.primary;
    Color bgColor = AppColors.primaryContainer;

    if (typeLower.contains('prescription')) {
      iconData = Icons.medication_outlined;
      iconColor = const Color(0xFF6750A4);
      bgColor = const Color(0xFFEDE7F6);
    } else if (typeLower.contains('lab') || typeLower.contains('diagnostic')) {
      iconData = Icons.science_outlined;
      iconColor = const Color(0xFF0277BD);
      bgColor = const Color(0xFFE1F5FE);
    } else if (typeLower.contains('x-ray') || typeLower.contains('scan')) {
      iconData = Icons.camera_alt_outlined;
      iconColor = const Color(0xFFE65100);
      bgColor = const Color(0xFFFFF3E0);
    }

    String dateStr = '';
    try {
      dateStr = DateFormat('dd MMM yyyy').format(doc.uploadedAt);
    } catch (_) {
      dateStr = doc.uploadedAt.toString().split(' ').first;
    }

    return SectionCard(
      onTap: () =>
          context.push('/documents/view/${doc.id}', extra: doc),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(iconData, color: iconColor, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        doc.title,
                        style: AppTextStyles.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(4),
                        border:
                            Border.all(color: AppColors.border, width: 0.5),
                      ),
                      child: Text(
                        doc.documentType,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (doc.notes != null && doc.notes!.trim().isNotEmpty) ...[
                  Text(
                    doc.notes!,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                ],
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(dateStr,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textMuted, fontSize: 12)),
                    if (doc.fileSize != null && doc.fileSize! > 0) ...[
                      const SizedBox(width: 12),
                      const Icon(Icons.attach_file,
                          size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 2),
                      Text(doc.formattedFileSize,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
