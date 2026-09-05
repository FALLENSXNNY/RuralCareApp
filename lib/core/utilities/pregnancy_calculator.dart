import '../models/pregnancy.dart';

/// Utility class for pregnancy gestational calculations and validation
class PregnancyCalculator {
  PregnancyCalculator._();

  /// Standard average pregnancy duration in days (40 weeks = 280 days)
  static const int standardPregnancyDays = 280;

  /// Calculate Estimated Due Date (EDD) from Last Menstrual Period (LMP)
  /// Naegele's rule: LMP + 280 days (or +1 year - 3 months + 7 days)
  static DateTime calculateEddFromLmp(DateTime lmp) {
    return lmp.add(const Duration(days: standardPregnancyDays));
  }

  /// Calculate Last Menstrual Period (LMP) from Estimated Due Date (EDD)
  static DateTime calculateLmpFromEdd(DateTime edd) {
    return edd.subtract(const Duration(days: standardPregnancyDays));
  }

  /// Calculate current gestational week (1 to 42) based on EDD
  static int calculateGestationalWeek({
    DateTime? edd,
    DateTime? lmp,
    DateTime? currentDate,
  }) {
    final now = currentDate ?? DateTime.now();

    if (edd != null) {
      final daysRemaining = edd.difference(now).inDays;
      final daysElapsed = standardPregnancyDays - daysRemaining;
      final week = (daysElapsed / 7).floor() + 1;
      return week.clamp(1, 42);
    }

    if (lmp != null) {
      final daysElapsed = now.difference(lmp).inDays;
      final week = (daysElapsed / 7).floor() + 1;
      return week.clamp(1, 42);
    }

    return 1;
  }

  /// Determine the current trimester from the gestational week
  /// 1st Trimester: Weeks 1–13
  /// 2nd Trimester: Weeks 14–27
  /// 3rd Trimester: Weeks 28–42
  static PregnancyTrimester calculateTrimester(int week) {
    if (week <= 13) {
      return PregnancyTrimester.first;
    } else if (week <= 27) {
      return PregnancyTrimester.second;
    } else {
      return PregnancyTrimester.third;
    }
  }

  /// Get days remaining until the estimated due date
  static int calculateDaysRemaining(DateTime? edd, [DateTime? currentDate]) {
    if (edd == null) return 0;
    final now = currentDate ?? DateTime.now();
    final diff = edd.difference(now).inDays;
    return diff > 0 ? diff : 0;
  }

  /// Progress fraction (0.0 to 1.0) through the 40 weeks
  static double calculateProgressFraction(int week) {
    return (week / 40.0).clamp(0.0, 1.0);
  }

  /// Validate if an EDD is reasonable (between today and +280 days)
  static bool isValidEdd(DateTime? edd, [DateTime? currentDate]) {
    if (edd == null) return false;
    final now = currentDate ?? DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final maxDate = startOfToday.add(const Duration(days: 300));

    return edd.isAfter(startOfToday.subtract(const Duration(days: 1))) &&
        edd.isBefore(maxDate);
  }

  /// Validate if an LMP is reasonable (within the last 280 days)
  static bool isValidLmp(DateTime? lmp, [DateTime? currentDate]) {
    if (lmp == null) return false;
    final now = currentDate ?? DateTime.now();
    final minDate = now.subtract(const Duration(days: 280));

    return lmp.isAfter(minDate) && lmp.isBefore(now.add(const Duration(days: 1)));
  }
}
