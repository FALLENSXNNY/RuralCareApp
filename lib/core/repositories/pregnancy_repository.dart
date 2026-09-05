import 'dart:convert';

import '../models/pregnancy.dart';
import '../storage/local_storage_service.dart';
import '../utilities/pregnancy_calculator.dart';

abstract class PregnancyRepository {
  Future<PregnancyProfile> getPregnancyProfile(String patientId);
  Future<void> savePregnancyProfile(PregnancyProfile profile);
  Future<List<AntenatalVisit>> getAntenatalVisits();
  Future<void> updateVisitStatus(int visitNumber, bool isCompleted);
  List<PregnancyGuidanceItem> getGuidanceForTrimester(PregnancyTrimester trimester);
  List<PregnancySymptom> getCommonSymptoms();
  List<PregnancySymptom> getEmergencyWarningSigns();
}

class ApiPregnancyRepository implements PregnancyRepository {
  final LocalStorageService _storage;

  ApiPregnancyRepository(this._storage);

  @override
  Future<PregnancyProfile> getPregnancyProfile(String patientId) async {
    final raw = _storage.rawPregnancyProfile;
    if (raw != null) {
      try {
        final profile = PregnancyProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
        // Recalculate current gestational week dynamically
        final week = PregnancyCalculator.calculateGestationalWeek(
          edd: profile.estimatedDueDate,
          lmp: profile.lastMenstrualPeriod,
        );
        return profile.copyWith(currentWeek: week);
      } catch (_) {}
    }

    // Default starter profile: Week 24 (2nd Trimester, EDD in ~112 days)
    final now = DateTime.now();
    final defaultEdd = now.add(const Duration(days: 112));
    final defaultLmp = PregnancyCalculator.calculateLmpFromEdd(defaultEdd);
    final calculatedWeek = PregnancyCalculator.calculateGestationalWeek(edd: defaultEdd);

    final defaultProfile = PregnancyProfile(
      id: 'preg_starter_${patientId.isNotEmpty ? patientId : "default"}',
      patientId: patientId.isNotEmpty ? patientId : 'patient_1',
      isPregnant: true,
      estimatedDueDate: defaultEdd,
      lastMenstrualPeriod: defaultLmp,
      currentWeek: calculatedWeek,
      riskLevel: PregnancyRiskLevel.normal,
      primaryHealthCenter: 'Nashik District Hospital / PHC Trimbak',
      doctorOrAshaWorker: 'Sunita Tai (ASHA) · Dr. Anjali Sharma',
      notes: 'Routine 2nd trimester antenatal monitoring. Iron and Calcium supplementation prescribed.',
      updatedAt: now,
    );

    await savePregnancyProfile(defaultProfile);
    return defaultProfile;
  }

  @override
  Future<void> savePregnancyProfile(PregnancyProfile profile) async {
    final jsonStr = jsonEncode(profile.toJson());
    await _storage.savePregnancyProfileJson(jsonStr);
  }

