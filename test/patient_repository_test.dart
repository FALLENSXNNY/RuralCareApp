import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ruralcare/core/models/patient.dart';
import 'package:ruralcare/core/networking/api_client.dart';
import 'package:ruralcare/core/repositories/api_patient_repository.dart';
import 'package:ruralcare/core/services/firebase_auth_service.dart';
import 'package:ruralcare/core/storage/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.init();
  });

  group('ApiPatientRepository', () {
    const testPatient = Patient(
      id: 'patient-123',
      name: 'Sunita Devi',
      phone: '+919876543210',
      age: 34,
      gender: 'Female',
      village: 'Koregaon',
      district: 'Satara',
      state: 'Maharashtra',
      bloodGroup: 'B+',
      allergies: ['Penicillin'],
      conditions: ['Anaemia'],
    );

    test('savePatientLocally and getLocalPatient roundtrip', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{}', 200);
      });
      final apiClient = ApiClient(client: mockClient);
      final repo = ApiPatientRepository(apiClient, FirebaseAuthService());

      expect(repo.getLocalPatient(), isNull);
      await repo.savePatientLocally(testPatient);

      final retrieved = repo.getLocalPatient();
      expect(retrieved, isNotNull);
      expect(retrieved?.id, 'patient-123');
      expect(retrieved?.name, 'Sunita Devi');
      expect(retrieved?.bloodGroup, 'B+');
      expect(retrieved?.allergies, ['Penicillin']);
    });

    test('Patient model copyWith updates all Phase 3 profile fields', () {
      final updated = testPatient.copyWith(
        name: 'Anita Pawar',
        age: 35,
        village: 'Wai',
        bloodGroup: 'O+',
        conditions: ['Diabetes'],
        allergies: ['Sulfa drugs'],
      );

      expect(updated.name, 'Anita Pawar');
      expect(updated.age, 35);
      expect(updated.village, 'Wai');
      expect(updated.bloodGroup, 'O+');
      expect(updated.conditions, ['Diabetes']);
      expect(updated.allergies, ['Sulfa drugs']);
      // Preserved fields
      expect(updated.id, 'patient-123');
      expect(updated.phone, '+919876543210');
      expect(updated.gender, 'Female');
    });

    test('Patient fromJson handles backend payload mapping', () {
      final backendJson = {
        'id': '64b0f9c2e1234567890abcde',
        'firebaseUid': 'uid-123',
        'name': 'Sunita Devi',
        'phone': '+919876543210',
        'age': 34,
        'gender': 'Female',
        'village': 'Koregaon',
        'district': 'Satara',
        'state': 'Maharashtra',
        'bloodGroup': 'B+',
        'allergies': ['Penicillin'],
        'conditions': ['Anaemia', 'Hypertension'],
      };

      final patient = Patient.fromJson(backendJson);
      expect(patient.id, '64b0f9c2e1234567890abcde');
      expect(patient.name, 'Sunita Devi');
      expect(patient.phone, '+919876543210');
      expect(patient.age, 34);
      expect(patient.gender, 'Female');
      expect(patient.village, 'Koregaon');
      expect(patient.district, 'Satara');
      expect(patient.state, 'Maharashtra');
      expect(patient.bloodGroup, 'B+');
      expect(patient.allergies, ['Penicillin']);
      expect(patient.conditions, ['Anaemia', 'Hypertension']);
    });
  });
}
