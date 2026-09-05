import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruralcare/core/localization/app_localizations.dart';
import 'package:ruralcare/core/models/pregnancy.dart';
import 'package:ruralcare/core/providers/app_providers.dart';
import 'package:ruralcare/core/repositories/pregnancy_repository.dart';
import 'package:ruralcare/core/storage/local_storage_service.dart';
import 'package:ruralcare/core/utilities/pregnancy_calculator.dart';
import 'package:ruralcare/features/pregnancy/screens/pregnancy_dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Phase 3 — Pregnancy Care Unit & Integration Tests', () {
    test('PregnancyCalculator computes gestational weeks accurately', () {
      final now = DateTime(2026, 9, 3);

      // EDD in exactly 112 days (16 weeks remaining) => 40 - 16 = 24 weeks
      final edd = now.add(const Duration(days: 112));
      final week = PregnancyCalculator.calculateGestationalWeek(
        edd: edd,
        currentDate: now,
      );
      expect(week, equals(25)); // (280 - 112)/7 + 1 = 168/7 + 1 = 25

      // LMP 70 days ago (10 weeks elapsed) => 10 + 1 = 11th week
      final lmp = now.subtract(const Duration(days: 70));
      final weekFromLmp = PregnancyCalculator.calculateGestationalWeek(
        lmp: lmp,
        currentDate: now,
      );
      expect(weekFromLmp, equals(11));
    });

    test('PregnancyCalculator determines trimester stages correctly', () {
      expect(PregnancyCalculator.calculateTrimester(1),
          equals(PregnancyTrimester.first));
      expect(PregnancyCalculator.calculateTrimester(13),
          equals(PregnancyTrimester.first));
      expect(PregnancyCalculator.calculateTrimester(14),
          equals(PregnancyTrimester.second));
      expect(PregnancyCalculator.calculateTrimester(27),
          equals(PregnancyTrimester.second));
      expect(PregnancyCalculator.calculateTrimester(28),
          equals(PregnancyTrimester.third));
      expect(PregnancyCalculator.calculateTrimester(40),
          equals(PregnancyTrimester.third));
    });

    test('PregnancyCalculator validates EDD and LMP date ranges', () {
      final now = DateTime(2026, 9, 3);
      final validEdd = now.add(const Duration(days: 120));
      final pastEdd = now.subtract(const Duration(days: 10));
      final farFutureEdd = now.add(const Duration(days: 400));

      expect(PregnancyCalculator.isValidEdd(validEdd, now), isTrue);
      expect(PregnancyCalculator.isValidEdd(pastEdd, now), isFalse);
      expect(PregnancyCalculator.isValidEdd(farFutureEdd, now), isFalse);

      final validLmp = now.subtract(const Duration(days: 60));
      final tooOldLmp = now.subtract(const Duration(days: 300));
      final futureLmp = now.add(const Duration(days: 5));

      expect(PregnancyCalculator.isValidLmp(validLmp, now), isTrue);
      expect(PregnancyCalculator.isValidLmp(tooOldLmp, now), isFalse);
      expect(PregnancyCalculator.isValidLmp(futureLmp, now), isFalse);
    });

    test('PregnancyProfile fromJson and toJson roundtrip', () {
      final now = DateTime.now();
      final profile = PregnancyProfile(
        id: 'preg_123',
        patientId: 'pat_456',
        isPregnant: true,
        estimatedDueDate: DateTime(2026, 11, 12),
        lastMenstrualPeriod: DateTime(2026, 2, 5),
        currentWeek: 24,
        riskLevel: PregnancyRiskLevel.normal,
        primaryHealthCenter: 'PHC Trimbak',
        doctorOrAshaWorker: 'Sunita Tai',
        notes: 'Iron tablets prescribed',
        updatedAt: now,
      );

      final json = profile.toJson();
      final parsed = PregnancyProfile.fromJson(json);

      expect(parsed.id, equals(profile.id));
      expect(parsed.patientId, equals(profile.patientId));
      expect(parsed.currentWeek, equals(profile.currentWeek));
      expect(parsed.riskLevel, equals(profile.riskLevel));
      expect(parsed.primaryHealthCenter, equals(profile.primaryHealthCenter));
      expect(parsed.doctorOrAshaWorker, equals(profile.doctorOrAshaWorker));
    });

    test('AntenatalVisit model fromJson and toJson roundtrip', () {
      final visit = AntenatalVisit(
        visitNumber: 2,
        title: '2nd ANC Visit',
        weekRange: '14 - 26 Weeks',
        description: 'Routine scan and TT booster',
        testsAndProcedures: ['Hb test', 'TT-2 injection', 'Ultrasound scan'],
        scheduledDate: DateTime(2026, 9, 15),
        isCompleted: true,
        clinicName: 'District Hospital',
        doctorNotes: 'BP normal',
      );

      final json = visit.toJson();
      final parsed = AntenatalVisit.fromJson(json);

      expect(parsed.visitNumber, equals(2));
      expect(parsed.title, equals(visit.title));
      expect(parsed.testsAndProcedures.length, equals(3));
      expect(parsed.isCompleted, isTrue);
      expect(parsed.clinicName, equals('District Hospital'));
    });

    test('ApiPregnancyRepository fetches visits, guidance, and warning signs',
        () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await LocalStorageService.init();
      final repo = ApiPregnancyRepository(storage);

      final profile = await repo.getPregnancyProfile('test_patient');
      expect(profile.isPregnant, isTrue);
      expect(profile.estimatedDueDate, isNotNull);

      final visits = await repo.getAntenatalVisits();
      expect(visits.length, equals(4));
      expect(visits.first.visitNumber, equals(1));

      // Toggle visit status
      await repo.updateVisitStatus(2, true);
      expect(storage.completedAncVisits, contains(2));

      // Guidance coverage for all 3 trimesters
      final g1 = repo.getGuidanceForTrimester(PregnancyTrimester.first);
      final g2 = repo.getGuidanceForTrimester(PregnancyTrimester.second);
      final g3 = repo.getGuidanceForTrimester(PregnancyTrimester.third);
      expect(g1.isNotEmpty, isTrue);
      expect(g2.isNotEmpty, isTrue);
      expect(g3.isNotEmpty, isTrue);

      // Warning signs & symptoms
      final warnings = repo.getEmergencyWarningSigns();
      expect(warnings.length, greaterThanOrEqualTo(5));
      expect(warnings.every((w) => w.isEmergencyWarningSign), isTrue);

      final symptoms = repo.getCommonSymptoms();
      expect(symptoms.isNotEmpty, isTrue);
    });

    test('Multilingual translation coverage for Pregnancy Care (en, hi, bn)',
        () {
      final en = AppLocalizations(const Locale('en'));
      final hi = AppLocalizations(const Locale('hi'));
      final bn = AppLocalizations(const Locale('bn'));

      expect(en.pregnancyTitle, equals('Mother & Child Care'));
      expect(hi.pregnancyTitle, contains('मातृ एवं शिशु'));
      expect(bn.pregnancyTitle, contains('মাতৃ ও শিশু'));

      expect(en.trimester1, equals('1st Trimester'));
      expect(hi.trimester1, contains('तिमाही'));
      expect(bn.trimester1, contains('ত্রৈমাসিক'));

      expect(en.daysRemaining(112), equals('112 days remaining'));
      expect(hi.daysRemaining(112), contains('112 दिन'));
      expect(bn.daysRemaining(112), contains('112 দিন'));

      expect(en.seekImmediateMedicalCare, equals('Seek Immediate Medical Care'));
      expect(hi.seekImmediateMedicalCare, contains('चिकित्सीय सहायता'));
      expect(bn.seekImmediateMedicalCare, contains('চিকিৎসা সেবা'));

      expect(en.askPregnancyAi, equals('Ask Pregnancy AI'));
      expect(hi.askPregnancyAi, contains('AI'));
      expect(bn.askPregnancyAi, contains('এআই'));
    });

    testWidgets('PregnancyDashboardScreen renders gestational progress, ANC schedule and nutrition',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final storage = await LocalStorageService.init();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageProvider.overrideWithValue(storage),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
            ],
            home: PregnancyDashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Mother & Child Care'), findsOneWidget);
      expect(find.text('Next ANC Visit'), findsOneWidget);
      expect(find.text('Kick Counter'), findsOneWidget);
      expect(find.text('Danger Signs'), findsOneWidget);
    });
  });
}
