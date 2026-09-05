import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruralcare/core/localization/app_localizations.dart';
import 'package:ruralcare/core/theme/app_colors.dart';
import 'package:ruralcare/features/appointments/controller/demo_appointment_controller.dart';
import 'package:ruralcare/features/appointments/models/demo_appointment.dart';
import 'package:ruralcare/features/appointments/models/demo_queue_status.dart';
import 'package:ruralcare/features/appointments/screens/appointment_confirmed_screen.dart';
import 'package:ruralcare/features/appointments/screens/book_appointment_screen.dart';
import 'package:ruralcare/features/appointments/screens/confirm_appointment_screen.dart';
import 'package:ruralcare/features/appointments/screens/live_queue_screen.dart';
import 'package:ruralcare/features/appointments/screens/my_appointments_screen.dart';
import 'package:ruralcare/features/healthcare_finder/models/healthcare_place.dart';
import 'package:ruralcare/features/healthcare_finder/widgets/healthcare_card.dart';

Widget createTestApp(Widget child, {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

void main() {
  group('DemoAppointment Model Tests', () {
    test('Default creation and copyWith', () {
      final appointment = DemoAppointment(
        id: 'RC-DEMO-1024',
        doctorName: 'Dr. Krishanu Chakraborty',
        specialty: 'Psychiatrist',
        facilityName: 'Doctor Clinic',
        facilityAddress: 'Prafulla Nagar Road',
        date: 'September 6, 2026',
        timeSlot: '10:30 AM',
        createdAt: DateTime(2026, 9, 5),
      );

      expect(appointment.id, 'RC-DEMO-1024');
      expect(appointment.doctorName, 'Dr. Krishanu Chakraborty');
      expect(appointment.specialty, 'Psychiatrist');
      expect(appointment.facilityName, 'Doctor Clinic');
      expect(appointment.status, AppointmentStatus.confirmed);
      expect(appointment.isCheckedIn, isFalse);
      expect(appointment.queueToken, isNull);

      final updated = appointment.copyWith(
        status: AppointmentStatus.checkedIn,
        queueToken: 'A024',
      );

      expect(updated.status, AppointmentStatus.checkedIn);
      expect(updated.isCheckedIn, isTrue);
      expect(updated.queueToken, 'A024');
    });
  });

  group('DemoQueueStatus Model Tests', () {
    test('Calculations and transitions', () {
      const queue = DemoQueueStatus(
        appointmentId: 'RC-DEMO-1024',
        userToken: 'A024',
        currentToken: 'A019',
        initialServingNumber: 19,
        userTokenNumber: 24,
        currentServingNumber: 19,
      );

      expect(queue.userToken, 'A024');
      expect(queue.currentToken, 'A019');
      expect(queue.patientsAhead, 5); // 24 - 19
      expect(queue.isApproaching, isFalse);
      expect(queue.isCalled, isFalse);

      // Approaching state (serving 23)
      final approaching = queue.copyWith(
        currentServingNumber: 23,
        currentToken: 'A023',
      );
      expect(approaching.isApproaching, isTrue);
      expect(approaching.isCalled, isFalse);
      expect(approaching.patientsAhead, 1);

      // Called state (serving 24)
      final called = approaching.copyWith(
        currentServingNumber: 24,
        currentToken: 'A024',
      );
      expect(called.isCalled, isTrue);
      expect(called.statusText, 'CALLED');
    });
  });

  group('DemoAppointmentController Flow Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Full Patient Journey: Booking -> Check In -> Queue Simulation', () {
      final notifier = container.read(demoAppointmentProvider.notifier);

      // 1. Initial State: Empty
      expect(container.read(demoAppointmentProvider).appointments, isEmpty);
      expect(container.read(demoAppointmentProvider).activeQueue, isNull);

      // 2. Book Appointment
      final booked = notifier.bookAppointment(
        doctorName: 'Dr. Krishanu Chakraborty',
        specialty: 'Psychiatrist',
        facilityName: 'Doctor Clinic',
        facilityAddress: 'Prafulla Nagar Road',
        date: 'September 6, 2026',
        timeSlot: '10:30 AM',
      );

      expect(booked.id, startsWith('RC-DEMO-'));
      expect(container.read(demoAppointmentProvider).appointments.length, 1);
      expect(container.read(demoAppointmentProvider).appointments.first.status,
          AppointmentStatus.confirmed);

      // 3. Check In
      final queueStatus = notifier.checkIn(booked.id);
      expect(queueStatus.userToken, 'A024');
      expect(queueStatus.currentToken, 'A019');

      final queue = container.read(demoAppointmentProvider).activeQueue;
      expect(queue, isNotNull);
      expect(queue!.userToken, 'A024');
      expect(queue.currentToken, 'A019');

      // 4. Simulate Step 1: A019 -> A020
      notifier.simulateNextQueuePatient();
      var q = container.read(demoAppointmentProvider).activeQueue!;
      expect(q.currentToken, 'A020');
      expect(q.currentServingNumber, 20);
      expect(q.isApproaching, isFalse);

      // 5. Simulate Step 2: A020 -> A021
      notifier.simulateNextQueuePatient();
      q = container.read(demoAppointmentProvider).activeQueue!;
      expect(q.currentToken, 'A021');

      // 6. Simulate Step 3: A021 -> A022
      notifier.simulateNextQueuePatient();
      q = container.read(demoAppointmentProvider).activeQueue!;
      expect(q.currentToken, 'A022');

      // 7. Simulate Step 4: A022 -> A023 ("Your turn is approaching")
      notifier.simulateNextQueuePatient();
      q = container.read(demoAppointmentProvider).activeQueue!;
      expect(q.currentToken, 'A023');
      expect(q.isApproaching, isTrue);
      expect(q.isCalled, isFalse);

      // 8. Simulate Step 5: A023 -> A024 ("It's your turn / CALLED")
      notifier.simulateNextQueuePatient();
      q = container.read(demoAppointmentProvider).activeQueue!;
      expect(q.currentToken, 'A024');
      expect(q.isCalled, isTrue);
      expect(q.statusText, 'CALLED');

      // 9. Reset Queue
      notifier.resetQueueDemo();
      q = container.read(demoAppointmentProvider).activeQueue!;
      expect(q.currentToken, 'A019');
      expect(q.isCalled, isFalse);
    });
  });

  group('HealthcarePlace Booking Support Tests', () {
    test('supportsAppointmentBooking correctly identifies doctors and hospitals', () {
      const doctorPlace = HealthcarePlace(
        id: '1',
        name: 'Dr. Krishanu Chakraborty',
        category: 'Doctors',
        type: 'Psychiatrist',
        address: 'Satara',
      );
      expect(doctorPlace.supportsAppointmentBooking, isTrue);

      const hospitalPlace = HealthcarePlace(
        id: '2',
        name: 'Satara District Hospital',
        category: 'Hospitals',
        type: 'District Hospital',
        address: 'Satara',
      );
      expect(hospitalPlace.supportsAppointmentBooking, isTrue);

      const pharmacyPlace = HealthcarePlace(
        id: '3',
        name: 'Apollo Pharmacy & Medical Store',
        category: 'Pharmacies',
        type: 'Pharmacy',
        address: 'Satara',
      );
      expect(pharmacyPlace.supportsAppointmentBooking, isFalse);
    });
  });

  group('Widget Tests for Demo Appointment & Queue Flow', () {
    testWidgets('HealthcareCard renders Book Appointment for Doctor but hides for Pharmacy',
        (tester) async {
      bool bookedTapped = false;
      const doctorPlace = HealthcarePlace(
        id: 'dr_krishanu',
        name: 'Dr. Krishanu Chakraborty',
        category: 'Doctors',
        type: 'Psychiatrist',
        address: 'Prafulla Nagar Road, Satara',
        distance: '2.3 km',
        phone: '+91 98765 43210',
        rating: 4.2,
      );

      const pharmacyPlace = HealthcarePlace(
        id: 'pharmacy_1',
        name: 'Sanjeevani Medico',
        category: 'Pharmacies',
        type: 'Pharmacy',
        address: 'Main Bazaar, Satara',
        distance: '0.8 km',
        phone: '+91 98765 11111',
      );

      // Doctor Card
      await tester.pumpWidget(
        createTestApp(
          Scaffold(
            body: HealthcareCard(
              place: doctorPlace,
              onTap: () {},
              onCall: () {},
              onDirections: () {},
              onBookAppointment: () {
                bookedTapped = true;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dr. Krishanu Chakraborty'), findsOneWidget);
      expect(find.text('Book Appointment'), findsOneWidget);

      await tester.tap(find.text('Book Appointment'));
      await tester.pumpAndSettle();
      expect(bookedTapped, isTrue);

      // Pharmacy Card - should NOT render Book Appointment
      await tester.pumpWidget(
        createTestApp(
          Scaffold(
            body: HealthcareCard(
              place: pharmacyPlace,
              onTap: () {},
              onCall: () {},
              onDirections: () {},
              onBookAppointment: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sanjeevani Medico'), findsOneWidget);
      expect(find.text('Book Appointment'), findsNothing);
    });

    testWidgets('BookAppointmentScreen displays Doctor info and Date/Time slots',
        (tester) async {
      const place = HealthcarePlace(
        id: 'dr_krishanu',
        name: 'Dr. Krishanu Chakraborty',
        category: 'Doctors',
        type: 'Psychiatrist',
        address: 'Doctor Clinic, Prafulla Nagar Road',
        distance: '2.3 km',
        phone: '+91 98765 43210',
      );

      await tester.pumpWidget(
        createTestApp(
          const BookAppointmentScreen(place: place),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Book Appointment'), findsWidgets);
      expect(find.text('Dr. Krishanu Chakraborty'), findsOneWidget);
      expect(find.text('Psychiatrist'), findsOneWidget);
      expect(find.text('Select Date'), findsOneWidget);
      expect(find.text('Available Time'), findsOneWidget);
      expect(find.text('10:30 AM'), findsOneWidget);
    });

    testWidgets('ConfirmAppointmentScreen displays summary and confirm button',
        (tester) async {
      final appointmentData = {
        'doctorName': 'Dr. Krishanu Chakraborty',
        'specialty': 'Psychiatrist',
        'facilityName': 'Doctor Clinic',
        'facilityAddress': 'Prafulla Nagar Road',
        'date': 'September 6, 2026',
        'time': '10:30 AM',
        'distance': '2.3 km',
      };

      await tester.pumpWidget(
        createTestApp(
          ConfirmAppointmentScreen(appointmentData: appointmentData),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Confirm Appointment'), findsWidgets);
      expect(find.text('Dr. Krishanu Chakraborty'), findsOneWidget);
      expect(find.text('Psychiatrist'), findsOneWidget);
      expect(find.text('Doctor Clinic'), findsOneWidget);
      expect(find.text('September 6, 2026'), findsOneWidget);
      expect(find.text('10:30 AM'), findsOneWidget);
      expect(find.text('Confirm Booking'), findsOneWidget);
    });

    testWidgets('AppointmentConfirmedScreen shows success state with ID RC-DEMO-1024',
        (tester) async {
      final appointment = DemoAppointment(
        id: 'RC-DEMO-1024',
        doctorName: 'Dr. Krishanu Chakraborty',
        specialty: 'Psychiatrist',
        facilityName: 'Doctor Clinic',
        facilityAddress: 'Prafulla Nagar Road',
        date: 'September 6, 2026',
        timeSlot: '10:30 AM',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        createTestApp(
          AppointmentConfirmedScreen(appointment: appointment),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Appointment Confirmed'), findsWidgets);
      expect(find.text('RC-DEMO-1024'), findsOneWidget);
      expect(find.text('Dr. Krishanu Chakraborty'), findsOneWidget);
      expect(find.text('View Appointment'), findsOneWidget);
      expect(find.text('Check In'), findsOneWidget);
    });

    testWidgets('MyAppointmentsScreen shows empty state and booked state',
        (tester) async {
      final container = ProviderContainer();

      // Empty state
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: ThemeData(useMaterial3: true, primaryColor: AppColors.primary),
            localizationsDelegates: const [AppLocalizations.delegate],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const MyAppointmentsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No upcoming appointments'), findsOneWidget);
      expect(find.text('Find Healthcare'), findsOneWidget);

      // Add appointment
      container.read(demoAppointmentProvider.notifier).bookAppointment(
            doctorName: 'Dr. Krishanu Chakraborty',
            specialty: 'Psychiatrist',
            facilityName: 'Doctor Clinic',
            facilityAddress: 'Prafulla Nagar Road',
            date: 'September 6, 2026',
            timeSlot: '10:30 AM',
          );

      await tester.pumpAndSettle();
      expect(find.text('Dr. Krishanu Chakraborty'), findsOneWidget);
      expect(find.text('View Details'), findsOneWidget);
    });

    testWidgets('LiveQueueScreen renders token A024 and simulates next patient',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer();

      // Initialize with checked in appointment & active queue
      final appt = container.read(demoAppointmentProvider.notifier).bookAppointment(
            doctorName: 'Dr. Krishanu Chakraborty',
            specialty: 'Psychiatrist',
            facilityName: 'Doctor Clinic',
            facilityAddress: 'Prafulla Nagar Road',
            date: 'September 6, 2026',
            timeSlot: '10:30 AM',
          );
      container.read(demoAppointmentProvider.notifier).checkIn(appt.id);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: ThemeData(useMaterial3: true, primaryColor: AppColors.primary),
            localizationsDelegates: const [AppLocalizations.delegate],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const LiveQueueScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('My Queue'), findsWidgets);
      expect(find.text('A024'), findsWidgets); // Your token
      expect(find.text('A019'), findsWidgets); // Currently serving
      expect(find.text('Simulate Next Patient'), findsOneWidget);

      // Simulate step 1
      await tester.tap(find.text('Simulate Next Patient'));
      await tester.pumpAndSettle();

      expect(find.text('A020'), findsWidgets);

      // Simulate step 2
      await tester.tap(find.text('Simulate Next Patient'));
      await tester.pumpAndSettle();
      expect(find.text('A021'), findsWidgets);

      // Simulate step 3
      await tester.tap(find.text('Simulate Next Patient'));
      await tester.pumpAndSettle();
      expect(find.text('A022'), findsWidgets);

      // Simulate step 4 -> Approaching
      await tester.tap(find.text('Simulate Next Patient'));
      await tester.pumpAndSettle();
      expect(find.text('A023'), findsWidgets);
      expect(find.textContaining('Your turn is approaching'), findsOneWidget);

      // Simulate step 5 -> Called
      await tester.tap(find.text('Simulate Next Patient'));
      await tester.pumpAndSettle();
      expect(find.textContaining("It's your turn"), findsOneWidget);
      expect(find.text('CALLED'), findsOneWidget);
    });
  });
}
