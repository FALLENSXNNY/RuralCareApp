// Medical document model — represents an uploaded medical document in RuralCare
class MedicalDocument {
  final String id;
  final String title;
  final String documentType;
  final String? filePath;
  final String? fileUrl;
  final String? fileData; // Base64 encoded file or thumbnail string
  final String? mimeType;
  final int? fileSize;
  final String? notes;
  final DateTime uploadedAt;

  const MedicalDocument({
    required this.id,
    required this.title,
    required this.documentType,
    this.filePath,
    this.fileUrl,
    this.fileData,
    this.mimeType,
    this.fileSize,
    this.notes,
    required this.uploadedAt,
  });

  factory MedicalDocument.fromJson(Map<String, dynamic> json) {
    return MedicalDocument(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      documentType: json['documentType'] as String? ?? 'Other',
      filePath: json['filePath'] as String?,
      fileUrl: json['fileUrl'] as String?,
      fileData: json['fileData'] as String?,
      mimeType: json['mimeType'] as String? ?? 'image/jpeg',
      fileSize: (json['fileSize'] as num?)?.toInt(),
      notes: json['notes'] as String?,
      uploadedAt:
          DateTime.tryParse(json['uploadedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'documentType': documentType,
      if (filePath != null) 'filePath': filePath,
      if (fileUrl != null) 'fileUrl': fileUrl,
      if (fileData != null) 'fileData': fileData,
      if (mimeType != null) 'mimeType': mimeType,
      if (fileSize != null) 'fileSize': fileSize,
      if (notes != null) 'notes': notes,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  MedicalDocument copyWith({
    String? id,
    String? title,
    String? documentType,
    String? filePath,
    String? fileUrl,
    String? fileData,
    String? mimeType,
    int? fileSize,
    String? notes,
    DateTime? uploadedAt,
  }) {
    return MedicalDocument(
      id: id ?? this.id,
      title: title ?? this.title,
      documentType: documentType ?? this.documentType,
      filePath: filePath ?? this.filePath,
      fileUrl: fileUrl ?? this.fileUrl,
      fileData: fileData ?? this.fileData,
      mimeType: mimeType ?? this.mimeType,
      fileSize: fileSize ?? this.fileSize,
      notes: notes ?? this.notes,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }

  String get formattedFileSize {
    if (fileSize == null || fileSize! <= 0) return 'Unknown size';
    if (fileSize! < 1024) return '$fileSize B';
    if (fileSize! < 1024 * 1024) {
      return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
