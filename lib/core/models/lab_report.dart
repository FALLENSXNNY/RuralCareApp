// Lab report model — represents a diagnostic/lab test result
class LabReport {
  final String id;
  final String testName;
  final String date;
  final String result;
  final String status; // Normal / Abnormal / Pending
  final String facility;

  const LabReport({
    required this.id,
    required this.testName,
    required this.date,
    required this.result,
    required this.status,
    required this.facility,
  });

  factory LabReport.fromJson(Map<String, dynamic> json) {
    final results = (json['results'] as List<dynamic>?) ?? const [];
    final hasAbnormal = results.any((r) => r is Map && r['isAbnormal'] == true);

    String res = json['result'] as String? ?? json['resultSummary'] as String? ?? '';
    if (res.isEmpty && results.isNotEmpty) {
      res = results
          .map((r) => r is Map ? "${r['parameter']}: ${r['value']} ${r['unit'] ?? ''}" : r.toString())
          .join(', ');
    }

    final rawStatus = json['status'] as String? ?? '';
    final status = hasAbnormal
        ? 'Abnormal'
        : (rawStatus.isNotEmpty ? rawStatus : 'Normal');

    return LabReport(
      id: json['id'] as String? ?? '',
      testName: json['testName'] as String? ?? '',
      date: json['date'] as String? ?? '',
      result: res.isNotEmpty ? res : 'Completed',
      status: status,
      facility: json['facility'] as String? ?? json['facilityName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'testName': testName,
      'date': date,
      'result': result,
      'status': status,
      'facility': facility,
    };
  }

  bool get isAbnormal => status == 'Abnormal';
}
