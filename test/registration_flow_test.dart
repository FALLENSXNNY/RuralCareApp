import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruralcare/core/models/patient.dart';
import 'package:ruralcare/core/providers/app_providers.dart';
import 'package:ruralcare/features/home/screens/home_shell.dart';
import 'package:ruralcare/core/localization/app_localizations.dart';
import 'package:ruralcare/core/storage/local_storage_service.dart';
import 'package:ruralcare/features/profile/screens/patient_profile_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Patient Registration & Conditional Pregnancy Tab Tests', () {
    test('Patient model serializes and deserializes new registration fields', () {
      final patient = Patient(
        id: 'P-12345',
        name: 'Sunita Devi',
        phone: '+919876543210',
        age: 26,
        gender: 'Female',
        isPregnant: true,
        gestationalWeek: 22,
        edd: '2026-12-15',
        emergencyContactName: 'Ramesh Devi',
        emergencyContactPhone: '+919876543211',
        abhaId: '12-3456-7890-1234',
        preferredLanguage: 'hi',
        bloodGroup: 'B+',
        conditions: ['Anaemia'],
        allergies: ['Penicillin'],
        village: 'Rampur',
        district: 'Varanasi',
        state: 'Uttar Pradesh',
      );

      final json = patient.toJson();
      expect(json['isPregnant'], isTrue);
      expect(json['gestationalWeek'], 22);
      expect(json['emergencyContactName'], 'Ramesh Devi');
      expect(json['emergencyContactPhone'], '+919876543211');
      expect(json['abhaId'], '12-3456-7890-1234');
      expect(json['preferredLanguage'], 'hi');

      final fromJson = Patient.fromJson(json);
      expect(fromJson.isPregnant, isTrue);
      expect(fromJson.gestationalWeek, 22);
      expect(fromJson.emergencyContactName, 'Ramesh Devi');
      expect(fromJson.emergencyContactPhone, '+919876543211');
      expect(fromJson.abhaId, '12-3456-7890-1234');
      expect(fromJson.preferredLanguage, 'hi');
    });

    testWidgets('HomeShell displays 5 tabs when patient is Female and Pregnant',
        (tester) async {
      final pregnantFemale = Patient(
        id: 'P-1',
        name: 'Sunita',
        phone: '9999999999',
        age: 25,
        gender: 'Female',
        village: 'Rampur',
        district: 'Varanasi',
        state: 'Uttar Pradesh',
        bloodGroup: 'B+',
        allergies: const [],
        conditions: const [],
        isPregnant: true,
        gestationalWeek: 16,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentPatientProvider
                .overrideWith((ref) => Future.value(pregnantFemale)),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('hi'),
              Locale('bn'),
            ],
            home: const HomeShell(
              child: Scaffold(body: Center(child: Text('Shell Body'))),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navBar.destinations.length, 5);
      expect(find.byIcon(Icons.pregnant_woman_outlined), findsOneWidget);
    });

    testWidgets(
        'HomeShell displays 4 tabs (no pregnancy tab) when patient is Male',
        (tester) async {
      final malePatient = Patient(
        id: 'P-2',
        name: 'Rahul',
        phone: '9999999998',
        age: 30,
        gender: 'Male',
        village: 'Rampur',
        district: 'Varanasi',
        state: 'Uttar Pradesh',
        bloodGroup: 'O+',
        allergies: const [],
        conditions: const [],
        isPregnant: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentPatientProvider
                .overrideWith((ref) => Future.value(malePatient)),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('hi'),
              Locale('bn'),
            ],
            home: const HomeShell(
              child: Scaffold(body: Center(child: Text('Shell Body'))),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navBar.destinations.length, 4);
      expect(find.byIcon(Icons.pregnant_woman_rounded), findsNothing);
    });

    testWidgets(
        'HomeShell displays 4 tabs when patient is Female but NOT pregnant',
        (tester) async {
      final nonPregnantFemale = Patient(
        id: 'P-3',
        name: 'Pooja',
        phone: '9999999997',
        age: 22,
        gender: 'Female',
        village: 'Rampur',
        district: 'Varanasi',
        state: 'Uttar Pradesh',
        bloodGroup: 'A+',
        allergies: const [],
        conditions: const [],
        isPregnant: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentPatientProvider
                .overrideWith((ref) => Future.value(nonPregnantFemale)),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('hi'),
              Locale('bn'),
            ],
            home: const HomeShell(
              child: Scaffold(body: Center(child: Text('Shell Body'))),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navBar.destinations.length, 4);
      expect(find.byIcon(Icons.pregnant_woman_rounded), findsNothing);
    });

    testWidgets('PatientProfileScreen displays pregnancy card and status for pregnant female',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final storage = await LocalStorageService.init();

      final pregnantFemale = Patient(
        id: 'P-1',
        name: 'Sunita Devi',
        phone: '9999999999',
        age: 25,
        gender: 'Female',
        village: 'Rampur',
        district: 'Varanasi',
        state: 'Uttar Pradesh',
        bloodGroup: 'B+',
        allergies: const [],
        conditions: const [],
        isPregnant: true,
        gestationalWeek: 20,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageProvider.overrideWithValue(storage),
            currentPatientProvider
                .overrideWith((ref) => Future.value(pregnantFemale)),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
              Locale('en'),
              Locale('hi'),
              Locale('bn'),
            ],
            home: PatientProfileScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Sunita Devi'), findsOneWidget);
      expect(find.text('Mother & Child Care'), findsWidgets);
      expect(find.textContaining('Week 20'), findsWidgets);
    });
  });
}