  @override
  Future<List<AntenatalVisit>> getAntenatalVisits() async {
    final completed = _storage.completedAncVisits;
    final now = DateTime.now();

    final starterVisits = [
      AntenatalVisit(
        visitNumber: 1,
        title: '1st ANC Visit (Registration & Baseline)',
        weekRange: 'Within first 12 Weeks',
        description: 'Early pregnancy confirmation, blood tests (Hb, Blood Group, HIV, VDRL), urine test, and first dose of Tetanus Toxoid (TT-1).',
        testsAndProcedures: [
          'Hemoglobin (Hb) test',
          'Blood grouping & Rh typing',
          'Urine routine & microscopy',
          'Blood sugar & VDRL screening',
          'TT-1 (Tetanus) injection',
          'Daily Folic Acid (5mg) prescription',
        ],
        scheduledDate: now.subtract(const Duration(days: 90)),
        isCompleted: completed.contains(1) || true, // First visit completed
        clinicName: 'PHC Trimbak',
        doctorNotes: 'BP 110/70, Hb 11.2 g/dL. Registration completed on MCP card.',
      ),
      AntenatalVisit(
        visitNumber: 2,
        title: '2nd ANC Visit (Growth & Anomaly Screening)',
        weekRange: '14 – 26 Weeks',
        description: 'Physical examination, fetal heartbeat check, fundal height measurement, TT-2 injection, and start of Iron-Folic Acid (IFA) & Calcium tablets.',
        testsAndProcedures: [
          'Abdominal palpation & fundal height',
          'Fetal heart sound (FHS) check',
          'TT-2 or TT Booster injection',
          'IFA (100 tablets) & Calcium tablets distribution',
          'Level-2 Ultrasound anomaly scan',
        ],
        scheduledDate: now.add(const Duration(days: 12)),
        isCompleted: completed.contains(2),
        clinicName: 'Nashik District Hospital',
        doctorNotes: 'Scheduled for routine ultrasound and second TT booster.',
      ),
      AntenatalVisit(
        visitNumber: 3,
        title: '3rd ANC Visit (Third Trimester Health)',
        weekRange: '28 – 34 Weeks',
        description: 'Screening for gestational hypertension, pre-eclampsia, gestational diabetes, fetal growth, and maternal anemia check.',
        testsAndProcedures: [
          'Blood pressure & weight monitoring',
          'Urine albumin & sugar screening',
          'Repeat Hemoglobin (Hb) check',
          'Fetal position & movement assessment',
          'Birth preparedness counselling',
        ],
        scheduledDate: now.add(const Duration(days: 56)),
        isCompleted: completed.contains(3),
        clinicName: 'PHC Trimbak',
        doctorNotes: 'Monitor blood pressure closely and review birth plan.',
      ),
      AntenatalVisit(
        visitNumber: 4,
        title: '4th ANC Visit (Delivery Preparedness)',
        weekRange: '36 – 40 Weeks',
        description: 'Final birth plan preparation, institutional delivery arrangement, identification of blood donor, and newborn care guidance.',
        testsAndProcedures: [
          'Fetal presentation & lie assessment',
          'Pelvic assessment & delivery planning',
          'Identification of nearest 24/7 delivery facility',
          'Emergency transport plan (108 Ambulance)',
          'Immediate breastfeeding counselling',
        ],
        scheduledDate: now.add(const Duration(days: 98)),
        isCompleted: completed.contains(4),
        clinicName: 'Nashik District Hospital',
        doctorNotes: 'Final delivery readiness check. Keep hospital bag ready.',
      ),
    ];

    return starterVisits;
  }

  @override
  Future<void> updateVisitStatus(int visitNumber, bool isCompleted) async {
    await _storage.setAncVisitCompleted(visitNumber, isCompleted);
  }

