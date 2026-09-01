import 'package:flutter_test/flutter_test.dart';
import 'package:ruralcare/core/models/doctor.dart';
import 'package:ruralcare/core/models/facility.dart';
import 'package:ruralcare/core/repositories/mock_repositories.dart';

void main() {
  group('Phase 5 Facility & Doctor Models Test', () {
    test('HealthcareFacility fromJson and toJson roundtrip', () {
      final json = {
        'id': 'FAC-101',
        'name': 'PHC Koregaon',
        'type': 'Primary Health Centre',
        'address': 'Main Road, Koregaon, Satara',
        'distance': '0.8 km',
        'phone': '02163-123456',
        'hours': 'Mon–Sat: 8am–4pm',
        'isOpen': true,
        'services': ['OPD', 'Maternity', 'Lab Tests'],
      };

      final facility = HealthcareFacility.fromJson(json);
      expect(facility.id, 'FAC-101');
      expect(facility.name, 'PHC Koregaon');
      expect(facility.type, 'Primary Health Centre');
      expect(facility.distance, '0.8 km');
      expect(facility.isOpen, true);
      expect(facility.services.length, 3);
      expect(facility.services, contains('Maternity'));

      final serialized = facility.toJson();
      expect(serialized['id'], 'FAC-101');
      expect(serialized['name'], 'PHC Koregaon');
    });

    test('Doctor fromJson and toJson roundtrip', () {
      final json = {
        'id': 'DOC-202',
        'name': 'Dr. Rajesh Kumar',
        'speciality': 'General Physician',
        'qualification': 'MBBS, MD',
        'facility': 'PHC Koregaon',
        'experience': '12 years',
        'availableSlots': 'Today, 10am–1pm',
        'acceptsOnline': true,
      };

      final doc = Doctor.fromJson(json);
      expect(doc.id, 'DOC-202');
      expect(doc.name, 'Dr. Rajesh Kumar');
      expect(doc.speciality, 'General Physician');
      expect(doc.qualification, 'MBBS, MD');
      expect(doc.facility, 'PHC Koregaon');
      expect(doc.acceptsOnline, true);

      final serialized = doc.toJson();
      expect(serialized['id'], 'DOC-202');
      expect(serialized['acceptsOnline'], true);
    });

    test('MockFacilityRepository returns starter facilities and doctors', () async {
      final repo = MockFacilityRepository();

      final facilities = await repo.getFacilities();
      expect(facilities.isNotEmpty, true);
      expect(facilities.first.name, contains('PHC'));

      final searchResults = await repo.searchFacilities('Wai');
      expect(searchResults.any((f) => f.name.contains('Wai')), true);

      final phcList = await repo.getFacilitiesByType('PHC');
      expect(phcList.every((f) => f.type.contains('PHC')), true);

      final doctors = await repo.getDoctors();
      expect(doctors.isNotEmpty, true);

      final doc = await repo.getDoctor('DOC-001');
      expect(doc.id, 'DOC-001');
    });
  });
}
