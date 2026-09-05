// Local storage service — SharedPreferences wrapper for patient MVP
// Stores: auth session, patient profile, offline content state, app preferences
// NOTE: Sensitive medical data should NOT be stored in plain SharedPreferences.
// For sensitive data, use secure storage (flutter_secure_storage) in a later phase.
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../error/app_exception.dart';
import '../models/patient.dart';

class LocalStorageService {
  LocalStorageService._(this._prefs);

  final SharedPreferences _prefs;

  static LocalStorageService? _instance;

  /// Initializes the storage service. Call once at app startup.
  static Future<LocalStorageService> init() async {
    if (_instance != null) return _instance!;
    final prefs = await SharedPreferences.getInstance();
    _instance = LocalStorageService._(prefs);
    return _instance!;
  }

  static LocalStorageService get instance {
    if (_instance == null) {
      throw AppException.storage('LocalStorageService not initialized');
    }
    return _instance!;
  }

  // ── Auth session ────────────────────────────────────────────────────────

  static const _keyIsLoggedIn = 'is_logged_in';
  static const _keyPatientPhone = 'patient_phone';
  static const _keyPatientName = 'patient_name';
  static const _keyFirebaseUid = 'firebase_uid';
  static const _keyPatientId = 'patient_id';
  static const _keyIsNewUser = 'is_new_user';

  bool get isLoggedIn => _prefs.getBool(_keyIsLoggedIn) ?? false;

  Future<void> setLoggedIn(bool value) async {
    await _prefs.setBool(_keyIsLoggedIn, value);
  }

  String? get patientPhone => _prefs.getString(_keyPatientPhone);

  Future<void> setPatientPhone(String phone) async {
    await _prefs.setString(_keyPatientPhone, phone);
  }

  String? get patientName => _prefs.getString(_keyPatientName);

  Future<void> setPatientName(String name) async {
    await _prefs.setString(_keyPatientName, name);
  }

  String? get firebaseUid => _prefs.getString(_keyFirebaseUid);

  Future<void> setFirebaseUid(String uid) async {
    await _prefs.setString(_keyFirebaseUid, uid);
  }

  String? get patientId => _prefs.getString(_keyPatientId);

  Future<void> setPatientId(String id) async {
    await _prefs.setString(_keyPatientId, id);
  }

  /// True when the user just registered (not yet completed profile setup).
  bool get isNewUser => _prefs.getBool(_keyIsNewUser) ?? false;

  Future<void> setIsNewUser(bool value) async {
    await _prefs.setBool(_keyIsNewUser, value);
  }

  // ── Patient profile ─────────────────────────────────────────────────────


  static const _keyPatientProfile = 'patient_profile';

  Patient? get patientProfile {
    final raw = _prefs.getString(_keyPatientProfile);
    if (raw == null) return null;
    try {
      return Patient.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> savePatientProfile(Patient patient) async {
    await _prefs.setString(_keyPatientProfile, jsonEncode(patient.toJson()));
  }

  Future<void> clearPatientProfile() async {
    await _prefs.remove(_keyPatientProfile);
  }

  // ── Offline emergency content ───────────────────────────────────────────

  static const _keyOfflineContentDownloaded = 'offline_content_downloaded';
  static const _keyOfflineContentVersion = 'offline_content_version';

  bool get isOfflineContentDownloaded =>
      _prefs.getBool(_keyOfflineContentDownloaded) ?? false;

  Future<void> setOfflineContentDownloaded(bool value) async {
    await _prefs.setBool(_keyOfflineContentDownloaded, value);
  }

  String? get offlineContentVersion =>
      _prefs.getString(_keyOfflineContentVersion);

  Future<void> setOfflineContentVersion(String version) async {
    await _prefs.setString(_keyOfflineContentVersion, version);
  }

  // ── App preferences ─────────────────────────────────────────────────────

  static const _keyVoiceLanguage = 'voice_language';
  static const _keyAppLanguage = 'app_language';

  String get voiceLanguage => _prefs.getString(_keyVoiceLanguage) ?? 'en';

  Future<void> setVoiceLanguage(String language) async {
    await _prefs.setString(_keyVoiceLanguage, language);
  }

  String get appLanguage => _prefs.getString(_keyAppLanguage) ?? 'en';

  Future<void> setAppLanguage(String language) async {
    await _prefs.setString(_keyAppLanguage, language);
  }

  // ── Pregnancy profile & ANC care ────────────────────────────────────────

  static const _keyPregnancyProfile = 'pregnancy_profile';
  static const _keyAncCompletedVisits = 'anc_completed_visits';

  String? get rawPregnancyProfile => _prefs.getString(_keyPregnancyProfile);

  Future<void> savePregnancyProfileJson(String jsonStr) async {
    await _prefs.setString(_keyPregnancyProfile, jsonStr);
  }

  List<int> get completedAncVisits {
    final raw = _prefs.getStringList(_keyAncCompletedVisits);
    if (raw == null) return [];
    return raw.map((e) => int.tryParse(e) ?? 0).where((n) => n > 0).toList();
  }

  Future<void> setAncVisitCompleted(int visitNumber, bool isCompleted) async {
    final current = completedAncVisits.toSet();
    if (isCompleted) {
      current.add(visitNumber);
    } else {
      current.remove(visitNumber);
    }
    await _prefs.setStringList(
      _keyAncCompletedVisits,
      current.map((e) => e.toString()).toList(),
    );
  }

  // ── Child Care & Fetal Kick Tracking ─────────────────────────────────

  static const _keyCompletedVaccines = 'child_completed_vaccines';
  static const _keyKickSessions = 'fetal_kick_sessions';
  static const _keyDailyChecklist = 'maternal_daily_checklist';

  List<String> get completedVaccines {
    return _prefs.getStringList(_keyCompletedVaccines) ?? [];
  }

  Future<void> setVaccineCompleted(String vaccineId, bool isCompleted) async {
    final current = completedVaccines.toSet();
    if (isCompleted) {
      current.add(vaccineId);
    } else {
      current.remove(vaccineId);
    }
    await _prefs.setStringList(_keyCompletedVaccines, current.toList());
  }

  List<String> get rawKickSessions {
    return _prefs.getStringList(_keyKickSessions) ?? [];
  }

  Future<void> saveKickSession(String sessionJson) async {
    final current = rawKickSessions;
    current.insert(0, sessionJson);
    // Keep last 30 sessions
    if (current.length > 30) current.removeLast();
    await _prefs.setStringList(_keyKickSessions, current);
  }

  Map<String, bool> get dailyChecklist {
    final raw = _prefs.getString(_keyDailyChecklist);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, v as bool));
    } catch (_) {
      return {};
    }
  }

  Future<void> saveDailyChecklist(Map<String, bool> checklist) async {
    await _prefs.setString(_keyDailyChecklist, jsonEncode(checklist));
  }

  // ── Clear all ───────────────────────────────────────────────────────────

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