  @override
  List<PregnancyGuidanceItem> getGuidanceForTrimester(PregnancyTrimester trimester) {
    switch (trimester) {
      case PregnancyTrimester.first:
        return const [
          PregnancyGuidanceItem(
            id: 'g_t1_nut',
            trimester: PregnancyTrimester.first,
            category: 'Nutrition',
            title: 'Folic Acid & Essential Early Nutrients',
            summary: 'Crucial for early neural tube development of your baby.',
            bulletPoints: [
              'Take 5mg Folic Acid tablet daily as prescribed by your ASHA worker or doctor.',
              'Eat green leafy vegetables (Palak, Methi), lentils (Dal), and whole grains.',
              'Drink clean boiled water; aim for at least 8 to 10 glasses daily.',
              'Eat small, frequent meals if experiencing morning sickness or nausea.',
            ],
            importantNotice: 'Avoid consuming raw or unpasteurized milk and unwashed fruits.',
          ),
          PregnancyGuidanceItem(
            id: 'g_t1_well',
            trimester: PregnancyTrimester.first,
            category: 'Wellness',
            title: 'Rest & Managing Early Symptoms',
            summary: 'Your body is adjusting to major hormonal changes.',
            bulletPoints: [
              'Get at least 8 hours of sleep at night and 1-2 hours of daytime rest.',
              'Sip ginger or lemon water to help ease morning sickness.',
              'Avoid lifting heavy farm equipment or carrying heavy water pots.',
              'Avoid exposure to pesticide sprays, smoke, and chemical fumes.',
            ],
          ),
          PregnancyGuidanceItem(
            id: 'g_t1_med',
            trimester: PregnancyTrimester.first,
            category: 'Medical',
            title: 'First ANC Registration & MCP Card',
            summary: 'Register your pregnancy at your nearest PHC or Sub-center within 12 weeks.',
            bulletPoints: [
              'Collect your Mother & Child Protection (MCP) card from your ASHA or ANM.',
              'Get your baseline blood and urine tests completed.',
              'Receive your 1st Tetanus Toxoid (TT-1) vaccination.',
            ],
          ),
        ];

      case PregnancyTrimester.second:
        return const [
          PregnancyGuidanceItem(
            id: 'g_t2_nut',
            trimester: PregnancyTrimester.second,
            category: 'Nutrition',
            title: 'Iron, Calcium & Balanced Diet',
            summary: 'Supporting rapid fetal bone and blood growth during weeks 14–27.',
            bulletPoints: [
              'Take one Iron-Folic Acid (IFA) tablet daily with lemon water or amla (Vitamin C helps absorption).',
              'Take Calcium tablets with milk or meals — never take Iron and Calcium together at the same time.',
              'Include protein: Dal, milk, curd, eggs, paneer, and roasted chana.',
              'Eat seasonal fruits like Guava, Pomegranate, Banana, and seasonal greens.',
            ],
            importantNotice: 'Never drink tea or coffee within 1 hour of taking your Iron tablet.',
          ),
          PregnancyGuidanceItem(
            id: 'g_t2_well',
            trimester: PregnancyTrimester.second,
            category: 'Wellness',
            title: 'Physical Activity & Posture',
            summary: 'Staying comfortably active while protecting your back and pelvis.',
            bulletPoints: [
              'Practice gentle 20-minute daily walking in a safe, even area.',
              'Sleep comfortably on your left side to maximize blood flow to your baby.',
              'Wear loose, comfortable cotton clothing and supportive footwear.',
              'Notice your baby\'s first gentle flutter movements (quickening around weeks 18–22).',
            ],
          ),
          PregnancyGuidanceItem(
            id: 'g_t2_med',
            trimester: PregnancyTrimester.second,
            category: 'Medical',
            title: 'Second ANC Visit & Ultrasound Scan',
            summary: 'Track baby growth and maternal health between weeks 14 and 26.',
            bulletPoints: [
              'Undergo the routine Level-2 anomaly ultrasound scan at your district hospital.',
              'Receive your second Tetanus Toxoid (TT-2) booster injection.',
              'Monitor blood pressure and check for swelling in feet or hands.',
            ],
          ),
        ];

      case PregnancyTrimester.third:
        return const [
          PregnancyGuidanceItem(
            id: 'g_t3_nut',
            trimester: PregnancyTrimester.third,
            category: 'Nutrition',
            title: 'Third Trimester Energy & Hydration',
            summary: 'Fueling baby weight gain and preparing maternal strength for labor.',
            bulletPoints: [
              'Continue taking daily Iron and Calcium tablets as prescribed.',
              'Eat easily digestible, high-fiber foods to prevent late-pregnancy constipation.',
              'Stay well hydrated with clean water, coconut water, and buttermilk (Chaas).',
              'Include healthy fats (nuts, seeds, ghee in moderation) and seasonal vegetables.',
            ],
          ),
          PregnancyGuidanceItem(
            id: 'g_t3_well',
            trimester: PregnancyTrimester.third,
            category: 'Birth Preparation',
            title: 'Birth Preparedness & Hospital Bag',
            summary: 'Be ready for your safe institutional delivery.',
            bulletPoints: [
              'Identify the nearest 24/7 delivery hospital or First Referral Unit (FRU).',
              'Keep your MCP Card, Aadhaar Card, bank passbook, and medical records ready in a bag.',
              'Pack clean clothes for mother and baby, sanitary napkins, and baby blankets.',
              'Confirm emergency transport contact: Dial 108 / local ambulance helpline.',
              'Identify at least two family members or community blood donors.',
            ],
            importantNotice: 'Plan for institutional delivery at a government hospital or PHC with 24/7 labor room.',
          ),
          PregnancyGuidanceItem(
            id: 'g_t3_med',
            trimester: PregnancyTrimester.third,
            category: 'Movement & Monitoring',
            title: 'Fetal Movement Counting',
            summary: 'Your baby should move actively every day.',
            bulletPoints: [
              'Count baby kicks after meals while resting on your left side.',
              'Expect at least 10 distinct movements within a 2-hour window.',
              'If movements feel significantly reduced or absent, go immediately to your nearest hospital.',
            ],
          ),
        ];
    }
  }

