import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/medical_document.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ruralcare_button.dart';
import '../../../core/widgets/section_card.dart';

class DocumentUploadScreen extends ConsumerStatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  ConsumerState<DocumentUploadScreen> createState() =>
      _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends ConsumerState<DocumentUploadScreen> {
  String _selectedType = 'Prescription';
  bool _isUploading = false;
  bool _uploadDone = false;
  MedicalDocument? _uploadedDoc;
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedFileName;
  int? _selectedFileSize;
  String _selectedMimeType = 'image/jpeg';
  String? _selectedFileData;

  final ImagePicker _imagePicker = ImagePicker();

  final List<String> _docTypes = [
    'Prescription',
    'Lab Report',
    'Discharge Summary',
    'X-Ray / Scan',
    'Insurance',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _setDefaultTitle('Prescription');
  }

  void _setDefaultTitle(String type) {
    final now = DateFormat('d MMM yyyy').format(DateTime.now());
    _titleController.text = '$type — $now';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickFromCamera() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        final base64Data = base64Encode(bytes);
        if (mounted) {
          setState(() {
            _selectedFileName = photo.name.isNotEmpty
                ? photo.name
                : 'Camera_Capture_${DateTime.now().millisecondsSinceEpoch}.jpg';
            _selectedFileSize = bytes.length;
            _selectedMimeType = photo.mimeType ?? 'image/jpeg';
            _selectedFileData = base64Data;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not capture photo from camera: $e'),
            backgroundColor: AppColors.emergency,
          ),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64Data = base64Encode(bytes);
        if (mounted) {
          setState(() {
            _selectedFileName = image.name.isNotEmpty
                ? image.name
                : 'Gallery_Photo_${DateTime.now().millisecondsSinceEpoch}.png';
            _selectedFileSize = bytes.length;
            _selectedMimeType = image.mimeType ?? 'image/png';
            _selectedFileData = base64Data;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open photo gallery: $e'),
            backgroundColor: AppColors.emergency,
          ),
        );
      }
    }
  }

  Future<void> _pickPDF() async {
    try {
      final files = await FilePickerPlatform.instance.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (files.isNotEmpty) {
        final file = files.first;
        final bytes = await file.readAsBytes();
        final size = await file.length();
        final base64Data = base64Encode(bytes);
        if (mounted) {
          setState(() {
            _selectedFileName = file.name;
            _selectedFileSize = size > 0 ? size : bytes.length;
            _selectedMimeType = 'application/pdf';
            _selectedFileData = base64Data;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not select PDF file: $e'),
            backgroundColor: AppColors.emergency,
          ),
        );
      }
    }
  }

  void _showFilePickerSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select Medical Document', style: AppTextStyles.titleMedium),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_outlined,
                      color: AppColors.primary),
                ),
                title: const Text('Take Photo / Scan with Camera'),
                subtitle: const Text('Capture prescription, bill, or report'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickFromCamera();
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library_outlined,
                      color: AppColors.secondary),
                ),
                title: const Text('Choose from Photo Gallery'),
                subtitle: const Text('JPG, PNG image files'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickFromGallery();
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.picture_as_pdf_outlined,
                      color: AppColors.primary),
                ),
                title: const Text('Choose PDF Document'),
                subtitle: const Text('Lab report or discharge summary'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickPDF();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _upload() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title for the document.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (_selectedFileName == null || _selectedFileData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or capture a document file first.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final repo = ref.read(documentRepositoryProvider);

      final newDoc = MedicalDocument(
        id: '',
        title: title,
        documentType: _selectedType,
        filePath: _selectedFileName ?? 'document.jpg',
        mimeType: _selectedMimeType,
        fileSize: _selectedFileSize ?? (1024 * 512),
        fileData: _selectedFileData,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        uploadedAt: DateTime.now(),
      );

      final saved = await repo.saveDocument(newDoc);
      ref.invalidate(patientDocumentsProvider);

      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadDone = true;
          _uploadedDoc = saved;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: AppColors.emergency,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_uploadDone) return _buildSuccess();

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        title: const Text('Upload Medical Document'),
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step 1: Document Type
            const _StepHeader(step: 1, title: 'Choose Document Type'),
            const SizedBox(height: 12),
            SectionCard(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _docTypes.map((t) {
                  final selected = _selectedType == t;
                  return ChoiceChip(
                    label: Text(t),
                    selected: selected,
                    onSelected: (_) {
                      setState(() {
                        _selectedType = t;
                        _setDefaultTitle(t);
                      });
                    },
                    selectedColor: AppColors.primaryContainer,
                    labelStyle: AppTextStyles.labelMedium.copyWith(
                      color:
                          selected ? AppColors.primary : AppColors.textPrimary,
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Step 2: Document Title
            const _StepHeader(step: 2, title: 'Document Title'),
            const SizedBox(height: 12),
            SectionCard(
              child: TextFormField(
                controller: _titleController,
                style: AppTextStyles.bodyLarge,
                decoration: const InputDecoration(
                  hintText: 'e.g. Blood Test 20 Aug 2026',
                  prefixIcon:
                      Icon(Icons.title_outlined, color: AppColors.primary),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Step 3: Select File
            const _StepHeader(step: 3, title: 'Select or Capture File'),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _showFilePickerSheet,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _selectedFileName != null
                        ? AppColors.primary
                        : AppColors.border,
                    width: _selectedFileName != null ? 2 : 1,
                  ),
                ),
                child: _selectedFileName == null
                    ? Column(
                        children: [
                          const Icon(Icons.cloud_upload_outlined,
                              size: 48, color: AppColors.primary),
                          const SizedBox(height: 12),
                          Text('Tap to take photo or choose file',
                              style: AppTextStyles.titleSmall
                                  .copyWith(color: AppColors.primary)),
                          const SizedBox(height: 4),
                          Text(
                              'Prescriptions, Lab Reports, Scans (JPG, PNG, PDF)',
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.textMuted)),
                        ],
                      )
                    : Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _selectedMimeType == 'application/pdf'
                                  ? Icons.picture_as_pdf
                                  : Icons.image,
                              color: AppColors.primary,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_selectedFileName!,
                                    style: AppTextStyles.titleSmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 2),
                                Text(
                                  'Ready to upload • ${((_selectedFileSize ?? 0) / 1024).toStringAsFixed(0)} KB',
                                  style: AppTextStyles.bodySmall
                                      .copyWith(color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined,
                                color: AppColors.primary),
                            onPressed: _showFilePickerSheet,
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Step 4: Optional Notes
            const _StepHeader(step: 4, title: 'Notes / Context (Optional)'),
            const SizedBox(height: 12),
            SectionCard(
              child: TextFormField(
                controller: _notesController,
                maxLines: 2,
                style: AppTextStyles.bodyMedium,
                decoration: const InputDecoration(
                  hintText: 'e.g. Prescribed at PHC Koregaon for fever',
                  prefixIcon:
                      Icon(Icons.notes_outlined, color: AppColors.textMuted),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            RuralCareButton(
              label: 'Upload Document',
              onPressed: _upload,
              isLoading: _isUploading,
              icon: Icons.upload_rounded,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccess() {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: AppColors.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline,
                    size: 52, color: AppColors.secondary),
              ),
              const SizedBox(height: 24),
              Text('Document Uploaded!',
                  style: AppTextStyles.headlineMedium,
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                'Your ${_selectedType.toLowerCase()} has been securely saved to your health record.',
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              RuralCareButton(
                label: 'View Document',
                icon: Icons.visibility_outlined,
                onPressed: () {
                  if (_uploadedDoc != null) {
                    context.push('/documents/view/${_uploadedDoc!.id}');
                  } else {
                    context.pop();
                  }
                },
              ),
              const SizedBox(height: 12),
              RuralCareButton(
                label: 'Upload Another',
                onPressed: () {
                  setState(() {
                    _uploadDone = false;
                    _selectedFileName = null;
                    _selectedFileSize = null;
                    _selectedFileData = null;
                    _setDefaultTitle(_selectedType);
                    _notesController.clear();
                  });
                },
                variant: RuralCareButtonVariant.outline,
                icon: Icons.add,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.step, required this.title});
  final int step;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$step',
              style: AppTextStyles.labelSmall
                  .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(title,
            style:
                AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
