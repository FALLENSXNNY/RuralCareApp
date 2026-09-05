/// Status of the live demo queue
class DemoQueueStatus {
  final String appointmentId;
  final String userToken; // e.g. "A024"
  final String currentToken; // e.g. "A019"
  final int initialServingNumber; // 19
  final int userTokenNumber; // 24
  final int currentServingNumber; // 19 -> 20 -> 21 -> 22 -> 23 -> 24
  final String doctorName;
  final String specialty;
  final String facilityName;
  final String facilityAddress;

  const DemoQueueStatus({
    required this.appointmentId,
    this.userToken = 'A024',
    this.currentToken = 'A019',
    this.initialServingNumber = 19,
    this.userTokenNumber = 24,
    this.currentServingNumber = 19,
    this.doctorName = 'Dr. Krishanu Chakraborty',
    this.specialty = 'Psychiatrist',
    this.facilityName = 'Doctor Clinic',
    this.facilityAddress = 'Prafulla Nagar Road',
  });

  int get patientsAhead => (userTokenNumber - currentServingNumber).clamp(0, 99);

  bool get isApproaching => patientsAhead == 1 || (currentServingNumber == 23);

  bool get isCalled => currentServingNumber >= userTokenNumber;

  String get estimatedWait {
    if (isCalled) return '0 min (Now Calling)';
    if (isApproaching) return '5–10 min';
    final ahead = patientsAhead;
    if (ahead == 2) return '15–20 min';
    if (ahead == 3) return '25–35 min';
    return '35–45 min';
  }

  String get statusText {
    if (isCalled) return 'CALLED';
    if (isApproaching) return 'Approaching';
    return 'Queue Active';
  }

  /// List of tokens in queue sequence around the user token
  List<QueueTokenItem> get tokenSequence {
    final list = <QueueTokenItem>[];
    for (int i = initialServingNumber; i <= userTokenNumber; i++) {
      final tokenStr = 'A0${i < 10 ? '0$i' : '$i'}';
      final isCompleted = i < currentServingNumber;
      final isCurrent = i == currentServingNumber;
      final isUser = i == userTokenNumber;

      list.add(
        QueueTokenItem(
          token: tokenStr,
          isCompleted: isCompleted,
          isCurrentServing: isCurrent,
          isUserToken: isUser,
        ),
      );
    }
    return list;
  }

  DemoQueueStatus copyWith({
    String? appointmentId,
    String? userToken,
    String? currentToken,
    int? initialServingNumber,
    int? userTokenNumber,
    int? currentServingNumber,
    String? doctorName,
    String? specialty,
    String? facilityName,
    String? facilityAddress,
  }) {
    return DemoQueueStatus(
      appointmentId: appointmentId ?? this.appointmentId,
      userToken: userToken ?? this.userToken,
      currentToken: currentToken ?? this.currentToken,
      initialServingNumber: initialServingNumber ?? this.initialServingNumber,
      userTokenNumber: userTokenNumber ?? this.userTokenNumber,
      currentServingNumber: currentServingNumber ?? this.currentServingNumber,
      doctorName: doctorName ?? this.doctorName,
      specialty: specialty ?? this.specialty,
      facilityName: facilityName ?? this.facilityName,
      facilityAddress: facilityAddress ?? this.facilityAddress,
    );
  }
}

class QueueTokenItem {
  final String token;
  final bool isCompleted;
  final bool isCurrentServing;
  final bool isUserToken;

  const QueueTokenItem({
    required this.token,
    required this.isCompleted,
    required this.isCurrentServing,
    required this.isUserToken,
  });
}