  @override
  List<PregnancySymptom> getCommonSymptoms() {
    return const [
      PregnancySymptom(
        id: 'sym_morning_sickness',
        name: 'Morning Sickness & Nausea',
        description: 'Mild to moderate nausea during early pregnancy (weeks 6–14).',
        urgency: SymptomUrgency.routine,
        actionRequired: 'Eat small frequent meals, sip ginger/lemon water, rest well.',
      ),
      PregnancySymptom(
        id: 'sym_mild_backache',
        name: 'Mild Lower Backache',
        description: 'Common as belly grows and posture shifts in 2nd and 3rd trimesters.',
        urgency: SymptomUrgency.routine,
        actionRequired: 'Avoid heavy lifting, use pillow support, maintain good posture.',
      ),
      PregnancySymptom(
        id: 'sym_mild_swelling',
        name: 'Mild Foot Swelling (End of Day)',
        description: 'Mild puffiness in feet/ankles after standing, resolves after resting.',
        urgency: SymptomUrgency.routine,
        actionRequired: 'Elevate feet while sitting, drink ample water, avoid tight socks.',
      ),
      PregnancySymptom(
        id: 'sym_frequent_urination',
        name: 'Frequent Urination',
        description: 'Uterus presses on the bladder as baby grows.',
        urgency: SymptomUrgency.routine,
        actionRequired: 'Stay hydrated during the day; avoid holding urine for long periods.',
      ),
      PregnancySymptom(
        id: 'sym_persistent_vomiting',
        name: 'Severe Persistent Vomiting',
        description: 'Unable to keep food or fluids down for more than 24 hours.',
        urgency: SymptomUrgency.concerning,
        actionRequired: 'Visit your PHC or doctor for oral rehydration or antiemetic support.',
      ),
      PregnancySymptom(
        id: 'sym_burning_urination',
        name: 'Pain or Burning During Urination',
        description: 'Possible urinary tract infection (UTI).',
        urgency: SymptomUrgency.concerning,
        actionRequired: 'Get a urine test at PHC; requires doctor evaluation and treatment.',
      ),
    ];
  }

  @override
  List<PregnancySymptom> getEmergencyWarningSigns() {
    return const [
      PregnancySymptom(
        id: 'warn_bleeding',
        name: 'Vaginal Bleeding or Spotting',
        description: 'Any bleeding during pregnancy can be dangerous and needs immediate clinical review.',
        urgency: SymptomUrgency.emergency,
        actionRequired: 'Seek immediate emergency care at nearest 24/7 hospital. Call 108.',
        isEmergencyWarningSign: true,
      ),
      PregnancySymptom(
        id: 'warn_severe_headache',
        name: 'Severe Headache & Blurred Vision',
        description: 'Severe headache, flashing lights, dizziness, or upper belly pain (Signs of Pre-eclampsia).',
        urgency: SymptomUrgency.emergency,
        actionRequired: 'Immediate emergency hospital checkup for blood pressure monitoring.',
        isEmergencyWarningSign: true,
      ),
      PregnancySymptom(
        id: 'warn_severe_pain',
        name: 'Severe Abdominal or Pelvic Pain',
        description: 'Intense or constant sharp pain in the abdomen or lower back.',
        urgency: SymptomUrgency.emergency,
        actionRequired: 'Go immediately to emergency hospital facility. Do not self-medicate.',
        isEmergencyWarningSign: true,
      ),
      PregnancySymptom(
        id: 'warn_reduced_movement',
        name: 'Markedly Reduced or Absent Baby Movement',
        description: 'Noticeable drop or cessation in daily fetal kicks in 28+ weeks.',
        urgency: SymptomUrgency.emergency,
        actionRequired: 'Immediate hospital visit for non-stress test (NST) and fetal heart check.',
        isEmergencyWarningSign: true,
      ),
      PregnancySymptom(
        id: 'warn_fluid_leakage',
        name: 'Sudden Gush or Continuous Fluid Leakage',
        description: 'Water breaking (amniotic fluid leakage) before expected term.',
        urgency: SymptomUrgency.emergency,
        actionRequired: 'Go immediately to delivery hospital. Risk of early labor or infection.',
        isEmergencyWarningSign: true,
      ),
      PregnancySymptom(
        id: 'warn_high_fever',
        name: 'High Fever with Chills (>38.5°C / 101.3°F)',
        description: 'High temperature that could indicate serious maternal or intrauterine infection.',
        urgency: SymptomUrgency.emergency,
        actionRequired: 'Seek urgent medical attention at PHC/Hospital.',
        isEmergencyWarningSign: true,
      ),
      PregnancySymptom(
        id: 'warn_seizures',
        name: 'Fits, Seizures or Loss of Consciousness',
        description: 'Critical emergency (Eclampsia).',
        urgency: SymptomUrgency.emergency,
        actionRequired: 'Call 108 Ambulance immediately. Position patient on left side.',
        isEmergencyWarningSign: true,
      ),
    ];
  }
}
