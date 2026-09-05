import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../healthcare_finder/models/healthcare_place.dart';
import '../models/demo_appointment.dart';
import '../models/demo_queue_status.dart';

/// State of the demo appointment and queue system
class DemoAppointmentState {
  final List<DemoAppointment> appointments;
  final DemoAppointment? selectedAppointment;
  final DemoQueueStatus? activeQueue;

  const DemoAppointmentState({
    this.appointments = const [],
    this.selectedAppointment,
    this.activeQueue,
  });

  DemoAppointmentState copyWith({
    List<DemoAppointment>? appointments,
    DemoAppointment? selectedAppointment,
    DemoQueueStatus? activeQueue,
    bool clearActiveQueue = false,
    bool clearSelectedAppointment = false,
  }) {
    return DemoAppointmentState(
      appointments: appointments ?? this.appointments,
      selectedAppointment: clearSelectedAppointment
          ? null
          : (selectedAppointment ?? this.selectedAppointment),
      activeQueue: clearActiveQueue
          ? null
          : (activeQueue ?? this.activeQueue),
    );
  }
}

/// StateNotifierProvider for Demo Appointments and Live Queue
final demoAppointmentProvider =
    StateNotifierProvider<DemoAppointmentNotifier, DemoAppointmentState>((ref) {
  return DemoAppointmentNotifier();
});

class DemoAppointmentNotifier extends StateNotifier<DemoAppointmentState> {
  DemoAppointmentNotifier() : super(const DemoAppointmentState());

  static int _idCounter = 1024;

  /// Books a new demo appointment with selected date and time
  DemoAppointment bookAppointment({
    required String doctorName,
    required String specialty,
    required String facilityName,
    required String facilityAddress,
    required String date,
    required String timeSlot,
    HealthcarePlace? place,
  }) {
    final appointmentId = 'RC-DEMO-$_idCounter';
    _idCounter++;

    final newAppointment = DemoAppointment(
      id: appointmentId,
      doctorName: doctorName.isNotEmpty ? doctorName : 'Dr. Krishanu Chakraborty',
      specialty: specialty.isNotEmpty ? specialty : 'Psychiatrist',
      facilityName: facilityName.isNotEmpty ? facilityName : 'Doctor Clinic',
      facilityAddress: facilityAddress.isNotEmpty ? facilityAddress : 'Prafulla Nagar Road',
      date: date,
      timeSlot: timeSlot,
      status: AppointmentStatus.confirmed,
      place: place,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      appointments: [newAppointment, ...state.appointments],
      selectedAppointment: newAppointment,
    );

    return newAppointment;
  }

  /// Checks in the patient for the given appointment, assigning token A024
  DemoQueueStatus checkIn(String appointmentId) {
    final appointment = state.appointments.firstWhere(
      (a) => a.id == appointmentId,
      orElse: () => state.selectedAppointment ??
          DemoAppointment(
            id: appointmentId,
            doctorName: 'Dr. Krishanu Chakraborty',
            specialty: 'Psychiatrist',
            facilityName: 'Doctor Clinic',
            facilityAddress: 'Prafulla Nagar Road',
            date: 'September 6, 2026',
            timeSlot: '10:30 AM',
            status: AppointmentStatus.confirmed,
            createdAt: DateTime.now(),
          ),
    );

    const assignedToken = 'A024';

    final updatedAppointment = appointment.copyWith(
      status: AppointmentStatus.checkedIn,
      queueToken: assignedToken,
    );

    final updatedList = state.appointments.map((a) {
      return a.id == appointmentId ? updatedAppointment : a;
    }).toList();

    final queueStatus = DemoQueueStatus(
      appointmentId: appointmentId,
      userToken: assignedToken,
      currentToken: 'A019',
      initialServingNumber: 19,
      userTokenNumber: 24,
      currentServingNumber: 19,
      doctorName: appointment.doctorName,
      specialty: appointment.specialty,
      facilityName: appointment.facilityName,
      facilityAddress: appointment.facilityAddress,
    );

    state = state.copyWith(
      appointments: updatedList,
      selectedAppointment: updatedAppointment,
      activeQueue: queueStatus,
    );

    return queueStatus;
  }

  /// Simulates queue movement: A019 -> A020 -> A021 -> A022 -> A023 -> A024
  void simulateNextQueuePatient() {
    final currentQueue = state.activeQueue;
    if (currentQueue == null) return;

    if (currentQueue.currentServingNumber >= currentQueue.userTokenNumber) {
      return; // Already called user
    }

    final nextNumber = currentQueue.currentServingNumber + 1;
    final nextTokenStr = 'A0${nextNumber < 10 ? '0$nextNumber' : '$nextNumber'}';

    final updatedQueue = currentQueue.copyWith(
      currentServingNumber: nextNumber,
      currentToken: nextTokenStr,
    );

    state = state.copyWith(activeQueue: updatedQueue);
  }

  /// Resets queue simulation back to A019
  void resetQueueDemo() {
    final currentQueue = state.activeQueue;
    if (currentQueue == null) return;

    final resetQueue = currentQueue.copyWith(
      currentServingNumber: 19,
      currentToken: 'A019',
    );

    state = state.copyWith(activeQueue: resetQueue);
  }

  /// Selects an appointment for viewing details
  void selectAppointment(DemoAppointment appointment) {
    state = state.copyWith(selectedAppointment: appointment);
  }

  /// Finds appointment by ID or returns latest
  DemoAppointment? getAppointmentById(String id) {
    try {
      return state.appointments.firstWhere((a) => a.id == id);
    } catch (_) {
      return state.selectedAppointment;
    }
  }
}
